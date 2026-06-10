// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tchat_status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TchatStatusModel _$TchatStatusModelFromJson(Map<String, dynamic> json) {
  return _TchatStatusModel.fromJson(json);
}

/// @nodoc
mixin _$TchatStatusModel {
  String get tchatId => throw _privateConstructorUsedError;
  List<TchatUserStatusModel> get status => throw _privateConstructorUsedError;

  /// Serializes this TchatStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TchatStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TchatStatusModelCopyWith<TchatStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TchatStatusModelCopyWith<$Res> {
  factory $TchatStatusModelCopyWith(
          TchatStatusModel value, $Res Function(TchatStatusModel) then) =
      _$TchatStatusModelCopyWithImpl<$Res, TchatStatusModel>;
  @useResult
  $Res call({String tchatId, List<TchatUserStatusModel> status});
}

/// @nodoc
class _$TchatStatusModelCopyWithImpl<$Res, $Val extends TchatStatusModel>
    implements $TchatStatusModelCopyWith<$Res> {
  _$TchatStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TchatStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tchatId = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      tchatId: null == tchatId
          ? _value.tchatId
          : tchatId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as List<TchatUserStatusModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TchatStatusModelImplCopyWith<$Res>
    implements $TchatStatusModelCopyWith<$Res> {
  factory _$$TchatStatusModelImplCopyWith(_$TchatStatusModelImpl value,
          $Res Function(_$TchatStatusModelImpl) then) =
      __$$TchatStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String tchatId, List<TchatUserStatusModel> status});
}

