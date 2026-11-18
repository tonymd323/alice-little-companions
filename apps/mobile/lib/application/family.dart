import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../data/database.dart';
import '../data/device.dart';
import '../domain/companions.dart';
import '../domain/pin.dart';
import '../domain/rules.dart';

part 'economy.dart';
part 'task_rules.dart';

class FamilyOverview {
  FamilyOverview(Json row)
    : id = row['id'] as String,
      childId = row['child_id'] as String,
      nickname = row['nickname'] as String,
      companion = Companion.values.byName(row['active_pet_id'] as String),
      balance = row['balance'] as int,
      stage = row['stage'] as int,
      days = row['growth_days'] as int,
      revision = row['domain_revision'] as int,
      latestDay = row['latest_local_day'] as String?;
  final String id;
  final String childId;
  final String nickname;
  final Companion companion;
  final int balance;
  final int stage;
  final int days;
  final int revision;
  final String? latestDay;
}

class TaskDraft {
  const TaskDraft(
    this.title,
    this.content,
    this.criteria,
    this.type, {
    this.due,
  });
  final String title;
  final String content;
  final String criteria;
  final String type;
  final String? due;

  Json encode() => {
    'title': title,
    'content': content,
    'criteria': criteria,
    'type': type,
    'due': due,
  };
}

class TaskEntry {
  TaskEntry(Json row)
    : id = row['id'] as String,
      title = row['title'] as String,
      projectTitle = row['project_title'] as String?,
      content = row['content'] as String,
      criteria = row['criteria'] as String,
      reward = row['reward'] as int,
      state = row['state'] as String,
      planned = row['planned_day'] as String,
      due = row['due_day'] as String?,
      actual = row['actual_date'] as String?,
      feedback = row['feedback'] as String?,
      resolution = row['resolution_note'] as String,
      submission = row['submission_note'] as String?;
  final String id;
  final String title;
  final String? projectTitle;
  final String content;
  final String criteria;
  final int reward;
  final String state;
  final String planned;
  final String? due;
  final String? actual;
  final String? feedback;
  final String resolution;
  final String? submission;

  bool get canSubmit => state == 'OPEN' || state == 'RETURNED';
  String get stateLabel => switch (state) {
    'OPEN' => '待完成',
    'RETURNED' => '继续完成',
    'SUBMITTED' => '待家长确认',
    'APPROVED' => '已确认',
    'EXPIRED' => '已到期',
    'CANCELLED' => '已取消',
    'CORRECTED' => '已更正',
    _ => '等待前一阶段',
  };
}

class SerialWork {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }
}

class FamilyService {
  FamilyService(
    this.db,
    this.pin,
    this.rules, {
    DateTime Function()? clock,
    this.fault,
  }) : _now = clock ?? DateTime.now;

  final FamilyDatabase db;
  final PinGate pin;
  final Rules rules;
  final DateTime Function() _now;
  final void Function(String phase)? fault;
  final serial = SerialWork();
  bool frozen = false;
  final _undoClock = Stopwatch()..start();
  final _childUndoStarts = <String, int>{};
  String get today => familyDay(_now());
  int get now => _now().millisecondsSinceEpoch;

  static Future<FamilyService> load(
    DeviceStore device,
    String generation,
    Rules rules, {
    DateTime Function()? clock,
  }) async {
    final db = await device.openGeneration(generation);
    final pin = PinGate(
      device.secure,
      generation,
      iterations: rules.pinIterations,
      now: clock,
    );
    final service = FamilyService(db, pin, rules, clock: clock);
    await service.overview();
    return service;
  }

