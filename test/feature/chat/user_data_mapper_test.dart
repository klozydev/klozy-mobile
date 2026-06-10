import 'package:flutter_test/flutter_test.dart';
import 'package:klozy/src/domain/social/entity/social_profile.dart';
import 'package:klozy/src/feature/chat/bridge/user_data_mapper.dart';

void main() {
  test('maps SocialProfile into the SocialUser map shape chat expects', () {
    const profile = SocialProfile(
      id: 'u1',
      handle: 'janedoe',
      displayName: 'Jane Doe',
      avatarUrl: 'https://cdn/x.png',
      rating: 4.5,
    );

    final map = socialProfileToChatUserMap(profile);

    expect(map['firstname'], 'Jane Doe');
    expect(map['lastname'], '');
    expect(map['pseudo'], 'janedoe');
    expect(map['profileImage'], 'https://cdn/x.png');
    expect(map['rating'], 4.5);
  });
}
