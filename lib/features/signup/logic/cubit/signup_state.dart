import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/features/signup/data/model/signup_response.dart';

@immutable
sealed class SignUpState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final SignUpResponse response;
  SignUpSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class SignUpError extends SignUpState {
  final String message;
  SignUpError(this.message);
  @override
  List<Object?> get props => [message];
}
