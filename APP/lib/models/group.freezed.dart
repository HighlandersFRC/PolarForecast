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

Picks _$PicksFromJson(Map<String, dynamic> json) {
  return _Picks.fromJson(json);
}

/// @nodoc
mixin _$Picks {
  String get number => throw _privateConstructorUsedError;
  String get comments => throw _privateConstructorUsedError;

  /// Serializes this Picks to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Picks
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PicksCopyWith<Picks> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PicksCopyWith<$Res> {
  factory $PicksCopyWith(Picks value, $Res Function(Picks) then) =
      _$PicksCopyWithImpl<$Res, Picks>;
  @useResult
  $Res call({String number, String comments});
}

/// @nodoc
class _$PicksCopyWithImpl<$Res, $Val extends Picks>
    implements $PicksCopyWith<$Res> {
  _$PicksCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Picks
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? comments = null,
  }) {
    return _then(_value.copyWith(
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PicksImplCopyWith<$Res> implements $PicksCopyWith<$Res> {
  factory _$$PicksImplCopyWith(
          _$PicksImpl value, $Res Function(_$PicksImpl) then) =
      __$$PicksImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String number, String comments});
}

/// @nodoc
class __$$PicksImplCopyWithImpl<$Res>
    extends _$PicksCopyWithImpl<$Res, _$PicksImpl>
    implements _$$PicksImplCopyWith<$Res> {
  __$$PicksImplCopyWithImpl(
      _$PicksImpl _value, $Res Function(_$PicksImpl) _then)
      : super(_value, _then);

  /// Create a copy of Picks
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? number = null,
    Object? comments = null,
  }) {
    return _then(_$PicksImpl(
      number: null == number
          ? _value.number
          : number // ignore: cast_nullable_to_non_nullable
              as String,
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PicksImpl implements _Picks {
  const _$PicksImpl({required this.number, required this.comments});

  factory _$PicksImpl.fromJson(Map<String, dynamic> json) =>
      _$$PicksImplFromJson(json);

  @override
  final String number;
  @override
  final String comments;

  @override
  String toString() {
    return 'Picks(number: $number, comments: $comments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PicksImpl &&
            (identical(other.number, number) || other.number == number) &&
            (identical(other.comments, comments) ||
                other.comments == comments));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, number, comments);

  /// Create a copy of Picks
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PicksImplCopyWith<_$PicksImpl> get copyWith =>
      __$$PicksImplCopyWithImpl<_$PicksImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PicksImplToJson(
      this,
    );
  }
}

abstract class _Picks implements Picks {
  const factory _Picks(
      {required final String number,
      required final String comments}) = _$PicksImpl;

  factory _Picks.fromJson(Map<String, dynamic> json) = _$PicksImpl.fromJson;

  @override
  String get number;
  @override
  String get comments;

  /// Create a copy of Picks
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PicksImplCopyWith<_$PicksImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Picklist2026 _$Picklist2026FromJson(Map<String, dynamic> json) {
  return _Picklist2026.fromJson(json);
}

/// @nodoc
mixin _$Picklist2026 {
  String get picklist_id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  List<Picks> get picks => throw _privateConstructorUsedError;

  /// Serializes this Picklist2026 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Picklist2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $Picklist2026CopyWith<Picklist2026> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $Picklist2026CopyWith<$Res> {
  factory $Picklist2026CopyWith(
          Picklist2026 value, $Res Function(Picklist2026) then) =
      _$Picklist2026CopyWithImpl<$Res, Picklist2026>;
  @useResult
  $Res call({String picklist_id, String name, List<Picks> picks});
}

/// @nodoc
class _$Picklist2026CopyWithImpl<$Res, $Val extends Picklist2026>
    implements $Picklist2026CopyWith<$Res> {
  _$Picklist2026CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Picklist2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? picklist_id = null,
    Object? name = null,
    Object? picks = null,
  }) {
    return _then(_value.copyWith(
      picklist_id: null == picklist_id
          ? _value.picklist_id
          : picklist_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      picks: null == picks
          ? _value.picks
          : picks // ignore: cast_nullable_to_non_nullable
              as List<Picks>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$Picklist2026ImplCopyWith<$Res>
    implements $Picklist2026CopyWith<$Res> {
  factory _$$Picklist2026ImplCopyWith(
          _$Picklist2026Impl value, $Res Function(_$Picklist2026Impl) then) =
      __$$Picklist2026ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String picklist_id, String name, List<Picks> picks});
}

/// @nodoc
class __$$Picklist2026ImplCopyWithImpl<$Res>
    extends _$Picklist2026CopyWithImpl<$Res, _$Picklist2026Impl>
    implements _$$Picklist2026ImplCopyWith<$Res> {
  __$$Picklist2026ImplCopyWithImpl(
      _$Picklist2026Impl _value, $Res Function(_$Picklist2026Impl) _then)
      : super(_value, _then);

  /// Create a copy of Picklist2026
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? picklist_id = null,
    Object? name = null,
    Object? picks = null,
  }) {
    return _then(_$Picklist2026Impl(
      picklist_id: null == picklist_id
          ? _value.picklist_id
          : picklist_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      picks: null == picks
          ? _value._picks
          : picks // ignore: cast_nullable_to_non_nullable
              as List<Picks>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$Picklist2026Impl implements _Picklist2026 {
  const _$Picklist2026Impl(
      {required this.picklist_id,
      required this.name,
      required final List<Picks> picks})
      : _picks = picks;

  factory _$Picklist2026Impl.fromJson(Map<String, dynamic> json) =>
      _$$Picklist2026ImplFromJson(json);

  @override
  final String picklist_id;
  @override
  final String name;
  final List<Picks> _picks;
  @override
  List<Picks> get picks {
    if (_picks is EqualUnmodifiableListView) return _picks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_picks);
  }

  @override
  String toString() {
    return 'Picklist2026(picklist_id: $picklist_id, name: $name, picks: $picks)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Picklist2026Impl &&
            (identical(other.picklist_id, picklist_id) ||
                other.picklist_id == picklist_id) &&
            (identical(other.name, name) || other.name == name) &&
            const DeepCollectionEquality().equals(other._picks, _picks));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, picklist_id, name,
      const DeepCollectionEquality().hash(_picks));

  /// Create a copy of Picklist2026
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Picklist2026ImplCopyWith<_$Picklist2026Impl> get copyWith =>
      __$$Picklist2026ImplCopyWithImpl<_$Picklist2026Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$Picklist2026ImplToJson(
      this,
    );
  }
}

abstract class _Picklist2026 implements Picklist2026 {
  const factory _Picklist2026(
      {required final String picklist_id,
      required final String name,
      required final List<Picks> picks}) = _$Picklist2026Impl;

  factory _Picklist2026.fromJson(Map<String, dynamic> json) =
      _$Picklist2026Impl.fromJson;

  @override
  String get picklist_id;
  @override
  String get name;
  @override
  List<Picks> get picks;

  /// Create a copy of Picklist2026
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Picklist2026ImplCopyWith<_$Picklist2026Impl> get copyWith =>
      throw _privateConstructorUsedError;
}

Group _$GroupFromJson(Map<String, dynamic> json) {
  return _Group.fromJson(json);
}

/// @nodoc
mixin _$Group {
  String get group_id => throw _privateConstructorUsedError;
  String get owner_group_id => throw _privateConstructorUsedError;
  String get admin_group_id => throw _privateConstructorUsedError;
  String get member_group_id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get affiliation => throw _privateConstructorUsedError;
  String? get join_code => throw _privateConstructorUsedError;
  List<GroupEvent> get events => throw _privateConstructorUsedError;
  GroupSettings get settings => throw _privateConstructorUsedError;
  int get last_update => throw _privateConstructorUsedError;

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
      String owner_group_id,
      String admin_group_id,
      String member_group_id,
      String name,
      String affiliation,
      String? join_code,
      List<GroupEvent> events,
      GroupSettings settings,
      int last_update});

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
    Object? owner_group_id = null,
    Object? admin_group_id = null,
    Object? member_group_id = null,
    Object? name = null,
    Object? affiliation = null,
    Object? join_code = freezed,
    Object? events = null,
    Object? settings = null,
    Object? last_update = null,
  }) {
    return _then(_value.copyWith(
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      owner_group_id: null == owner_group_id
          ? _value.owner_group_id
          : owner_group_id // ignore: cast_nullable_to_non_nullable
              as String,
      admin_group_id: null == admin_group_id
          ? _value.admin_group_id
          : admin_group_id // ignore: cast_nullable_to_non_nullable
              as String,
      member_group_id: null == member_group_id
          ? _value.member_group_id
          : member_group_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      affiliation: null == affiliation
          ? _value.affiliation
          : affiliation // ignore: cast_nullable_to_non_nullable
              as String,
      join_code: freezed == join_code
          ? _value.join_code
          : join_code // ignore: cast_nullable_to_non_nullable
              as String?,
      events: null == events
          ? _value.events
          : events // ignore: cast_nullable_to_non_nullable
              as List<GroupEvent>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupSettings,
      last_update: null == last_update
          ? _value.last_update
          : last_update // ignore: cast_nullable_to_non_nullable
              as int,
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
      String owner_group_id,
      String admin_group_id,
      String member_group_id,
      String name,
      String affiliation,
      String? join_code,
      List<GroupEvent> events,
      GroupSettings settings,
      int last_update});

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
    Object? owner_group_id = null,
    Object? admin_group_id = null,
    Object? member_group_id = null,
    Object? name = null,
    Object? affiliation = null,
    Object? join_code = freezed,
    Object? events = null,
    Object? settings = null,
    Object? last_update = null,
  }) {
    return _then(_$GroupImpl(
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      owner_group_id: null == owner_group_id
          ? _value.owner_group_id
          : owner_group_id // ignore: cast_nullable_to_non_nullable
              as String,
      admin_group_id: null == admin_group_id
          ? _value.admin_group_id
          : admin_group_id // ignore: cast_nullable_to_non_nullable
              as String,
      member_group_id: null == member_group_id
          ? _value.member_group_id
          : member_group_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      affiliation: null == affiliation
          ? _value.affiliation
          : affiliation // ignore: cast_nullable_to_non_nullable
              as String,
      join_code: freezed == join_code
          ? _value.join_code
          : join_code // ignore: cast_nullable_to_non_nullable
              as String?,
      events: null == events
          ? _value._events
          : events // ignore: cast_nullable_to_non_nullable
              as List<GroupEvent>,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupSettings,
      last_update: null == last_update
          ? _value.last_update
          : last_update // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupImpl implements _Group {
  const _$GroupImpl(
      {required this.group_id,
      required this.owner_group_id,
      required this.admin_group_id,
      required this.member_group_id,
      required this.name,
      required this.affiliation,
      required this.join_code,
      required final List<GroupEvent> events,
      required this.settings,
      required this.last_update})
      : _events = events;

  factory _$GroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupImplFromJson(json);

  @override
  final String group_id;
  @override
  final String owner_group_id;
  @override
  final String admin_group_id;
  @override
  final String member_group_id;
  @override
  final String name;
  @override
  final String affiliation;
  @override
  final String? join_code;
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
  final int last_update;

  @override
  String toString() {
    return 'Group(group_id: $group_id, owner_group_id: $owner_group_id, admin_group_id: $admin_group_id, member_group_id: $member_group_id, name: $name, affiliation: $affiliation, join_code: $join_code, events: $events, settings: $settings, last_update: $last_update)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupImpl &&
            (identical(other.group_id, group_id) ||
                other.group_id == group_id) &&
            (identical(other.owner_group_id, owner_group_id) ||
                other.owner_group_id == owner_group_id) &&
            (identical(other.admin_group_id, admin_group_id) ||
                other.admin_group_id == admin_group_id) &&
            (identical(other.member_group_id, member_group_id) ||
                other.member_group_id == member_group_id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.affiliation, affiliation) ||
                other.affiliation == affiliation) &&
            (identical(other.join_code, join_code) ||
                other.join_code == join_code) &&
            const DeepCollectionEquality().equals(other._events, _events) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            (identical(other.last_update, last_update) ||
                other.last_update == last_update));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      group_id,
      owner_group_id,
      admin_group_id,
      member_group_id,
      name,
      affiliation,
      join_code,
      const DeepCollectionEquality().hash(_events),
      settings,
      last_update);

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
      required final String owner_group_id,
      required final String admin_group_id,
      required final String member_group_id,
      required final String name,
      required final String affiliation,
      required final String? join_code,
      required final List<GroupEvent> events,
      required final GroupSettings settings,
      required final int last_update}) = _$GroupImpl;

  factory _Group.fromJson(Map<String, dynamic> json) = _$GroupImpl.fromJson;

  @override
  String get group_id;
  @override
  String get owner_group_id;
  @override
  String get admin_group_id;
  @override
  String get member_group_id;
  @override
  String get name;
  @override
  String get affiliation;
  @override
  String? get join_code;
  @override
  List<GroupEvent> get events;
  @override
  GroupSettings get settings;
  @override
  int get last_update;

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
  bool get up_to_date => throw _privateConstructorUsedError;
  GroupEventSettings get settings => throw _privateConstructorUsedError;
  List<AllianceGroup> get alliance_groups => throw _privateConstructorUsedError;
  List<Picklist2026> get picklists => throw _privateConstructorUsedError;

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
  $Res call(
      {String event_code,
      bool up_to_date,
      GroupEventSettings settings,
      List<AllianceGroup> alliance_groups,
      List<Picklist2026> picklists});

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
    Object? up_to_date = null,
    Object? settings = null,
    Object? alliance_groups = null,
    Object? picklists = null,
  }) {
    return _then(_value.copyWith(
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      up_to_date: null == up_to_date
          ? _value.up_to_date
          : up_to_date // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupEventSettings,
      alliance_groups: null == alliance_groups
          ? _value.alliance_groups
          : alliance_groups // ignore: cast_nullable_to_non_nullable
              as List<AllianceGroup>,
      picklists: null == picklists
          ? _value.picklists
          : picklists // ignore: cast_nullable_to_non_nullable
              as List<Picklist2026>,
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
  $Res call(
      {String event_code,
      bool up_to_date,
      GroupEventSettings settings,
      List<AllianceGroup> alliance_groups,
      List<Picklist2026> picklists});

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
    Object? up_to_date = null,
    Object? settings = null,
    Object? alliance_groups = null,
    Object? picklists = null,
  }) {
    return _then(_$GroupEventImpl(
      event_code: null == event_code
          ? _value.event_code
          : event_code // ignore: cast_nullable_to_non_nullable
              as String,
      up_to_date: null == up_to_date
          ? _value.up_to_date
          : up_to_date // ignore: cast_nullable_to_non_nullable
              as bool,
      settings: null == settings
          ? _value.settings
          : settings // ignore: cast_nullable_to_non_nullable
              as GroupEventSettings,
      alliance_groups: null == alliance_groups
          ? _value._alliance_groups
          : alliance_groups // ignore: cast_nullable_to_non_nullable
              as List<AllianceGroup>,
      picklists: null == picklists
          ? _value._picklists
          : picklists // ignore: cast_nullable_to_non_nullable
              as List<Picklist2026>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GroupEventImpl implements _GroupEvent {
  const _$GroupEventImpl(
      {required this.event_code,
      required this.up_to_date,
      required this.settings,
      required final List<AllianceGroup> alliance_groups,
      required final List<Picklist2026> picklists})
      : _alliance_groups = alliance_groups,
        _picklists = picklists;

  factory _$GroupEventImpl.fromJson(Map<String, dynamic> json) =>
      _$$GroupEventImplFromJson(json);

  @override
  final String event_code;
  @override
  final bool up_to_date;
  @override
  final GroupEventSettings settings;
  final List<AllianceGroup> _alliance_groups;
  @override
  List<AllianceGroup> get alliance_groups {
    if (_alliance_groups is EqualUnmodifiableListView) return _alliance_groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alliance_groups);
  }

  final List<Picklist2026> _picklists;
  @override
  List<Picklist2026> get picklists {
    if (_picklists is EqualUnmodifiableListView) return _picklists;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_picklists);
  }

  @override
  String toString() {
    return 'GroupEvent(event_code: $event_code, up_to_date: $up_to_date, settings: $settings, alliance_groups: $alliance_groups, picklists: $picklists)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GroupEventImpl &&
            (identical(other.event_code, event_code) ||
                other.event_code == event_code) &&
            (identical(other.up_to_date, up_to_date) ||
                other.up_to_date == up_to_date) &&
            (identical(other.settings, settings) ||
                other.settings == settings) &&
            const DeepCollectionEquality()
                .equals(other._alliance_groups, _alliance_groups) &&
            const DeepCollectionEquality()
                .equals(other._picklists, _picklists));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      event_code,
      up_to_date,
      settings,
      const DeepCollectionEquality().hash(_alliance_groups),
      const DeepCollectionEquality().hash(_picklists));

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
      required final bool up_to_date,
      required final GroupEventSettings settings,
      required final List<AllianceGroup> alliance_groups,
      required final List<Picklist2026> picklists}) = _$GroupEventImpl;

  factory _GroupEvent.fromJson(Map<String, dynamic> json) =
      _$GroupEventImpl.fromJson;

  @override
  String get event_code;
  @override
  bool get up_to_date;
  @override
  GroupEventSettings get settings;
  @override
  List<AllianceGroup> get alliance_groups;
  @override
  List<Picklist2026> get picklists;

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

