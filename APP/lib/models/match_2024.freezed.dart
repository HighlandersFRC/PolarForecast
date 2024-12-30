// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_2024.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Match2024 _$Match2024FromJson(Map<String, dynamic> json) {
  return _Match2024.fromJson(json);
}

/// @nodoc
mixin _$Match2024 {
  int? get actual_time => throw _privateConstructorUsedError;
  Alliances get alliances => throw _privateConstructorUsedError;
  String get comp_level => throw _privateConstructorUsedError;
  String get event_key => throw _privateConstructorUsedError;
  String get key => throw _privateConstructorUsedError;
  int get match_number => throw _privateConstructorUsedError;
  int? get post_result_time => throw _privateConstructorUsedError;
  int? get predicted_time => throw _privateConstructorUsedError;
  ScoreBreakdowns2024? get score_breakdown =>
      throw _privateConstructorUsedError;
  int get set_number => throw _privateConstructorUsedError;
  int get time => throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get videos => throw _privateConstructorUsedError;
  String get winning_alliance => throw _privateConstructorUsedError;

  /// Serializes this Match2024 to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $Match2024CopyWith<Match2024> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $Match2024CopyWith<$Res> {
  factory $Match2024CopyWith(Match2024 value, $Res Function(Match2024) then) =
      _$Match2024CopyWithImpl<$Res, Match2024>;
  @useResult
  $Res call(
      {int? actual_time,
      Alliances alliances,
      String comp_level,
      String event_key,
      String key,
      int match_number,
      int? post_result_time,
      int? predicted_time,
      ScoreBreakdowns2024? score_breakdown,
      int set_number,
      int time,
      List<Map<String, dynamic>> videos,
      String winning_alliance});

  $AlliancesCopyWith<$Res> get alliances;
  $ScoreBreakdowns2024CopyWith<$Res>? get score_breakdown;
}

