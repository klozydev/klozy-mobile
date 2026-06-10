import 'package:hive/hive.dart';
import 'package:kosmos_chat/backend/model/tchat/tchat_model.dart';

class TchatModelAdapter extends TypeAdapter<TchatModel> {
  @override
  final typeId = 20;

  @override
  TchatModel read(BinaryReader reader) {
    final micros = reader.readMap();
    return TchatModel.fromJson(Map<String, dynamic>.from(micros));
  }

  @override
  void write(BinaryWriter writer, TchatModel obj) {
    writer.writeMap((obj).toJson());
  }
}
