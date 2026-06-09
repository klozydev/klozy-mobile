import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
sealed class AppEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

@immutable
final class AppInitEvent extends AppEvent {}