/// @nodoc
class _$Match2024CopyWithImpl<$Res, $Val extends Match2024>
    implements $Match2024CopyWith<$Res> {
  _$Match2024CopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actual_time = freezed,
    Object? alliances = null,
    Object? comp_level = null,
    Object? event_key = null,
    Object? key = null,
    Object? match_number = null,
    Object? post_result_time = freezed,
    Object? predicted_time = freezed,
    Object? score_breakdown = freezed,
    Object? set_number = null,
    Object? time = null,
    Object? videos = null,
    Object? winning_alliance = null,
  }) {
    return _then(_value.copyWith(
      actual_time: freezed == actual_time
          ? _value.actual_time
          : actual_time // ignore: cast_nullable_to_non_nullable
              as int?,
      alliances: null == alliances
          ? _value.alliances
          : alliances // ignore: cast_nullable_to_non_nullable
              as Alliances,
      comp_level: null == comp_level
          ? _value.comp_level
          : comp_level // ignore: cast_nullable_to_non_nullable
              as String,
      event_key: null == event_key
          ? _value.event_key
          : event_key // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      match_number: null == match_number
          ? _value.match_number
          : match_number // ignore: cast_nullable_to_non_nullable
              as int,
      post_result_time: freezed == post_result_time
          ? _value.post_result_time
          : post_result_time // ignore: cast_nullable_to_non_nullable
              as int?,
      predicted_time: freezed == predicted_time
          ? _value.predicted_time
          : predicted_time // ignore: cast_nullable_to_non_nullable
              as int?,
      score_breakdown: freezed == score_breakdown
          ? _value.score_breakdown
          : score_breakdown // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdowns2024?,
      set_number: null == set_number
          ? _value.set_number
          : set_number // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      videos: null == videos
          ? _value.videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      winning_alliance: null == winning_alliance
          ? _value.winning_alliance
          : winning_alliance // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AlliancesCopyWith<$Res> get alliances {
    return $AlliancesCopyWith<$Res>(_value.alliances, (value) {
      return _then(_value.copyWith(alliances: value) as $Val);
    });
  }

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ScoreBreakdowns2024CopyWith<$Res>? get score_breakdown {
    if (_value.score_breakdown == null) {
      return null;
    }

    return $ScoreBreakdowns2024CopyWith<$Res>(_value.score_breakdown!, (value) {
      return _then(_value.copyWith(score_breakdown: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$Match2024ImplCopyWith<$Res>
    implements $Match2024CopyWith<$Res> {
  factory _$$Match2024ImplCopyWith(
          _$Match2024Impl value, $Res Function(_$Match2024Impl) then) =
      __$$Match2024ImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? actual_time,
      Alliances alliances,
      String comp_level,
      String event_key,
      String key,
      int match_number,
      int? post_result_time,
      int? predicted_time,
      ScoreBreakdowns2024? score_breakdown,
      int set_number,
      int time,
      List<Map<String, dynamic>> videos,
      String winning_alliance});

  @override
  $AlliancesCopyWith<$Res> get alliances;
  @override
  $ScoreBreakdowns2024CopyWith<$Res>? get score_breakdown;
}

/// @nodoc
class __$$Match2024ImplCopyWithImpl<$Res>
    extends _$Match2024CopyWithImpl<$Res, _$Match2024Impl>
    implements _$$Match2024ImplCopyWith<$Res> {
  __$$Match2024ImplCopyWithImpl(
      _$Match2024Impl _value, $Res Function(_$Match2024Impl) _then)
      : super(_value, _then);

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actual_time = freezed,
    Object? alliances = null,
    Object? comp_level = null,
    Object? event_key = null,
    Object? key = null,
    Object? match_number = null,
    Object? post_result_time = freezed,
    Object? predicted_time = freezed,
    Object? score_breakdown = freezed,
    Object? set_number = null,
    Object? time = null,
    Object? videos = null,
    Object? winning_alliance = null,
  }) {
    return _then(_$Match2024Impl(
      actual_time: freezed == actual_time
          ? _value.actual_time
          : actual_time // ignore: cast_nullable_to_non_nullable
              as int?,
      alliances: null == alliances
          ? _value.alliances
          : alliances // ignore: cast_nullable_to_non_nullable
              as Alliances,
      comp_level: null == comp_level
          ? _value.comp_level
          : comp_level // ignore: cast_nullable_to_non_nullable
              as String,
      event_key: null == event_key
          ? _value.event_key
          : event_key // ignore: cast_nullable_to_non_nullable
              as String,
      key: null == key
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
      match_number: null == match_number
          ? _value.match_number
          : match_number // ignore: cast_nullable_to_non_nullable
              as int,
      post_result_time: freezed == post_result_time
          ? _value.post_result_time
          : post_result_time // ignore: cast_nullable_to_non_nullable
              as int?,
      predicted_time: freezed == predicted_time
          ? _value.predicted_time
          : predicted_time // ignore: cast_nullable_to_non_nullable
              as int?,
      score_breakdown: freezed == score_breakdown
          ? _value.score_breakdown
          : score_breakdown // ignore: cast_nullable_to_non_nullable
              as ScoreBreakdowns2024?,
      set_number: null == set_number
          ? _value.set_number
          : set_number // ignore: cast_nullable_to_non_nullable
              as int,
      time: null == time
          ? _value.time
          : time // ignore: cast_nullable_to_non_nullable
              as int,
      videos: null == videos
          ? _value._videos
          : videos // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      winning_alliance: null == winning_alliance
          ? _value.winning_alliance
          : winning_alliance // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$Match2024Impl with DiagnosticableTreeMixin implements _Match2024 {
  const _$Match2024Impl(
      {this.actual_time,
      required this.alliances,
      required this.comp_level,
      required this.event_key,
      required this.key,
      required this.match_number,
      this.post_result_time,
      this.predicted_time,
      this.score_breakdown,
      required this.set_number,
      required this.time,
      required final List<Map<String, dynamic>> videos,
      required this.winning_alliance})
      : _videos = videos;

  factory _$Match2024Impl.fromJson(Map<String, dynamic> json) =>
      _$$Match2024ImplFromJson(json);

  @override
  final int? actual_time;
  @override
  final Alliances alliances;
  @override
  final String comp_level;
  @override
  final String event_key;
  @override
  final String key;
  @override
  final int match_number;
  @override
  final int? post_result_time;
  @override
  final int? predicted_time;
  @override
  final ScoreBreakdowns2024? score_breakdown;
  @override
  final int set_number;
  @override
  final int time;
  final List<Map<String, dynamic>> _videos;
  @override
  List<Map<String, dynamic>> get videos {
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videos);
  }

  @override
  final String winning_alliance;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Match2024(actual_time: $actual_time, alliances: $alliances, comp_level: $comp_level, event_key: $event_key, key: $key, match_number: $match_number, post_result_time: $post_result_time, predicted_time: $predicted_time, score_breakdown: $score_breakdown, set_number: $set_number, time: $time, videos: $videos, winning_alliance: $winning_alliance)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Match2024'))
      ..add(DiagnosticsProperty('actual_time', actual_time))
      ..add(DiagnosticsProperty('alliances', alliances))
      ..add(DiagnosticsProperty('comp_level', comp_level))
      ..add(DiagnosticsProperty('event_key', event_key))
      ..add(DiagnosticsProperty('key', key))
      ..add(DiagnosticsProperty('match_number', match_number))
      ..add(DiagnosticsProperty('post_result_time', post_result_time))
      ..add(DiagnosticsProperty('predicted_time', predicted_time))
      ..add(DiagnosticsProperty('score_breakdown', score_breakdown))
      ..add(DiagnosticsProperty('set_number', set_number))
      ..add(DiagnosticsProperty('time', time))
      ..add(DiagnosticsProperty('videos', videos))
      ..add(DiagnosticsProperty('winning_alliance', winning_alliance));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Match2024Impl &&
            (identical(other.actual_time, actual_time) ||
                other.actual_time == actual_time) &&
            (identical(other.alliances, alliances) ||
                other.alliances == alliances) &&
            (identical(other.comp_level, comp_level) ||
                other.comp_level == comp_level) &&
            (identical(other.event_key, event_key) ||
                other.event_key == event_key) &&
            (identical(other.key, key) || other.key == key) &&
            (identical(other.match_number, match_number) ||
                other.match_number == match_number) &&
            (identical(other.post_result_time, post_result_time) ||
                other.post_result_time == post_result_time) &&
            (identical(other.predicted_time, predicted_time) ||
                other.predicted_time == predicted_time) &&
            (identical(other.score_breakdown, score_breakdown) ||
                other.score_breakdown == score_breakdown) &&
            (identical(other.set_number, set_number) ||
                other.set_number == set_number) &&
            (identical(other.time, time) || other.time == time) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            (identical(other.winning_alliance, winning_alliance) ||
                other.winning_alliance == winning_alliance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      actual_time,
      alliances,
      comp_level,
      event_key,
      key,
      match_number,
      post_result_time,
      predicted_time,
      score_breakdown,
      set_number,
      time,
      const DeepCollectionEquality().hash(_videos),
      winning_alliance);

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$Match2024ImplCopyWith<_$Match2024Impl> get copyWith =>
      __$$Match2024ImplCopyWithImpl<_$Match2024Impl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$Match2024ImplToJson(
      this,
    );
  }
}

abstract class _Match2024 implements Match2024 {
  const factory _Match2024(
      {final int? actual_time,
      required final Alliances alliances,
      required final String comp_level,
      required final String event_key,
      required final String key,
      required final int match_number,
      final int? post_result_time,
      final int? predicted_time,
      final ScoreBreakdowns2024? score_breakdown,
      required final int set_number,
      required final int time,
      required final List<Map<String, dynamic>> videos,
      required final String winning_alliance}) = _$Match2024Impl;

  factory _Match2024.fromJson(Map<String, dynamic> json) =
      _$Match2024Impl.fromJson;

  @override
  int? get actual_time;
  @override
  Alliances get alliances;
  @override
  String get comp_level;
  @override
  String get event_key;
  @override
  String get key;
  @override
  int get match_number;
  @override
  int? get post_result_time;
  @override
  int? get predicted_time;
  @override
  ScoreBreakdowns2024? get score_breakdown;
  @override
  int get set_number;
  @override
  int get time;
  @override
  List<Map<String, dynamic>> get videos;
  @override
  String get winning_alliance;

  /// Create a copy of Match2024
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$Match2024ImplCopyWith<_$Match2024Impl> get copyWith =>
      throw _privateConstructorUsedError;
}
