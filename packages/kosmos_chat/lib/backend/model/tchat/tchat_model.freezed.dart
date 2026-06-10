// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tchat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TchatModel _$TchatModelFromJson(Map<String, dynamic> json) {
  return _TchatModel.fromJson(json);
}

/// @nodoc
mixin _$TchatModel {
  String? get id => throw _privateConstructorUsedError;

  ///Tchat data
  List<String> get participants =>
      throw _privateConstructorUsedError; // admin give permission to all users to admin the tchat only for changing tchat name and picture and adding new users
  bool get allUserCanAdmin => throw _privateConstructorUsedError;
  Map<String, DeletedMessageHistory> get deletedMessageHistory =>
      throw _privateConstructorUsedError;

  /// Group data
  bool get isGroup => throw _privateConstructorUsedError;
  TchatType get type => throw _privateConstructorUsedError;
  String? get adminId =>
      throw _privateConstructorUsedError; // maps to refer when user X muted user Y => X_Y
  List<String> get mutedUsersList =>
      throw _privateConstructorUsedError; // maps to refer when user X muted all users
  List<String> get chatMutedBy => throw _privateConstructorUsedError;
  String? get tchatName => throw _privateConstructorUsedError;
  String? get tchatPicture => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get createdAt => throw _privateConstructorUsedError;
  bool get closed => throw _privateConstructorUsedError;

  /// Last message data
  @MessageModelJsonConverter()
  MessageModel? get lastMessage => throw _privateConstructorUsedError;
  List<String> get lastMessageSeenBy => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get lastMessageSentAt => throw _privateConstructorUsedError;
  Map<String, dynamic> get metadata => throw _privateConstructorUsedError;
  List<String> get admins => throw _privateConstructorUsedError;

  /// Deleted status
  List<TchatDeletedStatus>? get deletedBy =>
      throw _privateConstructorUsedError; // Blocked status (only for [TchatType.oneToOne] tchat)
  List<String> get blockedByUsers => throw _privateConstructorUsedError;

  /// Serializes this TchatModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TchatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TchatModelCopyWith<TchatModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TchatModelCopyWith<$Res> {
  factory $TchatModelCopyWith(
          TchatModel value, $Res Function(TchatModel) then) =
      _$TchatModelCopyWithImpl<$Res, TchatModel>;
  @useResult
  $Res call(
      {String? id,
      List<String> participants,
      bool allUserCanAdmin,
      Map<String, DeletedMessageHistory> deletedMessageHistory,
      bool isGroup,
      TchatType type,
      String? adminId,
      List<String> mutedUsersList,
      List<String> chatMutedBy,
      String? tchatName,
      String? tchatPicture,
      @TimestampConverter() DateTime? createdAt,
      bool closed,
      @MessageModelJsonConverter() MessageModel? lastMessage,
      List<String> lastMessageSeenBy,
      @TimestampConverter() DateTime? lastMessageSentAt,
      Map<String, dynamic> metadata,
      List<String> admins,
      List<TchatDeletedStatus>? deletedBy,
      List<String> blockedByUsers});

  $MessageModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$TchatModelCopyWithImpl<$Res, $Val extends TchatModel>
    implements $TchatModelCopyWith<$Res> {
  _$TchatModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TchatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? participants = null,
    Object? allUserCanAdmin = null,
    Object? deletedMessageHistory = null,
    Object? isGroup = null,
    Object? type = null,
    Object? adminId = freezed,
    Object? mutedUsersList = null,
    Object? chatMutedBy = null,
    Object? tchatName = freezed,
    Object? tchatPicture = freezed,
    Object? createdAt = freezed,
    Object? closed = null,
    Object? lastMessage = freezed,
    Object? lastMessageSeenBy = null,
    Object? lastMessageSentAt = freezed,
    Object? metadata = null,
    Object? admins = null,
    Object? deletedBy = freezed,
    Object? blockedByUsers = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      allUserCanAdmin: null == allUserCanAdmin
          ? _value.allUserCanAdmin
          : allUserCanAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedMessageHistory: null == deletedMessageHistory
          ? _value.deletedMessageHistory
          : deletedMessageHistory // ignore: cast_nullable_to_non_nullable
              as Map<String, DeletedMessageHistory>,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TchatType,
      adminId: freezed == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String?,
      mutedUsersList: null == mutedUsersList
          ? _value.mutedUsersList
          : mutedUsersList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chatMutedBy: null == chatMutedBy
          ? _value.chatMutedBy
          : chatMutedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tchatName: freezed == tchatName
          ? _value.tchatName
          : tchatName // ignore: cast_nullable_to_non_nullable
              as String?,
      tchatPicture: freezed == tchatPicture
          ? _value.tchatPicture
          : tchatPicture // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closed: null == closed
          ? _value.closed
          : closed // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as MessageModel?,
      lastMessageSeenBy: null == lastMessageSeenBy
          ? _value.lastMessageSeenBy
          : lastMessageSeenBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastMessageSentAt: freezed == lastMessageSentAt
          ? _value.lastMessageSentAt
          : lastMessageSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      admins: null == admins
          ? _value.admins
          : admins // ignore: cast_nullable_to_non_nullable
              as List<String>,
      deletedBy: freezed == deletedBy
          ? _value.deletedBy
          : deletedBy // ignore: cast_nullable_to_non_nullable
              as List<TchatDeletedStatus>?,
      blockedByUsers: null == blockedByUsers
          ? _value.blockedByUsers
          : blockedByUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  /// Create a copy of TchatModel
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
abstract class _$$TchatModelImplCopyWith<$Res>
    implements $TchatModelCopyWith<$Res> {
  factory _$$TchatModelImplCopyWith(
          _$TchatModelImpl value, $Res Function(_$TchatModelImpl) then) =
      __$$TchatModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? id,
      List<String> participants,
      bool allUserCanAdmin,
      Map<String, DeletedMessageHistory> deletedMessageHistory,
      bool isGroup,
      TchatType type,
      String? adminId,
      List<String> mutedUsersList,
      List<String> chatMutedBy,
      String? tchatName,
      String? tchatPicture,
      @TimestampConverter() DateTime? createdAt,
      bool closed,
      @MessageModelJsonConverter() MessageModel? lastMessage,
      List<String> lastMessageSeenBy,
      @TimestampConverter() DateTime? lastMessageSentAt,
      Map<String, dynamic> metadata,
      List<String> admins,
      List<TchatDeletedStatus>? deletedBy,
      List<String> blockedByUsers});

  @override
  $MessageModelCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$TchatModelImplCopyWithImpl<$Res>
    extends _$TchatModelCopyWithImpl<$Res, _$TchatModelImpl>
    implements _$$TchatModelImplCopyWith<$Res> {
  __$$TchatModelImplCopyWithImpl(
      _$TchatModelImpl _value, $Res Function(_$TchatModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TchatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? participants = null,
    Object? allUserCanAdmin = null,
    Object? deletedMessageHistory = null,
    Object? isGroup = null,
    Object? type = null,
    Object? adminId = freezed,
    Object? mutedUsersList = null,
    Object? chatMutedBy = null,
    Object? tchatName = freezed,
    Object? tchatPicture = freezed,
    Object? createdAt = freezed,
    Object? closed = null,
    Object? lastMessage = freezed,
    Object? lastMessageSeenBy = null,
    Object? lastMessageSentAt = freezed,
    Object? metadata = null,
    Object? admins = null,
    Object? deletedBy = freezed,
    Object? blockedByUsers = null,
  }) {
    return _then(_$TchatModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _value._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      allUserCanAdmin: null == allUserCanAdmin
          ? _value.allUserCanAdmin
          : allUserCanAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedMessageHistory: null == deletedMessageHistory
          ? _value._deletedMessageHistory
          : deletedMessageHistory // ignore: cast_nullable_to_non_nullable
              as Map<String, DeletedMessageHistory>,
      isGroup: null == isGroup
          ? _value.isGroup
          : isGroup // ignore: cast_nullable_to_non_nullable
              as bool,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TchatType,
      adminId: freezed == adminId
          ? _value.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String?,
      mutedUsersList: null == mutedUsersList
          ? _value._mutedUsersList
          : mutedUsersList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      chatMutedBy: null == chatMutedBy
          ? _value._chatMutedBy
          : chatMutedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tchatName: freezed == tchatName
          ? _value.tchatName
          : tchatName // ignore: cast_nullable_to_non_nullable
              as String?,
      tchatPicture: freezed == tchatPicture
          ? _value.tchatPicture
          : tchatPicture // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      closed: null == closed
          ? _value.closed
          : closed // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: freezed == lastMessage
          ? _value.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as MessageModel?,
      lastMessageSeenBy: null == lastMessageSeenBy
          ? _value._lastMessageSeenBy
          : lastMessageSeenBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      lastMessageSentAt: freezed == lastMessageSentAt
          ? _value.lastMessageSentAt
          : lastMessageSentAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      metadata: null == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      admins: null == admins
          ? _value._admins
          : admins // ignore: cast_nullable_to_non_nullable
              as List<String>,
      deletedBy: freezed == deletedBy
          ? _value._deletedBy
          : deletedBy // ignore: cast_nullable_to_non_nullable
              as List<TchatDeletedStatus>?,
      blockedByUsers: null == blockedByUsers
          ? _value._blockedByUsers
          : blockedByUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TchatModelImpl implements _TchatModel {
  const _$TchatModelImpl(
      {this.id,
      required final List<String> participants,
      this.allUserCanAdmin = false,
      final Map<String, DeletedMessageHistory> deletedMessageHistory = const {},
      this.isGroup = false,
      this.type = TchatType.oneToOne,
      this.adminId,
      final List<String> mutedUsersList = const [],
      final List<String> chatMutedBy = const [],
      this.tchatName,
      this.tchatPicture,
      @TimestampConverter() this.createdAt,
      this.closed = false,
      @MessageModelJsonConverter() this.lastMessage,
      final List<String> lastMessageSeenBy = const [],
      @TimestampConverter() this.lastMessageSentAt,
      final Map<String, dynamic> metadata = const {},
      final List<String> admins = const [],
      final List<TchatDeletedStatus>? deletedBy,
      final List<String> blockedByUsers = const []})
      : _participants = participants,
        _deletedMessageHistory = deletedMessageHistory,
        _mutedUsersList = mutedUsersList,
        _chatMutedBy = chatMutedBy,
        _lastMessageSeenBy = lastMessageSeenBy,
        _metadata = metadata,
        _admins = admins,
        _deletedBy = deletedBy,
        _blockedByUsers = blockedByUsers;

  factory _$TchatModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TchatModelImplFromJson(json);

  @override
  final String? id;

  ///Tchat data
  final List<String> _participants;

  ///Tchat data
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

// admin give permission to all users to admin the tchat only for changing tchat name and picture and adding new users
  @override
  @JsonKey()
  final bool allUserCanAdmin;
  final Map<String, DeletedMessageHistory> _deletedMessageHistory;
  @override
  @JsonKey()
  Map<String, DeletedMessageHistory> get deletedMessageHistory {
    if (_deletedMessageHistory is EqualUnmodifiableMapView)
      return _deletedMessageHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_deletedMessageHistory);
  }

  /// Group data
  @override
  @JsonKey()
  final bool isGroup;
  @override
  @JsonKey()
  final TchatType type;
  @override
  final String? adminId;
// maps to refer when user X muted user Y => X_Y
  final List<String> _mutedUsersList;
// maps to refer when user X muted user Y => X_Y
  @override
  @JsonKey()
  List<String> get mutedUsersList {
    if (_mutedUsersList is EqualUnmodifiableListView) return _mutedUsersList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mutedUsersList);
  }

// maps to refer when user X muted all users
  final List<String> _chatMutedBy;
// maps to refer when user X muted all users
  @override
  @JsonKey()
  List<String> get chatMutedBy {
    if (_chatMutedBy is EqualUnmodifiableListView) return _chatMutedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chatMutedBy);
  }

  @override
  final String? tchatName;
  @override
  final String? tchatPicture;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @JsonKey()
  final bool closed;

  /// Last message data
  @override
  @MessageModelJsonConverter()
  final MessageModel? lastMessage;
  final List<String> _lastMessageSeenBy;
  @override
  @JsonKey()
  List<String> get lastMessageSeenBy {
    if (_lastMessageSeenBy is EqualUnmodifiableListView)
      return _lastMessageSeenBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lastMessageSeenBy);
  }

  @override
  @TimestampConverter()
  final DateTime? lastMessageSentAt;
  final Map<String, dynamic> _metadata;
  @override
  @JsonKey()
  Map<String, dynamic> get metadata {
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_metadata);
  }

  final List<String> _admins;
  @override
  @JsonKey()
  List<String> get admins {
    if (_admins is EqualUnmodifiableListView) return _admins;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_admins);
  }

  /// Deleted status
  final List<TchatDeletedStatus>? _deletedBy;

  /// Deleted status
  @override
  List<TchatDeletedStatus>? get deletedBy {
    final value = _deletedBy;
    if (value == null) return null;
    if (_deletedBy is EqualUnmodifiableListView) return _deletedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

// Blocked status (only for [TchatType.oneToOne] tchat)
  final List<String> _blockedByUsers;
// Blocked status (only for [TchatType.oneToOne] tchat)
  @override
  @JsonKey()
  List<String> get blockedByUsers {
    if (_blockedByUsers is EqualUnmodifiableListView) return _blockedByUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedByUsers);
  }

  @override
  String toString() {
    return 'TchatModel(id: $id, participants: $participants, allUserCanAdmin: $allUserCanAdmin, deletedMessageHistory: $deletedMessageHistory, isGroup: $isGroup, type: $type, adminId: $adminId, mutedUsersList: $mutedUsersList, chatMutedBy: $chatMutedBy, tchatName: $tchatName, tchatPicture: $tchatPicture, createdAt: $createdAt, closed: $closed, lastMessage: $lastMessage, lastMessageSeenBy: $lastMessageSeenBy, lastMessageSentAt: $lastMessageSentAt, metadata: $metadata, admins: $admins, deletedBy: $deletedBy, blockedByUsers: $blockedByUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TchatModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.allUserCanAdmin, allUserCanAdmin) ||
                other.allUserCanAdmin == allUserCanAdmin) &&
            const DeepCollectionEquality()
                .equals(other._deletedMessageHistory, _deletedMessageHistory) &&
            (identical(other.isGroup, isGroup) || other.isGroup == isGroup) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            const DeepCollectionEquality()
                .equals(other._mutedUsersList, _mutedUsersList) &&
            const DeepCollectionEquality()
                .equals(other._chatMutedBy, _chatMutedBy) &&
            (identical(other.tchatName, tchatName) ||
                other.tchatName == tchatName) &&
            (identical(other.tchatPicture, tchatPicture) ||
                other.tchatPicture == tchatPicture) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.closed, closed) || other.closed == closed) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            const DeepCollectionEquality()
                .equals(other._lastMessageSeenBy, _lastMessageSeenBy) &&
            (identical(other.lastMessageSentAt, lastMessageSentAt) ||
                other.lastMessageSentAt == lastMessageSentAt) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            const DeepCollectionEquality().equals(other._admins, _admins) &&
            const DeepCollectionEquality()
                .equals(other._deletedBy, _deletedBy) &&
            const DeepCollectionEquality()
                .equals(other._blockedByUsers, _blockedByUsers));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        const DeepCollectionEquality().hash(_participants),
        allUserCanAdmin,
        const DeepCollectionEquality().hash(_deletedMessageHistory),
        isGroup,
        type,
        adminId,
        const DeepCollectionEquality().hash(_mutedUsersList),
        const DeepCollectionEquality().hash(_chatMutedBy),
        tchatName,
        tchatPicture,
        createdAt,
        closed,
        lastMessage,
        const DeepCollectionEquality().hash(_lastMessageSeenBy),
        lastMessageSentAt,
        const DeepCollectionEquality().hash(_metadata),
        const DeepCollectionEquality().hash(_admins),
        const DeepCollectionEquality().hash(_deletedBy),
        const DeepCollectionEquality().hash(_blockedByUsers)
      ]);

  /// Create a copy of TchatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TchatModelImplCopyWith<_$TchatModelImpl> get copyWith =>
      __$$TchatModelImplCopyWithImpl<_$TchatModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TchatModelImplToJson(
      this,
    );
  }
}

