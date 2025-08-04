// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'scouting_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ScoutingReport _$ScoutingReportFromJson(Map<String, dynamic> json) {
  return _ScoutingReport.fromJson(json);
}

/// @nodoc
mixin _$ScoutingReport {
  String get group => throw _privateConstructorUsedError;
  String get event => throw _privateConstructorUsedError;
  List<ScoutingReportEntry> get report => throw _privateConstructorUsedError;

  /// Serializes this ScoutingReport to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutingReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutingReportCopyWith<ScoutingReport> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutingReportCopyWith<$Res> {
  factory $ScoutingReportCopyWith(
          ScoutingReport value, $Res Function(ScoutingReport) then) =
      _$ScoutingReportCopyWithImpl<$Res, ScoutingReport>;
  @useResult
  $Res call({String group, String event, List<ScoutingReportEntry> report});
}

/// @nodoc
class _$ScoutingReportCopyWithImpl<$Res, $Val extends ScoutingReport>
    implements $ScoutingReportCopyWith<$Res> {
  _$ScoutingReportCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutingReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group = null,
    Object? event = null,
    Object? report = null,
  }) {
    return _then(_value.copyWith(
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
      event: null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as String,
      report: null == report
          ? _value.report
          : report // ignore: cast_nullable_to_non_nullable
              as List<ScoutingReportEntry>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoutingReportImplCopyWith<$Res>
    implements $ScoutingReportCopyWith<$Res> {
  factory _$$ScoutingReportImplCopyWith(_$ScoutingReportImpl value,
          $Res Function(_$ScoutingReportImpl) then) =
      __$$ScoutingReportImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String group, String event, List<ScoutingReportEntry> report});
}

/// @nodoc
class __$$ScoutingReportImplCopyWithImpl<$Res>
    extends _$ScoutingReportCopyWithImpl<$Res, _$ScoutingReportImpl>
    implements _$$ScoutingReportImplCopyWith<$Res> {
  __$$ScoutingReportImplCopyWithImpl(
      _$ScoutingReportImpl _value, $Res Function(_$ScoutingReportImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoutingReport
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? group = null,
    Object? event = null,
    Object? report = null,
  }) {
    return _then(_$ScoutingReportImpl(
      group: null == group
          ? _value.group
          : group // ignore: cast_nullable_to_non_nullable
              as String,
      event: null == event
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as String,
      report: null == report
          ? _value._report
          : report // ignore: cast_nullable_to_non_nullable
              as List<ScoutingReportEntry>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutingReportImpl implements _ScoutingReport {
  const _$ScoutingReportImpl(
      {required this.group,
      required this.event,
      required final List<ScoutingReportEntry> report})
      : _report = report;

  factory _$ScoutingReportImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutingReportImplFromJson(json);

  @override
  final String group;
  @override
  final String event;
  final List<ScoutingReportEntry> _report;
  @override
  List<ScoutingReportEntry> get report {
    if (_report is EqualUnmodifiableListView) return _report;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_report);
  }

  @override
  String toString() {
    return 'ScoutingReport(group: $group, event: $event, report: $report)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutingReportImpl &&
            (identical(other.group, group) || other.group == group) &&
            (identical(other.event, event) || other.event == event) &&
            const DeepCollectionEquality().equals(other._report, _report));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, group, event, const DeepCollectionEquality().hash(_report));

  /// Create a copy of ScoutingReport
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutingReportImplCopyWith<_$ScoutingReportImpl> get copyWith =>
      __$$ScoutingReportImplCopyWithImpl<_$ScoutingReportImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutingReportImplToJson(
      this,
    );
  }
}

abstract class _ScoutingReport implements ScoutingReport {
  const factory _ScoutingReport(
      {required final String group,
      required final String event,
      required final List<ScoutingReportEntry> report}) = _$ScoutingReportImpl;

  factory _ScoutingReport.fromJson(Map<String, dynamic> json) =
      _$ScoutingReportImpl.fromJson;

  @override
  String get group;
  @override
  String get event;
  @override
  List<ScoutingReportEntry> get report;

  /// Create a copy of ScoutingReport
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutingReportImplCopyWith<_$ScoutingReportImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoutingReportEntry _$ScoutingReportEntryFromJson(Map<String, dynamic> json) {
  return _ScoutingReportEntry.fromJson(json);
}

/// @nodoc
mixin _$ScoutingReportEntry {
  List<ScoutingReportScout> get scouts => throw _privateConstructorUsedError;
  String get eventCode => throw _privateConstructorUsedError;
  String get groupId => throw _privateConstructorUsedError;
  double get trustRatings => throw _privateConstructorUsedError;
  double get entries => throw _privateConstructorUsedError;
  double get contribution => throw _privateConstructorUsedError;

  /// Serializes this ScoutingReportEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutingReportEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutingReportEntryCopyWith<ScoutingReportEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutingReportEntryCopyWith<$Res> {
  factory $ScoutingReportEntryCopyWith(
          ScoutingReportEntry value, $Res Function(ScoutingReportEntry) then) =
      _$ScoutingReportEntryCopyWithImpl<$Res, ScoutingReportEntry>;
  @useResult
  $Res call(
      {List<ScoutingReportScout> scouts,
      String eventCode,
      String groupId,
      double trustRatings,
      double entries,
      double contribution});
}

/// @nodoc
class _$ScoutingReportEntryCopyWithImpl<$Res, $Val extends ScoutingReportEntry>
    implements $ScoutingReportEntryCopyWith<$Res> {
  _$ScoutingReportEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutingReportEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scouts = null,
    Object? eventCode = null,
    Object? groupId = null,
    Object? trustRatings = null,
    Object? entries = null,
    Object? contribution = null,
  }) {
    return _then(_value.copyWith(
      scouts: null == scouts
          ? _value.scouts
          : scouts // ignore: cast_nullable_to_non_nullable
              as List<ScoutingReportScout>,
      eventCode: null == eventCode
          ? _value.eventCode
          : eventCode // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      trustRatings: null == trustRatings
          ? _value.trustRatings
          : trustRatings // ignore: cast_nullable_to_non_nullable
              as double,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as double,
      contribution: null == contribution
          ? _value.contribution
          : contribution // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoutingReportEntryImplCopyWith<$Res>
    implements $ScoutingReportEntryCopyWith<$Res> {
  factory _$$ScoutingReportEntryImplCopyWith(_$ScoutingReportEntryImpl value,
          $Res Function(_$ScoutingReportEntryImpl) then) =
      __$$ScoutingReportEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ScoutingReportScout> scouts,
      String eventCode,
      String groupId,
      double trustRatings,
      double entries,
      double contribution});
}

/// @nodoc
class __$$ScoutingReportEntryImplCopyWithImpl<$Res>
    extends _$ScoutingReportEntryCopyWithImpl<$Res, _$ScoutingReportEntryImpl>
    implements _$$ScoutingReportEntryImplCopyWith<$Res> {
  __$$ScoutingReportEntryImplCopyWithImpl(_$ScoutingReportEntryImpl _value,
      $Res Function(_$ScoutingReportEntryImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoutingReportEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scouts = null,
    Object? eventCode = null,
    Object? groupId = null,
    Object? trustRatings = null,
    Object? entries = null,
    Object? contribution = null,
  }) {
    return _then(_$ScoutingReportEntryImpl(
      scouts: null == scouts
          ? _value._scouts
          : scouts // ignore: cast_nullable_to_non_nullable
              as List<ScoutingReportScout>,
      eventCode: null == eventCode
          ? _value.eventCode
          : eventCode // ignore: cast_nullable_to_non_nullable
              as String,
      groupId: null == groupId
          ? _value.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String,
      trustRatings: null == trustRatings
          ? _value.trustRatings
          : trustRatings // ignore: cast_nullable_to_non_nullable
              as double,
      entries: null == entries
          ? _value.entries
          : entries // ignore: cast_nullable_to_non_nullable
              as double,
      contribution: null == contribution
          ? _value.contribution
          : contribution // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutingReportEntryImpl implements _ScoutingReportEntry {
  const _$ScoutingReportEntryImpl(
      {required final List<ScoutingReportScout> scouts,
      required this.eventCode,
      required this.groupId,
      required this.trustRatings,
      required this.entries,
      required this.contribution})
      : _scouts = scouts;

  factory _$ScoutingReportEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutingReportEntryImplFromJson(json);

  final List<ScoutingReportScout> _scouts;
  @override
  List<ScoutingReportScout> get scouts {
    if (_scouts is EqualUnmodifiableListView) return _scouts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scouts);
  }

  @override
  final String eventCode;
  @override
  final String groupId;
  @override
  final double trustRatings;
  @override
  final double entries;
  @override
  final double contribution;

  @override
  String toString() {
    return 'ScoutingReportEntry(scouts: $scouts, eventCode: $eventCode, groupId: $groupId, trustRatings: $trustRatings, entries: $entries, contribution: $contribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutingReportEntryImpl &&
            const DeepCollectionEquality().equals(other._scouts, _scouts) &&
            (identical(other.eventCode, eventCode) ||
                other.eventCode == eventCode) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.trustRatings, trustRatings) ||
                other.trustRatings == trustRatings) &&
            (identical(other.entries, entries) || other.entries == entries) &&
            (identical(other.contribution, contribution) ||
                other.contribution == contribution));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_scouts),
      eventCode,
      groupId,
      trustRatings,
      entries,
      contribution);

  /// Create a copy of ScoutingReportEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutingReportEntryImplCopyWith<_$ScoutingReportEntryImpl> get copyWith =>
      __$$ScoutingReportEntryImplCopyWithImpl<_$ScoutingReportEntryImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutingReportEntryImplToJson(
      this,
    );
  }
}

