// To parse this JSON data, do
//
//     final yandexResponseModel = yandexResponseModelFromJson(jsonString);

import 'dart:convert';

YandexResponseModel yandexResponseModelFromJson(String str) => YandexResponseModel.fromJson(json.decode(str));

String yandexResponseModelToJson(YandexResponseModel data) => json.encode(data.toJson());

class YandexResponseModel {
  bool susses;
  String token;
  int expiresIn;

  YandexResponseModel({
    required this.susses,
    required this.token,
    required this.expiresIn,
  });

  YandexResponseModel copyWith({
    String? provider,
    bool? susses,
    String? token,
    int? expiresIn,
  }) =>
      YandexResponseModel(
        susses: susses ?? this.susses,
        token: token ?? this.token,
        expiresIn: expiresIn ?? this.expiresIn,
      );

  factory YandexResponseModel.fromJson(Map<String, dynamic> json) => YandexResponseModel(
    susses: json["susses"],
    token: json["token"],
    expiresIn: json["expiresIn"],
  );

  Map<String, dynamic> toJson() => {
    "susses": susses,
    "token": token,
    "expiresIn": expiresIn,
  };

  @override
  String toString() {
    return "Успешный запрос: ${susses?'да':'нет'} токен: ${token}";
  }
}