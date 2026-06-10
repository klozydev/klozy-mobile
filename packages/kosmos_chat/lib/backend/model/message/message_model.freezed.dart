// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MessageModel _$MessageModelFromJson(Map<String, dynamic> json) {
  return _MessageModel.fromJson(json);
}

/// @nodoc
mixin _$MessageModel {
  /// Principal data
  String? get id => throw _privateConstructorUsedError;
  String get tchatId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;

  /// Message data
  String get messageType => throw _privateConstructorUsedError;
  @MessageModelJsonConverter()
  MessageModel? get replyTo => throw _privateConstructorUsedError;
  String? get content => throw _privateConstructorUsedError;
  Map<dynamic, dynamic> get metadata => throw _privateConstructorUsedError;
  @ListMediaModelJsonConverter()
  List<MediaModel>? get media => throw _privateConstructorUsedError;

  /// Message status data
  List<String> get readBy => throw _privateConstructorUsedError;
  List<String> get deleteBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get sendAt => throw _privateConstructorUsedError;
  String? get sendStatus => throw _privateConstructorUsedError;
  bool get fromWeb => throw _privateConstructorUsedError;

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageModelCopyWith<MessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) then) =
      _$MessageModelCopyWithImpl<$Res, MessageModel>;
  @useResult
  $Res call(
      {String? id,
      String tchatId,
      String senderId,
      String messageType,
      @MessageModelJsonConverter() MessageModel? replyTo,
      String? content,
      Map<dynamic, dynamic> metadata,
      @ListMediaModelJsonConverter() List<MediaModel>? media,
      List<String> readBy,
      List<String> deleteBy,
      @TimestampConverter() DateTime? sendAt,
      String? sendStatus,
      bool fromWeb});

  $MessageModelCopyWith<$Res>? get replyTo;
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res, $Val extends MessageModel>
    implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? tchatId = null,
    Object? senderId = null,
    Object? messageType = null,
    Object? replyTo = freezed,
    Object? content = freezed,
    Object? metadata = null,
    Object? media = freezed,
    Object? readBy = null,
    Object? deleteBy = null,
    Object? sendAt = freezed,
    Object? sendStatus = freezed,
    Object? fromWeb = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      tchatId: null == tchatId
          ? _value.tchatId
          : tchatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      replyTo: freezed == replyTo
          ? _value.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as MessageModel?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<dynamic, dynamic>,
      media: freezed == media
          ? _value.media
          : media // ignore: cast_nullable_to_non_nullable
              as List<MediaModel>?,
      readBy: null == readBy
          ? _value.readBy
          : readBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      deleteBy: null == deleteBy
          ? _value.deleteBy
          : deleteBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sendAt: freezed == sendAt
          ? _value.sendAt
          : sendAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sendStatus: freezed == sendStatus
          ? _value.sendStatus
          : sendStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      fromWeb: null == fromWeb
          ? _value.fromWeb
          : fromWeb // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageModelCopyWith<$Res>? get replyTo {
    if (_value.replyTo == null) {
      return null;
    }

    return $MessageModelCopyWith<$Res>(_value.replyTo!, (value) {
      return _then(_value.copyWith(replyTo: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageModelImplCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$$MessageModelImplCopyWith(
          _$MessageModelImpl value, $Res Function(_$MessageModelImpl) then) =
      __$$MessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      String tchatId,
      String senderId,
      String messageType,
      @MessageModelJsonConverter() MessageModel? replyTo,
      String? content,
      Map<dynamic, dynamic> metadata,
      @ListMediaModelJsonConverter() List<MediaModel>? media,
      List<String> readBy,
      List<String> deleteBy,
      @TimestampConverter() DateTime? sendAt,
      String? sendStatus,
      bool fromWeb});

  @override
  $MessageModelCopyWith<$Res>? get replyTo;
}

/// @nodoc
class __$$MessageModelImplCopyWithImpl<$Res>
    extends _$MessageModelCopyWithImpl<$Res, _$MessageModelImpl>
    implements _$$MessageModelImplCopyWith<$Res> {
  __$$MessageModelImplCopyWithImpl(
      _$MessageModelImpl _value, $Res Function(_$MessageModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? tchatId = null,
    Object? senderId = null,
    Object? messageType = null,
    Object? replyTo = freezed,
    Object? content = freezed,
    Object? metadata = null,
    Object? media = freezed,
    Object? readBy = null,
    Object? deleteBy = null,
    Object? sendAt = freezed,
    Object? sendStatus = freezed,
    Object? fromWeb = null,
  }) {
    return _then(_$MessageModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      tchatId: null == tchatId
          ? _value.tchatId
          : tchatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      messageType: null == messageType
          ? _value.messageType
          : messageType // ignore: cast_nullable_to_non_nullable
              as String,
      replyTo: freezed == replyTo
          ? _value.replyTo
          : replyTo // ignore: cast_nullable_to_non_nullable
              as MessageModel?,
      content: freezed == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<dynamic, dynamic>,
      media: freezed == media
          ? _value._media
          : media // ignore: cast_nullable_to_non_nullable
              as List<MediaModel>?,
      readBy: null == readBy
          ? _value._readBy
          : readBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      deleteBy: null == deleteBy
          ? _value._deleteBy
          : deleteBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sendAt: freezed == sendAt
          ? _value.sendAt
          : sendAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      sendStatus: freezed == sendStatus
          ? _value.sendStatus
          : sendStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      fromWeb: null == fromWeb
          ? _value.fromWeb
          : fromWeb // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageModelImpl implements _MessageModel {
  const _$MessageModelImpl(
      {this.id,
      required this.tchatId,
      required this.senderId,
      required this.messageType,
      @MessageModelJsonConverter() this.replyTo,
      this.content,
      final Map<dynamic, dynamic> metadata = const {},
      @ListMediaModelJsonConverter() final List<MediaModel>? media,
      final List<String> readBy = const [],
      final List<String> deleteBy = const [],
      @TimestampConverter() this.sendAt,
      this.sendStatus,
      this.fromWeb = false})
      : _metadata = metadata,
        _media = media,
        _readBy = readBy,
        _deleteBy = deleteBy;

  factory _$MessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageModelImplFromJson(json);

  /// Principal data
  @override
  final String? id;
  @override
  final String tchatId;
  @override
  final String senderId;

  /// Message data
  @override
  final String messageType;
  @override
  @MessageModelJsonConverter()
  final MessageModel? replyTo;
  @override
  final String? content;
  final Map<dynamic, dynamic> _metadata;
  @override
  @JsonKey()
  Map<dynamic, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  final List<MediaModel>? _media;
  @override
  @ListMediaModelJsonConverter()
  List<MediaModel>? get media {
    final value = _media;
    if (value == null) return null;
    if (_media is EqualUnmodifiableListView) return _media;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Message status data
  final List<String> _readBy;

  /// Message status data
  @override
  @JsonKey()
  List<String> get readBy {
    if (_readBy is EqualUnmodifiableListView) return _readBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_readBy);
  }

  final List<String> _deleteBy;
  @override
  @JsonKey()
  List<String> get deleteBy {
    if (_deleteBy is EqualUnmodifiableListView) return _deleteBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_deleteBy);
  }

  @override
  @TimestampConverter()
  final DateTime? sendAt;
  @override
  final String? sendStatus;
  @override
  @JsonKey()
  final bool fromWeb;

  @override
  String toString() {
    return 'MessageModel(id: $id, tchatId: $tchatId, senderId: $senderId, messageType: $messageType, replyTo: $replyTo, content: $content, metadata: $metadata, media: $media, readBy: $readBy, deleteBy: $deleteBy, sendAt: $sendAt, sendStatus: $sendStatus, fromWeb: $fromWeb)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tchatId, tchatId) || other.tchatId == tchatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.replyTo, replyTo) || other.replyTo == replyTo) &&
            (identical(other.content, content) || other.content == content) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._media, _media) &&
            const DeepCollectionEquality().equals(other._readBy, _readBy) &&
            const DeepCollectionEquality().equals(other._deleteBy, _deleteBy) &&
            (identical(other.sendAt, sendAt) || other.sendAt == sendAt) &&
            (identical(other.sendStatus, sendStatus) ||
                other.sendStatus == sendStatus) &&
            (identical(other.fromWeb, fromWeb) || other.fromWeb == fromWeb));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tchatId,
      senderId,
      messageType,
      replyTo,
      content,
      const DeepCollectionEquality().hash(_metadata),
      const DeepCollectionEquality().hash(_media),
      const DeepCollectionEquality().hash(_readBy),
      const DeepCollectionEquality().hash(_deleteBy),
      sendAt,
      sendStatus,
      fromWeb);

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      __$$MessageModelImplCopyWithImpl<_$MessageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageModelImplToJson(
      this,
    );
  }
}

