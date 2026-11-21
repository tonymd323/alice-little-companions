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

typedef FoodStock = ({String id, int affinity, int count});

extension FamilyCompanions on FamilyService {
  Future<Map<Companion, CompanionProgress>> companionProgress() async => {
    for (final row in await db.rows('''
      SELECT p.pet_id, p.retained_stage, ($_companionExperience) AS experience,
        ($_companionAffinity) AS affinity
      FROM owned_companions p
      '''))
      rules.companion(row['pet_id'] as String): CompanionProgress(row, rules),
  };

  // Each serving uses the inventory table introduced for candy in schema 9.
  Future<Map<CompanionFood, FoodStock>> availableFood() async => {
    for (final row in await db.rows(
      '''
      WITH stock AS (
        SELECT c.purchase_id, c.affinity, p.item_id,
          COUNT(*) OVER (PARTITION BY p.item_id) AS available,
          ROW_NUMBER() OVER (PARTITION BY p.item_id ORDER BY p.rowid) AS oldest
        FROM companion_candies c JOIN purchases p ON p.id = c.purchase_id
        WHERE c.pet_id IS NULL AND p.refunded_at IS NULL
      )
      SELECT purchase_id, affinity, item_id, available FROM stock WHERE oldest = 1
      ''',
    ))
      ?CompanionFood.forItem(row['item_id']): (
        id: row['purchase_id'] as String,
        affinity: row['affinity'] as int,
        count: row['available'] as int,
      ),
  };

  Future<Json> redeemFood(CompanionFood food, {String? commandId}) async {
    String? fresh;
    final offer = rules.foodOffers[food]!;
    final result = await _command(
      food == CompanionFood.candy ? 'redeem-candy' : 'redeem-food',
      food.itemId,
      commandId,
      (id, family) async {
        if (family.balance < offer.price) {
          throw UserError('还差 ${offer.price - family.balance} 分。');
        }
        final receipt = await _recordPurchase(
          id,
          food.itemId,
          food.label,
          food.itemId,
          offer.price,
        );
        await db.insertRow('companion_candies', {
          'purchase_id': receipt['id'],
          'child_id': family.childId,
          'affinity': offer.affinity,
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

  // Keep the existing feeding command identity when opening older saves.
  Future<Json> feedFood(String purchaseId, Companion companion) => _command(
    'feed-candy',
    [purchaseId, companion.name],
    'feed-candy/$purchaseId',
    (_, family) async {
      if (family.companion != companion) {
        throw const UserError('请先带要喂的伙伴回小家。');
      }
      final serving = await db.row(
        '''
        SELECT c.affinity FROM companion_candies c JOIN purchases p ON p.id = c.purchase_id
        WHERE c.purchase_id = ? AND c.child_id = ?
          AND c.pet_id IS NULL AND p.refunded_at IS NULL
        ''',
        [purchaseId, family.childId],
      );
      if (serving == null) throw const UserError('这份食物已经用掉或退回了。');
      await db.customStatement(
        '''
        UPDATE companion_candies SET pet_id = ?, fed_at = ? WHERE purchase_id = ?
        ''',
        [companion.name, now, purchaseId],
      );
      return {
        'affinity': serving['affinity'],
        'previous_affinity': family.bond.value,
      };
    },
  );

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
