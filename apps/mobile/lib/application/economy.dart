part of 'family.dart';

class CorrectionQuote {
  const CorrectionQuote({
    required this.instance,
    required this.reward,
    required this.recoverable,
    required this.shortfall,
    required this.revision,
    required this.refunds,
    required this.related,
  });
  final String instance;
  final int reward;
  final int recoverable;
  final int shortfall;
  final int revision;
  final List<String> refunds;
  final List<Json> related;
}

extension FamilyEconomy on FamilyService {
  Future<List<Json>> penaltyRules() =>
      db.rows('SELECT * FROM penalty_rules ORDER BY rowid DESC');
  Future<List<Json>> penalties() => db.rows('''
    SELECT p.*, r.behavior, l.back_id
    FROM penalty_events p JOIN penalty_rules r ON r.id = p.rule_id
    LEFT JOIN (SELECT reversal_of, id AS back_id FROM ledger_entries WHERE kind = 'penalty_reversal') l
    ON l.reversal_of = p.ledger_id ORDER BY p.rowid DESC
    ''');

  Future<Json> definePenalty(
    String behavior,
    String condition,
    int points, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'penalty-rule',
    [behavior, condition, points],
    commandId,
    (_, _) async {
      if (points < 1 || points > 3) throw const UserError('扣分档位为 1、2 或 3 分。');
      final id = uuid.v4();
      await db.insertRow('penalty_rules', {
        'id': id,
        'behavior': textValue(behavior, 80, requiredLabel: '约定行为'),
        'condition_text': textValue(condition, 300, requiredLabel: '触发条件'),
        'points': points,
      });
      return {'rule_id': id};
    },
    parentRequired: true,
    session: session,
  );

  Future<int> penaltyUsed(String day) async =>
      await db.value(
        'SELECT used FROM penalty_day_usage WHERE posted_day = ?',
        [day],
      ) as int? ??
      0;

  Future<Json> applyPenalty(
    String ruleId,
    String eventId,
    String fact,
    String actual, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'penalty',
    [ruleId, eventId, fact, actual],
    commandId,
    (id, family) async {
      _validateActualDate(actual);
      final text = textValue(fact, 500, requiredLabel: '事实说明');
      final before = await db.row('SELECT * FROM penalty_events WHERE id = ?', [
        eventId,
      ]);
      if (before != null) {
        if (before['rule_id'] != ruleId ||
            before['fact'] != text ||
            before['actual_date'] != actual) {
          throw const UserError('这个事件已经有一条不同的扣分记录。');
        }
        return {'id': eventId, 'deducted': before['deducted']};
      }
      final rule = await db.row('SELECT * FROM penalty_rules WHERE id = ?', [
        ruleId,
      ]);
      if (rule == null) throw const UserError('请先选择事先约定的扣分规则。');
      final day = today;
      final used = await penaltyUsed(day);
      final planned = rule['points'] as int;
      final deducted = min(
        planned,
        min(family.balance, rules.penaltyCap - used),
      );
      final entry = await _addLedger(
        id,
        -deducted,
        'penalty',
        'penalty:$eventId',
        actual,
        postedDay: day,
      );
      await db.insertRow('penalty_events', {
        'id': eventId,
        'rule_id': ruleId,
        'fact': text,
        'actual_date': actual,
        'posted_day': day,
        'planned_points': planned,
        'deducted': deducted,
        'ledger_id': entry['id'],
      });
      await db.customStatement(
        '''
      INSERT INTO penalty_day_usage(account_id, posted_day, used) VALUES ((SELECT id FROM accounts), ?, ?)
      ON CONFLICT(account_id, posted_day) DO UPDATE SET used = excluded.used
      ''',
        [day, used + deducted],
      );
      return {
        'id': eventId,
        'deducted': deducted,
        'used': used + deducted,
        'balance': entry['balance'],
      };
    },
    parentRequired: true,
    session: session,
  );

  Future<Json> reversePenalty(
    String event, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'reverse-penalty',
    event,
    commandId,
    (id, _) async {
      final original = await db.row(
        'SELECT * FROM penalty_events WHERE id = ?',
        [event],
      );
      if (original == null) throw const UserError('找不到这次扣分。');
      final prior = await db.row(
        'SELECT id, delta FROM ledger_entries WHERE reversal_of = ?',
        [original['ledger_id']],
      );
      if (prior != null) return prior;
      return _addLedger(
        id,
        original['deducted'] as int,
        'penalty_reversal',
        'penalty-reversal:$event',
        today,
        reversalOf: original['ledger_id'] as String,
      );
    },
    parentRequired: true,
    session: session,
  );

