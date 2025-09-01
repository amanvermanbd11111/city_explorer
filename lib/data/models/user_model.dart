import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class UserModel extends User {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String username;
  
  @HiveField(2)
  final bool isGuest;

  const UserModel({
    required this.id,
    required this.username,
    this.isGuest = true,
  }) : super(
          id: id,
          username: username,
          isGuest: isGuest,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.guest(String username) {
    return UserModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      isGuest: true,
    );
  }
}