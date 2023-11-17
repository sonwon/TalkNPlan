import 'dart:collection';
import 'package:ai_scheduler/Login.dart';
import 'package:ai_scheduler/network.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main(){
  runApp(const Calendar());
}

class Calendar extends StatelessWidget{
  const Calendar({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget{
  const CalendarPage({super.key});

  @override
  State<StatefulWidget> createState() => CalendarPageState();
  
}

class CalendarPageState extends State<CalendarPage>{
  final Network network = new Network();
  Map<DateTime, List<Event>> events = {};
  late final ValueNotifier<List<Event>> _selectedEvents;
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();
  DateTime _encodedDay = DateTime.now();
  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _encodedDay = DateTime.parse("${_focusedDay.year}-${EncodeDay(_focusedDay.month)}-${EncodeDay(_focusedDay.day)}");
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }
  List<Event> _getEventsForDay(DateTime day){
    String stringDay = "${day.year}-${EncodeDay(day.month)}-${EncodeDay(day.day)}";
    DateTime encodedDay = DateTime.parse(stringDay);
    return events[encodedDay] ?? [];
  }
  Widget RefreshPage(List<Event> getEvents){
    return Scaffold(
      appBar: AppBar(
        title: Text("일정 관리"),
      ),
      body: Center(
          child : ListView.builder( //리스트뷰로 출력
            itemBuilder: (c, index) {
              return Column(
                children: <Widget>[
                  Container(
                    width : 300,
                    padding: EdgeInsets.all(5),
                    margin: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(getEvents[index].title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
                        Divider(color: Colors.black, thickness: 2.0),
                        Text(getEvents[index].content, style: TextStyle(fontSize: 16),),
                        ElevatedButton(
                          onPressed: () async{
                            network.DeletePlan(USER_ID, _encodedDay, index);
                            List<Event> deletedEvent = [];
                            for(int i=0; i<getEvents.length; i++){
                              if(i != index){
                                deletedEvent.add(getEvents[i]);
                              }
                            }
                            events[_encodedDay] = deletedEvent;
                            setState(() {

                            });
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => RefreshPage(deletedEvent)));
                          },
                          child: Text("일정 삭제", style: TextStyle(fontSize: 12, color: Colors.black),),
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(Colors.grey),
                            minimumSize: MaterialStateProperty.all(Size(20, 20)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 0, height: 10,),
                ],
              );
            },
            itemCount: getEvents.length,
          )
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title : Text("Calendar Page"),
      ),
      body: Center(
        child: Column(
          children : <Widget>[
            Container(
              child : TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day){ //어떤 날짜가 선택됐는지 정함
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay){
                if(!isSameDay(_selectedDay, selectedDay)){
                  setState(() { //클릭한 날짜를 변수에 저장하고 포커싱
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                    _encodedDay = DateTime.parse("${_focusedDay.year}-${EncodeDay(_focusedDay.month)}-${EncodeDay(_focusedDay.day)}");
                    //_getEventsForDay 함수로 클릭한 날짜의 스케줄을 받아와 위젯에 표시

                  });
                }
              },
              onFormatChanged: (format){
                if(_calendarFormat != format){ //포멧 업데이트
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _encodedDay = DateTime.parse("${_focusedDay.year}-${EncodeDay(_focusedDay.month)}-${EncodeDay(_focusedDay.day)}");
              },
              onCalendarCreated: (controller) async{
                events = await network.GetPlan(USER_ID);
                setState(() {

                });
              },
              eventLoader: _getEventsForDay,//해달 날짜에 이벤트가있으면 마커표시
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("${_focusedDay.month}월 ${_focusedDay.day}일  ", style: TextStyle(fontSize: 20),),
                  TextButton(onPressed:
                      (){
                        //해당 날짜의 스케줄을 getEvents 변수에 저장
                        List<Event> getEvents = _getEventsForDay(_encodedDay);
                        print(getEvents);
                        Navigator.push(context,
                          MaterialPageRoute(builder: (c){
                            return RefreshPage(getEvents);
                          })
                        );
                      },
                      child: Text("일정 확인", style: TextStyle(fontSize: 18),)
                  ),
                ],
              ),
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "할 일을 입력해주세요"
              ),
              controller: titleController,
            ),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: "AI의 입력"
              ),
              controller: contentController,
            ),
            ElevatedButton(//일정 추가 버튼
                onPressed: () async {
                  String getTitle = (titleController.text.length != 0) ? titleController.text : "";
                  String getContent = (contentController.text != 0) ? contentController.text : "";
                  if(getTitle == "" || getContent == ""){
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(content: Text("할 일을 입력해주세요"));
                        }
                    );
                    return;
                  }
                  await network.SetPlan(USER_ID, _encodedDay, getTitle, getContent);//firebase 처리

                  List<Event> getEvents = _getEventsForDay(_encodedDay);
                  Event newEvent = Event(getTitle, getContent, false);
                  if(getEvents.isEmpty){
                    getEvents.add(newEvent);
                    events[_encodedDay] = getEvents;
                  }
                  else{
                    getEvents.add(newEvent);
                    events.update(_encodedDay, (value) => getEvents);
                  }
                  titleController.text = "";
                  contentController.text = "";
                  setState(() {

                  });
                },
                child: Text("일정 추가")

            ),
          ]
        ),
      ),

    );
  }

  // List<Event> getEventsForDay(DateTime day){
  //   return events[day] ?? [];
  // }
}

String EncodeDay(int day){
  return (day >= 10) ? "${day}" : "0${day}";
}

//달력 이벤트를 가져오는 이벤트
class Event {
  String title;
  String content;
  bool complete;
  Event(this.title, this.content, this.complete);

  Event.fromJson(Map<String, dynamic> json)
  : title = json['title'], content=json['content'], complete = json['complete'];

  Map<String, dynamic> toJson(){
    return{
      "title" : title,
      "content" : content,
      "complete" : complete
    };
  }

  String getTitle() => title;
  String getContent() => content;
}
