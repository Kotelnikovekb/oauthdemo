// To parse this JSON data, do
//
//     final yandexResponseModel = yandexResponseModelFromJson(jsonString);

import 'dart:convert';

YandexResponseModel yandexResponseModelFromJson(String str) => YandexResponseModel.fromJson(json.decode(str));

String yandexResponseModelToJson(YandexResponseModel data) => json.encode(data.toJson());

class YandexResponseModel {
  String provider;
  bool susses;
  String token;
  int expiresIn;

  YandexResponseModel({
    required this.provider,
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
        provider: provider ?? this.provider,
        susses: susses ?? this.susses,
        token: token ?? this.token,
        expiresIn: expiresIn ?? this.expiresIn,
      );

  factory YandexResponseModel.fromJson(Map<String, dynamic> json) => YandexResponseModel(
    provider: json["provider"],
    susses: json["susses"],
    token: json["token"],
    expiresIn: json["expiresIn"],
  );

  Map<String, dynamic> toJson() => {
    "provider": provider,
    "susses": susses,
    "token": token,
    "expiresIn": expiresIn,
  };
}