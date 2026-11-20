import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../data/checkpoints.dart';
import '../data/database.dart';
import '../data/device.dart';
import '../data/snapshot.dart';
import '../domain/companion_bond.dart';
import '../domain/companions.dart';
import '../domain/layout_rules.dart';
import '../domain/pin.dart';
import '../domain/rain_map.dart';
import '../domain/rules.dart';
import '../domain/wind_progress.dart';
import '../domain/window_page.dart';

part 'decorations.dart';
part 'economy.dart';
part 'task_rules.dart';

class FamilyOverview {
  FamilyOverview(Json row, Rules rules)
    : id = row['id'] as String,
      childId = row['child_id'] as String,
      nickname = row['nickname'] as String,
      companion = Companion.values.byName(row['active_pet_id'] as String),
      balance = row['balance'] as int,
      stage = max(
        row['stage'] as int,
        rules.earnedStage(row['experience'] as int),
      ),
      experience = row['experience'] as int,
      taskCount = row['task_count'] as int,
      windowsLit = (row['windows_lit'] as int) != 0,
      rainMapCleared = row['rain_map_cleared'] == 1,
      bond = CompanionBond(
        touched: row['companion_touched'] == 1,
        called: row['companion_called'] == 1,
      ),
      days = row['growth_days'] as int,
      revision = row['domain_revision'] as int,
      latestDay = row['latest_local_day'] as String?;
  final String id;
  final String childId;
  final String nickname;
  final Companion companion;
  final int balance;
  final int stage;
  final int experience;
  final int taskCount;
  final bool windowsLit;
  final bool rainMapCleared;
  final CompanionBond bond;
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
      submission = row['submission_note'] as String?,
      detailsLoaded = row['details_loaded'] != 0;
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
  final bool detailsLoaded;

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

class FamilyService implements RainMapCommands {
  FamilyService(
    this.db,
    this.pin,
    this.rules, {
    DateTime Function()? clock,
    this.fault,
    this._protectBeforeCorrection,
  }) : _now = clock ?? DateTime.now;