abstract class _TchatModel implements TchatModel {
  const factory _TchatModel(
      {final String? id,
      required final List<String> participants,
      final bool allUserCanAdmin,
      final Map<String, DeletedMessageHistory> deletedMessageHistory,
      final bool isGroup,
      final TchatType type,
      final String? adminId,
      final List<String> mutedUsersList,
      final List<String> chatMutedBy,
      final String? tchatName,
      final String? tchatPicture,
      @TimestampConverter() final DateTime? createdAt,
      final bool closed,
      @MessageModelJsonConverter() final MessageModel? lastMessage,
      final List<String> lastMessageSeenBy,
      @TimestampConverter() final DateTime? lastMessageSentAt,
      final Map<String, dynamic> metadata,
      final List<String> admins,
      final List<TchatDeletedStatus>? deletedBy,
      final List<String> blockedByUsers}) = _$TchatModelImpl;

  factory _TchatModel.fromJson(Map<String, dynamic> json) =
      _$TchatModelImpl.fromJson;

  @override
  String? get id;

  ///Tchat data
  @override
  List<String>
      get participants; // admin give permission to all users to admin the tchat only for changing tchat name and picture and adding new users
  @override
  bool get allUserCanAdmin;
  @override
  Map<String, DeletedMessageHistory> get deletedMessageHistory;

