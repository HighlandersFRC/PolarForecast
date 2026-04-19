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
  ScoutInfo get scout => throw _privateConstructorUsedError;
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
      {ScoutInfo scout,
      String eventCode,
      String groupId,
      double trustRatings,
      double entries,
      double contribution});

  $ScoutInfoCopyWith<$Res> get scout;
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
    Object? scout = null,
    Object? eventCode = null,
    Object? groupId = null,
    Object? trustRatings = null,
    Object? entries = null,
    Object? contribution = null,
  }) {
    return _then(_value.copyWith(
      scout: null == scout
          ? _value.scout
          : scout // ignore: cast_nullable_to_non_nullable
              as ScoutInfo,
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

  /// Create a copy of ScoutingReportEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoutInfoCopyWith<$Res> get scout {
    return $ScoutInfoCopyWith<$Res>(_value.scout, (value) {
      return _then(_value.copyWith(scout: value) as $Val);
    });
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
      {ScoutInfo scout,
      String eventCode,
      String groupId,
      double trustRatings,
      double entries,
      double contribution});

  @override
  $ScoutInfoCopyWith<$Res> get scout;
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
    Object? scout = null,
    Object? eventCode = null,
    Object? groupId = null,
    Object? trustRatings = null,
    Object? entries = null,
    Object? contribution = null,
  }) {
    return _then(_$ScoutingReportEntryImpl(
      scout: null == scout
          ? _value.scout
          : scout // ignore: cast_nullable_to_non_nullable
              as ScoutInfo,
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
      {required this.scout,
      required this.eventCode,
      required this.groupId,
      required this.trustRatings,
      required this.entries,
      required this.contribution});

  factory _$ScoutingReportEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ScoutingReportEntryImplFromJson(json);

  @override
  final ScoutInfo scout;
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
    return 'ScoutingReportEntry(scout: $scout, eventCode: $eventCode, groupId: $groupId, trustRatings: $trustRatings, entries: $entries, contribution: $contribution)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ScoutingReportEntryImpl &&
            (identical(other.scout, scout) || other.scout == scout) &&
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
  int get hashCode => Object.hash(runtimeType, scout, eventCode, groupId,
      trustRatings, entries, contribution);

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
      {required final ScoutInfo scout,
      required final String eventCode,
      required final String groupId,
      required final double trustRatings,
      required final double entries,
      required final double contribution}) = _$ScoutingReportEntryImpl;

  factory _ScoutingReportEntry.fromJson(Map<String, dynamic> json) =
      _$ScoutingReportEntryImpl.fromJson;

  @override
  ScoutInfo get scout;
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
