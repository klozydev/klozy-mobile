// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'deleted_message_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DeletedMessageHistory _$DeletedMessageHistoryFromJson(
    Map<String, dynamic> json) {
  return _DeletedMessageHistory.fromJson(json);
}

/// @nodoc
mixin _$DeletedMessageHistory {
  MessageModel? get lastMessage => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get mostRecentDeletedMessageDate =>
      throw _privateConstructorUsedError;
  String? get mostRecentDeletedMessageId => throw _privateConstructorUsedError;

  /// Serializes this DeletedMessageHistory to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeletedMessageHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeletedMessageHistoryCopyWith<DeletedMessageHistory> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeletedMessageHistoryCopyWith<$Res> {
  factory $DeletedMessageHistoryCopyWith(DeletedMessageHistory value,
          $Res Function(DeletedMessageHistory) then) =
      _$DeletedMessageHistoryCopyWithImpl<$Res, DeletedMessageHistory>;
  @useResult
  $Res call(
      {MessageModel? lastMessage,
      @TimestampConverter() DateTime? mostRecentDeletedMessageDate,
      String? mostRecentDeletedMessageId});

  $MessageModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$DeletedMessageHistoryCopyWithImpl<$Res,
        $Val extends DeletedMessageHistory>
    implements $DeletedMessageHistoryCopyWith<$Res> {
  _$DeletedMessageHistoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeletedMessageHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastMessage = freezed,
    Object? mostRecentDeletedMessageDate = freezed,
    Object? mostRecentDeletedMessageId = freezed,
  }) {
    return _then(_value.copyWith(
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as MessageModel?,
      mostRecentDeletedMessageDate: freezed == mostRecentDeletedMessageDate
          ? _value.mostRecentDeletedMessageDate
          : mostRecentDeletedMessageDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mostRecentDeletedMessageId: freezed == mostRecentDeletedMessageId
          ? _value.mostRecentDeletedMessageId
          : mostRecentDeletedMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of DeletedMessageHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageModelCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MessageModelCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DeletedMessageHistoryImplCopyWith<$Res>
    implements $DeletedMessageHistoryCopyWith<$Res> {
  factory _$$DeletedMessageHistoryImplCopyWith(
          _$DeletedMessageHistoryImpl value,
          $Res Function(_$DeletedMessageHistoryImpl) then) =
      __$$DeletedMessageHistoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {MessageModel? lastMessage,
      @TimestampConverter() DateTime? mostRecentDeletedMessageDate,
      String? mostRecentDeletedMessageId});

  @override
  $MessageModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$DeletedMessageHistoryImplCopyWithImpl<$Res>
    extends _$DeletedMessageHistoryCopyWithImpl<$Res,
        _$DeletedMessageHistoryImpl>
    implements _$$DeletedMessageHistoryImplCopyWith<$Res> {
  __$$DeletedMessageHistoryImplCopyWithImpl(_$DeletedMessageHistoryImpl _value,
      $Res Function(_$DeletedMessageHistoryImpl) _then)
      : super(_value, _then);

  /// Create a copy of DeletedMessageHistory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lastMessage = freezed,
    Object? mostRecentDeletedMessageDate = freezed,
    Object? mostRecentDeletedMessageId = freezed,
  }) {
    return _then(_$DeletedMessageHistoryImpl(
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as MessageModel?,
      mostRecentDeletedMessageDate: freezed == mostRecentDeletedMessageDate
          ? _value.mostRecentDeletedMessageDate
          : mostRecentDeletedMessageDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mostRecentDeletedMessageId: freezed == mostRecentDeletedMessageId
          ? _value.mostRecentDeletedMessageId
          : mostRecentDeletedMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DeletedMessageHistoryImpl implements _DeletedMessageHistory {
  const _$DeletedMessageHistoryImpl(
      {this.lastMessage,
      @TimestampConverter() this.mostRecentDeletedMessageDate,
      this.mostRecentDeletedMessageId});

  factory _$DeletedMessageHistoryImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeletedMessageHistoryImplFromJson(json);

  @override
  final MessageModel? lastMessage;
  @override
  @TimestampConverter()
  final DateTime? mostRecentDeletedMessageDate;
  @override
  final String? mostRecentDeletedMessageId;

  @override
  String toString() {
    return 'DeletedMessageHistory(lastMessage: $lastMessage, mostRecentDeletedMessageDate: $mostRecentDeletedMessageDate, mostRecentDeletedMessageId: $mostRecentDeletedMessageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeletedMessageHistoryImpl &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.mostRecentDeletedMessageDate,
                    mostRecentDeletedMessageDate) ||
                other.mostRecentDeletedMessageDate ==
                    mostRecentDeletedMessageDate) &&
            (identical(other.mostRecentDeletedMessageId,
                    mostRecentDeletedMessageId) ||
                other.mostRecentDeletedMessageId ==
                    mostRecentDeletedMessageId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, lastMessage,
      mostRecentDeletedMessageDate, mostRecentDeletedMessageId);

  /// Create a copy of DeletedMessageHistory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeletedMessageHistoryImplCopyWith<_$DeletedMessageHistoryImpl>
      get copyWith => __$$DeletedMessageHistoryImplCopyWithImpl<
          _$DeletedMessageHistoryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeletedMessageHistoryImplToJson(
      this,
    );
  }
}

abstract class _DeletedMessageHistory implements DeletedMessageHistory {
  const factory _DeletedMessageHistory(
      {final MessageModel? lastMessage,
      @TimestampConverter() final DateTime? mostRecentDeletedMessageDate,
      final String? mostRecentDeletedMessageId}) = _$DeletedMessageHistoryImpl;

  factory _DeletedMessageHistory.fromJson(Map<String, dynamic> json) =
      _$DeletedMessageHistoryImpl.fromJson;

  @override
  MessageModel? get lastMessage;
  @override
  @TimestampConverter()
  DateTime? get mostRecentDeletedMessageDate;
  @override
  String? get mostRecentDeletedMessageId;

  /// Create a copy of DeletedMessageHistory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeletedMessageHistoryImplCopyWith<_$DeletedMessageHistoryImpl>
      get copyWith => throw _privateConstructorUsedError;
}
