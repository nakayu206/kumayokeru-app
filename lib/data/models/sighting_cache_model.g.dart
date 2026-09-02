// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sighting_cache_model.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSightingCacheModelCollection on Isar {
  IsarCollection<String, SightingCacheModel> get sightingCacheModels =>
      this.collection();
}

final SightingCacheModelSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'SightingCacheModel',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'id', type: IsarType.string),
      IsarPropertySchema(name: 'sightingId', type: IsarType.string),
      IsarPropertySchema(name: 'lat', type: IsarType.double),
      IsarPropertySchema(name: 'lng', type: IsarType.double),
      IsarPropertySchema(name: 'sightedAt', type: IsarType.dateTime),
      IsarPropertySchema(name: 'description', type: IsarType.string),
      IsarPropertySchema(name: 'areaName', type: IsarType.string),
      IsarPropertySchema(
        name: 'sourceType',
        type: IsarType.byte,

        enumMap: {"official": 0, "user": 1},
      ),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<String, SightingCacheModel>(
    serialize: serializeSightingCacheModel,
    deserialize: deserializeSightingCacheModel,
    deserializeProperty: deserializeSightingCacheModelProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeSightingCacheModel(IsarWriter writer, SightingCacheModel object) {
  IsarCore.writeString(writer, 1, object.id);
  IsarCore.writeString(writer, 2, object.sightingId);
  IsarCore.writeDouble(writer, 3, object.lat);
  IsarCore.writeDouble(writer, 4, object.lng);
  IsarCore.writeLong(
    writer,
    5,
    object.sightedAt.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeString(writer, 6, object.description);
  IsarCore.writeString(writer, 7, object.areaName);
  IsarCore.writeByte(writer, 8, object.sourceType.index);
  return Isar.fastHash(object.id);
}

@isarProtected
SightingCacheModel deserializeSightingCacheModel(IsarReader reader) {
  final object = SightingCacheModel();
  object.sightingId = IsarCore.readString(reader, 2) ?? '';
  object.lat = IsarCore.readDouble(reader, 3);
  object.lng = IsarCore.readDouble(reader, 4);
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      object.sightedAt = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      object.sightedAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  object.description = IsarCore.readString(reader, 6) ?? '';
  object.areaName = IsarCore.readString(reader, 7) ?? '';
  {
    if (IsarCore.readNull(reader, 8)) {
      object.sourceType = SightingSourceType.official;
    } else {
      object.sourceType =
          _sightingCacheModelSourceType[IsarCore.readByte(reader, 8)] ??
          SightingSourceType.official;
    }
  }
  return object;
}

@isarProtected
dynamic deserializeSightingCacheModelProp(IsarReader reader, int property) {
  switch (property) {
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      return IsarCore.readDouble(reader, 3);
    case 4:
      return IsarCore.readDouble(reader, 4);
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    case 7:
      return IsarCore.readString(reader, 7) ?? '';
    case 8:
      {
        if (IsarCore.readNull(reader, 8)) {
          return SightingSourceType.official;
        } else {
          return _sightingCacheModelSourceType[IsarCore.readByte(reader, 8)] ??
              SightingSourceType.official;
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _SightingCacheModelUpdate {
  bool call({
    required String id,
    String? sightingId,
    double? lat,
    double? lng,
    DateTime? sightedAt,
    String? description,
    String? areaName,
    SightingSourceType? sourceType,
  });
}

class _SightingCacheModelUpdateImpl implements _SightingCacheModelUpdate {
  const _SightingCacheModelUpdateImpl(this.collection);

  final IsarCollection<String, SightingCacheModel> collection;

  @override
  bool call({
    required String id,
    Object? sightingId = ignore,
    Object? lat = ignore,
    Object? lng = ignore,
    Object? sightedAt = ignore,
    Object? description = ignore,
    Object? areaName = ignore,
    Object? sourceType = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (sightingId != ignore) 2: sightingId as String?,
            if (lat != ignore) 3: lat as double?,
            if (lng != ignore) 4: lng as double?,
            if (sightedAt != ignore) 5: sightedAt as DateTime?,
            if (description != ignore) 6: description as String?,
            if (areaName != ignore) 7: areaName as String?,
            if (sourceType != ignore) 8: sourceType as SightingSourceType?,
          },
        ) >
        0;
  }
}

sealed class _SightingCacheModelUpdateAll {
  int call({
    required List<String> id,
    String? sightingId,
    double? lat,
    double? lng,
    DateTime? sightedAt,
    String? description,
    String? areaName,
    SightingSourceType? sourceType,
  });
}

class _SightingCacheModelUpdateAllImpl implements _SightingCacheModelUpdateAll {
  const _SightingCacheModelUpdateAllImpl(this.collection);

  final IsarCollection<String, SightingCacheModel> collection;

  @override
  int call({
    required List<String> id,
    Object? sightingId = ignore,
    Object? lat = ignore,
    Object? lng = ignore,
    Object? sightedAt = ignore,
    Object? description = ignore,
    Object? areaName = ignore,
    Object? sourceType = ignore,
  }) {
    return collection.updateProperties(id, {
      if (sightingId != ignore) 2: sightingId as String?,
      if (lat != ignore) 3: lat as double?,
      if (lng != ignore) 4: lng as double?,
      if (sightedAt != ignore) 5: sightedAt as DateTime?,
      if (description != ignore) 6: description as String?,
      if (areaName != ignore) 7: areaName as String?,
      if (sourceType != ignore) 8: sourceType as SightingSourceType?,
    });
  }
}

extension SightingCacheModelUpdate
    on IsarCollection<String, SightingCacheModel> {
  _SightingCacheModelUpdate get update => _SightingCacheModelUpdateImpl(this);

  _SightingCacheModelUpdateAll get updateAll =>
      _SightingCacheModelUpdateAllImpl(this);
}

sealed class _SightingCacheModelQueryUpdate {
  int call({
    String? sightingId,
    double? lat,
    double? lng,
    DateTime? sightedAt,
    String? description,
    String? areaName,
    SightingSourceType? sourceType,
  });
}

class _SightingCacheModelQueryUpdateImpl
    implements _SightingCacheModelQueryUpdate {
  const _SightingCacheModelQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<SightingCacheModel> query;
  final int? limit;

  @override
  int call({
    Object? sightingId = ignore,
    Object? lat = ignore,
    Object? lng = ignore,
    Object? sightedAt = ignore,
    Object? description = ignore,
    Object? areaName = ignore,
    Object? sourceType = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (sightingId != ignore) 2: sightingId as String?,
      if (lat != ignore) 3: lat as double?,
      if (lng != ignore) 4: lng as double?,
      if (sightedAt != ignore) 5: sightedAt as DateTime?,
      if (description != ignore) 6: description as String?,
      if (areaName != ignore) 7: areaName as String?,
      if (sourceType != ignore) 8: sourceType as SightingSourceType?,
    });
  }
}

extension SightingCacheModelQueryUpdate on IsarQuery<SightingCacheModel> {
  _SightingCacheModelQueryUpdate get updateFirst =>
      _SightingCacheModelQueryUpdateImpl(this, limit: 1);

  _SightingCacheModelQueryUpdate get updateAll =>
      _SightingCacheModelQueryUpdateImpl(this);
}

class _SightingCacheModelQueryBuilderUpdateImpl
    implements _SightingCacheModelQueryUpdate {
  const _SightingCacheModelQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<SightingCacheModel, SightingCacheModel, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? sightingId = ignore,
    Object? lat = ignore,
    Object? lng = ignore,
    Object? sightedAt = ignore,
    Object? description = ignore,
    Object? areaName = ignore,
    Object? sourceType = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (sightingId != ignore) 2: sightingId as String?,
        if (lat != ignore) 3: lat as double?,
        if (lng != ignore) 4: lng as double?,
        if (sightedAt != ignore) 5: sightedAt as DateTime?,
        if (description != ignore) 6: description as String?,
        if (areaName != ignore) 7: areaName as String?,
        if (sourceType != ignore) 8: sourceType as SightingSourceType?,
      });
    } finally {
      q.close();
    }
  }
}

