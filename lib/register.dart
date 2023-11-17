import 'package:ai_scheduler/network.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => RegisterPageState();

}

class RegisterPageState extends State<RegisterPage>{
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text("Register Page"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                child: Text("TalkNPlan",
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
              Container(//비밀번호
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "EMAIL을 입력하세요",
                  ),
                  controller: emailController,
                ),
                padding: EdgeInsets.all(10.0),
              ),
              ElevatedButton(
                  onPressed: () async {
                    String id = idController.text;
                    String password = passwordController.text;
                    //서버에 보내서 로그인 처리 로그인 성공하면 result가 트루
                    Network network = new Network();

                    bool result = await network.RegisterTask(id, password);

                    if(result){ //회원가입성공
                      Navigator.pop(context);
                    }
                    else{//로그인 실패
                      showDialog(
                          context: context,
                          builder: (context){
                            return AlertDialog(content: Text("중복된 ID입니다"));
                          }
                      );
                    }
                  },
                  child: Text("회원가입")
              ),
            ],
          ),
        )
    );
  }
}