  Future<List<Json>> purchases() =>
      db.rows('SELECT * FROM purchases ORDER BY rowid DESC');
  Future<List<Json>> items() =>
      db.rows('SELECT * FROM entitlements WHERE revoked = 0 ORDER BY rowid');
  Future<List<Json>> spaces() => db.rows('SELECT * FROM spaces ORDER BY rowid');
  Future<Json?> wish() => db.row('SELECT * FROM wishes');

  Future<Json> setWish(String? item, {String? commandId}) =>
      _command('wish', item, commandId, (_, family) async {
        if (item == null) {
          await db.customStatement('DELETE FROM wishes WHERE child_id = ?', [
            family.childId,
          ]);
        } else {
          final product = _product(item);
          await db.customStatement(
            '''
            INSERT INTO wishes(child_id, item_id, selected_price, selected_at) VALUES (?, ?, ?, ?)
            ON CONFLICT(child_id) DO UPDATE SET item_id = excluded.item_id,
              selected_price = excluded.selected_price, selected_at = excluded.selected_at
            WHERE item_id != excluded.item_id
            ''',
            [family.childId, item, product['price'], now],
          );
        }
        return {'item_id': item};
      });

  Json _product(String id) =>
      rules.catalog[id] ?? (throw const UserError('这个成果暂不可兑换。'));

  Future<Json> purchase(String item, {String? commandId}) async {
    String? fresh;
    final result = await _command('purchase', item, commandId, (
      id,
      family,
    ) async {
      final owned = await db.row(
        'SELECT id, price_paid FROM purchases WHERE item_id = ? AND refunded_at IS NULL',
        [item],
      );
      if (owned != null) {
        return {'id': owned['id'], 'charged': 0, 'owned': true};
      }
      final product = _product(item);
      final wish = await this.wish();
      final fixed = product['price'] as int;
      final price = wish?['item_id'] == item
          ? min(fixed, wish!['selected_price'] as int)
          : fixed;
      if (family.balance < price) {
        throw UserError('还差 ${price - family.balance} 分。');
      }
      final key = uuid.v4();
      final ledger = await _addLedger(
        id,
        -price,
        'purchase',
        'purchase:$key',
        today,
      );
      await db.insertRow('purchases', {
        'id': key,
        'item_id': item,
        'name': product['name'],
        'price_paid': price,
        'ledger_id': ledger['id'],
        'created_at': now,
        'command_id': id,
        'asset_id': product['asset_id'],
      });
      final spaceType = product['space_id'] as String?;
      final space = spaceType == null ? null : uuid.v4();
      if (space != null) {
        await db.insertRow('spaces', {
          'id': space,
          'scene_id': spaceType,
          'name': product['name'],
          'purchase_id': key,
        });
      }
      final components = (product['included_items'] as List?)?.cast<Json>();
      for (final (index, part) in (components ?? [product]).indexed) {
        final instance = uuid.v4();
        await db.insertRow('entitlements', {
          'id': instance,
          'purchase_id': key,
          'item_id': part['id'],
          'asset_id': part['asset_id'],
          'name': part['name'],
          'slot': part['slot'],
          'bound_space': part['bound_to_container'] == true ? space : null,
        });
        if (space != null) {
          await db.insertRow('placements', {
            'entitlement_id': instance,
            'space_id': space,
            'x': [.26, .52, .75][index],
            'y': [.80, .89, .74][index],
            'z': index,
          });
        }
      }
      fault?.call('ownership');
      await db.customStatement(
        'DELETE FROM wishes WHERE child_id = ? AND item_id = ?',
        [family.childId, item],
      );
      fresh = key;
      return {'id': key, 'charged': price, 'balance': ledger['balance']};
    });
    if (fresh != null) {
      _childUndoStarts[fresh!] = _undoClock.elapsedMilliseconds;
    }
    return result;
  }

  bool canChildUndo(String purchase) {
    final start = _childUndoStarts[purchase];
    return start != null && _undoClock.elapsedMilliseconds - start < 300000;
  }

  Future<Json> refund(
    String purchase, {
    ParentSession? session,
    String? commandId,
  }) => _command('refund', purchase, commandId, (id, _) async {
    final existing = await db.row(
      'SELECT id, delta FROM ledger_entries WHERE source_key = ?',
      ['refund:$purchase'],
    );
    if (existing != null) return existing;
    if (!pin.allows(session) && !canChildUndo(purchase)) {
      throw const UserError('请家长查看这笔误购。');
    }
    return _refundInTransaction(id, purchase);
  });

