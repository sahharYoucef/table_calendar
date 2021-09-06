// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../utils.dart';

class TableRangeExample extends StatefulWidget {
  @override
  _TableRangeExampleState createState() => _TableRangeExampleState();
}

class _TableRangeExampleState extends State<TableRangeExample> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOn; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TableCalendar - Range'),
      ),
      body: TableCalendar(
        headerVisible: true,
        headerStyle: HeaderStyle(
          rightChevronVisible: false,
          headerPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          titleTextStyle: TextStyle(color: Colors.red),
          leftChevronVisible: false,
          formatButtonVisible: false,
          formatButtonShowsNext: false,
        ),
        calendarStyle: CalendarStyle(
          cellMargin: EdgeInsets.symmetric(vertical: 2),
          markerMargin: EdgeInsets.zero,
          rangeHighlightColor: Colors.transparent,
        ),
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
        availableGestures: AvailableGestures.horizontalSwipe,
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selectedDay, selectedDay)) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _rangeStart = null; // Important to clean those
              _rangeEnd = null;
              _rangeSelectionMode = RangeSelectionMode.toggledOff;
            });
          }
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        onRangeSelected: (start, end, focusedDay) {
          setState(() {
            _selectedDay = null;
            _focusedDay = focusedDay;
            _rangeStart = start;
            _rangeEnd = end;
            _rangeSelectionMode = RangeSelectionMode.toggledOn;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          setState(() {});
        },
        rowHeight: 50,
        calendarBuilders: CalendarBuilders(
          rangeStartBuilder: (context, date, _) {
            return Container(
                margin: EdgeInsets.only(
                  left: 6,
                  top: 2,
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                    color: _rangeEnd != null ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      bottomLeft: Radius.circular(50),
                      topRight: Radius.circular(
                          date.weekday != 7 && _rangeEnd != null ? 0 : 50),
                      bottomRight: Radius.circular(
                          date.weekday != 7 && _rangeEnd != null ? 0 : 50),
                    )),
                child: Container(
                  margin: EdgeInsets.only(
                    right: 6,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        bottomLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      )),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${date.day}',
                        ),
                      ],
                    ),
                  ),
                ));
          },
          rangeEndBuilder: (context, date, _) {
            return Container(
                margin: EdgeInsets.only(
                  right: 6,
                  top: 2,
                  bottom: 2,
                ),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          date.weekday != 1 && _rangeStart != null ? 0 : 50),
                      bottomLeft: Radius.circular(
                          date.weekday != 1 && _rangeStart != null ? 0 : 50),
                      topRight: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    )),
                child: Container(
                  margin: EdgeInsets.only(
                    left: 6,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        bottomLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                        bottomRight: Radius.circular(50),
                      )),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${date.day}',
                        ),
                      ],
                    ),
                  ),
                ));
          },
          disabledBuilder: (context, date, _) {
            return Container(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '${date.day}',
                  ),
                ],
              ),
            ));
          },
          withinRangeBuilder: (context, date, _) {
            return Container(
                margin: EdgeInsets.only(top: 2, bottom: 2),
                decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(date.weekday != 1 ? 0 : 50),
                      bottomLeft: Radius.circular(date.weekday != 1 ? 0 : 50),
                      topRight: Radius.circular(date.weekday != 7 ? 0 : 50),
                      bottomRight: Radius.circular(date.weekday != 7 ? 0 : 50),
                    )),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        '${date.day}',
                      ),
                    ],
                  ),
                ));
          },
        ),
      ),
    );
  }
}