  static Future<FamilyService> initialize(
    DeviceStore device,
    Rules rules, {
    required String nickname,
    required Companion companion,
    required String pin,
    required String recovery,
    DateTime Function()? clock,
  }) async {
    if (await device.activeGeneration() != null) {
      throw const UserError('这台设备已有一个小家。');
    }
    final name = textValue(nickname, 30, requiredLabel: '孩子称呼');
    final generation = device.newGeneration();
    final service = await load(device, generation, rules, clock: clock);
    try {
      await service.pin.configure(pin, recovery);
      final familyId = uuid.v4();
      final childId = uuid.v4();
      await service.db.transaction(() async {
        await service.db.insertRow('households', {
          'id': familyId,
          'lineage_id': uuid.v4(),
          'timezone': rules.timezone,
          'rules_version': rules.version,
          'catalog_version': rules.catalogVersion,
          'latest_local_day': service.today,
        });
        await service.db.insertRow('child_profiles', {
          'id': childId,
          'family_id': familyId,
          'nickname': name,
          'active_pet_id': companion.name,
        });
        await service.db.insertRow('accounts', {
          'id': uuid.v4(),
          'child_id': childId,
        });
        await service.db.insertRow('spaces', {
          'id': uuid.v4(),
          'scene_id': 'base_room',
          'name': '银杏家园',
        });
      });
      await device.activate(generation);
      return service;
    } catch (_) {
      await service.db.close();
      rethrow;
    }
  }

  Future<FamilyOverview?> overview() async {
    final row = await db.row('''
      SELECT h.*, c.id AS child_id, c.nickname, c.active_pet_id, a.balance,
        (SELECT COUNT(DISTINCT actual_date) FROM completions WHERE is_valid = 1) AS growth_days,
        COALESCE((SELECT MAX(stage) FROM growth_awards WHERE child_id = c.id), 1) AS stage
      FROM households h JOIN child_profiles c ON h.id = c.family_id
      JOIN accounts a ON a.child_id = c.id
      ''');
    return row == null ? null : FamilyOverview(row);
  }

  static const taskFields = '''
    SELECT i.*, COALESCE(s.title, v.title) AS title,
      CASE WHEN s.id IS NULL THEN NULL ELSE v.title END AS project_title,
      v.content, COALESCE(s.criteria, v.criteria) AS criteria,
      COALESCE(s.reward, v.reward) AS reward, c.feedback,
      (SELECT note FROM submissions WHERE instance_id = i.id ORDER BY created_at DESC, rowid DESC LIMIT 1)
        AS submission_note
    FROM task_instances i JOIN task_versions v ON v.id = i.version_id
    LEFT JOIN project_stages s ON s.id = i.stage_id LEFT JOIN completions c ON c.instance_id = i.id
    ''';

  Future<List<TaskEntry>> tasks() async => (await db.rows('''
        $taskFields
        ORDER BY COALESCE(i.actual_date, i.planned_day) DESC, COALESCE(i.approved_at, 0) DESC,
        i.version_id, i.slot, i.rowid
        ''')).map(TaskEntry.new).toList(growable: false);

  Future<TaskEntry> task(String id) async {
    final row = await db.row('$taskFields WHERE i.id = ?', [id]);
    if (row == null) throw const UserError('这件小事已不存在。');
    return TaskEntry(row);
  }

  Future<Json> _command(
    String action,
    Object? payload,
    String? commandId,
    Future<Json> Function(String id, FamilyOverview family) run, {
    bool parentRequired = false,
    ParentSession? session,
  }) => serial.run(() async {
    if (parentRequired) checkParent(session);
    if (frozen) throw const UserError('这台设备当前只读，请在新设备继续。');
    final id = commandId ?? uuid.v4();
    return db.transaction(() async {
      final family = await overview();
      if (family == null) throw const UserError('请先创建小家。');
      if (parentRequired) checkParent(session);
      final hash = sha256
          .convert(utf8.encode(jsonEncode([action, family.id, payload])))
          .toString();
      final prior = await db.row(
        'SELECT payload_hash, result_json FROM processed_commands WHERE id = ?',
        [id],
      );
      if (prior != null) {
        if (prior['payload_hash'] != hash) {
          throw const UserError('这次操作与已记录的请求不一致。');
        }
        return jsonDecode(prior['result_json'] as String) as Json;
      }
      final result = await run(id, family);
      if (parentRequired) checkParent(session);
      await db.insertRow('processed_commands', {
        'id': id,
        'payload_hash': hash,
        'result_json': jsonEncode(result),
        'created_at': now,
      });
      await db.customStatement(
        '''
        UPDATE households SET domain_revision = domain_revision + 1,
          latest_local_day = MAX(COALESCE(latest_local_day, ?), ?)
        ''',
        [today, today],
      );
      return result;
    });
  });