abstract class _MessageModel implements MessageModel {
  const factory _MessageModel(
      {final String? id,
      required final String tchatId,
      required final String senderId,
      required final String messageType,
      @MessageModelJsonConverter() final MessageModel? replyTo,
      final String? content,
      final Map<dynamic, dynamic> metadata,
      @ListMediaModelJsonConverter() final List<MediaModel>? media,
      final List<String> readBy,
      final List<String> deleteBy,
      @TimestampConverter() final DateTime? sendAt,
      final String? sendStatus,
      final bool fromWeb}) = _$MessageModelImpl;

  factory _MessageModel.fromJson(Map<String, dynamic> json) =
      _$MessageModelImpl.fromJson;

  /// Principal data
  @override
  String? get id;
  @override
  String get tchatId;
  @override
  String get senderId;

  /// Message data
  @override
  String get messageType;
  @override
  @MessageModelJsonConverter()
  MessageModel? get replyTo;
  @override
  String? get content;
  @override
  Map<dynamic, dynamic> get metadata;
  @override
  @ListMediaModelJsonConverter()
  List<MediaModel>? get media;

  /// Message status data
  @override
  List<String> get readBy;
  @override
  List<String> get deleteBy;
  @override
  @TimestampConverter()
  DateTime? get sendAt;
  @override
  String? get sendStatus;
  @override
  bool get fromWeb;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageModelImplCopyWith<_$MessageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