  Future<Json> _refundInTransaction(String command, String purchase) async {
    final row = await db.row(
      'SELECT * FROM purchases WHERE id = ? AND refunded_at IS NULL',
      [purchase],
    );
    if (row == null) throw const UserError('此兑换已退回或不存在。');
    final entitlementIds = 'SELECT id FROM entitlements WHERE purchase_id = ?';
    await db.customStatement(
      'DELETE FROM pet_state WHERE entitlement_id IN ($entitlementIds)',
      [purchase],
    );
    await db.customStatement(
      '''
      DELETE FROM placements WHERE entitlement_id IN ($entitlementIds)
        OR space_id IN (SELECT id FROM spaces WHERE purchase_id = ?)
      ''',
      [purchase, purchase],
    );
    await db.customStatement(
      'UPDATE entitlements SET revoked = 1, bound_space = NULL WHERE purchase_id = ?',
      [purchase],
    );
    await db.customStatement('DELETE FROM spaces WHERE purchase_id = ?', [
      purchase,
    ]);
    await db.customStatement(
      'UPDATE purchases SET refunded_at = ? WHERE id = ?',
      [now, purchase],
    );
    return _addLedger(
      command,
      row['price_paid'] as int,
      'refund',
      'refund:$purchase',
      today,
      reversalOf: row['ledger_id'] as String,
    );
  }

  Future<CorrectionQuote> correctionQuote(
    String instance,
    List<String> refunds,
    ParentSession? session,
  ) {
    checkParent(session);
    return serial.run(() async {
      checkParent(session);
      final family = (await overview())!;
      return _quote(instance, refunds, family);
    });
  }

  Future<CorrectionQuote> _quote(
    String instance,
    List<String> refunds,
    FamilyOverview family,
  ) async {
    final entry = await task(instance);
    if (entry.state != 'APPROVED') throw const UserError('请选择尚未更正的已确认成果。');
    final related = await db.rows(
      '''
      SELECT p.* FROM purchases p JOIN ledger_entries l ON l.id = p.ledger_id
      WHERE p.refunded_at IS NULL AND l.rowid >
        (SELECT rowid FROM ledger_entries WHERE source_key = ?)
      ORDER BY l.rowid
      ''',
      ['reward:$instance'],
    );
    final chosen = refunds.toSet();
    if (chosen.length != refunds.length ||
        !chosen.every((id) => related.any((row) => row['id'] == id))) {
      throw const UserError('有兑换记录已变化，请重新预览。');
    }
    final refundTotal = related
        .where((row) => chosen.contains(row['id']))
        .fold(0, (sum, row) => sum + (row['price_paid'] as int));
    final recover = min(entry.reward, family.balance + refundTotal);
    return CorrectionQuote(
      instance: instance,
      reward: entry.reward,
      recoverable: recover,
      shortfall: entry.reward - recover,
      revision: family.revision,
      refunds: refunds.toList(growable: false),
      related: related,
    );
  }

  Future<Json> correctAward(
    CorrectionQuote quote,
    String reason,
    bool acceptsShortfall, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'correct',
    [quote.instance, quote.revision, quote.refunds, reason, acceptsShortfall],
    commandId,
    (id, family) async {
      if (family.revision != quote.revision) {
        throw const UserError('数据已变化，请重新预览。');
      }
      final verified = await _quote(quote.instance, quote.refunds, family);
      if (verified.shortfall > 0 && !acceptsShortfall) {
        throw const UserError('请确认无法追回的差额。');
      }
      final explanation = textValue(reason, 500, requiredLabel: '更正说明');
      await _protectBeforeCorrection?.call();
      for (final purchase in verified.refunds) {
        await _refundInTransaction(id, purchase);
      }
      final original = (await db.row(
        'SELECT id, actual_date FROM ledger_entries WHERE source_key = ?',
        ['reward:${quote.instance}'],
      ))!;
      final reversal = await _addLedger(
        id,
        -verified.recoverable,
        'correction',
        'correction:${quote.instance}',
        original['actual_date'] as String,
        reversalOf: original['id'] as String,
      );
      await db.insertRow('correction_records', {
        'instance_id': quote.instance,
        'original_reward_id': original['id'],
        'recovered': verified.recoverable,
        'shortfall': verified.shortfall,
        'reason': explanation,
        'refunded_purchase_ids': jsonEncode(verified.refunds),
        'command_id': id,
      });
      await db.customStatement(
        'UPDATE completions SET is_valid = 0 WHERE instance_id = ?',
        [quote.instance],
      );
      await db.customStatement(
        "UPDATE task_instances SET state = 'CORRECTED', resolution_note = ? WHERE id = ?",
        [explanation, quote.instance],
      );
      return {...reversal, 'shortfall': verified.shortfall};
    },
    parentRequired: true,
    session: session,
  );
}
