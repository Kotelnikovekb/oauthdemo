import 'dart:io';

import 'package:flutter/services.dart';
import 'package:oauthdemo/domain/yandex_response_model.dart';

import 'domain/fingerprint_model.dart';

enum FingerprintType{
  SHA1('SHA'),
  SHA256('SHA256');
  final String label;

  const FingerprintType(this.label);
}
class OAuthYandex{
  // Создаем наш канал. Для удобства сделаем его приватным для класса
  final _methodChannel = const MethodChannel('kotelnikoff_dev');

  // Инициализация библиотеки
  Future<bool> setUp()async{

    try{
      // этот метод нужен для инициализации библиотеки авторизации яндекса
      final message=await _methodChannel.invokeMethod('start');
      return message;
    }catch(e,s){
      rethrow;
    }
  }
  // Метод авторизации через яндекс
  Future<YandexResponseModel> login()async{
    try{
      // Тут запускаем авторизацию. И все готово
      final message=await _methodChannel.invokeMethod('yandexAuth');
      //парсим ответ
      final res=yandexResponseModelFromJson(message);
      return res;
    }catch(e,s){
      rethrow;
    }
  }

  /// Метод получения SHA256 или SHA1 Fingerprints. Требуется для создания приложения в консоли яндекса. и много где еще
  Future<FingerprintModel> getCertificateFingerprint({FingerprintType type=FingerprintType.SHA1})async{
    if(!Platform.isAndroid){
      throw UnsupportedError('Метод доступен только на android');
    }
    try{
      final message=await _methodChannel.invokeMethod('getCertificateFingerprint',type.label);
      //парсим ответ
      return fingerprintModelFromJson(message);
    }catch(e,s){
      rethrow;
    }
  }
}