import 'package:flutter/material.dart';

void main() {
  runApp(const Login());
}


class Login extends StatelessWidget{
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home : LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget{
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();

}

class LoginPageState extends State<LoginPage>{
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text("AI Scheduler",
              style: TextStyle(fontSize: 20, color: Colors.blueGrey),),
              padding: EdgeInsets.fromLTRB(10.0, 0, 10.0, 20.0),
            ),
            Container(//아이디
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "ID를 입력하세요",
                ),
                controller: idController,
              ),
              padding: EdgeInsets.all(10.0),
            ),
            Container(//비밀번호
              child: TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "PASSWORD를 입력하세요",
                ),
                controller: passwordController,
              ),
              padding: EdgeInsets.all(10.0),
            ),
            ElevatedButton(
                onPressed: () {
                  String id = idController.text;
                  String password = passwordController.text;
                  //서버에 보내서 로그인 처리 로그인 성공하면 result가 트루
                  bool result = true;
                  if(result){ //로그인 성공하면 Calender page로 이동
                    Navigator.pushNamed(context, '/calendar');
                  }
                  else{//로그인 실패
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(content: Text("로그인 실패"));
                        }
                    );
                  }
                },
                child: Text("로그인")
            ),
          ],
        ),
      )
    );
  }
}

