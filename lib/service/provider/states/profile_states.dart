import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileStateInitial extends ProfileState {
  const ProfileStateInitial();

  @override
  List<Object> get props => [];
}

class ProfileStateLoading extends ProfileState {
  const ProfileStateLoading();

  @override
  List<Object> get props => [];
}

class ProfileStateSuccess extends ProfileState {
  const ProfileStateSuccess();

  @override
  List<Object> get props => [];
}

class ProfileStateError extends ProfileState {
  final String error;

  const ProfileStateError(this.error);

  @override
  List<Object> get props => [error];
}