extension SightingCacheModelQueryBuilderUpdate
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QOperations> {
  _SightingCacheModelQueryUpdate get updateFirst =>
      _SightingCacheModelQueryBuilderUpdateImpl(this, limit: 1);

  _SightingCacheModelQueryUpdate get updateAll =>
      _SightingCacheModelQueryBuilderUpdateImpl(this);
}

const _sightingCacheModelSourceType = {
  0: SightingSourceType.official,
  1: SightingSourceType.user,
};

extension SightingCacheModelQueryFilter
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QFilterCondition> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  idIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightingIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  latEqualTo(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  latGreaterThan(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  latGreaterThanOrEqualTo(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  latLessThan(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  latLessThanOrEqualTo(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  latBetween(double lower, double upper, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 3,
          lower: lower,
          upper: upper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  lngEqualTo(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  lngGreaterThan(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  lngGreaterThanOrEqualTo(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  lngLessThan(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  lngLessThanOrEqualTo(double value, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value, epsilon: epsilon),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  lngBetween(double lower, double upper, {double epsilon = Filter.epsilon}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 4,
          lower: lower,
          upper: upper,

          epsilon: epsilon,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightedAtGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightedAtGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightedAtLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightedAtLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sightedAtBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 7, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 7,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 7,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 7,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  areaNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 7, value: ''),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sourceTypeEqualTo(SightingSourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value.index),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sourceTypeGreaterThan(SightingSourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 8, value: value.index),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sourceTypeGreaterThanOrEqualTo(SightingSourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 8, value: value.index),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sourceTypeLessThan(SightingSourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 8, value: value.index),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sourceTypeLessThanOrEqualTo(SightingSourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 8, value: value.index),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
  sourceTypeBetween(SightingSourceType lower, SightingSourceType upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 8, lower: lower.index, upper: upper.index),
      );
    });
  }
}

extension SightingCacheModelQueryObject
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QFilterCondition> {}

extension SightingCacheModelQuerySortBy
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QSortBy> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy> sortById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortBySightingId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortBySightingIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortBySightedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortBySightedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByAreaName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortByAreaNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension SightingCacheModelQuerySortThenBy
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QSortThenBy> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy> thenById({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenBySightingId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenBySightingIdDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenBySightedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenBySightedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByDescriptionDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByAreaName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenByAreaNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
  thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension SightingCacheModelQueryWhereDistinct
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctBySightingId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctBySightedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctByAreaName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterDistinct>
  distinctBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension SightingCacheModelQueryProperty1
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QProperty> {
  QueryBuilder<SightingCacheModel, String, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SightingCacheModel, String, QAfterProperty>
  sightingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SightingCacheModel, double, QAfterProperty> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SightingCacheModel, double, QAfterProperty> lngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SightingCacheModel, DateTime, QAfterProperty>
  sightedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SightingCacheModel, String, QAfterProperty>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SightingCacheModel, String, QAfterProperty> areaNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SightingCacheModel, SightingSourceType, QAfterProperty>
  sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension SightingCacheModelQueryProperty2<R>
    on QueryBuilder<SightingCacheModel, R, QAfterProperty> {
  QueryBuilder<SightingCacheModel, (R, String), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SightingCacheModel, (R, String), QAfterProperty>
  sightingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SightingCacheModel, (R, double), QAfterProperty> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SightingCacheModel, (R, double), QAfterProperty> lngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SightingCacheModel, (R, DateTime), QAfterProperty>
  sightedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SightingCacheModel, (R, String), QAfterProperty>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SightingCacheModel, (R, String), QAfterProperty>
  areaNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SightingCacheModel, (R, SightingSourceType), QAfterProperty>
  sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension SightingCacheModelQueryProperty3<R1, R2>
    on QueryBuilder<SightingCacheModel, (R1, R2), QAfterProperty> {
  QueryBuilder<SightingCacheModel, (R1, R2, String), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, String), QOperations>
  sightingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, double), QOperations>
  latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, double), QOperations>
  lngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, DateTime), QOperations>
  sightedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, String), QOperations>
  descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, String), QOperations>
  areaNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<SightingCacheModel, (R1, R2, SightingSourceType), QOperations>
  sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
