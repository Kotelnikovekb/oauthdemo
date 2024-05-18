// To parse this JSON data, do
//
//     final fingerprintModel = fingerprintModelFromJson(jsonString);

import 'dart:convert';

FingerprintModel fingerprintModelFromJson(String str) => FingerprintModel.fromJson(json.decode(str));

String fingerprintModelToJson(FingerprintModel data) => json.encode(data.toJson());

class FingerprintModel {
  String fingerprint;
  String packageName;

  FingerprintModel({
    required this.fingerprint,
    required this.packageName,
  });

  FingerprintModel copyWith({
    String? fingerprint,
    String? packageName,
  }) =>
      FingerprintModel(
        fingerprint: fingerprint ?? this.fingerprint,
        packageName: packageName ?? this.packageName,
      );

  factory FingerprintModel.fromJson(Map<String, dynamic> json) => FingerprintModel(
    fingerprint: json["fingerprint"],
    packageName: json["packageName"],
  );

  Map<String, dynamic> toJson() => {
    "fingerprint": fingerprint,
    "packageName": packageName,
  };

  @override
  String toString() {
    return "Пакет: ${packageName}, отпечаток: $fingerprint";
  }
}