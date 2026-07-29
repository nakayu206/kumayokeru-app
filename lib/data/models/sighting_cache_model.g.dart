// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sighting_cache_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSightingCacheModelCollection on Isar {
  IsarCollection<SightingCacheModel> get sightingCacheModels =>
      this.collection();
}

const SightingCacheModelSchema = CollectionSchema(
  name: r'SightingCacheModel',
  id: 5321850004326664363,
  properties: {
    r'areaName': PropertySchema(
      id: 0,
      name: r'areaName',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'lat': PropertySchema(
      id: 2,
      name: r'lat',
      type: IsarType.double,
    ),
    r'lng': PropertySchema(
      id: 3,
      name: r'lng',
      type: IsarType.double,
    ),
    r'sightedAt': PropertySchema(
      id: 4,
      name: r'sightedAt',
      type: IsarType.dateTime,
    ),
    r'sightingId': PropertySchema(
      id: 5,
      name: r'sightingId',
      type: IsarType.string,
    ),
    r'sourceType': PropertySchema(
      id: 6,
      name: r'sourceType',
      type: IsarType.byte,
      enumMap: _SightingCacheModelsourceTypeEnumValueMap,
    )
  },
  estimateSize: _sightingCacheModelEstimateSize,
  serialize: _sightingCacheModelSerialize,
  deserialize: _sightingCacheModelDeserialize,
  deserializeProp: _sightingCacheModelDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _sightingCacheModelGetId,
  getLinks: _sightingCacheModelGetLinks,
  attach: _sightingCacheModelAttach,
  version: '3.1.0+1',
);

int _sightingCacheModelEstimateSize(
  SightingCacheModel object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.areaName.length * 3;
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.sightingId.length * 3;
  return bytesCount;
}

void _sightingCacheModelSerialize(
  SightingCacheModel object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.areaName);
  writer.writeString(offsets[1], object.description);
  writer.writeDouble(offsets[2], object.lat);
  writer.writeDouble(offsets[3], object.lng);
  writer.writeDateTime(offsets[4], object.sightedAt);
  writer.writeString(offsets[5], object.sightingId);
  writer.writeByte(offsets[6], object.sourceType.index);
}

SightingCacheModel _sightingCacheModelDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SightingCacheModel();
  object.areaName = reader.readString(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.id = id;
  object.lat = reader.readDouble(offsets[2]);
  object.lng = reader.readDouble(offsets[3]);
  object.sightedAt = reader.readDateTime(offsets[4]);
  object.sightingId = reader.readString(offsets[5]);
  object.sourceType = _SightingCacheModelsourceTypeValueEnumMap[
          reader.readByteOrNull(offsets[6])] ??
      SightingSourceType.official;
  return object;
}

P _sightingCacheModelDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (_SightingCacheModelsourceTypeValueEnumMap[
              reader.readByteOrNull(offset)] ??
          SightingSourceType.official) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _SightingCacheModelsourceTypeEnumValueMap = {
  'official': 0,
  'user': 1,
};
const _SightingCacheModelsourceTypeValueEnumMap = {
  0: SightingSourceType.official,
  1: SightingSourceType.user,
};

Id _sightingCacheModelGetId(SightingCacheModel object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _sightingCacheModelGetLinks(
    SightingCacheModel object) {
  return [];
}

void _sightingCacheModelAttach(
    IsarCollection<dynamic> col, Id id, SightingCacheModel object) {
  object.id = id;
}

extension SightingCacheModelQueryWhereSort
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QWhere> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SightingCacheModelQueryWhere
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QWhereClause> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterWhereClause>
      idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SightingCacheModelQueryFilter
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QFilterCondition> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'areaName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'areaName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'areaName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaName',
        value: '',
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      areaNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'areaName',
        value: '',
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      latEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      latGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      latLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      latBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      lngEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      lngGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      lngLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      lngBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lng',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sightedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sightedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sightedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sightedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sightingId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sightingId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sightingId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sightingId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sightingId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sightingId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sightingId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sightingId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sightingId',
        value: '',
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sightingIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sightingId',
        value: '',
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sourceTypeEqualTo(SightingSourceType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceType',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sourceTypeGreaterThan(
    SightingSourceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceType',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sourceTypeLessThan(
    SightingSourceType value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceType',
        value: value,
      ));
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterFilterCondition>
      sourceTypeBetween(
    SightingSourceType lower,
    SightingSourceType upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SightingCacheModelQueryObject
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QFilterCondition> {}

extension SightingCacheModelQueryLinks
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QFilterCondition> {}

extension SightingCacheModelQuerySortBy
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QSortBy> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByAreaName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByAreaNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortBySightedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightedAt', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortBySightedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightedAt', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortBySightingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightingId', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortBySightingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightingId', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      sortBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }
}

extension SightingCacheModelQuerySortThenBy
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QSortThenBy> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByAreaName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByAreaNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'areaName', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenBySightedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightedAt', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenBySightedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightedAt', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenBySightingId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightingId', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenBySightingIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sightingId', Sort.desc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.asc);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QAfterSortBy>
      thenBySourceTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceType', Sort.desc);
    });
  }
}

extension SightingCacheModelQueryWhereDistinct
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct> {
  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctByAreaName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'areaName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctByDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lat');
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lng');
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctBySightedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sightedAt');
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctBySightingId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sightingId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SightingCacheModel, SightingCacheModel, QDistinct>
      distinctBySourceType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceType');
    });
  }
}

extension SightingCacheModelQueryProperty
    on QueryBuilder<SightingCacheModel, SightingCacheModel, QQueryProperty> {
  QueryBuilder<SightingCacheModel, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SightingCacheModel, String, QQueryOperations>
      areaNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'areaName');
    });
  }

  QueryBuilder<SightingCacheModel, String, QQueryOperations>
      descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<SightingCacheModel, double, QQueryOperations> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lat');
    });
  }

  QueryBuilder<SightingCacheModel, double, QQueryOperations> lngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lng');
    });
  }

  QueryBuilder<SightingCacheModel, DateTime, QQueryOperations>
      sightedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sightedAt');
    });
  }

  QueryBuilder<SightingCacheModel, String, QQueryOperations>
      sightingIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sightingId');
    });
  }

  QueryBuilder<SightingCacheModel, SightingSourceType, QQueryOperations>
      sourceTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceType');
    });
  }
}
