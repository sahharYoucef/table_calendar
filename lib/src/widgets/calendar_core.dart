// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';

import '../shared/utils.dart';
import 'calendar_page.dart';

typedef _OnCalendarPageChanged = void Function(
    int pageIndex, DateTime focusedDay);

class CalendarCore extends StatelessWidget {
  final DateTime? focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final CalendarFormat calendarFormat;
  final DayBuilder? dowBuilder;
  final FocusedDayBuilder dayBuilder;
  final bool sixWeekMonthsEnforced;
  final bool dowVisible;
  final Decoration? dowDecoration;
  final Decoration? rowDecoration;
  final TableBorder? tableBorder;
  final double? dowHeight;
  final double? rowHeight;
  final BoxConstraints constraints;
  final int? previousIndex;
  final StartingDayOfWeek startingDayOfWeek;
  final PageController? pageController;
  final ScrollPhysics? scrollPhysics;
  final _OnCalendarPageChanged onPageChanged;

  const CalendarCore({
    Key? key,
    this.dowBuilder,
    required this.dayBuilder,
    required this.onPageChanged,
    required this.firstDay,
    required this.lastDay,
    required this.constraints,
    this.dowHeight,
    this.rowHeight,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.calendarFormat = CalendarFormat.month,
    this.pageController,
    this.focusedDay,
    this.previousIndex,
    this.sixWeekMonthsEnforced = false,
    this.dowVisible = true,
    this.dowDecoration,
    this.rowDecoration,
    this.tableBorder,
    this.scrollPhysics,
  })  : assert(!dowVisible || (dowHeight != null && dowBuilder != null)),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      physics: scrollPhysics,
      itemCount:
          getPageCount(calendarFormat, firstDay, lastDay, startingDayOfWeek),
      itemBuilder: (context, index) {
        final baseDay = getBaseDay(calendarFormat, firstDay, lastDay, index);
        final visibleRange = getVisibleRange(
            calendarFormat, baseDay, sixWeekMonthsEnforced, startingDayOfWeek);
        final visibleDays = daysInRange(visibleRange.start, visibleRange.end);

        final actualDowHeight = dowVisible ? dowHeight! : 0.0;
        final constrainedRowHeight = constraints.hasBoundedHeight
            ? (constraints.maxHeight - actualDowHeight) /
                getRowCount(calendarFormat, baseDay, sixWeekMonthsEnforced,
                    startingDayOfWeek)
            : null;

        return CalendarPage(
          visibleDays: visibleDays,
          dowVisible: dowVisible,
          dowDecoration: dowDecoration,
          rowDecoration: rowDecoration,
          tableBorder: tableBorder,
          dowBuilder: (context, day) {
            return SizedBox(
              height: dowHeight,
              child: dowBuilder?.call(context, day),
            );
          },
          dayBuilder: (context, day) {
            DateTime baseDay;
            final previousFocusedDay = focusedDay;
            if (previousFocusedDay == null || previousIndex == null) {
              baseDay = getBaseDay(calendarFormat, firstDay, lastDay, index);
            } else {
              baseDay = getFocusedDay(calendarFormat, firstDay, lastDay,
                  previousFocusedDay, index, previousIndex);
            }

            return SizedBox(
              height: constrainedRowHeight ?? rowHeight,
              child: dayBuilder(context, day, baseDay),
            );
          },
        );
      },
      // onPageChanged: (index) {
      //   DateTime baseDay;
      //   final previousFocusedDay = focusedDay;
      //   if (previousFocusedDay == null || previousIndex == null) {
      //     baseDay = getBaseDay(calendarFormat, firstDay, lastDay, index);
      //   } else {
      //     baseDay = getFocusedDay(calendarFormat, firstDay, lastDay,
      //         previousFocusedDay, index, previousIndex);
      //   }

      //   return onPageChanged(index, baseDay);
      // },
    );
  }
}
