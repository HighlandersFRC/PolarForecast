// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  String get name => throw _privateConstructorUsedError;
  List<String> get surrogate_team_keys => throw _privateConstructorUsedError;
  List<String> get team_keys => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;

  /// Serializes this Group to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupCopyWith<Group> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupCopyWith<$Res> {
  factory $GroupCopyWith(Group value, $Res Function(Group) then) =
      _$GroupCopyWithImpl<$Res, Group>;
  @useResult
  $Res call(
      {String name,
      List<String> surrogate_team_keys,
      List<String> team_keys,
      int score});
}

/// @nodoc
class _$GroupCopyWithImpl<$Res, $Val extends Group>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? surrogate_team_keys = null,
    Object? team_keys = null,
    Object? score = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      surrogate_team_keys: null == surrogate_team_keys
          ? _value.surrogate_team_keys
          : surrogate_team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      team_keys: null == team_keys
          ? _value.team_keys
          : team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupImplCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$$GroupImplCopyWith(
          _$GroupImpl value, $Res Function(_$GroupImpl) then) =
      __$$GroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      List<String> surrogate_team_keys,
      List<String> team_keys,
      int score});
}

/// @nodoc
class __$$GroupImplCopyWithImpl<$Res>
    extends _$GroupCopyWithImpl<$Res, _$GroupImpl>
    implements _$$GroupImplCopyWith<$Res> {
  __$$GroupImplCopyWithImpl(
      _$GroupImpl _value, $Res Function(_$GroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? surrogate_team_keys = null,
    Object? team_keys = null,
    Object? score = null,
  }) {
    return _then(_$GroupImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      surrogate_team_keys: null == surrogate_team_keys
          ? _value._surrogate_team_keys
          : surrogate_team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      team_keys: null == team_keys
          ? _value._team_keys
          : team_keys // ignore: cast_nullable_to_non_nullable
              as List<String>,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl with DiagnosticableTreeMixin implements _Group {
  const _$GroupImpl(
      {required this.name,
      required final List<String> surrogate_team_keys,
      required final List<String> team_keys,
      required this.score})
      : _surrogate_team_keys = surrogate_team_keys,
        _team_keys = team_keys;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String name;
  final List<String> _surrogate_team_keys;
  @override
  List<String> get surrogate_team_keys {
    if (_surrogate_team_keys is EqualUnmodifiableListView)
      return _surrogate_team_keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_surrogate_team_keys);
  }

  final List<String> _team_keys;
  @override
  List<String> get team_keys {
    if (_team_keys is EqualUnmodifiableListView) return _team_keys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_team_keys);
  }

  @override
  final int score;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Group(name: $name, surrogate_team_keys: $surrogate_team_keys, team_keys: $team_keys, score: $score)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Group'))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('surrogate_team_keys', surrogate_team_keys))
      ..add(DiagnosticsProperty('team_keys', team_keys))
      ..add(DiagnosticsProperty('score', score));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality()
                .equals(other._surrogate_team_keys, _surrogate_team_keys) &&
            const DeepCollectionEquality()
                .equals(other._team_keys, _team_keys) &&
            (identical(other.score, score) || other.score == score));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      name,
      const DeepCollectionEquality().hash(_surrogate_team_keys),
      const DeepCollectionEquality().hash(_team_keys),
      score);

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      __$$GroupImplCopyWithImpl<_$GroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupImplToJson(
      this,
    );
  }
}

abstract class _Group implements Group {
  const factory _Group(
      {required final String name,
      required final List<String> surrogate_team_keys,
      required final List<String> team_keys,
      required final int score}) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get name;
  @override
  List<String> get surrogate_team_keys;
  @override
  List<String> get team_keys;
  @override
  int get score;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
