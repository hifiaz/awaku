import 'package:equatable/equatable.dart';

class GeneralState extends Equatable {
  const GeneralState();

  @override
  List<Object> get props => [];
}

class GeneralStateInitial extends GeneralState {
  const GeneralStateInitial();

  @override
  List<Object> get props => [];
}

class GeneralStateLoading extends GeneralState {
  const GeneralStateLoading();

  @override
  List<Object> get props => [];
}

class GeneralStateSuccess extends GeneralState {
  const GeneralStateSuccess();

  @override
  List<Object> get props => [];
}

class GeneralStateError extends GeneralState {
  final String error;

  const GeneralStateError(this.error);

  @override
  List<Object> get props => [error];
}