AllianceGroup _$AllianceGroupFromJson(Map<String, dynamic> json) {
  return _AllianceGroup.fromJson(json);
}

/// @nodoc
mixin _$AllianceGroup {
  String get group_id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get affiliation => throw _privateConstructorUsedError;

  /// Serializes this AllianceGroup to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AllianceGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AllianceGroupCopyWith<AllianceGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllianceGroupCopyWith<$Res> {
  factory $AllianceGroupCopyWith(
          AllianceGroup value, $Res Function(AllianceGroup) then) =
      _$AllianceGroupCopyWithImpl<$Res, AllianceGroup>;
  @useResult
  $Res call({String group_id, String name, String affiliation});
}

/// @nodoc
class _$AllianceGroupCopyWithImpl<$Res, $Val extends AllianceGroup>
    implements $AllianceGroupCopyWith<$Res> {
  _$AllianceGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AllianceGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group_id = null,
    Object? name = null,
    Object? affiliation = null,
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
      affiliation: null == affiliation
          ? _value.affiliation
          : affiliation // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AllianceGroupImplCopyWith<$Res>
    implements $AllianceGroupCopyWith<$Res> {
  factory _$$AllianceGroupImplCopyWith(
          _$AllianceGroupImpl value, $Res Function(_$AllianceGroupImpl) then) =
      __$$AllianceGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String group_id, String name, String affiliation});
}