/// @nodoc
class __$$TchatStatusModelImplCopyWithImpl<$Res>
    extends _$TchatStatusModelCopyWithImpl<$Res, _$TchatStatusModelImpl>
    implements _$$TchatStatusModelImplCopyWith<$Res> {
  __$$TchatStatusModelImplCopyWithImpl(_$TchatStatusModelImpl _value,
      $Res Function(_$TchatStatusModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TchatStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? tchatId = null,
    Object? status = null,
  }) {
    return _then(_$TchatStatusModelImpl(
      tchatId: null == tchatId
          ? _value.tchatId
          : tchatId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value._status
          : status // ignore: cast_nullable_to_non_nullable
              as List<TchatUserStatusModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TchatStatusModelImpl implements _TchatStatusModel {
  const _$TchatStatusModelImpl(
      {required this.tchatId,
      final List<TchatUserStatusModel> status = const []})
      : _status = status;

  factory _$TchatStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TchatStatusModelImplFromJson(json);

  @override
  final String tchatId;
  final List<TchatUserStatusModel> _status;
  @override
  @JsonKey()
  List<TchatUserStatusModel> get status {
    if (_status is EqualUnmodifiableListView) return _status;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_status);
  }

  @override
  String toString() {
    return 'TchatStatusModel(tchatId: $tchatId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TchatStatusModelImpl &&
            (identical(other.tchatId, tchatId) || other.tchatId == tchatId) &&
            const DeepCollectionEquality().equals(other._status, _status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, tchatId, const DeepCollectionEquality().hash(_status));

  /// Create a copy of TchatStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TchatStatusModelImplCopyWith<_$TchatStatusModelImpl> get copyWith =>
      __$$TchatStatusModelImplCopyWithImpl<_$TchatStatusModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TchatStatusModelImplToJson(
      this,
    );
  }
}

abstract class _TchatStatusModel implements TchatStatusModel {
  const factory _TchatStatusModel(
      {required final String tchatId,
      final List<TchatUserStatusModel> status}) = _$TchatStatusModelImpl;

  factory _TchatStatusModel.fromJson(Map<String, dynamic> json) =
      _$TchatStatusModelImpl.fromJson;

  @override
  String get tchatId;
  @override
  List<TchatUserStatusModel> get status;

  /// Create a copy of TchatStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TchatStatusModelImplCopyWith<_$TchatStatusModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TchatUserStatusModel _$TchatUserStatusModelFromJson(Map<String, dynamic> json) {
  return _TchatUserStatusModel.fromJson(json);
}

/// @nodoc
mixin _$TchatUserStatusModel {
  String get userId => throw _privateConstructorUsedError;
  TchatingStatus get status => throw _privateConstructorUsedError;
  DateTime? get lastUpdate => throw _privateConstructorUsedError;

  /// Serializes this TchatUserStatusModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TchatUserStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TchatUserStatusModelCopyWith<TchatUserStatusModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TchatUserStatusModelCopyWith<$Res> {
  factory $TchatUserStatusModelCopyWith(TchatUserStatusModel value,
          $Res Function(TchatUserStatusModel) then) =
      _$TchatUserStatusModelCopyWithImpl<$Res, TchatUserStatusModel>;
  @useResult
  $Res call({String userId, TchatingStatus status, DateTime? lastUpdate});
}

/// @nodoc
class _$TchatUserStatusModelCopyWithImpl<$Res,
        $Val extends TchatUserStatusModel>
    implements $TchatUserStatusModelCopyWith<$Res> {
  _$TchatUserStatusModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TchatUserStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? status = null,
    Object? lastUpdate = freezed,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TchatingStatus,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TchatUserStatusModelImplCopyWith<$Res>
    implements $TchatUserStatusModelCopyWith<$Res> {
  factory _$$TchatUserStatusModelImplCopyWith(_$TchatUserStatusModelImpl value,
          $Res Function(_$TchatUserStatusModelImpl) then) =
      __$$TchatUserStatusModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, TchatingStatus status, DateTime? lastUpdate});
}

/// @nodoc
class __$$TchatUserStatusModelImplCopyWithImpl<$Res>
    extends _$TchatUserStatusModelCopyWithImpl<$Res, _$TchatUserStatusModelImpl>
    implements _$$TchatUserStatusModelImplCopyWith<$Res> {
  __$$TchatUserStatusModelImplCopyWithImpl(_$TchatUserStatusModelImpl _value,
      $Res Function(_$TchatUserStatusModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TchatUserStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? status = null,
    Object? lastUpdate = freezed,
  }) {
    return _then(_$TchatUserStatusModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as TchatingStatus,
      lastUpdate: freezed == lastUpdate
          ? _value.lastUpdate
          : lastUpdate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TchatUserStatusModelImpl implements _TchatUserStatusModel {
  const _$TchatUserStatusModelImpl(
      {required this.userId, required this.status, this.lastUpdate});

  factory _$TchatUserStatusModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TchatUserStatusModelImplFromJson(json);

  @override
  final String userId;
  @override
  final TchatingStatus status;
  @override
  final DateTime? lastUpdate;

  @override
  String toString() {
    return 'TchatUserStatusModel(userId: $userId, status: $status, lastUpdate: $lastUpdate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TchatUserStatusModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.lastUpdate, lastUpdate) ||
                other.lastUpdate == lastUpdate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, status, lastUpdate);

  /// Create a copy of TchatUserStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TchatUserStatusModelImplCopyWith<_$TchatUserStatusModelImpl>
      get copyWith =>
          __$$TchatUserStatusModelImplCopyWithImpl<_$TchatUserStatusModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TchatUserStatusModelImplToJson(
      this,
    );
  }
}

abstract class _TchatUserStatusModel implements TchatUserStatusModel {
  const factory _TchatUserStatusModel(
      {required final String userId,
      required final TchatingStatus status,
      final DateTime? lastUpdate}) = _$TchatUserStatusModelImpl;

  factory _TchatUserStatusModel.fromJson(Map<String, dynamic> json) =
      _$TchatUserStatusModelImpl.fromJson;

  @override
  String get userId;
  @override
  TchatingStatus get status;
  @override
  DateTime? get lastUpdate;

  /// Create a copy of TchatUserStatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TchatUserStatusModelImplCopyWith<_$TchatUserStatusModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
