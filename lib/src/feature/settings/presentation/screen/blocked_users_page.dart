import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_loader.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/entity/blocked_user.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

@RoutePage()
class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final MeRepository _repo = locator<MeRepository>();
  bool _loading = true;
  List<BlockedUser> _users = const <BlockedUser>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _users = await _repo.getBlocked();
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _unblock(BlockedUser user) async {
    final previous = _users;
    setState(
      () => _users = _users.where((BlockedUser u) => u.id != user.id).toList(),
    );
    try {
      await _repo.unblock(user.id);
    } catch (_) {
      // Roll back: the user is still blocked server-side, so silently
      // removing the row would lie about it.
      if (mounted) {
        setState(() => _users = previous);
        context.showSnackBar(context.l10N.settings_save_failed);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColor.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 22),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(context.l10N.settings_blocked_users),
      ),
      body: _loading
          ? const DSLoader()
          : _users.isEmpty
          ? Center(
              child: Text(
                context.l10N.settings_no_blocked,
                style: const TextStyle(
                  fontFamily: dsFontFamily,
                  fontSize: DSFontSize.bodyMedium,
                  color: DSColor.onSurface45,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: _users.length,
              itemBuilder: (BuildContext context, int i) {
                final BlockedUser u = _users[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: <Widget>[
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: DSColor.lowBlack,
                        backgroundImage: u.avatarUrl == null
                            ? null
                            : NetworkImage(u.avatarUrl!),
                        child: u.avatarUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 22,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          u.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: dsFontFamily,
                            fontSize: DSFontSize.bodyLarge,
                            fontWeight: DSFontWeight.semiBold,
                            color: DSColor.onSurface,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _unblock(u),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: DSColor.onSurface07,
                            borderRadius: BorderRadius.circular(
                              DSBorderRadius.chip,
                            ),
                            border: Border.all(
                              color: DSColor.onSurface15,
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            context.l10N.settings_unblock,
                            style: const TextStyle(
                              fontFamily: dsFontFamily,
                              fontSize: DSFontSize.bodyMedium,
                              fontWeight: DSFontWeight.semiBold,
                              color: DSColor.onSurface75,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
