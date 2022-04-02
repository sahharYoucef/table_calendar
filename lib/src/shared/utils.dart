// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Signature for a function that creates a widget for a given `day`.
typedef DayBuilder = Widget? Function(BuildContext context, DateTime day);

/// Signature for a function that creates a widget for a given `day`.
/// Additionally, contains the currently focused day.
typedef FocusedDayBuilder = Widget? Function(
    BuildContext context, DateTime day, DateTime focusedDay);

/// Signature for a function returning text that can be localized and formatted with `DateFormat`.
typedef TextFormatter = String Function(DateTime date, dynamic locale);

/// Gestures available for the calendar.
enum AvailableGestures { none, verticalSwipe, horizontalSwipe, all }

/// Formats that the calendar can display.
enum CalendarFormat { month, twoWeeks, week }

/// Days of the week that the calendar can start with.
enum StartingDayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}

/// Returns a numerical value associated with given `weekday`.
///
/// Returns 1 for `StartingDayOfWeek.monday`, all the way to 7 for `StartingDayOfWeek.sunday`.
int getWeekdayNumber(StartingDayOfWeek weekday) {
  return StartingDayOfWeek.values.indexOf(weekday) + 1;
}

/// Returns `date` in UTC format, without its time part.
DateTime normalizeDate(DateTime date) {
  return DateTime.utc(date.year, date.month, date.day);
}

/// Checks if two DateTime objects are the same day.
/// Returns `false` if either of them is null.
bool isSameDay(DateTime? a, DateTime? b) {
  if (a == null || b == null) {
    return false;
  }

  return a.year == b.year && a.month == b.month && a.day == b.day;
}

int getPageCount(CalendarFormat format, DateTime first, DateTime last,
    StartingDayOfWeek startingDayOfWeek) {
  switch (format) {
    case CalendarFormat.month:
      return _getMonthCount(first, last) + 1;
    case CalendarFormat.twoWeeks:
      return _getTwoWeekCount(first, last, startingDayOfWeek) + 1;
    case CalendarFormat.week:
      return _getWeekCount(first, last, startingDayOfWeek) + 1;
    default:
      return _getMonthCount(first, last) + 1;
  }
}

int _getMonthCount(DateTime first, DateTime last) {
  final yearDif = last.year - first.year;
  final monthDif = last.month - first.month;

  return yearDif * 12 + monthDif;
}

int _getWeekCount(
    DateTime first, DateTime last, StartingDayOfWeek startingDayOfWeek) {
  return last.difference(_firstDayOfWeek(first, startingDayOfWeek)).inDays ~/ 7;
}

int _getTwoWeekCount(
    DateTime first, DateTime last, StartingDayOfWeek startingDayOfWeek) {
  return last.difference(_firstDayOfWeek(first, startingDayOfWeek)).inDays ~/
      14;
}

DateTime getFocusedDay(
    CalendarFormat format,
    DateTime firstDay,
    DateTime lastDay,
    DateTime prevFocusedDay,
    int pageIndex,
    int? previousIndex) {
  if (pageIndex == previousIndex) {
    return prevFocusedDay;
  }

  final pageDif = pageIndex - previousIndex!;
  DateTime day;

  switch (format) {
    case CalendarFormat.month:
      day = DateTime.utc(prevFocusedDay.year, prevFocusedDay.month + pageDif);
      break;
    case CalendarFormat.twoWeeks:
      day = DateTime.utc(prevFocusedDay.year, prevFocusedDay.month,
          prevFocusedDay.day + pageDif * 14);
      break;
    case CalendarFormat.week:
      day = DateTime.utc(prevFocusedDay.year, prevFocusedDay.month,
          prevFocusedDay.day + pageDif * 7);
      break;
  }

  if (day.isBefore(firstDay)) {
    day = firstDay;
  } else if (day.isAfter(lastDay)) {
    day = lastDay;
  }

  return day;
}

DateTime getBaseDay(
    CalendarFormat format, DateTime firstDay, DateTime lastDay, int pageIndex) {
  DateTime day;

  switch (format) {
    case CalendarFormat.month:
      day = DateTime.utc(firstDay.year, firstDay.month + pageIndex);
      break;
    case CalendarFormat.twoWeeks:
      day = DateTime.utc(
          firstDay.year, firstDay.month, firstDay.day + pageIndex * 14);
      break;
    case CalendarFormat.week:
      day = DateTime.utc(
          firstDay.year, firstDay.month, firstDay.day + pageIndex * 7);
      break;
  }

  if (day.isBefore(firstDay)) {
    day = firstDay;
  } else if (day.isAfter(lastDay)) {
    day = lastDay;
  }

  return day;
}