  /// Group data
  @override
  bool get isGroup;
  @override
  TchatType get type;
  @override
  String? get adminId; // maps to refer when user X muted user Y => X_Y
  @override
  List<String> get mutedUsersList; // maps to refer when user X muted all users
  @override
  List<String> get chatMutedBy;
  @override
  String? get tchatName;
  @override
  String? get tchatPicture;
  @override
  @TimestampConverter()
  DateTime? get createdAt;
  @override
  bool get closed;

  /// Last message data
  @override
  @MessageModelJsonConverter()
  MessageModel? get lastMessage;
  @override
  List<String> get lastMessageSeenBy;
  @override
  @TimestampConverter()
  DateTime? get lastMessageSentAt;
  @override
  Map<String, dynamic> get metadata;
  @override
  List<String> get admins;

  /// Deleted status
  @override
  List<TchatDeletedStatus>?
      get deletedBy; // Blocked status (only for [TchatType.oneToOne] tchat)
  @override
  List<String> get blockedByUsers;

  /// Create a copy of TchatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TchatModelImplCopyWith<_$TchatModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TchatDeletedStatus _$TchatDeletedStatusFromJson(Map<String, dynamic> json) {
  return _TchatDeletedStatus.fromJson(json);
}

/// @nodoc
mixin _$TchatDeletedStatus {
  String get userId => throw _privateConstructorUsedError;
  @TimestampConverter()
  DateTime? get deletedAt => throw _privateConstructorUsedError;

  /// Serializes this TchatDeletedStatus to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TchatDeletedStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TchatDeletedStatusCopyWith<TchatDeletedStatus> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TchatDeletedStatusCopyWith<$Res> {
  factory $TchatDeletedStatusCopyWith(
          TchatDeletedStatus value, $Res Function(TchatDeletedStatus) then) =
      _$TchatDeletedStatusCopyWithImpl<$Res, TchatDeletedStatus>;
  @useResult
  $Res call({String userId, @TimestampConverter() DateTime? deletedAt});
}

