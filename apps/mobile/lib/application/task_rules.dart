part of 'family.dart';

class RepeatSchedule {
  const RepeatSchedule(
    this.from,
    this.until,
    this.count, {
    this.weekdays = const [1, 2, 3, 4, 5, 6, 7],
  });
  final String from;
  final String until;
  final int count;
  final List<int> weekdays;

  Json encode() => {
    'from': from,
    'until': until,
    'count': count,
    'weekdays': weekdays,
  };

  factory RepeatSchedule.decode(Json row) => RepeatSchedule(
    row['from'] as String,
    row['until'] as String,
    row['count'] as int,
    weekdays: (row['weekdays'] as List).cast<int>(),
  );

  void validate(int maxPerDay) {
    final start = parseDay(from);
    final end = parseDay(until);
    if (start.isAfter(end)) throw const UserError('结束日期应与开始日期相同或更晚。');
    if (count < 1 ||
        count > maxPerDay ||
        weekdays.isEmpty ||
        weekdays.any((day) => day < 1 || day > 7)) {
      throw const UserError('请选择有效星期和每天 1–5 次。');
    }
  }

  Iterable<String> days(String through, {String? starting}) sync* {
    final first = starting != null && starting.compareTo(from) > 0
        ? starting
        : from;
    final last = through.compareTo(until) < 0 ? through : until;
    for (
      var date = parseDay(first);
      dateKey(date).compareTo(last) <= 0;
      date = date.add(const Duration(days: 1))
    ) {
      if (weekdays.contains(date.weekday)) yield dateKey(date);
    }
  }
}

class StageDraft {
  const StageDraft(this.title, this.criteria, this.type);
  final String title;
  final String criteria;
  final String type;
  Json encode() => {'title': title, 'criteria': criteria, 'type': type};
}

extension TaskRules on FamilyService {
  Future<Json> publishRecurring(
    TaskDraft draft,
    RepeatSchedule schedule, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'repeat',
    [draft.encode(), schedule.encode()],
    commandId,
    (_, family) async {
      schedule.validate(rules.maxPerDay);
      final saved = await _saveVersion(
        draft,
        family,
        mode: 'recurring',
        schedule: schedule.encode(),
      );
      await _generateSchedule(saved.template, saved.version, schedule, today);
      return {'template_id': saved.template};
    },
    parentRequired: true,
    session: session,
  );

  Future<List<Json>> recurringTemplates() => db.rows('''
    SELECT t.id, t.paused, t.current_version, v.title, v.content, v.criteria, v.task_type, v.schedule_json
    FROM task_templates t JOIN task_versions v ON t.id = v.template_id AND t.current_version = v.version
    WHERE t.mode = 'recurring' ORDER BY t.rowid DESC
    ''');

  Future<Json> editRecurring(
    String template,
    int expectedVersion,
    TaskDraft draft,
    RepeatSchedule schedule, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'edit-repeat',
    [template, expectedVersion, draft.encode(), schedule.encode()],
    commandId,
    (_, family) async {
      final row = await db.row(
        "SELECT current_version, paused FROM task_templates WHERE id = ? AND mode = 'recurring'",
        [template],
      );
      if (row == null || row['current_version'] != expectedVersion) {
        throw const UserError('计划已变化，请重新打开后编辑。');
      }
      schedule.validate(rules.maxPerDay);
      // Earlier versions already generated slots through today. A changed plan starts tomorrow.
      final floor =
          await db.value('SELECT latest_local_day FROM households')
              as String? ??
          today;
      final changeFrom = dateKey(
        parseDay(floor.compareTo(today) > 0 ? floor : today)
            .add(const Duration(days: 1)),
      );
      final nextVersion = expectedVersion + 1;
      await _saveVersion(
        draft,
        family,
        mode: 'recurring',
        templateId: template,
        version: nextVersion,
        schedule: {...schedule.encode(), 'effective_from': changeFrom},
      );
      await db.customStatement(
        'UPDATE task_templates SET current_version = ? WHERE id = ?',
        [nextVersion, template],
      );
      return {'version': nextVersion, 'effective_from': changeFrom};
    },
    parentRequired: true,
    session: session,
  );

