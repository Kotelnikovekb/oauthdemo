import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Создаем канал для обмена сообщений с платформой
  static const platform=MethodChannel('kotelnikoff_dev');
  @override
  void initState() {
    super.initState();
    setUp();
  }
  Future<String> setUp()async{
    try{
      // этот метод нужен для инициализации библиотеки авторизации яндекса
      final message=await platform.invokeMethod('start');
      return message;

    }catch(e,s){
      return 'error';
    }
  }
  void login()async{
    try{
      // Тут запускаем авторизацию. И все готово
      final message=await platform.invokeMethod('yandexAuth');
      print("===>>>>>>>>>>>>${message}");
    }catch(e,s){
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Войти через яндекс'),
          onPressed:login,
        ),
      ),
    );
  }

}
