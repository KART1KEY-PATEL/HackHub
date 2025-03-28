// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      userType: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      phoneNumber: fields[3] as String,
      collegeName: fields[4] as String,
      external: fields[5] as bool,
      gender: fields[6] as String,
      username: fields[7] as String,
      password: fields[8] as String,
      approved: fields[9] as bool,
      id: fields[10] as String,
      teamId: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.userType)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.collegeName)
      ..writeByte(5)
      ..write(obj.external)
      ..writeByte(6)
      ..write(obj.gender)
      ..writeByte(7)
      ..write(obj.username)
      ..writeByte(8)
      ..write(obj.password)
      ..writeByte(9)
      ..write(obj.approved)
      ..writeByte(10)
      ..write(obj.id)
      ..writeByte(11)
      ..write(obj.teamId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