abstract class _ScoutingReportEntry implements ScoutingReportEntry {
  const factory _ScoutingReportEntry(
      {required final List<ScoutingReportScout> scouts,
      required final String eventCode,
      required final String groupId,
      required final double trustRatings,
      required final double entries,
      required final double contribution}) = _$ScoutingReportEntryImpl;

  factory _ScoutingReportEntry.fromJson(Map<String, dynamic> json) =
      _$ScoutingReportEntryImpl.fromJson;

  @override
  List<ScoutingReportScout> get scouts;
  @override
  String get eventCode;
  @override
  String get groupId;
  @override
  double get trustRatings;
  @override
  double get entries;
  @override
  double get contribution;

  /// Create a copy of ScoutingReportEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutingReportEntryImplCopyWith<_$ScoutingReportEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoutingReportScout _$ScoutingReportScoutFromJson(Map<String, dynamic> json) {
  return _ScoutingReportScout.fromJson(json);
}

/// @nodoc
mixin _$ScoutingReportScout {
  ScoutingReportUser get name => throw _privateConstructorUsedError;

  /// Serializes this ScoutingReportScout to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutingReportScout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutingReportScoutCopyWith<ScoutingReportScout> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutingReportScoutCopyWith<$Res> {
  factory $ScoutingReportScoutCopyWith(
          ScoutingReportScout value, $Res Function(ScoutingReportScout) then) =
      _$ScoutingReportScoutCopyWithImpl<$Res, ScoutingReportScout>;
  @useResult
  $Res call({ScoutingReportUser name});

  $ScoutingReportUserCopyWith<$Res> get name;
}

