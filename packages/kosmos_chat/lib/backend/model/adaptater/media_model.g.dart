import 'package:hive/hive.dart';
import 'package:ui_kosmos_v4/ui_kosmos_v4.dart';

class MediaModelAdapter extends TypeAdapter<MediaModel> {
  @override
  final typeId = 18;

  @override
  MediaModel read(BinaryReader reader) {
    final micros = reader.readMap();
    return MediaModel.fromJson(Map<String, dynamic>.from(micros));
  }

  @override
  void write(BinaryWriter writer, MediaModel obj) {
    writer.writeMap((obj).toJson());
  }
}
