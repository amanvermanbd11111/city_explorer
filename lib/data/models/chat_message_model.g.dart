// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageModelAdapter extends TypeAdapter<ChatMessageModel> {
  @override
  final int typeId = 0;

  @override
  ChatMessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessageModel(
      id: fields[0] as String,
      username: fields[1] as String,
      message: fields[2] as String,
      cityName: fields[3] as String,
      timestamp: fields[4] as DateTime,
      isOwnMessage: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.cityName)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isOwnMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageModel _$ChatMessageModelFromJson(Map<String, dynamic> json) =>
    ChatMessageModel(
      id: json['id'] as String,
      username: json['username'] as String,
      message: json['message'] as String,
      cityName: json['cityName'] as String,
      timestamp: ChatMessageModel._dateTimeFromMilliseconds(
          (json['timestamp'] as num).toInt()),
      isOwnMessage: json['isOwnMessage'] as bool,
    );

Map<String, dynamic> _$ChatMessageModelToJson(ChatMessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'message': instance.message,
      'cityName': instance.cityName,
      'timestamp': ChatMessageModel._dateTimeToMilliseconds(instance.timestamp),
      'isOwnMessage': instance.isOwnMessage,
    };
