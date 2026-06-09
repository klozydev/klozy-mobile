import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klozy/src/core/extensions/context_ext.dart';
import 'package:klozy/src/design/components/ds_bottom_bar.dart';
import 'package:klozy/src/design/components/ds_bottom_sheet.dart';
import 'package:klozy/src/design/components/ds_button_elevated.dart';
import 'package:klozy/src/design/components/ds_list_item.dart';
import 'package:klozy/src/design/tokens/ds_border_radius.dart';
import 'package:klozy/src/design/tokens/ds_color.dart';
import 'package:klozy/src/design/tokens/ds_font.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_bloc.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_event.dart';
import 'package:klozy/src/feature/sell/presentation/bloc/sell_state.dart';

const int _maxPhotos = 8;

class SellPhotosWidget extends StatefulWidget {
  final SellPhotosState state;

  const SellPhotosWidget({super.key, required this.state});

  @override
  State<SellPhotosWidget> createState() => _SellPhotosWidgetState();
}

class _SellPhotosWidgetState extends State<SellPhotosWidget> {
  late final List<String> _paths = <String>[...widget.state.paths];

  Future<void> _add() async {
    final source = await DSBottomSheet.show<ImageSource>(
      context,
      title: context.l10N.sell_add_a_photo,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DSListItem(
            leading: const Icon(Icons.camera_alt_outlined, color: Colors.white),
            title: context.l10N.sell_take_a_photo,
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          DSListItem(
            leading: const Icon(Icons.image_outlined, color: Colors.white),
            title: context.l10N.sell_choose_from_gallery,
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
    if (source == null) return;
    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final files = await picker.pickMultiImage();
      _append(files.map((XFile f) => f.path));
    } else {
      final file = await picker.pickImage(source: ImageSource.camera);
      if (file != null) _append(<String>[file.path]);
    }
  }

  void _append(Iterable<String> paths) {
    setState(() {
      for (final p in paths) {
        if (_paths.length < _maxPhotos) _paths.add(p);
      }
    });
  }

  void _remove(int index) => setState(() => _paths.removeAt(index));

  void _reorder(int from, int to) {
    setState(() {
      final String moved = _paths.removeAt(from);
      _paths.insert(to, moved);
    });
  }

  /// Long-press a photo to drag it onto another slot (first slot = cover).
  Widget _draggableTile(BuildContext context, int index) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (DragTargetDetails<int> d) => d.data != index,
      onAcceptWithDetails: (DragTargetDetails<int> d) =>
          _reorder(d.data, index),
      builder: (BuildContext context, List<int?> candidate, List<dynamic> r) {
        return LongPressDraggable<int>(
          data: index,
          feedback: SizedBox(
            width: 110,
            height: 146,
            child: Opacity(opacity: 0.9, child: _tile(context, index)),
          ),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _tile(context, index),
          ),
          child: _tile(context, index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _paths.isEmpty
                      ? context.l10N.sell_sell_in_seconds
                      : context.l10N.sell_your_photos,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.headlineLarge,
                    fontWeight: DSFontWeight.bold,
                    color: DSColor.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10N.sell_add_photos_hint,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: DSFontSize.bodyMedium,
                    color: DSColor.onSurface60,
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 3 / 4,
                  children: <Widget>[
                    for (int i = 0; i < _paths.length; i++)
                      _draggableTile(context, i),
                    if (_paths.length < _maxPhotos) _addTile(),
                  ],
                ),
              ],
            ),
          ),
        ),
        DSBottomBar(
          child: DSButtonElevated(
            text: context.l10N.sell_continue,
            isEnable: _paths.isNotEmpty,
            onPressed: () =>
                context.read<SellBloc>().add(SellAnalyzeRequested(_paths)),
          ),
        ),
      ],
    );
  }

  Widget _tile(BuildContext context, int index) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DSBorderRadius.image),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Image.file(File(_paths[index]), fit: BoxFit.cover),
          if (index == 0)
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: DSColor.primary,
                  borderRadius: BorderRadius.circular(DSBorderRadius.chip),
                ),
                child: Text(
                  context.l10N.sell_cover,
                  style: const TextStyle(
                    fontFamily: dsFontFamily,
                    fontSize: 9,
                    fontWeight: DSFontWeight.bold,
                    color: DSColor.surface,
                  ),
                ),
              ),
            ),
          Positioned(
            right: 8,
            top: 8,
            child: GestureDetector(
              onTap: () => _remove(index),
              child: const CircleAvatar(
                radius: 13,
                backgroundColor: Color(0x99000000),
                child: Icon(Icons.close, size: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addTile() {
    return GestureDetector(
      onTap: _add,
      child: const DottedBorderBox(
        child: Center(
          child: Icon(
            Icons.add_a_photo_outlined,
            size: 28,
            color: DSColor.onSurface45,
          ),
        ),
      ),
    );
  }
}

class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DSColor.card,
        borderRadius: BorderRadius.circular(DSBorderRadius.image),
        border: Border.all(color: DSColor.onSurface15, width: 0.5),
      ),
      child: child,
    );
  }
}
