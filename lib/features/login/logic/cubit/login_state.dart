import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import 'package:chat_app/features/login/data/model/login_response.dart';


@immutable
sealed class LoginState extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponse response;
  LoginSuccess(this.response);
  @override
  List<Object?> get props => [response];
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
  @override
  List<Object?> get props => [message];
}