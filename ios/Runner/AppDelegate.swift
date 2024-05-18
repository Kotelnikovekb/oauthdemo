import UIKit
import Flutter
import YandexLoginSDK


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var myYandex:MyYandexLoginSDKObserver=MyYandexLoginSDKObserver()

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
      guard let controller = window?.rootViewController as? FlutterViewController else {
                  fatalError("Invalid root view controller")
              }
      //Подключаемся к нашему каналу
      let channel = FlutterMethodChannel(name: "kotelnikoff_dev", binaryMessenger: controller.binaryMessenger)
      // добавляем слушаем
      channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
                  if call.method == "start" {
                    
                      do {
                          let clientID = "{ВАШ_КЛЮЧ}" //<= ваш id приложения из консоли. В теории можно взять из Info.plist
                          try YandexLoginSDK.shared.activate(with: clientID)
                          self.myYandex = MyYandexLoginSDKObserver()
                          YandexLoginSDK.shared.add(observer: self.myYandex)
                          result(true)
                      } catch {
                          result(FlutterError(code: "InitError",
                                                                                message: "Error YandexLoginSDK \(error)",
                                                                                details: "\(error)"))

                          
                      }
                      
                  } else if call.method == "yandexAuth" {
                      if let viewController = UIApplication.shared.keyWindow?.rootViewController {
                          do{
                              self.myYandex.setResult(result: result);
                              try YandexLoginSDK.shared.authorize(with: viewController)
                          }catch{
                              result(FlutterError(code: "ERROR YandexLoginSDK",
                                                      message: "Error YandexLoginSDK \(error)",
                                                      details: "\(error)"))
                          }
                      }
                      
                  }
                  else {
                      result(FlutterMethodNotImplemented)
                  }
              }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class MyYandexLoginSDKObserver: NSObject, YandexLoginSDKObserver {
    var resultFlutter: FlutterResult!
    
    
    func setResult(result: @escaping FlutterResult){
        self.resultFlutter = result
    }
    
    func didFinishLogin(with result: Result<LoginResult, any Error>) {
        do {
            let res = try result.get()
            
            
            
            
            let book = SussesResponse(susses: true, token: res.token, expiresIn: -1)
            
            
            let encoder = JSONEncoder()
            
            let bookJson = try encoder.encode(book)
            let bookJsonString = String(data: bookJson, encoding: .utf8)
            
            self.resultFlutter(bookJsonString)
            
        }catch{
            let book = ErrorResponse(susses: false, errorMessage: "\(error)")
            let encoder = JSONEncoder()
            
            do {
                let bookJson = try encoder.encode(book)
                let bookJsonString = String(data: bookJson, encoding: .utf8)
                
                self.resultFlutter(FlutterError.init(code: "errorSetDebug",message: bookJsonString,details:nil))
            }catch{
                
            }
        }
        
    }
}


//Это нужно для типизации успешного результата с токеном. Я не нашел как это реализовать иначе. Если есть идеи, то напишите в комменты
struct SussesResponse: Encodable {
    var susses: Bool
    var token: String
    var expiresIn: Int
}

struct ErrorResponse: Encodable {
    var susses: Bool
    var errorMessage: String
}
