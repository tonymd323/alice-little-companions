part of 'family.dart';

const _completionBelongsToCompanion = '''
  EXISTS (
    SELECT 1 FROM companion_completions x
    WHERE x.completion_id = a.id AND x.child_id = p.child_id AND x.pet_id = p.pet_id
  )
''';

// Each credit references a completion. Read the smaller validity group by
// its index so large histories also stay efficient after many corrections.
const _companionExperience =
    '''
  SELECT CASE
    WHEN (SELECT COUNT(*) FROM completions WHERE is_valid = 0) <
         (SELECT COUNT(*) FROM completions WHERE is_valid = 1)
    THEN
      (SELECT COUNT(*) FROM companion_completions x
       WHERE x.child_id = p.child_id AND x.pet_id = p.pet_id) -
      (SELECT COUNT(*) FROM completions a
       WHERE a.is_valid = 0 AND $_completionBelongsToCompanion)
    ELSE
      (SELECT COUNT(*) FROM completions a
       WHERE a.is_valid = 1 AND $_completionBelongsToCompanion)
  END
''';

const _companionAffinity = '''
  SELECT
    (SELECT COUNT(*) FROM companion_affinity_days a
     WHERE a.child_id = p.child_id AND a.pet_id = p.pet_id) +
    COALESCE((SELECT SUM(c.affinity) FROM companion_candies c
              WHERE c.child_id = p.child_id AND c.pet_id = p.pet_id), 0)
''';

class CompanionProgress {
  CompanionProgress(Json row, Rules rules)
    : experience = row['experience'] as int,
      bond = CompanionBond(row['affinity'] as int),
      stage = max(
        row['retained_stage'] as int,
        rules.earnedStage(row['experience'] as int),
      );

  final int experience;
  final CompanionBond bond;
  final int stage;
}

extension FamilyCompanions on FamilyService {
  Future<Map<Companion, CompanionProgress>> companionProgress() async => {
    for (final row in await db.rows('''
      SELECT p.pet_id, p.retained_stage, ($_companionExperience) AS experience,
        ($_companionAffinity) AS affinity
      FROM owned_companions p
      '''))
      rules.companion(row['pet_id'] as String): CompanionProgress(row, rules),
  };

  Future<({String id, int affinity, int count})?>
  availableAffinityCandy() async {
    final row = await db.row('''
      SELECT c.purchase_id, c.affinity, COUNT(*) OVER () AS available
      FROM companion_candies c JOIN purchases p ON p.id = c.purchase_id
      WHERE c.pet_id IS NULL AND p.refunded_at IS NULL
      ORDER BY p.rowid LIMIT 1
      ''');
    if (row == null) return null;
    return (
      id: row['purchase_id'] as String,
      affinity: row['affinity'] as int,
      count: row['available'] as int,
    );
  }

  Future<Json> redeemAffinityCandy({String? commandId}) async {
    String? fresh;
    final price = rules.affinityCandyPrice;
    final result = await _command(
      'redeem-candy',
      affinityCandyItemId,
      commandId,
      (id, family) async {
        if (family.balance < price) {
          throw UserError('还差 ${price - family.balance} 分。');
        }
        final receipt = await _recordPurchase(
          id,
          affinityCandyItemId,
          affinityCandyName,
          affinityCandyItemId,
          price,
        );
        await db.insertRow('companion_candies', {
          'purchase_id': receipt['id'],
          'child_id': family.childId,
          'affinity': rules.affinityPerCandy,
        });
        fault?.call('ownership');
        fresh = receipt['id'] as String;
        return receipt;
      },
    );
    if (fresh != null) {
      _childUndoStarts[fresh!] = _undoClock.elapsedMilliseconds;
    }
    return result;
  }

  Future<Json> feedAffinityCandy(String candyId, Companion companion) =>
      _command('feed-candy', [candyId, companion.name], 'feed-candy/$candyId', (
        _,
        family,
      ) async {
        if (family.companion != companion) {
          throw const UserError('请先带要喂的伙伴回小家。');
        }
        final candy = await db.row(
          '''
        SELECT c.affinity FROM companion_candies c JOIN purchases p ON p.id = c.purchase_id
        WHERE c.purchase_id = ? AND c.child_id = ?
          AND c.pet_id IS NULL AND p.refunded_at IS NULL
        ''',
          [candyId, family.childId],
        );
        if (candy == null) throw const UserError('这颗糖果已经用掉或退回了。');
        await db.customStatement(
          '''
        UPDATE companion_candies SET pet_id = ?, fed_at = ? WHERE purchase_id = ?
        ''',
          [companion.name, now, candyId],
        );
        return {'affinity': candy['affinity']};
      });

  Future<Json> selectCompanion(Companion companion, {String? commandId}) =>
      _command('select', companion.name, commandId, (_, family) async {
        if (await _ownedCompanion(family.childId, companion) == null) {
          throw const UserError('请先用积分解锁这位伙伴。');
        }
        await db.customStatement(
          'UPDATE child_profiles SET active_pet_id = ? WHERE id = ?',
          [companion.name, family.childId],
        );
        return {'pet': companion.name};
      });

  Future<Json> unlockCompanion(Companion companion, {String? commandId}) =>
      _command('unlock-companion', companion.name, commandId, (
        id,
        family,
      ) async {
        final owned = await _ownedCompanion(family.childId, companion);
        if (owned != null) {
          return {'id': owned['purchase_id'], 'charged': 0, 'owned': true};
        }
        final price = rules.companionUnlockPrice;
        if (family.balance < price) {
          throw UserError('还差 ${price - family.balance} 分。');
        }
        final receipt = await _recordPurchase(
          id,
          companion.unlockItemId,
          companion.nickname,
          companion.firstStageAssetId,
          price,
        );
        await db.insertRow('owned_companions', {
          'child_id': family.childId,
          'pet_id': companion.name,
          'purchase_id': receipt['id'],
        });
        fault?.call('ownership');
        return receipt;
      });

  Future<Json?> _ownedCompanion(String child, Companion companion) => db.row(
    'SELECT purchase_id FROM owned_companions WHERE child_id = ? AND pet_id = ?',
    [child, companion.name],
  );

  Future<void> _retainCompanionStage(String child, String pet, int stage) =>
      db.customStatement(
        '''
        UPDATE owned_companions SET retained_stage = ?
        WHERE child_id = ? AND pet_id = ? AND retained_stage < ?
        ''',
        [stage, child, pet, stage],
      );

  Future<void> _retainCreditedCompanionStage(String instance) async {
    // An old save may already qualify for a stage it never recorded.
    final credited = (await db.row(
      '''
      SELECT p.child_id, p.pet_id, p.retained_stage,
        ($_companionExperience) AS experience
      FROM completions a
      JOIN companion_completions x ON x.completion_id = a.id
      JOIN owned_companions p ON p.child_id = x.child_id AND p.pet_id = x.pet_id
      WHERE a.instance_id = ?
      ''',
      [instance],
    ))!;
    await _retainCompanionStage(
      credited['child_id'] as String,
      credited['pet_id'] as String,
      rules.earnedStage(credited['experience'] as int),
    );
  }
}