  Future<Json> pauseRecurring(
    String template,
    bool pause, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'pause-repeat',
    [template, pause],
    commandId,
    (_, family) async {
      final row = await db.row(
        '''
      SELECT t.*, v.schedule_json, v.title, v.criteria, v.content, v.task_type
      FROM task_templates t JOIN task_versions v ON v.template_id = t.id AND v.version = t.current_version
      WHERE t.id = ? AND t.mode = 'recurring'
      ''',
        [template],
      );
      if (row == null) throw const UserError('找不到这个重复计划。');
      final wasPaused = row['paused'] == 1;
      if (wasPaused == pause) return {'paused': pause};
      if (!pause) {
        final next = (row['current_version'] as int) + 1;
        final schedule = jsonDecode(row['schedule_json'] as String) as Json;
        final priorStart = schedule['effective_from'] as String?;
        final start = priorStart != null && priorStart.compareTo(today) > 0
            ? priorStart
            : today;
        await _saveVersion(
          TaskDraft(
            row['title'] as String,
            row['content'] as String,
            row['criteria'] as String,
            row['task_type'] as String,
          ),
          family,
          mode: 'recurring',
          templateId: template,
          version: next,
          schedule: {...schedule, 'effective_from': start},
        );
        await db.customStatement(
          'UPDATE task_templates SET current_version = ? WHERE id = ?',
          [next, template],
        );
      }
      await db.customStatement(
        'UPDATE task_templates SET paused = ? WHERE id = ?',
        [pause ? 1 : 0, template],
      );
      return {'paused': pause};
    },
    parentRequired: true,
    session: session,
  );

  Future<int> processCalendar() => serial.run(() async {
    if (frozen) return 0;
    return db.transaction(() async {
      final day = today;
      final change = await _processCalendar(day);
      if (change > 0) {
        await db.customStatement(
          '''
          UPDATE households SET domain_revision = domain_revision + 1,
            latest_local_day = MAX(COALESCE(latest_local_day, ?), ?)
          ''',
          [day, day],
        );
      }
      return change;
    });
  });

  Future<int> _processCalendar(String day) async {
    final templates = await db.rows('''
      SELECT t.id, v.id AS version_id, v.schedule_json FROM task_templates t
      JOIN task_versions v ON t.id = v.template_id AND t.current_version = v.version
      WHERE t.mode = 'recurring' AND t.paused = 0
      ''');
    var count = 0;
    for (final row in templates) {
      final config = jsonDecode(row['schedule_json'] as String) as Json;
      count += await _generateSchedule(
        row['id'] as String,
        row['version_id'] as String,
        RepeatSchedule.decode(config),
        day,
        starting: config['effective_from'] as String?,
      );
    }
    final expired = await db.rows(
      '''
      UPDATE task_instances SET state = 'EXPIRED'
      WHERE state IN ('OPEN', 'RETURNED') AND due_day < ? RETURNING id
      ''',
      [day],
    );
    return count + expired.length;
  }

  Future<int> _generateSchedule(
    String template,
    String version,
    RepeatSchedule schedule,
    String through, {
    String? starting,
  }) async {
    final latest = await db.value(
      'SELECT MAX(planned_day) FROM task_instances WHERE template_id = ?',
      [template],
    ) as String?;
    if (latest != null) {
      final next = dateKey(parseDay(latest).add(const Duration(days: 1)));
      if (starting == null || next.compareTo(starting) > 0) starting = next;
    }
    var created = 0;
    for (final day in schedule.days(through, starting: starting)) {
      for (var slot = 1; slot <= schedule.count; slot++) {
        final key = 'repeat:$template:$day:$slot';
        await _addInstance(
          uuid.v4(),
          key,
          template,
          version,
          day,
          slot: slot,
          due: day,
          state: day == through ? 'OPEN' : 'EXPIRED',
        );
        created++;
      }
    }
    return created;
  }

