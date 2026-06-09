import 'package:flutter/foundation.dart';

@immutable
sealed class AppState {}

@immutable
final class AppIdleState extends AppState {}
