import 'package:hive/hive.dart';
import 'package:jiffy/jiffy.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:paperless_api/config/hive/hive_type_ids.dart';

import 'date_range_query.dart';
import 'date_range_query_field.dart';
import 'date_range_unit.dart';
part 'relative_date_range_query.g.dart';

@JsonSerializable()
@HiveType(typeId: PaperlessApiHiveTypeIds.relativeDateRangeQuery)
class RelativeDateRangeQuery extends DateRangeQuery {
  @HiveField(0)
  final int offset;
  @HiveField(1)
  final DateRangeUnit unit;

  const RelativeDateRangeQuery([
    this.offset = 1,
    this.unit = DateRangeUnit.day,
  ]);

  @override
  List<Object?> get props => [offset, unit];

  @override
  Map<String, String> toQueryParameter(DateRangeQueryField field) {
    return {
      'query': '${field.name}:[-$offset ${unit.name} to now]',
    };
  }

  RelativeDateRangeQuery copyWith({
    int? offset,
    DateRangeUnit? unit,
  }) {
    return RelativeDateRangeQuery(
      offset ?? this.offset,
      unit ?? this.unit,
    );
  }

  /// Returns the datetime when subtracting the offset given the unit from now.
  DateTime get dateTime {
    switch (unit) {
      case DateRangeUnit.day:
        return Jiffy().subtract(days: offset).dateTime;
      case DateRangeUnit.week:
        return Jiffy().subtract(weeks: offset).dateTime;
      case DateRangeUnit.month:
        return Jiffy().subtract(months: offset).dateTime;
      case DateRangeUnit.year:
        return Jiffy().subtract(years: offset).dateTime;
    }
  }

  @override
  Map<String, dynamic> toJson() => _$RelativeDateRangeQueryToJson(this);

  factory RelativeDateRangeQuery.fromJson(Map<String, dynamic> json) =>
      _$RelativeDateRangeQueryFromJson(json);

  @override
  bool matches(DateTime dt) {
    return dt.isAfter(dateTime) || dt == dateTime;
  }
}
