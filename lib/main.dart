import 'package:flutter/material.dart';
import 'package:oauthdemo/o_auth_yandex.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
  //Добавляем наш класс
  final oAuth=OAuthYandex();
  //Переменная отвечает за доступность авторизации
  bool available=false;
  @override
  void initState() {
    super.initState();
    oAuth.setUp().then(
            (value) {
              print('Яндекс доступен');
            setState(() {
              available=true;
            });
            }
    ).catchError((e,s){
      print('Яндекс не доступен ${e} ${s}');
    });
    oAuth.getCertificateFingerprint().then((value) => print(value));
    oAuth.getCertificateFingerprint(type: FingerprintType.SHA256).then((value) => print(value));
  }
  void login()async{
    if(!available){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Бибилиотека не доступна!'),
      ));
      return;
    }
    try{
      final res=await oAuth.login();
      print(res);
    }catch(e,s){
      print('Ошибка ${e}\n${s}');
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
          onPressed: login,
        ),
      ),
    );
  }

}