/// @nodoc
class _$TchatDeletedStatusCopyWithImpl<$Res, $Val extends TchatDeletedStatus>
    implements $TchatDeletedStatusCopyWith<$Res> {
  _$TchatDeletedStatusCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TchatDeletedStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TchatDeletedStatusImplCopyWith<$Res>
    implements $TchatDeletedStatusCopyWith<$Res> {
  factory _$$TchatDeletedStatusImplCopyWith(_$TchatDeletedStatusImpl value,
          $Res Function(_$TchatDeletedStatusImpl) then) =
      __$$TchatDeletedStatusImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, @TimestampConverter() DateTime? deletedAt});
}

/// @nodoc
class __$$TchatDeletedStatusImplCopyWithImpl<$Res>
    extends _$TchatDeletedStatusCopyWithImpl<$Res, _$TchatDeletedStatusImpl>
    implements _$$TchatDeletedStatusImplCopyWith<$Res> {
  __$$TchatDeletedStatusImplCopyWithImpl(_$TchatDeletedStatusImpl _value,
      $Res Function(_$TchatDeletedStatusImpl) _then)
      : super(_value, _then);

  /// Create a copy of TchatDeletedStatus
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? deletedAt = freezed,
  }) {
    return _then(_$TchatDeletedStatusImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      deletedAt: freezed == deletedAt
          ? _value.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TchatDeletedStatusImpl implements _TchatDeletedStatus {
  const _$TchatDeletedStatusImpl(
      {required this.userId, @TimestampConverter() this.deletedAt});

  factory _$TchatDeletedStatusImpl.fromJson(Map<String, dynamic> json) =>
      _$$TchatDeletedStatusImplFromJson(json);

  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime? deletedAt;

  @override
  String toString() {
    return 'TchatDeletedStatus(userId: $userId, deletedAt: $deletedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TchatDeletedStatusImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, deletedAt);

  /// Create a copy of TchatDeletedStatus
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TchatDeletedStatusImplCopyWith<_$TchatDeletedStatusImpl> get copyWith =>
      __$$TchatDeletedStatusImplCopyWithImpl<_$TchatDeletedStatusImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TchatDeletedStatusImplToJson(
      this,
    );
  }
}

abstract class _TchatDeletedStatus implements TchatDeletedStatus {
  const factory _TchatDeletedStatus(
          {required final String userId,
          @TimestampConverter() final DateTime? deletedAt}) =
      _$TchatDeletedStatusImpl;

  factory _TchatDeletedStatus.fromJson(Map<String, dynamic> json) =
      _$TchatDeletedStatusImpl.fromJson;

  @override
  String get userId;
  @override
  @TimestampConverter()
  DateTime? get deletedAt;

  /// Create a copy of TchatDeletedStatus
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TchatDeletedStatusImplCopyWith<_$TchatDeletedStatusImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