  void checkParent(ParentSession? session) {
    if (!pin.allows(session)) throw const UserError('请先验证家长 PIN。');
  }

  Future<Json> selectCompanion(Companion companion, {String? commandId}) =>
      _command('select', companion.name, commandId, (_, family) async {
        await db.customStatement(
          'UPDATE child_profiles SET active_pet_id = ? WHERE id = ?',
          [companion.name, family.childId],
        );
        return {'pet': companion.name};
      });

  Future<Json> publish(
    TaskDraft draft, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'publish',
    draft.encode(),
    commandId,
    (_, family) async {
      final ids = await _saveVersion(draft, family, mode: 'once');
      final instanceId = uuid.v4();
      await _addInstance(
        instanceId,
        instanceId,
        ids.template,
        ids.version,
        today,
        due: draft.due,
      );
      return {'instance_id': instanceId};
    },
    parentRequired: true,
    session: session,
  );

  Future<({String template, String version})> _saveVersion(
    TaskDraft draft,
    FamilyOverview family, {
    required String mode,
    String? templateId,
    int version = 1,
    Json schedule = const {},
  }) async {
    final title = textValue(draft.title, 40, requiredLabel: '小事名称');
    final content = textValue(draft.content, 500);
    final criteria = textValue(draft.criteria, 300, requiredLabel: '完成标准');
    final kind = rules.type(draft.type);
    if (draft.due case final day?) parseDay(day);
    final template = templateId ?? uuid.v4();
    if (templateId == null) {
      await db.insertRow('task_templates', {
        'id': template,
        'family_id': family.id,
        'mode': mode,
      });
    }
    final versionId = uuid.v4();
    await db.insertRow('task_versions', {
      'id': versionId,
      'template_id': template,
      'version': version,
      'title': title,
      'content': content,
      'criteria': criteria,
      'task_type': kind.id,
      'reward': kind.points,
      'rules_version': rules.version,
      'schedule_json': jsonEncode(schedule),
    });
    return (template: template, version: versionId);
  }

  Future<void> _addInstance(
    String id,
    String key,
    String template,
    String version,
    String day, {
    int slot = 1,
    String? due,
    String? stageId,
    String state = 'OPEN',
    String? prior,
  }) => db.insertRow('task_instances', {
    'id': id,
    'instance_key': key,
    'template_id': template,
    'version_id': version,
    'planned_day': day,
    'slot': slot,
    'due_day': due,
    'state': state,
    'stage_id': stageId,
    'prior_instance_id': prior,
  });

  Future<Json> submit(String instance, String note, {String? commandId}) =>
      _command('submit', [instance, note], commandId, (_, _) async {
        final entry = await task(instance);
        if (entry.state == 'SUBMITTED') return {'instance_id': instance};
        if (!entry.canSubmit ||
            (entry.due != null && entry.due!.compareTo(today) < 0)) {
          throw const UserError('这件小事目前无法申报。');
        }
        await db.insertRow('submissions', {
          'id': uuid.v4(),
          'instance_id': instance,
          'note': textValue(note, 500),
          'actual_date': today,
          'created_at': now,
        });
        await db.customStatement(
          "UPDATE task_instances SET state = 'SUBMITTED', actual_date = ? WHERE id = ?",
          [today, instance],
        );
        return {'instance_id': instance};
      });

  Future<Json> approve(
    String instance,
    String actual,
    String feedback, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'approve',
    [instance, actual, feedback],
    commandId,
    (id, family) =>
        _approveInTransaction(id, family, instance, actual, feedback),
    parentRequired: true,
    session: session,
  );