  Future<Json> publishProject(
    TaskDraft draft,
    List<StageDraft> stages, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'project',
    [draft.encode(), stages.map((stage) => stage.encode()).toList()],
    commandId,
    (_, family) async {
      if (stages.length < 2) throw const UserError('分阶段小事至少需要两个阶段。');
      final criteria = stages.map((stage) => stage.criteria.trim()).toSet();
      if (criteria.length != stages.length) {
        throw const UserError('每个阶段要填写各自的完成标准。');
      }
      final saved = await _saveVersion(draft, family, mode: 'staged');
      for (final (index, stage) in stages.indexed) {
        final id = uuid.v4();
        final kind = rules.type(stage.type);
        await db.insertRow('project_stages', {
          'id': id,
          'version_id': saved.version,
          'sequence': index + 1,
          'title': textValue(stage.title, 40, requiredLabel: '阶段名称'),
          'criteria': textValue(stage.criteria, 300, requiredLabel: '阶段完成标准'),
          'task_type': kind.id,
          'reward': kind.points,
        });
        await _addInstance(
          uuid.v4(),
          'stage:${saved.template}:$id',
          saved.template,
          saved.version,
          today,
          slot: index + 1,
          stageId: id,
          state: index == 0 ? 'OPEN' : 'WAITING',
          due: draft.due,
        );
      }
      return {
        'template_id': saved.template,
        'points': stages.fold<int>(
          0,
          (sum, stage) => sum + rules.type(stage.type).points,
        ),
      };
    },
    parentRequired: true,
    session: session,
  );

  Future<Json> returnTask(
    String instance,
    String reason, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'return',
    [instance, reason],
    commandId,
    (_, _) async {
      final entry = await task(instance);
      if (entry.state != 'SUBMITTED') throw const UserError('只有已申报的小事可以退回。');
      await db.customStatement(
        '''
      UPDATE task_instances SET state = 'RETURNED', resolution_note = ?
      WHERE id = ?
      ''',
        [textValue(reason, 500), instance],
      );
      return {'instance_id': instance};
    },
    parentRequired: true,
    session: session,
  );

  Future<Json> reopen(
    String instance,
    String? due, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'reopen',
    [instance, due],
    commandId,
    (_, _) async {
      final entry = await task(instance);
      if (entry.state != 'EXPIRED') throw const UserError('只能重开已到期的小事。');
      if (due != null) {
        parseDay(due);
        if (due.compareTo(today) < 0) throw const UserError('新的截止日期不能早于今天。');
      }
      await db.customStatement(
        "UPDATE task_instances SET state = 'OPEN', due_day = ? WHERE id = ?",
        [due, instance],
      );
      return {'instance_id': instance};
    },
    parentRequired: true,
    session: session,
  );

  Future<Json> cancel(
    String instance, {
    ParentSession? session,
    String? commandId,
  }) => _command(
    'cancel',
    instance,
    commandId,
    (_, _) async {
      final entry = await task(instance);
      if (entry.state == 'CANCELLED') return {'instance_id': instance};
      if (!['OPEN', 'RETURNED', 'EXPIRED', 'WAITING'].contains(entry.state)) {
        throw const UserError('请先处理已申报或已确认的小事。');
      }
      await db.customStatement(
        "UPDATE task_instances SET state = 'CANCELLED' WHERE id = ?",
        [instance],
      );
      return {'instance_id': instance};
    },
    parentRequired: true,
    session: session,
  );

  Future<Json> backfill(
    TaskDraft draft,
    String actual,
    String feedback, {
    String? correcting,
    ParentSession? session,
    String? commandId,
  }) => _command(
    'backfill',
    [draft.encode(), actual, feedback, correcting],
    commandId,
    (id, family) async {
      _validateActualDate(actual);
      if (correcting != null && (await task(correcting)).state != 'CORRECTED') {
        throw const UserError('请先完成原成果的更正。');
      }
      final saved = await _saveVersion(draft, family, mode: 'once');
      final instance = uuid.v4();
      await _addInstance(
        instance,
        instance,
        saved.template,
        saved.version,
        actual,
        state: 'SUBMITTED',
        prior: correcting,
      );
      return {
        ...await _approveInTransaction(id, family, instance, actual, feedback),
        'instance_id': instance,
      };
    },
    parentRequired: true,
    session: session,
  );
}

RepeatSchedule repeatConfig(String source) =>
    RepeatSchedule.decode(jsonDecode(source) as Json);
