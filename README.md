# OAuthDemo

Пример приложения с использованием нативного кода и сторонней библиотеки Яндекс ID.

- [Документация яндекса для работы с мобильными приложениями](https://yandex.ru/dev/id/doc/ru/mobileauthsdk/about)
- [Документация Flutter для работы с нативом](https://docs.flutter.dev/platform-integration/platform-channels)

## Работа с нативом на стороне Flutter№№#

Для общения с нативом вам требуется создать канал `MethodChannel`. И все! вы можете вызывать созданные вами методы и передавать аргументы на нативную платформу при помощи `invokeMethod`
### Пример:
```java
    // Создаем канал. 'kotelnikoff_dev' - его название.
    // Важно использовать название канала символ в символ на нативной платформе
    final _methodChannel = const MethodChannel('kotelnikoff_dev');
    // Вызов метода на нативе. Метод принимает 2 аргумента String method, [dynamic arguments].
    // method - должен совпадать символ в символ с нативом
    // arguments - необязательно. Можно передать простые типы. (список ниже)
    final message=await _methodChannel.invokeMethod('ping','Say hi to my little friends');
 ```
## Работа на kotlin

Для отслеживания вызовов необходимо добавить `MethodChannel.MethodCallHandler`

```kotlin
class MainActivity: FlutterActivity(), MethodChannel.MethodCallHandler {
    // Имя канала
    private final var CHANEL_NAME="kotelnikoff_dev"


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // При создании Activity создаем канал и добавляем слушатель вызовов из Flutter
        val channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Наш метод из кода выше
        if (call.method == "ping") {
            //Смотрим на arguments и если они совпадают, то вернем успешное выполнение запроса
            if(call.arguments.toString() == "Say hi to my little friends"){
                result.success("Hello")
            }else{
                // А тут вернем ошибку
                result.error("PingError", "What", "I don't know this phrase")
            }
        } else {
            // Ошибка на случай если метод не найден
            result.notImplemented()
        }
    }
}
```

## Работа на IOS

Для работы на IOS нам так же потребуется создать канал и слушателя в файле `ios/Runner/AppDelegate.swift`

```swift
override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
        guard let controller = window?.rootViewController as? FlutterViewController else {
            fatalError("Invalid root view controller")
        }
        //Создаем нанал
        let channel = FlutterMethodChannel(name: "kotelnikoff_dev", binaryMessenger: controller.binaryMessenger)
        // Слушаем сообщения
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
        
            if call.method == "ping" {
                //Смотрим на arguments и если они совпадают, то вернем успешное выполнение запроса
                if call.arguments == "Say hi to my little friends" {
                    result("Hello")
                }else {
                    // А тут вернем ошибку
                    result(FlutterError(code: "PingError",
                                        message: "What",
                                        details: "I don't know this phrase"))

                }
            }
            else {
                // Ошибка на случай если метод не найден
                result(FlutterMethodNotImplemented)
            }
        }
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
```


# Пример приложения для работы Yandex ID

Для работы необходимо создать приложение в [консоли разработчика yandex](https://oauth.yandex.ru/).
Для этого вам потребуются:

- Для android: имя пакета и отпечаток приложения (результат метода getCertificateFingerprint)
- Для IOS: имя пакета и Team ID из консоли разработчика.

## Подготовка приложения для Android
[Ссылка на документацию](https://yandex.ru/dev/id/doc/ru/mobileauthsdk/android/3.1.0/sdk-android-install)
1. Добавить в файл ``android/app/build.gradle`` ключ приложения из консоли и зависимость ``com.yandex.android:authsdk``

```groovy
android {
.....
	defaultConfig {
		....
		///Можно и повыше
		minSdkVersion 23
		//Добавим клюя авторизации для работы либы  
		manifestPlaceholders += [YANDEX_CLIENT_ID:"Ключ приложения"]
		...
	}
}
dependencies {  
    //Добавим библиотеку  
    implementation "com.yandex.android:authsdk:3.1.0"  
}

```
2. Для работы ``com.yandex.android:authsdk`` требуется изменить версию kotlin в файле ``android/settings.gradle``. Это нужно именно для authsdk. Если вы хотите использовать, чтото другое, то можно не менять эту зависимость.
```groovy
plugins {
	/// Обновить версию 1.8.0 или выше. Это нужно для библиотеки яндекса. Так можно не трогать
    id "org.jetbrains.kotlin.android" version "1.8.0" apply false 
}
```
3. Готово

## Подготовка приложения IOS
[Ссылка на документацию](https://yandex.ru/dev/id/doc/ru/mobileauthsdk/ios/3.0.0/sdk-ios-install)
1. Модифицировать ```ios/Podfile``` и добавить в него зависимость ``YandexLoginSDK``
```ruby
# Дефолтный файл Podfile
# Uncomment this line to define a global platform for your project  
platform :ios, '14.0'  
# Добавляем библиотеку авторизации яндекса  
pod 'YandexLoginSDK'  

# ....Продолжение файла...
```
2. Добавить информацию ``ios/Runner/Info.plist``
```xml
<key>LSApplicationQueriesSchemes</key>  
   <array>  
      <string>primaryyandexloginsdk</string>  
      <string>secondaryyandexloginsdk</string>  
   </array>  
   <key>CFBundleURLTypes</key>  
   <array>  
      <dict>  
         <key>CFBundleURLName</key>  
         <string>YandexLoginSDK</string>  
         <key>CFBundleURLSchemes</key>  
         <array>  
            <string>yx{ВАШ_КЛЮЧ}</string>  
         </array>  
      </dict>  
   </array>
```

> Блок `CFBundleURLTypes` должен быть только один на весь файл. Для нескольких сервисов просто создайте новые ``<dict>`` внутри `array`

3. Добавить домен ``applinks:yx{Client_ID}.oauth.yandex.ru`` в список ассоциированных доменов `Capability: Associated Domains`

4. Готово!

## Использование

1. Скопировать методы из `ios/Runner/AppDelegate.swift` и `app/src/main/kotlin/имя/вашего/пакета/MainActivity.kt`.
2. Скопировать `lib/o_auth_yandex.dart` и содержимое папки `lib/domain`. В ней лежат модели ответов от нативной платформы.
3. Используйте ``OAuthYandex`` для авторизации.

# От автора
Я в [telegram](https://t.me/kotelnikoff_dev)

[Подкинте автору на кофе](https://www.tinkoff.ru/rm/kotelnikov.yuriy2/PzxiM41989), а то ему еще песика кормить