  Future<Json> _approveInTransaction(
    String commandId,
    FamilyOverview family,
    String instance,
    String actual,
    String feedback,
  ) async {
    final entry = await task(instance);
    if (entry.state == 'APPROVED') {
      final existing = await db.row(
        'SELECT id, delta, balance_after FROM ledger_entries WHERE source_key = ?',
        ['reward:$instance'],
      );
      return {
        'id': existing!['id'],
        'delta': existing['delta'],
        'balance': existing['balance_after'],
        'new_stage': false,
        'stage': family.stage,
      };
    }
    if (entry.state != 'SUBMITTED') throw const UserError('这件小事目前无法确认。');
    _validateActualDate(actual);
    await db.customStatement(
      "UPDATE task_instances SET state = 'APPROVED', actual_date = ?, approved_at = ? WHERE id = ?",
      [actual, now, instance],
    );
    await db.insertRow('completions', {
      'id': uuid.v4(),
      'instance_id': instance,
      'actual_date': actual,
      'feedback': textValue(feedback, 500),
      'approval_command_id': commandId,
    });
    await db.customStatement(
      """
      UPDATE task_instances
      SET state = CASE WHEN due_day < ? THEN 'EXPIRED' ELSE 'OPEN' END
      WHERE state = 'WAITING' AND stage_id IS NOT NULL AND
        version_id = (SELECT version_id FROM task_instances WHERE id = ? AND stage_id IS NOT NULL)
        AND slot = (SELECT slot + 1 FROM task_instances WHERE id = ?)
      """,
      [today, instance, instance],
    );
    final ledger = await _addLedger(
      commandId,
      entry.reward,
      'reward',
      'reward:$instance',
      actual,
    );
    final days = await db.value(
      'SELECT COUNT(DISTINCT actual_date) FROM completions WHERE is_valid = 1',
    ) as int;
    for (
      var i = family.stage - 1;
      i < rules.thresholds.length && days >= rules.thresholds[i];
      i++
    ) {
      await db.insertRow('growth_awards', {
        'child_id': family.childId,
        'threshold': rules.thresholds[i],
        'stage': i + 2,
        'awarded_at': now,
      });
    }
    final stage = await db.value(
      'SELECT COALESCE(MAX(stage), 1) FROM growth_awards',
    ) as int;
    return {...ledger, 'new_stage': stage > family.stage, 'stage': stage};
  }

  void _validateActualDate(String actual) {
    parseDay(actual);
    if (actual.compareTo(today) > 0) throw const UserError('发生日期不能晚于今天。');
  }

  Future<Json> _addLedger(
    String commandId,
    int delta,
    String kind,
    String source,
    String actual, {
    String? reversalOf,
    String? postedDay,
  }) async {
    final account = (await db.row('SELECT id, balance FROM accounts'))!;
    final balance = (account['balance'] as int) + delta;
    if (balance < 0) throw const UserError('积分还不够。');
    await db.customStatement('UPDATE accounts SET balance = ? WHERE id = ?', [
      balance,
      account['id'],
    ]);
    fault?.call('balance');
    final id = uuid.v4();
    await db.insertRow('ledger_entries', {
      'id': id,
      'account_id': account['id'],
      'delta': delta,
      'balance_after': balance,
      'kind': kind,
      'source_key': source,
      'reversal_of': reversalOf,
      'actual_date': actual,
      'posted_day': postedDay ?? today,
      'created_at': now,
      'command_id': commandId,
    });
    fault?.call('ledger');
    return {'id': id, 'balance': balance, 'delta': delta};
  }

  Future<List<Json>> ledger() => db.rows(
    'SELECT * FROM ledger_entries ORDER BY created_at DESC, rowid DESC',
  );

  Future<void> close() => serial.run(db.close);

  Future<void> verifyAccounting() async {
    final row = await db
        .customSelect(
          '''
      SELECT a.balance, COALESCE(SUM(l.delta), 0) AS ledger
      FROM accounts a LEFT JOIN ledger_entries l ON l.account_id = a.id
      GROUP BY a.id
      ''',
          readsFrom: {db.accounts, db.ledgerEntries},
        )
        .getSingle();
    if (row.read<int>('balance') != row.read<int>('ledger')) {
      throw const UserError('积分与流水不一致。');
    }
  }
}
