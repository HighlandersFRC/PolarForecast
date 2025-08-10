// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_rank.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

GlobalRank _$GlobalRankFromJson(Map<String, dynamic> json) {
  return _GlobalRank.fromJson(json);
}

/// @nodoc
mixin _$GlobalRank {
  String get team => throw _privateConstructorUsedError;
  DateTime get eventDate => throw _privateConstructorUsedError;
  String get event => throw _privateConstructorUsedError;
  List<String> get all_events => throw _privateConstructorUsedError;
  TeamStats2025 get data => throw _privateConstructorUsedError;

  /// Serializes this GlobalRank to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GlobalRank
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GlobalRankCopyWith<GlobalRank> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GlobalRankCopyWith<$Res> {
  factory $GlobalRankCopyWith(
          GlobalRank value, $Res Function(GlobalRank) then) =
      _$GlobalRankCopyWithImpl<$Res, GlobalRank>;
  @useResult
  $Res call(
      {String team,
      DateTime eventDate,
      String event,
      List<String> all_events,
      TeamStats2025 data});

  $TeamStats2025CopyWith<$Res> get data;
}

/// @nodoc
class _$GlobalRankCopyWithImpl<$Res, $Val extends GlobalRank>
    implements $GlobalRankCopyWith<$Res> {
  _$GlobalRankCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GlobalRank
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? team = null,
    Object? eventDate = null,
    Object? event = null,
    Object? all_events = null,
    Object? data = null,
  }) {
    return _then(_value.copyWith(
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      event: null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as String,
      all_events: null == all_events
          ? _value.all_events
          : all_events // ignore: cast_nullable_to_non_nullable
              as List<String>,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as TeamStats2025,
    ) as $Val);
  }

  /// Create a copy of GlobalRank
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TeamStats2025CopyWith<$Res> get data {
    return $TeamStats2025CopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GlobalRankImplCopyWith<$Res>
    implements $GlobalRankCopyWith<$Res> {
  factory _$$GlobalRankImplCopyWith(
          _$GlobalRankImpl value, $Res Function(_$GlobalRankImpl) then) =
      __$$GlobalRankImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String team,
      DateTime eventDate,
      String event,
      List<String> all_events,
      TeamStats2025 data});

  @override
  $TeamStats2025CopyWith<$Res> get data;
}

/// @nodoc
class __$$GlobalRankImplCopyWithImpl<$Res>
    extends _$GlobalRankCopyWithImpl<$Res, _$GlobalRankImpl>
    implements _$$GlobalRankImplCopyWith<$Res> {
  __$$GlobalRankImplCopyWithImpl(
      _$GlobalRankImpl _value, $Res Function(_$GlobalRankImpl) _then)
      : super(_value, _then);

  /// Create a copy of GlobalRank
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? team = null,
    Object? eventDate = null,
    Object? event = null,
    Object? all_events = null,
    Object? data = null,
  }) {
    return _then(_$GlobalRankImpl(
      team: null == team
          ? _value.team
          : team // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: null == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      event: null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as String,
      all_events: null == all_events
          ? _value._all_events
          : all_events // ignore: cast_nullable_to_non_nullable
              as List<String>,
      data: null == data
          ? _value.data
          : data // ignore: cast_nullable_to_non_nullable
              as TeamStats2025,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GlobalRankImpl implements _GlobalRank {
  const _$GlobalRankImpl(
      {required this.team,
      required this.eventDate,
      required this.event,
      final List<String> all_events = const [],
      required this.data})
      : _all_events = all_events;

  factory _$GlobalRankImpl.fromJson(Map<String, dynamic> json) =>
      _$$GlobalRankImplFromJson(json);

  @override
  final String team;
  @override
  final DateTime eventDate;
  @override
  final String event;
  final List<String> _all_events;
  @override
  @JsonKey()
  List<String> get all_events {
    if (_all_events is EqualUnmodifiableListView) return _all_events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_all_events);
  }

  @override
  final TeamStats2025 data;

  @override
  String toString() {
    return 'GlobalRank(team: $team, eventDate: $eventDate, event: $event, all_events: $all_events, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GlobalRankImpl &&
            (identical(other.team, team) || other.team == team) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.event, event) || other.event == event) &&
            const DeepCollectionEquality()
                .equals(other._all_events, _all_events) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, team, eventDate, event,
      const DeepCollectionEquality().hash(_all_events), data);

  /// Create a copy of GlobalRank
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GlobalRankImplCopyWith<_$GlobalRankImpl> get copyWith =>
      __$$GlobalRankImplCopyWithImpl<_$GlobalRankImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GlobalRankImplToJson(
      this,
    );
  }
}

abstract class _GlobalRank implements GlobalRank {
  const factory _GlobalRank(
      {required final String team,
      required final DateTime eventDate,
      required final String event,
      final List<String> all_events,
      required final TeamStats2025 data}) = _$GlobalRankImpl;

  factory _GlobalRank.fromJson(Map<String, dynamic> json) =
      _$GlobalRankImpl.fromJson;

  @override
  String get team;
  @override
  DateTime get eventDate;
  @override
  String get event;
  @override
  List<String> get all_events;
  @override
  TeamStats2025 get data;

  /// Create a copy of GlobalRank
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GlobalRankImplCopyWith<_$GlobalRankImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
