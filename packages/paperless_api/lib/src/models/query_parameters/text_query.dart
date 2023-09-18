import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:paperless_api/config/hive/hive_type_ids.dart';

import 'query_type.dart';

part 'text_query.g.dart';

//TODO: Realize with freezed...
@HiveType(typeId: PaperlessApiHiveTypeIds.textQuery)
@JsonSerializable()
class TextQuery {
  @HiveField(0)
  final QueryType queryType;
  @HiveField(1)
  final String? queryText;

  const TextQuery({
    this.queryType = QueryType.titleAndContent,
    this.queryText,
  });

  const TextQuery.title(this.queryText) : queryType = QueryType.title;

  const TextQuery.titleAndContent(this.queryText)
      : queryType = QueryType.titleAndContent;

  const TextQuery.extended(this.queryText) : queryType = QueryType.extended;

  TextQuery copyWith({QueryType? queryType, String? queryText}) {
    return TextQuery(
      queryType: queryType ?? this.queryType,
      queryText: queryText ?? this.queryText,
    );
  }

  Map<String, String> toQueryParameter() {
    final params = <String, String>{};
    if (queryText != null && queryText!.isNotEmpty) {
      params.addAll({queryType.queryParam: queryText!});
    }
    return params;
  }

  String? get titleOnlyMatchString {
    if (queryType == QueryType.title) {
      return queryText?.isEmpty ?? true ? null : queryText;
    }
    return null;
  }

  String? get titleAndContentMatchString {
    if (queryType == QueryType.titleAndContent) {
      return queryText?.isEmpty ?? true ? null : queryText;
    }
    return null;
  }

  String? get extendedMatchString {
    if (queryType == QueryType.extended) {
      return queryText?.isEmpty ?? true ? null : queryText;
    }
    return null;
  }

  bool matches({
    required String title,
    String? content,
    int? asn,
  }) {
    if (queryText?.isEmpty ?? true) return true;
    switch (queryType) {
      case QueryType.title:
        return title.contains(queryText!);
      case QueryType.titleAndContent:
        return title.contains(queryText!) ||
            (content?.contains(queryText!) ?? false);
      case QueryType.extended:
        //TODO: Implement. Might be too complex...
        return true;
      case QueryType.asn:
        return int.tryParse(queryText!) == asn;
    }
  }

  Map<String, dynamic> toJson() => _$TextQueryToJson(this);

  factory TextQuery.fromJson(Map<String, dynamic> json) =>
      _$TextQueryFromJson(json);

  @override
  bool operator ==(Object? other) {
    if (identical(this, other)) return true;
    if (other is! TextQuery) return false;
    if (queryText == null && other.queryText == null) {
      return true;
    }
    return other.queryText == queryText && other.queryType == queryType;
  }

  @override
  int get hashCode => Object.hash(queryText, queryType);
}
