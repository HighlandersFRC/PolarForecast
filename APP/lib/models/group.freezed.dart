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
  String get group_id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get join_code => throw _privateConstructorUsedError;
  List<GroupEvent> get events => throw _privateConstructorUsedError;
  GroupSettings get settings => throw _privateConstructorUsedError;

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
      {String group_id,
      String name,
      String join_code,
      List<GroupEvent> events,
      GroupSettings settings});

  $GroupSettingsCopyWith<$Res> get settings;
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
    Object? group_id = null,
    Object? name = null,
    Object? join_code = null,
    Object? events = null,
    Object? settings = null,
  }) {
    return _then(_value.copyWith(
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      join_code: null == join_code
          ? _value.join_code
          : join_code // ignore: cast_nullable_to_non_nullable
              as String,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<GroupEvent>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupSettings,
    ) as $Val);
  }

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GroupSettingsCopyWith<$Res> get settings {
    return $GroupSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
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
      {String group_id,
      String name,
      String join_code,
      List<GroupEvent> events,
      GroupSettings settings});

  @override
  $GroupSettingsCopyWith<$Res> get settings;
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
    Object? group_id = null,
    Object? name = null,
    Object? join_code = null,
    Object? events = null,
    Object? settings = null,
  }) {
    return _then(_$GroupImpl(
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      join_code: null == join_code
          ? _value.join_code
          : join_code // ignore: cast_nullable_to_non_nullable
              as String,
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<GroupEvent>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupSettings,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl implements _Group {
  const _$GroupImpl(
      {required this.group_id,
      required this.name,
      required this.join_code,
      required final List<GroupEvent> events,
      required this.settings})
      : _events = events;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String group_id;
  @override
  final String name;
  @override
  final String join_code;
  final List<GroupEvent> _events;
  @override
  List<GroupEvent> get events {
    if (_events is EqualUnmodifiableListView) return _events;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_events);
  }

  @override
  final GroupSettings settings;

  @override
  String toString() {
    return 'Group(group_id: $group_id, name: $name, join_code: $join_code, events: $events, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.group_id, group_id) ||
                other.group_id == group_id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.join_code, join_code) ||
                other.join_code == join_code) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, group_id, name, join_code,
      const DeepCollectionEquality().hash(_events), settings);

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
      {required final String group_id,
      required final String name,
      required final String join_code,
      required final List<GroupEvent> events,
      required final GroupSettings settings}) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get group_id;
  @override
  String get name;
  @override
  String get join_code;
  @override
  List<GroupEvent> get events;
  @override
  GroupSettings get settings;

  /// Create a copy of Group
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupImplCopyWith<_$GroupImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupEvent _$GroupEventFromJson(Map<String, dynamic> json) {
  return _GroupEvent.fromJson(json);
}

