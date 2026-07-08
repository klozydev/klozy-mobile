import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klozy/src/core/events/profile_changed_event.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/core/image/app_image_cache_manager.dart';
import 'package:klozy/src/design/components/ds_avatar_uploader.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/di/injection.dart';
import 'package:klozy/src/domain/me/me_repository.dart';

/// Picks an avatar from the gallery and uploads it to `/v1/me/avatar`.
class AvatarUploadWidget extends StatefulWidget {
  /// Existing avatar URL shown until a new photo is picked.
  final String? initialUrl;

  const AvatarUploadWidget({super.key, this.initialUrl});

  @override
  State<AvatarUploadWidget> createState() => _AvatarUploadWidgetState();
}

class _AvatarUploadWidgetState extends State<AvatarUploadWidget> {
  final ImagePicker _picker = ImagePicker();
  final MeRepository _repo = locator<MeRepository>();
  File? _file;
  bool _busy = false;

  Future<void> _pick() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() {
      _file = File(picked.path);
      _busy = true;
    });
    try {
      await _repo.uploadAvatar(picked.path);
      // Avatar changes are persisted immediately (independently of the form's
      // Save button), so broadcast here too — every screen showing the user's
      // avatar (Profile tab, Chat participant data, …) refreshes via EventBus.
      locator<EventBus>().fire(const ProfileChangedEvent());
    } catch (_) {
      if (mounted) context.showSnackBar(context.l10N.onboarding_avatar_failed);
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        DSAvatarUploader(
          onTap: _busy ? () {} : _pick,
          image: _file != null
              ? FileImage(_file!)
              : (widget.initialUrl == null
                    ? null
                    : CachedNetworkImageProvider(
                        widget.initialUrl!,
                        cacheManager: AppImageCacheManager.instance,
                      )),
        ),
        if (_busy)
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: DSColor.primary,
            ),
          ),
      ],
    );
  }
}
