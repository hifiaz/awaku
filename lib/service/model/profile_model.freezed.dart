// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileModel {
  String? get uid;
  String? get email;
  int? get height;
  double? get weight;
  String? get name;
  String? get photoUrl;
  String? get gender;
  bool? get waterEnable;
  bool? get enableFasting;
  @TimestampConverter()
  DateTime? get dob;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileModelCopyWith<ProfileModel> get copyWith =>
      _$ProfileModelCopyWithImpl<ProfileModel>(
          this as ProfileModel, _$identity);

  /// Serializes this ProfileModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.waterEnable, waterEnable) ||
                other.waterEnable == waterEnable) &&
            (identical(other.enableFasting, enableFasting) ||
                other.enableFasting == enableFasting) &&
            (identical(other.dob, dob) || other.dob == dob));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, email, height, weight, name,
      photoUrl, gender, waterEnable, enableFasting, dob);

  @override
  String toString() {
    return 'ProfileModel(uid: $uid, email: $email, height: $height, weight: $weight, name: $name, photoUrl: $photoUrl, gender: $gender, waterEnable: $waterEnable, enableFasting: $enableFasting, dob: $dob)';
  }
}

/// @nodoc
abstract mixin class $ProfileModelCopyWith<$Res> {
  factory $ProfileModelCopyWith(
          ProfileModel value, $Res Function(ProfileModel) _then) =
      _$ProfileModelCopyWithImpl;
  @useResult
  $Res call(
      {String? uid,
      String? email,
      int? height,
      double? weight,
      String? name,
      String? photoUrl,
      String? gender,
      bool? waterEnable,
      bool? enableFasting,
      @TimestampConverter() DateTime? dob});
}

/// @nodoc
class _$ProfileModelCopyWithImpl<$Res> implements $ProfileModelCopyWith<$Res> {
  _$ProfileModelCopyWithImpl(this._self, this._then);

  final ProfileModel _self;
  final $Res Function(ProfileModel) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = freezed,
    Object? email = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? name = freezed,
    Object? photoUrl = freezed,
    Object? gender = freezed,
    Object? waterEnable = freezed,
    Object? enableFasting = freezed,
    Object? dob = freezed,
  }) {
    return _then(_self.copyWith(
      uid: freezed == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      waterEnable: freezed == waterEnable
          ? _self.waterEnable
          : waterEnable // ignore: cast_nullable_to_non_nullable
              as bool?,
      enableFasting: freezed == enableFasting
          ? _self.enableFasting
          : enableFasting // ignore: cast_nullable_to_non_nullable
              as bool?,
      dob: freezed == dob
          ? _self.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProfileModel].
extension ProfileModelPatterns on ProfileModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_ProfileModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_ProfileModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_ProfileModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String? uid,
            String? email,
            int? height,
            double? weight,
            String? name,
            String? photoUrl,
            String? gender,
            bool? waterEnable,
            bool? enableFasting,
            @TimestampConverter() DateTime? dob)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileModel() when $default != null:
        return $default(
            _that.uid,
            _that.email,
            _that.height,
            _that.weight,
            _that.name,
            _that.photoUrl,
            _that.gender,
            _that.waterEnable,
            _that.enableFasting,
            _that.dob);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String? uid,
            String? email,
            int? height,
            double? weight,
            String? name,
            String? photoUrl,
            String? gender,
            bool? waterEnable,
            bool? enableFasting,
            @TimestampConverter() DateTime? dob)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileModel():
        return $default(
            _that.uid,
            _that.email,
            _that.height,
            _that.weight,
            _that.name,
            _that.photoUrl,
            _that.gender,
            _that.waterEnable,
            _that.enableFasting,
            _that.dob);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String? uid,
            String? email,
            int? height,
            double? weight,
            String? name,
            String? photoUrl,
            String? gender,
            bool? waterEnable,
            bool? enableFasting,
            @TimestampConverter() DateTime? dob)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileModel() when $default != null:
        return $default(
            _that.uid,
            _that.email,
            _that.height,
            _that.weight,
            _that.name,
            _that.photoUrl,
            _that.gender,
            _that.waterEnable,
            _that.enableFasting,
            _that.dob);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProfileModel implements ProfileModel {
  const _ProfileModel(
      {this.uid,
      this.email,
      this.height,
      this.weight,
      this.name,
      this.photoUrl,
      this.gender,
      this.waterEnable,
      this.enableFasting,
      @TimestampConverter() this.dob});
  factory _ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  @override
  final String? uid;
  @override
  final String? email;
  @override
  final int? height;
  @override
  final double? weight;
  @override
  final String? name;
  @override
  final String? photoUrl;
  @override
  final String? gender;
  @override
  final bool? waterEnable;
  @override
  final bool? enableFasting;
  @override
  @TimestampConverter()
  final DateTime? dob;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileModelCopyWith<_ProfileModel> get copyWith =>
      __$ProfileModelCopyWithImpl<_ProfileModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProfileModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileModel &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.waterEnable, waterEnable) ||
                other.waterEnable == waterEnable) &&
            (identical(other.enableFasting, enableFasting) ||
                other.enableFasting == enableFasting) &&
            (identical(other.dob, dob) || other.dob == dob));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, uid, email, height, weight, name,
      photoUrl, gender, waterEnable, enableFasting, dob);

  @override
  String toString() {
    return 'ProfileModel(uid: $uid, email: $email, height: $height, weight: $weight, name: $name, photoUrl: $photoUrl, gender: $gender, waterEnable: $waterEnable, enableFasting: $enableFasting, dob: $dob)';
  }
}

/// @nodoc
abstract mixin class _$ProfileModelCopyWith<$Res>
    implements $ProfileModelCopyWith<$Res> {
  factory _$ProfileModelCopyWith(
          _ProfileModel value, $Res Function(_ProfileModel) _then) =
      __$ProfileModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? uid,
      String? email,
      int? height,
      double? weight,
      String? name,
      String? photoUrl,
      String? gender,
      bool? waterEnable,
      bool? enableFasting,
      @TimestampConverter() DateTime? dob});
}

/// @nodoc
class __$ProfileModelCopyWithImpl<$Res>
    implements _$ProfileModelCopyWith<$Res> {
  __$ProfileModelCopyWithImpl(this._self, this._then);

  final _ProfileModel _self;
  final $Res Function(_ProfileModel) _then;

  /// Create a copy of ProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? uid = freezed,
    Object? email = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? name = freezed,
    Object? photoUrl = freezed,
    Object? gender = freezed,
    Object? waterEnable = freezed,
    Object? enableFasting = freezed,
    Object? dob = freezed,
  }) {
    return _then(_ProfileModel(
      uid: freezed == uid
          ? _self.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      height: freezed == height
          ? _self.height
          : height // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _self.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      name: freezed == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _self.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _self.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      waterEnable: freezed == waterEnable
          ? _self.waterEnable
          : waterEnable // ignore: cast_nullable_to_non_nullable
              as bool?,
      enableFasting: freezed == enableFasting
          ? _self.enableFasting
          : enableFasting // ignore: cast_nullable_to_non_nullable
              as bool?,
      dob: freezed == dob
          ? _self.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