  final FamilyDatabase db;
  final PinGate pin;
  final Rules rules;
  final DateTime Function() _now;
  final void Function(String phase)? fault;
  final Future<void> Function()? _protectBeforeCorrection;
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
    bool protectUpgrade = true,
  }) async {
    final file = device.databaseFile(generation);
    if (protectUpgrade &&
        await file.exists() &&
        await inspectSchemaVersion(file.path) < currentSchemaVersion) {
      await CheckpointStore(device).protectDatabase(file);
    }
    final db = await device.openGeneration(generation);
    final pin = PinGate(
      device.secure,
      generation,
      iterations: rules.pinIterations,
      now: clock,
    );
    final service = FamilyService(
      db,
      pin,
      rules,
      clock: clock,
      protectBeforeCorrection: () =>
          CheckpointStore(device).protectDatabase(file),
    );
    try {
      await service.overview();
      final state = await device.control(generation);
      if (state['state'] == 'EXPORTING') {
        final draft = state.remove('draft_outgoing_id');
        if (draft is String &&
            RegExp(r'^[a-f0-9-]{36}$').hasMatch(draft) &&
            draft != state['outgoing_id']) {
          final abandoned = device.outgoingBackup(generation, draft);
          if (await abandoned.exists()) await abandoned.delete();
        }
        await device.updateControl(generation, {
          ...state,
          'state': 'IDLE',
          if (draft == null) ...{
            'outgoing_id': null,
            'outgoing_mode': null,
            'outgoing_sha256': null,
          },
        });
      } else {
        service.frozen = state['state'] != 'IDLE';
      }
      return service;
    } catch (_) {
      await service.close();
      rethrow;
    }
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
        (EXISTS(SELECT 1 FROM window_story_milestones) OR EXISTS(SELECT 1 FROM window_math_bookmarks WHERE page IN ('sunny','puzzle','finished'))) AS windows_lit,
        EXISTS(SELECT 1 FROM rain_map_runs r WHERE r.child_id = c.id AND r.cleared = 1) AS rain_map_cleared,
        EXISTS(SELECT 1 FROM companion_memories m WHERE m.child_id = c.id
          AND m.pet_id = c.active_pet_id AND m.moment = 'touch') AS companion_touched,
        EXISTS(SELECT 1 FROM companion_memories m WHERE m.child_id = c.id
          AND m.pet_id = c.active_pet_id AND m.moment = 'call') AS companion_called,
        (SELECT COUNT(*) FROM completions WHERE is_valid = 1) AS experience,
        (SELECT COUNT(*) FROM task_instances) AS task_count,
        (SELECT COUNT(DISTINCT actual_date) FROM completions WHERE is_valid = 1) AS growth_days,
        COALESCE((SELECT MAX(stage) FROM growth_awards WHERE child_id = c.id), 1) AS stage
      FROM households h JOIN child_profiles c ON h.id = c.family_id
      JOIN accounts a ON a.child_id = c.id
      ''');
    return row == null ? null : FamilyOverview(row, rules);
  }

  static const _currentTaskStates =
      "i.state IN ('OPEN', 'RETURNED', 'SUBMITTED', 'WAITING')";

  static String _taskFields({bool includeClosedDetails = true}) {
    final details = includeClosedDetails
        ? '1'
        : _currentTaskStates;
    return '''
      SELECT i.id, i.state, i.planned_day, i.due_day, i.actual_date,
        COALESCE(s.title, v.title) AS title,
        CASE WHEN s.id IS NULL THEN NULL ELSE v.title END AS project_title,
        COALESCE(s.reward, v.reward) AS reward, ($details) AS details_loaded,
        CASE WHEN $details THEN v.content ELSE '' END AS content,
        CASE WHEN $details THEN COALESCE(s.criteria, v.criteria) ELSE '' END AS criteria,
        CASE WHEN $details THEN i.resolution_note ELSE '' END AS resolution_note,
        c.feedback,
        CASE WHEN $details THEN (
          SELECT note FROM submissions WHERE instance_id = i.id
          ORDER BY created_at DESC, rowid DESC LIMIT 1
        ) END AS submission_note
      FROM task_instances i JOIN task_versions v ON v.id = i.version_id
      LEFT JOIN project_stages s ON s.id = i.stage_id
      LEFT JOIN completions c ON c.instance_id = i.id AND ($details)
      ''';
  }

  Future<List<TaskEntry>> tasks({bool includeClosedDetails = true}) =>
      _listTasks(includeClosedDetails: includeClosedDetails);

  Future<List<TaskEntry>> currentTasks() => _listTasks(currentOnly: true);

  Future<List<TaskEntry>> _listTasks({
    bool includeClosedDetails = true,
    bool currentOnly = false,
  }) async =>
      (await db.rows('''
        ${_taskFields(includeClosedDetails: includeClosedDetails)}
        ${currentOnly ? 'WHERE $_currentTaskStates' : ''}
        ORDER BY COALESCE(i.actual_date, i.planned_day) DESC, COALESCE(i.approved_at, 0) DESC,
        i.version_id, i.slot, i.rowid
        ''')).map(TaskEntry.new).toList(growable: false);

  Future<TaskEntry> task(String id) async {
    final row = await db.row('${_taskFields()} WHERE i.id = ?', [id]);
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

  Future<WindProgress> windProgress() async {
    final row = await db.row(
      'SELECT run_number, leaf_mask FROM wind_story_runs',
    );
    if (row == null) return const WindProgress();
    return WindProgress(
      run: row['run_number'] as int,
      mask: row['leaf_mask'] as int,
    );
  }

  Future<WindProgress> beginWindStory() async {
    await _command('wind_begin', null, 'wind/begin', (_, family) async {
      await db.customStatement(
        'INSERT INTO wind_story_runs (child_id, run_number, leaf_mask) VALUES (?, 1, 0)',
        [family.childId],
      );
      return {};
    });
    return windProgress();
  }

  Future<WindProgress> placeWindLeaf(int slot, {required int run}) async {
    if (slot < 0 || slot >= WindProgress.slots || run < 1) {
      throw const UserError('请选择本次故事中的空窗格。');
    }
    await _command('wind_leaf', [run, slot], 'wind/leaf/$run/$slot', (
      _,
      family,
    ) async {
      final progress = await windProgress();
      if (progress.run != run) throw const UserError('请重新打开当前的暖廊故事。');
      final mask = progress.mask | (1 << slot);
      await db.customStatement(
        'UPDATE wind_story_runs SET leaf_mask = ? WHERE child_id = ?',
        [mask, family.childId],
      );
      if (mask == WindProgress.fullMask) {
        await db.customStatement(
          'INSERT OR IGNORE INTO window_story_milestones(child_id) VALUES (?)',
          [family.childId],
        );
      }
      return {};
    });
    // A duplicate tap may have been followed by other leaves or a replay.
    return windProgress();
  }

  Future<WindProgress> replayWindStory({required int run}) async {
    await _command('wind_replay', run, 'wind/replay/$run', (_, family) async {
      final current = await windProgress();
      if (run != current.run || !current.complete) {
        throw const UserError('修复三扇窗后可以重新体验。');
      }
      await db.customStatement(
        'UPDATE wind_story_runs SET run_number = run_number + 1, leaf_mask = 0 WHERE child_id = ?',
        [family.childId],
      );
      return {};
    });
    return windProgress();
  }

  Future<RainMapProgress> rainMapProgress() async {
    final row = await db.row('SELECT * FROM rain_map_runs');
    if (row == null) return const RainMapProgress();
    return RainMapProgress(
      run: row['run_number'] as int,
      stones: row['stones'] as int,
      stamps: row['stamps'] as int,
      cleared: row['cleared'] == 1,
      challengeSolved: row['challenge_solved'] == 1,
    );
  }

  Future<RainMapProgress> _rainMapCommand(
    String action,
    List<int> args,
    Future<void> Function(FamilyOverview, RainMapProgress) apply,
  ) async {
    await _command('rain_$action', args, 'rain/$action/${args.join('/')}', (
      _,
      family,
    ) async {
      await apply(family, await rainMapProgress());
      return {};
    });
    return rainMapProgress();
  }

  @override
  Future<RainMapProgress> beginRainMap() =>
      _rainMapCommand('begin', const [], (family, progress) async {
        if (!family.windowsLit) {
          throw const UserError('先和桃桃修好暖廊的彩窗。');
        }
        if (progress.started) return;
        await db.insertRow('rain_map_runs', {
          'child_id': family.childId,
          'run_number': 1,
          'stones': 0,
          'stamps': 0,
          'cleared': 0,
          'challenge_solved': 0,
        });
      });

  @override
  Future<RainMapProgress> stepRainMapStone({
    required int run,
    required int group,
    required int stone,
  }) => _rainMapCommand('step', [run, group, stone], (family, progress) async {
    if (run < 1 ||
        progress.run != run ||
        progress.complete ||
        group != progress.stamps) {
      throw const UserError('请回到奶油所在的这一段路。');
    }
    if (stone != progress.stones || stone >= RainMapProgress.groupSize) {
      throw const UserError('从脚边那块还没踩过的石板开始。');
    }
    await db.customStatement(
      'UPDATE rain_map_runs SET stones = stones + 1 WHERE child_id = ?',
      [family.childId],
    );
  });

  @override
  Future<RainMapProgress> stampRainMap({
    required int run,
    required int group,
  }) => _rainMapCommand('stamp', [run, group], (family, progress) async {
    if (run < 1 ||
        progress.run != run ||
        group != progress.stamps ||
        !progress.canStamp) {
      throw const UserError('每踩过三块石板，就能在地图上盖一个爪印。');
    }
    final last = group + 1 == RainMapProgress.groupCount;
    await db.customStatement(
      '''
      UPDATE rain_map_runs
      SET stones = 0, stamps = stamps + 1, cleared = MAX(cleared, ?)
      WHERE child_id = ?
    ''',
      [last ? 1 : 0, family.childId],
    );
  });

  @override
  Future<RainMapProgress> restartRainMap({required int run}) =>
      _rainMapCommand('replay', [run], (family, progress) async {
        if (progress.run != run || !progress.complete) {
          throw const UserError('画完地图即可再走一次。');
        }
        await db.customStatement(
          '''
          UPDATE rain_map_runs
          SET run_number = run_number + 1, stones = 0, stamps = 0
          WHERE child_id = ?
        ''',
          [family.childId],
        );
      });

  @override
  Future<RainMapProgress> solveRainMapChallenge(int stones) =>
      _rainMapCommand('challenge', [stones], (family, progress) async {
        if (!progress.cleared) {
          throw const UserError('把完整的回家地图画好，就能试试这条小路。');
        }
        if (stones != RainMapProgress.challengeAnswer) {
          throw const UserError('看看三个爪印，每个都代表三块石板。');
        }
        await db.customStatement(
          'UPDATE rain_map_runs SET challenge_solved = 1 WHERE child_id = ?',
          [family.childId],
        );
      });

  Future<void> recordCompanionMoment(
    Companion companion,
    CompanionMoment moment,
  ) async {
    final args = [companion.name, moment.name];
    await _command('companion_moment', args, 'companion/${args.join('/')}', (
      _,
      family,
    ) async {
      if (family.companion != companion) {
        throw const UserError('这次互动属于刚才的伙伴。');
      }
      await db.customStatement(
        '''
        INSERT OR IGNORE INTO companion_memories(child_id, pet_id, moment)
        VALUES (?, ?, ?)
      ''',
        [family.childId, companion.name, moment.name],
      );
      return {};
    });
  }

  Future<({WindowPage page, Set<int> pattern, bool started})>
  windowMathBookmark() async {
    final row = await db.row(
      'SELECT page, first_pane, second_pane FROM window_math_bookmarks',
    );
    if (row == null) {
      return (page: WindowPage.count, pattern: <int>{}, started: false);
    }
    return (
      started: true,
      page: WindowPage.values.byName(row['page'] as String),
      pattern: {
        if (row['first_pane'] case final int first) first,
        if (row['second_pane'] case final int second) second,
      },
    );
  }

  Future<void> saveWindowMathBookmark(WindowPage page, Set<int> pattern) async {
    final panes = pattern.toList()..sort();
    if (panes.length != (page == WindowPage.finished ? 2 : 0) ||
        panes.any((i) => i < 0 || i >= 5)) {
      throw const UserError('窗花的位置无效。');
    }
    await _command('window_math_bookmark', [page.name, panes], null, (
      _,
      family,
    ) async {
      if (family.windowsLit || page.index >= WindowPage.sunny.index) {
        await db.customStatement(
          'INSERT OR IGNORE INTO window_story_milestones(child_id) VALUES (?)',
          [family.childId],
        );
      }
      await db.customStatement(
        '''
        INSERT INTO window_math_bookmarks (child_id, page, first_pane, second_pane)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(child_id) DO UPDATE SET page = excluded.page,
          first_pane = excluded.first_pane, second_pane = excluded.second_pane
        ''',
        [family.childId, page.name, panes.firstOrNull, panes.lastOrNull],
      );
      return {};
    });
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
        'experience_delta': 0,
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
    final experience = family.experience + 1;
    final stage = max(family.stage, rules.earnedStage(experience));
    await _preserveGrowth(family.childId, stage);
    return {
      ...ledger,
      'experience_delta': 1,
      'previous_stage': family.stage,
      'new_stage': stage > family.stage,
      'stage': stage,
    };
  }

  // An older database can earn a higher stage on first open through its
  // historical completions. Preserve that high-water mark before a correction.
  Future<void> _preserveGrowth(String child, int stage) async {
    for (var i = 0; i < stage - 1; i++) {
      await db.customStatement(
        'INSERT INTO growth_awards (child_id, threshold, stage, awarded_at) '
        'VALUES (?, ?, ?, ?) ON CONFLICT(child_id, threshold) DO NOTHING',
        [child, rules.thresholds[i], i + 2, now],
      );
    }
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
