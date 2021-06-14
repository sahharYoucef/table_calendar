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
        headerStyle: HeaderStyle(
          rightChevronVisible: false,
          headerPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          titleTextStyle: TextStyle(color: Colors.red),
          leftChevronVisible: false,
          formatButtonVisible: false,
          formatButtonShowsNext: false,
        ),
        calendarStyle: CalendarStyle(
          rangeHighlightColor: Theme.of(context).accentColor,
        ),
        firstDay: kFirstDay,
        lastDay: kLastDay,
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        rangeStartDay: _rangeStart,
        rangeEndDay: _rangeEnd,
        calendarFormat: _calendarFormat,
        rangeSelectionMode: _rangeSelectionMode,
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
        onRangeSelected: (start, end, focusedDay) {
          print(focusedDay);
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
        },
        // calendarBuilders: CalendarBuilders(
        //   selectedBuilder: (context, date, _) {
        //     return _date(date: date, isSelectedDay: true);
        //   },
        //   defaultBuilder: (context, date, _) {
        //     return _date(date: date, isSelectedDay: false);
        //   },
        //   disabledBuilder: (context, date, _) {
        //     return Container(
        //       padding: const EdgeInsets.only(bottom: 3.0),
        //       child: Center(
        //         child: Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: <Widget>[
        //             Text(
        //               '${date.day}',
        //               style: TextStyle(
        //                 fontWeight: FontWeight.w600,
        //                 color: Colors.black.withOpacity(0.2),
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ),
    );
  }

  Widget _date({required DateTime date, required bool isSelectedDay}) {
    String price;

    var outerDecoration;
    var decoration;

    // TRUE If ==> Departure date not selected, and Current Selected Date is Today's date
    var isTodaySDate = _rangeStart == null;

    decoration = BoxDecoration(
      color: isTodaySDate
          ? Colors.red.withOpacity(0.03)
          : isSelectedDay
              ? Colors.red
              : Colors.transparent,
      shape: BoxShape.circle,
    );

    // add outer ring to today
    if (!isSelectedDay) {
      decoration = BoxDecoration(
          shape: BoxShape.circle, color: Colors.red.withOpacity(0.03));
    }

    /// If we have return date ,
    ///
    /// Highlight All Dates Between Departure <--> Return
    if (_rangeEnd != null &&
        _rangeEnd!.compareTo(_rangeStart!) != 0 &&
        (_rangeEnd!.compareTo(date) >= 0) &&
        (_rangeStart!.compareTo(date) <= 0)) {
      // Change Flag To Highlight Selected days text values
      isSelectedDay = _rangeStart!.difference(date).inDays == 0 ||
          _rangeEnd!.difference(date).inDays == 0;

      var borderRadius;
      // ADD LEFT-Radius for departureDate
      if (_rangeStart!.difference(date).inDays == 0) {
        borderRadius = BorderRadius.only(
          bottomLeft: Radius.circular(40.0),
          topLeft: Radius.circular(40.0),
        );
      }
      // ADD RIGHT-Radius for returnDate
      if (_rangeEnd!.difference(date).inDays == 0) {
        borderRadius = BorderRadius.only(
          bottomRight: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        );
      }
      // Outer Container decoration
      outerDecoration = BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        shape: BoxShape.rectangle,
        borderRadius: borderRadius,
      );
      // Inner Container decoration
      decoration = BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
      );
      // ADD Dark-Background for selected days
      if (_rangeStart!.difference(date).inDays == 0 ||
          _rangeEnd!.difference(date).inDays == 0) {
        decoration = BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        );
      }
    }
    return Container(
      width: 40,
      height: 40,
      // margin: const EdgeInsets.symmetric(vertical: 3),
      decoration: outerDecoration,
      child: Container(
        padding: const EdgeInsets.only(bottom: 3.0),
        decoration: decoration,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${date.day}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelectedDay
                      ? (isTodaySDate ? Colors.black : Colors.white)
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
