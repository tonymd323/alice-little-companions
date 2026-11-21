import 'dart:convert';

import 'companion_food.dart';
import 'companions.dart';
import 'pin.dart';

typedef Json = Map<String, Object?>;
typedef FoodOffer = ({int price, int affinity});

class TaskType {
  const TaskType(this.id, this.label, this.points);
  final String id;
  final String label;
  final int points;
}

class Rules {
  Rules.fromJson(Json rules, Json catalog, Json scenes)
    : version = rules['rules_version'] as String,
      timezone = rules['family_timezone'] as String,
      types = (rules['task_types'] as List)
          .cast<Json>()
          .map(
            (v) => TaskType(
              v['id'] as String,
              v['name'] as String,
              v['points'] as int,
            ),
          )
          .toList(growable: false),
      thresholds = ((rules['growth'] as Json)['thresholds'] as List)
          .cast<int>(),
      pinIterations =
          (rules['parent_access'] as Json)['pin_pbkdf2_iterations'] as int,
      weeklyReference = rules['weekly_pricing_reference'] as int,
      companionUnlockPrice =
          (rules['companions'] as Json)['unlock_price'] as int,
      foodOffers = Map.unmodifiable({
        for (final food in CompanionFood.values)
          food: _foodOffer(
            ((rules['companions'] as Json)['food'] as Json)[food.name] as Json,
          ),
      }),
      maxPerDay = rules['max_instances_per_day_per_template'] as int,
      penaltyCap = (rules['penalty'] as Json)['daily_actual_cap'] as int,
      catalogVersion = catalog['catalog_version'] as String,
      catalog = {
        for (final v in (catalog['items'] as List).cast<Json>())
          v['id'] as String: v,
      },
      scenes = {
        for (final v in (scenes['scenes'] as List).cast<Json>())
          v['id'] as String: v,
      },
      wearAnchors = scenes['demo_wear_anchors'] as Json;

  factory Rules.decode(String rules, String catalog, String scenes) =>
      Rules.fromJson(
        jsonDecode(rules) as Json,
        jsonDecode(catalog) as Json,
        jsonDecode(scenes) as Json,
      );

  final String version;
  final String timezone;
  final List<TaskType> types;
  final List<int> thresholds;
  final int pinIterations;
  final int weeklyReference;
  final int companionUnlockPrice;
  final Map<CompanionFood, FoodOffer> foodOffers;
  final int maxPerDay;
  final int penaltyCap;
  final String catalogVersion;
  final Map<String, Json> catalog;
  final Map<String, Json> scenes;
  final Json wearAnchors;

  int earnedStage(int experience) =>
      1 + thresholds.takeWhile((threshold) => experience >= threshold).length;

  TaskType type(String id) => types.firstWhere(
    (value) => value.id == id,
    orElse: () => throw const UserError('请选择一种投入类型。'),
  );

  Companion companion(String id) => Companion.values.byName(id);
}

FoodOffer _foodOffer(Json row) =>
    (price: row['price'] as int, affinity: row['affinity'] as int);

String dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

String familyDay(DateTime instant) =>
    dateKey(instant.toUtc().add(const Duration(hours: 8)));

DateTime parseDay(String input) {
  final date = DateTime.tryParse('${input}T00:00:00Z');
  if (date == null ||
      dateKey(date) != input ||
      date.year < 1 ||
      date.year > 9999) {
    throw const UserError('请选择有效日期。');
  }
  return date;
}

String textValue(String value, int limit, {String? requiredLabel}) {
  final text = value.trim();
  if (text.isEmpty && requiredLabel != null) {
    throw UserError('请填写$requiredLabel。');
  }
  if (text.runes.length > limit) throw UserError('文字最多 $limit 字。');
  return text;
}
