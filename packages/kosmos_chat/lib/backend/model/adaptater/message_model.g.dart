import 'package:hive/hive.dart';
import 'package:kosmos_chat/backend/kosmos_chat_backend.dart';

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final typeId = 17;

  @override
  MessageModel read(BinaryReader reader) {
    final micros = reader.readMap();
    return MessageModel.fromJson(Map<String, dynamic>.from(micros));
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer.writeMap((obj).toJson());
  }
}
