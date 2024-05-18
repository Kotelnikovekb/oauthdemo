package expert.kotelnikoff.oauthdemo

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Log
import com.yandex.authsdk.YandexAuthException
import com.yandex.authsdk.YandexAuthLoginOptions
import com.yandex.authsdk.YandexAuthOptions
import com.yandex.authsdk.YandexAuthResult
import com.yandex.authsdk.YandexAuthSdk
import com.yandex.authsdk.YandexAuthToken
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject
import java.security.MessageDigest

class MainActivity: FlutterActivity(), MethodChannel.MethodCallHandler {
    /// Это наш канал для работы с флаттером. Важно указать его символ в символ
    private final var CHANEL_NAME="kotelnikoff_dev"
    private lateinit var yandexSdk: YandexAuthSdk
    private var result: MethodChannel.Result? = null
    private val REQUEST_LOGIN_YANDEX = 100
    private lateinit var channel : MethodChannel
    private lateinit var context: Context;


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if(call.method=="start"){
            try {
                yandexSdk = YandexAuthSdk.create(YandexAuthOptions(applicationContext))
                result.success(true)
            }catch (e: Exception){
                result.error("InitError","${e.message}","${e.stackTrace}")
            }
        }else if(call.method=="yandexAuth"){
            // создаем интент для запуска активити яндекса и авторизации в ней. Сохраняем result для последующего использования.
            if(this.result!=null){
                result.error("InitError","Прошлый запрос еще не выполнен, ждите","Подожди")
                return;
            }
            this.result=result
            // из документации яндекса
            try{
                val loginOptions = YandexAuthLoginOptions()
                val intent: Intent = yandexSdk.contract.createIntent(applicationContext,loginOptions)
                startActivityForResult(intent, REQUEST_LOGIN_YANDEX);
            }catch (e: Exception){
                result.error("InitError","${e.message}","${e.stackTrace}")
            }
        }
        // этот метод нужнен для получения отпечатка. можно использовать консольную команду, но у меня она не всегда работает.
        else if(call.method=="getCertificateFingerprint"){
            try {
                val info = context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
                for (signature in info.signatures) {
                    val md: MessageDigest = MessageDigest.getInstance(call.arguments.toString())
                    md.update(signature.toByteArray())
                    val digest = md.digest()
                    val hexString = digest.joinToString(":") { "%02x".format(it) }
                    val res=mapOf(
                        "fingerprint" to hexString,
                        "packageName" to context.packageName
                    )
                    result.success(JSONObject(res.toMap()).toString())
                }
            } catch (e: Exception) {
                result.error("Error cert","${e.message}","${e.stackTrace}")
            }
        }    else {
            result.notImplemented()
        }

    }
    // При создании нативной активити добавляем слушатель событий Flutter
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        context = applicationContext
        channel = MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANEL_NAME)
        channel.setMethodCallHandler(this)
    }
    // метод из документации яндекса. смотрим на сколько успешным был запрос
    private fun handleResult(result: YandexAuthResult) {
        when (result) {
            is YandexAuthResult.Success -> onSuccessAuth(result.token)
            is YandexAuthResult.Failure -> onProccessError(result.exception)
            YandexAuthResult.Cancelled -> onCancelled()
        }
    }
    private fun onSuccessAuth(token: YandexAuthToken){
        val res=mapOf(
            "susses" to true,
            "token" to token.value,
            "expiresIn" to token.expiresIn,
        )

        if(result!==null){
            result!!.success(JSONObject(res.toMap()).toString())
            result=null
        }

    }
    /// слушаем результат выполнения запроса на авторизацию
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode==REQUEST_LOGIN_YANDEX){
            val sdk = YandexAuthSdk.create(YandexAuthOptions(applicationContext))
            handleResult(sdk.contract.parseResult(resultCode,data))
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
    private fun onProccessError(exception: YandexAuthException){
        val arg = HashMap<String, Any>()
        arg.put("susses",false)
        arg.put("provider","yandex")
        arg.put("error",exception.toString())
        if(result!==null){
            result!!.success(JSONObject(arg.toMap()).toString())
            result=null
        }

    }
    private fun onCancelled(){
        val arg = HashMap<String, Any>()
        arg.put("susses",false)
        arg.put("provider","yandex")
        arg.put("cancelled",true)
        if(result!==null){
            result!!.success(JSONObject(arg.toMap()).toString())
            result=null
        }
    }


}
