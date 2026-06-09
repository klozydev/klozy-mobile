import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/feature/profile/presentation/widget/profile_view.dart';

/// A public user's profile (pushed by id).
@RoutePage()
class UserProfilePage extends StatelessWidget {
  final String userId;

  const UserProfilePage({@PathParam('id') required this.userId, super.key});

  @override
  Widget build(BuildContext context) => ProfileView(userId: userId);
}
