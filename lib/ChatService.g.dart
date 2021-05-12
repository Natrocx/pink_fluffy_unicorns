// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ChatService.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStatusAdapter extends TypeAdapter<AppStatus> {
  @override
  final int typeId = 5;

  @override
  AppStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AppStatus.GreeterPending;
      case 1:
        return AppStatus.RegistrationPending;
      case 2:
        return AppStatus.Operational;
      default:
        return AppStatus.GreeterPending;
    }
  }

  @override
  void write(BinaryWriter writer, AppStatus obj) {
    switch (obj) {
      case AppStatus.GreeterPending:
        writer.writeByte(0);
        break;
      case AppStatus.RegistrationPending:
        writer.writeByte(1);
        break;
      case AppStatus.Operational:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
