import 'package:flutter/material.dart';

separateText(String text) {
  List<String> separateList = [];
  String temp = "";
  for (int i = 0; i < text.length; i++) {
    temp = temp + text[i].toLowerCase();
    separateList.add(temp);
  }
  return separateList;
}

String timeBetween({required DateTime from, required DateTime to}) {
  from = DateTime(from.year, from.month, from.day, from.hour, from.minute);
  to = DateTime(to.year, to.month, to.day, to.hour, to.minute);
  String time;
  int minutes = to.difference(from).inSeconds ~/ 60;
  int hour = to.difference(from).inMinutes ~/ 60;
  int day = to.difference(from).inHours ~/ 24;
  int month = to.difference(from).inDays ~/ 30;
  int year = to.difference(from).inDays ~/ 360;
  if (year >= 1) {
    time = '$year years';
  } else if (month >= 1) {
    time = '$month months';
  } else if (day >= 1) {
    time = '$day days';
  } else if (hour >= 1) {
    time = '$hour hours';
  } else if (minutes >= 1) {
    time = '$minutes minutes';
  } else {
    time = 'Now';
  }
  return time;
}

checkPersonAvatar({required String avatar, double? size}) => avatar.trim() == ''
    ? Icon(Icons.person, size: size)
    : Image.network(avatar);

checkGroupAvatar({required String avatar, double? size}) => avatar.trim() == ''
    ? Icon(Icons.people, size: size)
    : Image.network(avatar);

double screenWidth(context) => MediaQuery.of(context).size.width;

double screenHeight(context) => MediaQuery.of(context).size.height;
