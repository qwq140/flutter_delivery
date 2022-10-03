import 'package:flutter_delivery/app/common/utils/data_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

abstract class UserModelBase{}

// 로그인 실패
class UserModelError extends UserModelBase{
  final String error;

  UserModelError({required this.error});
}

// 로그인 중
class UserModelLoading extends UserModelBase{

}

// 로그인 성공
@JsonSerializable()
class UserModel extends UserModelBase{
  final String id;
  final String username;
  @JsonKey(
    fromJson: DataUtils.pathToUrl
  )
  final String imageUrl;

  UserModel({required this.id, required this.username, required this.imageUrl});

  factory UserModel.fromJson(Map<String, dynamic> json)
  => _$UserModelFromJson(json);
}