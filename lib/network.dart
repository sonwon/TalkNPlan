import 'dart:convert';

import 'package:ai_scheduler/Calendar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

class Network {
  Network() {

  }

  Future<bool> RegisterTask(String _id, String _password) async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    DataSnapshot snapshot = await realtime.ref().child("userId")
        .child(_id)
        .get();
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    if (!value.isEmpty) { //중복된 아이디
      return false;
    }
    await realtime.ref().child("userId").child(_id).set(
        {"password": _password});
    return true;
  }

  Future<String> LoginTask(String _id, String _password) async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    DataSnapshot snapshot = await realtime.ref().child("userId")
        .child(_id)
        .get();
    if (!snapshot.exists) { //없는 아이디
      return "NO_USER";
    }
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    String readData = value.values.toString();
    String decodedData = readData.substring(1, readData.length - 1);

    if (decodedData == _password) { //로그인 성공
      return "SUCCESS";
    }
    else { //잘못된 비밀번호
      return "WRONG_PASSWORD";
    }
  }

  Future<Map<DateTime, List<Event>>> GetPlan(String _id) async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    DataSnapshot snapshot = await realtime.ref().child("userPlan")
        .child(_id)
        .get();
    if (!snapshot.exists) {
      return {};
    }
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    String readData = value.values.toString();
    String decodedData = readData.substring(1, readData.length - 1);
    Map<String, dynamic> decodedMap = await jsonDecode(decodedData);
    Map<DateTime, List<Event>> events = new Map();
    decodedMap.forEach((key, value) {
      List<Event> valueList = [];
      value.forEach((v) {
        Event event = new Event(v["title"], v["content"], v["complete"]);
        valueList.add(event);
      });
      events[DateTime.parse(key)] = valueList;
    });
    return events;
  }

  Future<void> SetPlan(String _id, DateTime _dateTime, String _title,
      String _content) async {
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    DataSnapshot snapshot = await realtime.ref().child("userPlan")
        .child(_id)
        .get();
    String encodedDateTime = "${_dateTime.year}-${EncodeDay(_dateTime.month)}-${EncodeDay(_dateTime.day)}";
    if (!snapshot.exists) { //값이 없는 경우 MAP을 만들어서 추가
      Event newEvent = new Event(_title, _content, false);
      Map<String, dynamic> events = {encodedDateTime: [newEvent.toJson()]};
      await realtime.ref().child("userPlan").child(_id).set(
          {"plans": jsonEncode(events)});
    }
    else { //값이 있는 경우 MAP을 받아서 추가
      Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
      String readData = value.values.toString();
      String decodedData = readData.substring(1, readData.length - 1);
      Map<String, dynamic> events = jsonDecode(decodedData);
      List plans = events[encodedDateTime] ?? [];
      if (plans.isEmpty) {
        Event newEvent = new Event(_title, _content, false);
        plans.add(newEvent.toJson());
        events[encodedDateTime] = plans;
      }
      else {
        Event newEvent = new Event(_title, _content, false);
        plans.add(newEvent.toJson());
        events.update(encodedDateTime, (value) => plans);
      }
      await realtime.ref().child("userPlan").child(_id).update(
          {"plans": jsonEncode(events)});
    }
  }

  Future<void> DeletePlan(String _id, DateTime _dateTime, int _planIndex) async{
    FirebaseDatabase realtime = FirebaseDatabase.instance;
    DataSnapshot snapshot = await realtime.ref().child("userPlan")
        .child(_id)
        .get();
    String encodedDateTime = "${_dateTime.year}-${EncodeDay(_dateTime.month)}-${EncodeDay(_dateTime.day)}";
    Map<dynamic, dynamic> value = snapshot.value as Map<dynamic, dynamic>;
    String readData = value.values.toString();
    String decodedData = readData.substring(1, readData.length - 1);
    Map<String, dynamic> events = jsonDecode(decodedData);
    List plans = events[encodedDateTime] ?? [];
    List newPlans = [];
    for(int i=0; i<plans.length; i++){
      if(i != _planIndex){
        newPlans.add(plans[i]);
      }
    }
    events.update(encodedDateTime, (value) => newPlans);
    await realtime.ref().child("userPlan").child(_id).update(
        {"plans": jsonEncode(events)});
  }
}

