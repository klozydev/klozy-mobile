import 'package:klozy/src/domain/social/entity/social_profile.dart';

/// Maps mobile's [SocialProfile] into the loose map the chat package feeds to
/// `SocialUser.fromJson(...)` (keys: firstname, lastname, pseudo, email,
/// rating, profileImage). The chat UI shows firstname (+ lastname) as the
/// display name and profileImage as the avatar.
Map<String, dynamic> socialProfileToChatUserMap(SocialProfile p) {
  return <String, dynamic>{
    'firstname': p.displayName,
    'lastname': '',
    'pseudo': p.displayName,
    'email': '',
    'rating': p.rating,
    'profileImage': p.avatarUrl,
  };
}