DateTimeRange getVisibleRange(CalendarFormat format, DateTime focusedDay,
    bool sixWeekMonthsEnforced, StartingDayOfWeek startingDayOfWeek) {
  switch (format) {
    case CalendarFormat.month:
      return _daysInMonth(focusedDay, sixWeekMonthsEnforced, startingDayOfWeek);
    case CalendarFormat.twoWeeks:
      return _daysInTwoWeeks(focusedDay, startingDayOfWeek);
    case CalendarFormat.week:
      return _daysInWeek(focusedDay, startingDayOfWeek);
    default:
      return _daysInMonth(focusedDay, sixWeekMonthsEnforced, startingDayOfWeek);
  }
}

DateTimeRange _daysInWeek(
    DateTime focusedDay, StartingDayOfWeek startingDayOfWeek) {
  final daysBefore = _getDaysBefore(focusedDay, startingDayOfWeek);
  final firstToDisplay = focusedDay.subtract(Duration(days: daysBefore));
  final lastToDisplay = firstToDisplay.add(const Duration(days: 7));
  return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
}

DateTimeRange _daysInTwoWeeks(
    DateTime focusedDay, StartingDayOfWeek startingDayOfWeek) {
  final daysBefore = _getDaysBefore(focusedDay, startingDayOfWeek);
  final firstToDisplay = focusedDay.subtract(Duration(days: daysBefore));
  final lastToDisplay = firstToDisplay.add(const Duration(days: 14));
  return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
}

DateTimeRange _daysInMonth(DateTime focusedDay, bool sixWeekMonthsEnforced,
    StartingDayOfWeek startingDayOfWeek) {
  final first = _firstDayOfMonth(focusedDay);
  final daysBefore = _getDaysBefore(first, startingDayOfWeek);
  final firstToDisplay = first.subtract(Duration(days: daysBefore));

  if (sixWeekMonthsEnforced) {
    final end = firstToDisplay.add(const Duration(days: 42));
    return DateTimeRange(start: firstToDisplay, end: end);
  }

  final last = _lastDayOfMonth(focusedDay);
  final daysAfter = _getDaysAfter(last, startingDayOfWeek);
  final lastToDisplay = last.add(Duration(days: daysAfter));

  return DateTimeRange(start: firstToDisplay, end: lastToDisplay);
}

List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

DateTime _firstDayOfWeek(DateTime week, StartingDayOfWeek startingDayOfWeek) {
  final daysBefore = _getDaysBefore(week, startingDayOfWeek);
  return week.subtract(Duration(days: daysBefore));
}

DateTime _firstDayOfMonth(DateTime month) {
  return DateTime.utc(month.year, month.month, 1);
}

DateTime _lastDayOfMonth(DateTime month) {
  final date = month.month < 12
      ? DateTime.utc(month.year, month.month + 1, 1)
      : DateTime.utc(month.year + 1, 1, 1);
  return date.subtract(const Duration(days: 1));
}

int getRowCount(CalendarFormat format, DateTime focusedDay,
    bool sixWeekMonthsEnforced, StartingDayOfWeek startingDayOfWeek) {
  if (format == CalendarFormat.twoWeeks) {
    return 2;
  } else if (format == CalendarFormat.week) {
    return 1;
  } else if (sixWeekMonthsEnforced) {
    return 6;
  }

  final first = _firstDayOfMonth(focusedDay);
  final daysBefore = _getDaysBefore(first, startingDayOfWeek);
  final firstToDisplay = first.subtract(Duration(days: daysBefore));

  final last = _lastDayOfMonth(focusedDay);
  final daysAfter = _getDaysAfter(last, startingDayOfWeek);
  final lastToDisplay = last.add(Duration(days: daysAfter));

  return (lastToDisplay.difference(firstToDisplay).inDays + 1) ~/ 7;
}

int _getDaysBefore(DateTime firstDay, StartingDayOfWeek startingDayOfWeek) {
  return (firstDay.weekday + 7 - getWeekdayNumber(startingDayOfWeek)) % 7;
}

int _getDaysAfter(DateTime lastDay, StartingDayOfWeek startingDayOfWeek) {
  int invertedStartingWeekday = 8 - getWeekdayNumber(startingDayOfWeek);

  int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);
  if (daysAfter == 7) {
    daysAfter = 0;
  }

  return daysAfter;
}
