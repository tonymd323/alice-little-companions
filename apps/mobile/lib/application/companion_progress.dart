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

class CompanionProgress {
  CompanionProgress(Json row, Rules rules)
    : experience = row['experience'] as int,
      stage = max(
        row['retained_stage'] as int,
        rules.earnedStage(row['experience'] as int),
      );

  final int experience;
  final int stage;
}

extension FamilyCompanions on FamilyService {
  Future<Map<Companion, CompanionProgress>> companionProgress() async => {
    for (final row in await db.rows('''
      SELECT p.pet_id, p.retained_stage, ($_companionExperience) AS experience
      FROM owned_companions p
      '''))
      rules.companion(row['pet_id'] as String): CompanionProgress(row, rules),
  };

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