/// @nodoc
class _$ScoutingReportScoutCopyWithImpl<$Res, $Val extends ScoutingReportScout>
    implements $ScoutingReportScoutCopyWith<$Res> {
  _$ScoutingReportScoutCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutingReportScout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as ScoutingReportUser,
    ) as $Val);
  }

  /// Create a copy of ScoutingReportScout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoutingReportUserCopyWith<$Res> get name {
    return $ScoutingReportUserCopyWith<$Res>(_value.name, (value) {
      return _then(_value.copyWith(name: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ScoutingReportScoutImplCopyWith<$Res>
    implements $ScoutingReportScoutCopyWith<$Res> {
  factory _$$ScoutingReportScoutImplCopyWith(_$ScoutingReportScoutImpl value,
          $Res Function(_$ScoutingReportScoutImpl) then) =
      __$$ScoutingReportScoutImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ScoutingReportUser name});

  @override
  $ScoutingReportUserCopyWith<$Res> get name;
}

/// @nodoc
class __$$ScoutingReportScoutImplCopyWithImpl<$Res>
    extends _$ScoutingReportScoutCopyWithImpl<$Res, _$ScoutingReportScoutImpl>
    implements _$$ScoutingReportScoutImplCopyWith<$Res> {
  __$$ScoutingReportScoutImplCopyWithImpl(_$ScoutingReportScoutImpl _value,
      $Res Function(_$ScoutingReportScoutImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoutingReportScout
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
  }) {
    return _then(_$ScoutingReportScoutImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as ScoutingReportUser,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutingReportScoutImpl implements _ScoutingReportScout {
  const _$ScoutingReportScoutImpl({required this.name});

  factory _$ScoutingReportScoutImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutingReportScoutImplFromJson(json);

  @override
  final ScoutingReportUser name;

  @override
  String toString() {
    return 'ScoutingReportScout(name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutingReportScoutImpl &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name);

  /// Create a copy of ScoutingReportScout
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutingReportScoutImplCopyWith<_$ScoutingReportScoutImpl> get copyWith =>
      __$$ScoutingReportScoutImplCopyWithImpl<_$ScoutingReportScoutImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutingReportScoutImplToJson(
      this,
    );
  }
}

abstract class _ScoutingReportScout implements ScoutingReportScout {
  const factory _ScoutingReportScout({required final ScoutingReportUser name}) =
      _$ScoutingReportScoutImpl;

  factory _ScoutingReportScout.fromJson(Map<String, dynamic> json) =
      _$ScoutingReportScoutImpl.fromJson;

  @override
  ScoutingReportUser get name;

  /// Create a copy of ScoutingReportScout
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutingReportScoutImplCopyWith<_$ScoutingReportScoutImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ScoutingReportUser _$ScoutingReportUserFromJson(Map<String, dynamic> json) {
  return _ScoutingReportUser.fromJson(json);
}

/// @nodoc
mixin _$ScoutingReportUser {
  String get user_id => throw _privateConstructorUsedError;
  String? get first_name => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  int get team_number => throw _privateConstructorUsedError;

  /// Serializes this ScoutingReportUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ScoutingReportUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ScoutingReportUserCopyWith<ScoutingReportUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ScoutingReportUserCopyWith<$Res> {
  factory $ScoutingReportUserCopyWith(
          ScoutingReportUser value, $Res Function(ScoutingReportUser) then) =
      _$ScoutingReportUserCopyWithImpl<$Res, ScoutingReportUser>;
  @useResult
  $Res call(
      {String user_id, String? first_name, String? username, int team_number});
}

/// @nodoc
class _$ScoutingReportUserCopyWithImpl<$Res, $Val extends ScoutingReportUser>
    implements $ScoutingReportUserCopyWith<$Res> {
  _$ScoutingReportUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ScoutingReportUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? first_name = freezed,
    Object? username = freezed,
    Object? team_number = null,
  }) {
    return _then(_value.copyWith(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      first_name: freezed == first_name
          ? _value.first_name
          : first_name // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ScoutingReportUserImplCopyWith<$Res>
    implements $ScoutingReportUserCopyWith<$Res> {
  factory _$$ScoutingReportUserImplCopyWith(_$ScoutingReportUserImpl value,
          $Res Function(_$ScoutingReportUserImpl) then) =
      __$$ScoutingReportUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String user_id, String? first_name, String? username, int team_number});
}

/// @nodoc
class __$$ScoutingReportUserImplCopyWithImpl<$Res>
    extends _$ScoutingReportUserCopyWithImpl<$Res, _$ScoutingReportUserImpl>
    implements _$$ScoutingReportUserImplCopyWith<$Res> {
  __$$ScoutingReportUserImplCopyWithImpl(_$ScoutingReportUserImpl _value,
      $Res Function(_$ScoutingReportUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of ScoutingReportUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user_id = null,
    Object? first_name = freezed,
    Object? username = freezed,
    Object? team_number = null,
  }) {
    return _then(_$ScoutingReportUserImpl(
      user_id: null == user_id
          ? _value.user_id
          : user_id // ignore: cast_nullable_to_non_nullable
              as String,
      first_name: freezed == first_name
          ? _value.first_name
          : first_name // ignore: cast_nullable_to_non_nullable
              as String?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      team_number: null == team_number
          ? _value.team_number
          : team_number // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ScoutingReportUserImpl implements _ScoutingReportUser {
  const _$ScoutingReportUserImpl(
      {required this.user_id,
      this.first_name,
      this.username,
      required this.team_number});

  factory _$ScoutingReportUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutingReportUserImplFromJson(json);

  @override
  final String user_id;
  @override
  final String? first_name;
  @override
  final String? username;
  @override
  final int team_number;

  @override
  String toString() {
    return 'ScoutingReportUser(user_id: $user_id, first_name: $first_name, username: $username, team_number: $team_number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutingReportUserImpl &&
            (identical(other.user_id, user_id) || other.user_id == user_id) &&
            (identical(other.first_name, first_name) ||
                other.first_name == first_name) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.team_number, team_number) ||
                other.team_number == team_number));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, user_id, first_name, username, team_number);

  /// Create a copy of ScoutingReportUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ScoutingReportUserImplCopyWith<_$ScoutingReportUserImpl> get copyWith =>
      __$$ScoutingReportUserImplCopyWithImpl<_$ScoutingReportUserImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ScoutingReportUserImplToJson(
      this,
    );
  }
}

abstract class _ScoutingReportUser implements ScoutingReportUser {
  const factory _ScoutingReportUser(
      {required final String user_id,
      final String? first_name,
      final String? username,
      required final int team_number}) = _$ScoutingReportUserImpl;

  factory _ScoutingReportUser.fromJson(Map<String, dynamic> json) =
      _$ScoutingReportUserImpl.fromJson;

  @override
  String get user_id;
  @override
  String? get first_name;
  @override
  String? get username;
  @override
  int get team_number;

  /// Create a copy of ScoutingReportUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ScoutingReportUserImplCopyWith<_$ScoutingReportUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
