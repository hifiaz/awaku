import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginStateInitial extends LoginState {
  const LoginStateInitial();

  @override
  List<Object> get props => [];
}

class LoginStateLoading extends LoginState {
  const LoginStateLoading();

  @override
  List<Object> get props => [];
}

class LoginStateSuccess extends LoginState {
  const LoginStateSuccess();

  @override
  List<Object> get props => [];
}


class LoginStateError extends LoginState {
  final String error;

  const LoginStateError(this.error);

  @override
  List<Object> get props => [error];
}

class LogoutStateSuccess extends LoginState {
  const LogoutStateSuccess();

  @override
  List<Object> get props => [];
}

class RegisterStateSuccess extends LoginState {
  final User user;

  const RegisterStateSuccess(this.user);

  @override
  List<Object> get props => [user];
}