import 'package:equatable/equatable.dart';

class NotificationSettings extends Equatable {
  final bool push;
  final bool email;

  const NotificationSettings({this.push = true, this.email = true});

  NotificationSettings copyWith({bool? push, bool? email}) {
    return NotificationSettings(
      push: push ?? this.push,
      email: email ?? this.email,
    );
  }

  @override
  List<Object?> get props => [push, email];
}