/// @nodoc
mixin _$GroupEvent {
  String get event_code => throw _privateConstructorUsedError;
  GroupEventSettings get settings => throw _privateConstructorUsedError;

  /// Serializes this GroupEvent to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupEventCopyWith<GroupEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupEventCopyWith<$Res> {
  factory $GroupEventCopyWith(
          GroupEvent value, $Res Function(GroupEvent) then) =
      _$GroupEventCopyWithImpl<$Res, GroupEvent>;
  @useResult
  $Res call({String event_code, GroupEventSettings settings});

  $GroupEventSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class _$GroupEventCopyWithImpl<$Res, $Val extends GroupEvent>
    implements $GroupEventCopyWith<$Res> {
  _$GroupEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event_code = null,
    Object? settings = null,
  }) {
    return _then(_value.copyWith(
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupEventSettings,
    ) as $Val);
  }

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $GroupEventSettingsCopyWith<$Res> get settings {
    return $GroupEventSettingsCopyWith<$Res>(_value.settings, (value) {
      return _then(_value.copyWith(settings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GroupEventImplCopyWith<$Res>
    implements $GroupEventCopyWith<$Res> {
  factory _$$GroupEventImplCopyWith(
          _$GroupEventImpl value, $Res Function(_$GroupEventImpl) then) =
      __$$GroupEventImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String event_code, GroupEventSettings settings});

  @override
  $GroupEventSettingsCopyWith<$Res> get settings;
}

/// @nodoc
class __$$GroupEventImplCopyWithImpl<$Res>
    extends _$GroupEventCopyWithImpl<$Res, _$GroupEventImpl>
    implements _$$GroupEventImplCopyWith<$Res> {
  __$$GroupEventImplCopyWithImpl(
      _$GroupEventImpl _value, $Res Function(_$GroupEventImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? event_code = null,
    Object? settings = null,
  }) {
    return _then(_$GroupEventImpl(
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupEventSettings,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupEventImpl implements _GroupEvent {
  const _$GroupEventImpl({required this.event_code, required this.settings});

  factory _$GroupEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupEventImplFromJson(json);

  @override
  final String event_code;
  @override
  final GroupEventSettings settings;

  @override
  String toString() {
    return 'GroupEvent(event_code: $event_code, settings: $settings)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupEventImpl &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.settings, settings) ||
                other.settings == settings));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, event_code, settings);

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupEventImplCopyWith<_$GroupEventImpl> get copyWith =>
      __$$GroupEventImplCopyWithImpl<_$GroupEventImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupEventImplToJson(
      this,
    );
  }
}

abstract class _GroupEvent implements GroupEvent {
  const factory _GroupEvent(
      {required final String event_code,
      required final GroupEventSettings settings}) = _$GroupEventImpl;

  factory _GroupEvent.fromJson(Map<String, dynamic> json) =
      _$GroupEventImpl.fromJson;

  @override
  String get event_code;
  @override
  GroupEventSettings get settings;

  /// Create a copy of GroupEvent
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupEventImplCopyWith<_$GroupEventImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupEventSettings _$GroupEventSettingsFromJson(Map<String, dynamic> json) {
  return _GroupEventSettings.fromJson(json);
}

/// @nodoc
mixin _$GroupEventSettings {
  bool get crowd_sourced_match_scouting => throw _privateConstructorUsedError;
  bool get crowd_sourced_pit_scouting => throw _privateConstructorUsedError;

  /// Serializes this GroupEventSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupEventSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupEventSettingsCopyWith<GroupEventSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupEventSettingsCopyWith<$Res> {
  factory $GroupEventSettingsCopyWith(
          GroupEventSettings value, $Res Function(GroupEventSettings) then) =
      _$GroupEventSettingsCopyWithImpl<$Res, GroupEventSettings>;
  @useResult
  $Res call(
      {bool crowd_sourced_match_scouting, bool crowd_sourced_pit_scouting});
}

/// @nodoc
class _$GroupEventSettingsCopyWithImpl<$Res, $Val extends GroupEventSettings>
    implements $GroupEventSettingsCopyWith<$Res> {
  _$GroupEventSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupEventSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crowd_sourced_match_scouting = null,
    Object? crowd_sourced_pit_scouting = null,
  }) {
    return _then(_value.copyWith(
      crowd_sourced_match_scouting: null == crowd_sourced_match_scouting
          ? _value.crowd_sourced_match_scouting
          : crowd_sourced_match_scouting // ignore: cast_nullable_to_non_nullable
              as bool,
      crowd_sourced_pit_scouting: null == crowd_sourced_pit_scouting
          ? _value.crowd_sourced_pit_scouting
          : crowd_sourced_pit_scouting // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupEventSettingsImplCopyWith<$Res>
    implements $GroupEventSettingsCopyWith<$Res> {
  factory _$$GroupEventSettingsImplCopyWith(_$GroupEventSettingsImpl value,
          $Res Function(_$GroupEventSettingsImpl) then) =
      __$$GroupEventSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool crowd_sourced_match_scouting, bool crowd_sourced_pit_scouting});
}

/// @nodoc
class __$$GroupEventSettingsImplCopyWithImpl<$Res>
    extends _$GroupEventSettingsCopyWithImpl<$Res, _$GroupEventSettingsImpl>
    implements _$$GroupEventSettingsImplCopyWith<$Res> {
  __$$GroupEventSettingsImplCopyWithImpl(_$GroupEventSettingsImpl _value,
      $Res Function(_$GroupEventSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupEventSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? crowd_sourced_match_scouting = null,
    Object? crowd_sourced_pit_scouting = null,
  }) {
    return _then(_$GroupEventSettingsImpl(
      crowd_sourced_match_scouting: null == crowd_sourced_match_scouting
          ? _value.crowd_sourced_match_scouting
          : crowd_sourced_match_scouting // ignore: cast_nullable_to_non_nullable
              as bool,
      crowd_sourced_pit_scouting: null == crowd_sourced_pit_scouting
          ? _value.crowd_sourced_pit_scouting
          : crowd_sourced_pit_scouting // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupEventSettingsImpl implements _GroupEventSettings {
  const _$GroupEventSettingsImpl(
      {required this.crowd_sourced_match_scouting,
      required this.crowd_sourced_pit_scouting});

  factory _$GroupEventSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupEventSettingsImplFromJson(json);

  @override
  final bool crowd_sourced_match_scouting;
  @override
  final bool crowd_sourced_pit_scouting;

  @override
  String toString() {
    return 'GroupEventSettings(crowd_sourced_match_scouting: $crowd_sourced_match_scouting, crowd_sourced_pit_scouting: $crowd_sourced_pit_scouting)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupEventSettingsImpl &&
            (identical(other.crowd_sourced_match_scouting,
                    crowd_sourced_match_scouting) ||
                other.crowd_sourced_match_scouting ==
                    crowd_sourced_match_scouting) &&
            (identical(other.crowd_sourced_pit_scouting,
                    crowd_sourced_pit_scouting) ||
                other.crowd_sourced_pit_scouting ==
                    crowd_sourced_pit_scouting));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, crowd_sourced_match_scouting, crowd_sourced_pit_scouting);

  /// Create a copy of GroupEventSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupEventSettingsImplCopyWith<_$GroupEventSettingsImpl> get copyWith =>
      __$$GroupEventSettingsImplCopyWithImpl<_$GroupEventSettingsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupEventSettingsImplToJson(
      this,
    );
  }
}

abstract class _GroupEventSettings implements GroupEventSettings {
  const factory _GroupEventSettings(
          {required final bool crowd_sourced_match_scouting,
          required final bool crowd_sourced_pit_scouting}) =
      _$GroupEventSettingsImpl;

  factory _GroupEventSettings.fromJson(Map<String, dynamic> json) =
      _$GroupEventSettingsImpl.fromJson;

  @override
  bool get crowd_sourced_match_scouting;
  @override
  bool get crowd_sourced_pit_scouting;

  /// Create a copy of GroupEventSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupEventSettingsImplCopyWith<_$GroupEventSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GroupSettings _$GroupSettingsFromJson(Map<String, dynamic> json) {
  return _GroupSettings.fromJson(json);
}

/// @nodoc
mixin _$GroupSettings {
  bool get approve_new_members => throw _privateConstructorUsedError;

  /// Serializes this GroupSettings to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GroupSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GroupSettingsCopyWith<GroupSettings> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GroupSettingsCopyWith<$Res> {
  factory $GroupSettingsCopyWith(
          GroupSettings value, $Res Function(GroupSettings) then) =
      _$GroupSettingsCopyWithImpl<$Res, GroupSettings>;
  @useResult
  $Res call({bool approve_new_members});
}

/// @nodoc
class _$GroupSettingsCopyWithImpl<$Res, $Val extends GroupSettings>
    implements $GroupSettingsCopyWith<$Res> {
  _$GroupSettingsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GroupSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? approve_new_members = null,
  }) {
    return _then(_value.copyWith(
      approve_new_members: null == approve_new_members
          ? _value.approve_new_members
          : approve_new_members // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GroupSettingsImplCopyWith<$Res>
    implements $GroupSettingsCopyWith<$Res> {
  factory _$$GroupSettingsImplCopyWith(
          _$GroupSettingsImpl value, $Res Function(_$GroupSettingsImpl) then) =
      __$$GroupSettingsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool approve_new_members});
}

/// @nodoc
class __$$GroupSettingsImplCopyWithImpl<$Res>
    extends _$GroupSettingsCopyWithImpl<$Res, _$GroupSettingsImpl>
    implements _$$GroupSettingsImplCopyWith<$Res> {
  __$$GroupSettingsImplCopyWithImpl(
      _$GroupSettingsImpl _value, $Res Function(_$GroupSettingsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GroupSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? approve_new_members = null,
  }) {
    return _then(_$GroupSettingsImpl(
      approve_new_members: null == approve_new_members
          ? _value.approve_new_members
          : approve_new_members // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupSettingsImpl implements _GroupSettings {
  const _$GroupSettingsImpl({required this.approve_new_members});

  factory _$GroupSettingsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupSettingsImplFromJson(json);

  @override
  final bool approve_new_members;

  @override
  String toString() {
    return 'GroupSettings(approve_new_members: $approve_new_members)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupSettingsImpl &&
            (identical(other.approve_new_members, approve_new_members) ||
                other.approve_new_members == approve_new_members));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, approve_new_members);

  /// Create a copy of GroupSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GroupSettingsImplCopyWith<_$GroupSettingsImpl> get copyWith =>
      __$$GroupSettingsImplCopyWithImpl<_$GroupSettingsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GroupSettingsImplToJson(
      this,
    );
  }
}

abstract class _GroupSettings implements GroupSettings {
  const factory _GroupSettings({required final bool approve_new_members}) =
      _$GroupSettingsImpl;

  factory _GroupSettings.fromJson(Map<String, dynamic> json) =
      _$GroupSettingsImpl.fromJson;

  @override
  bool get approve_new_members;

  /// Create a copy of GroupSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GroupSettingsImplCopyWith<_$GroupSettingsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