/// @nodoc
class __$$AllianceGroupImplCopyWithImpl<$Res>
    extends _$AllianceGroupCopyWithImpl<$Res, _$AllianceGroupImpl>
    implements _$$AllianceGroupImplCopyWith<$Res> {
  __$$AllianceGroupImplCopyWithImpl(
      _$AllianceGroupImpl _value, $Res Function(_$AllianceGroupImpl) _then)
      : super(_value, _then);

  /// Create a copy of AllianceGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group_id = null,
    Object? name = null,
    Object? affiliation = null,
  }) {
    return _then(_$AllianceGroupImpl(
      group_id: null == group_id
          ? _value.group_id
          : group_id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      affiliation: null == affiliation
          ? _value.affiliation
          : affiliation // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AllianceGroupImpl implements _AllianceGroup {
  const _$AllianceGroupImpl(
      {required this.group_id, required this.name, required this.affiliation});

  factory _$AllianceGroupImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllianceGroupImplFromJson(json);

  @override
  final String group_id;
  @override
  final String name;
  @override
  final String affiliation;

  @override
  String toString() {
    return 'AllianceGroup(group_id: $group_id, name: $name, affiliation: $affiliation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllianceGroupImpl &&
            (identical(other.group_id, group_id) ||
                other.group_id == group_id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.affiliation, affiliation) ||
                other.affiliation == affiliation));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, group_id, name, affiliation);

  /// Create a copy of AllianceGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AllianceGroupImplCopyWith<_$AllianceGroupImpl> get copyWith =>
      __$$AllianceGroupImplCopyWithImpl<_$AllianceGroupImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllianceGroupImplToJson(
      this,
    );
  }
}

abstract class _AllianceGroup implements AllianceGroup {
  const factory _AllianceGroup(
      {required final String group_id,
      required final String name,
      required final String affiliation}) = _$AllianceGroupImpl;

  factory _AllianceGroup.fromJson(Map<String, dynamic> json) =
      _$AllianceGroupImpl.fromJson;

  @override
  String get group_id;
  @override
  String get name;
  @override
  String get affiliation;

  /// Create a copy of AllianceGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AllianceGroupImplCopyWith<_$AllianceGroupImpl> get copyWith =>
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
