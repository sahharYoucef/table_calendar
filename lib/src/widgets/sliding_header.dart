import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class SlidingHeader extends StatefulWidget {
  final int pageCount;
  final ScrollController headerScrollController;
  final PageController pageController;
  final DateTime firstDay;
  final DateTime lastDay;
  final HeaderStyle? headerStyle;
  final CalendarFormat? calendarFormat;

  const SlidingHeader({
    Key? key,
    required this.pageCount,
    required this.headerScrollController,
    required this.pageController,
    required this.firstDay,
    required this.lastDay,
    this.headerStyle,
    this.calendarFormat,
  }) : super(key: key);
  @override
  _SlidingHeaderState createState() => _SlidingHeaderState();
}

class _SlidingHeaderState extends State<SlidingHeader> {
  late double currentPage;
  @override
  void initState() {
    super.initState();
    currentPage = widget.pageController.initialPage.toDouble();
    widget.pageController.addListener(() {
      setState(() {
        currentPage = widget.pageController.page!.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: IgnorePointer(
        ignoring: true,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: widget.headerScrollController,
            physics: NeverScrollableScrollPhysics(),
            itemCount: widget.pageCount + 1,
            itemBuilder: (context, index) {
              var opacity = (currentPage + 1 - index).clamp(0.2, 1.0);
              return Opacity(
                opacity: opacity,
                child: Container(
                  padding: EdgeInsets.only(left: 16),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.9,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.pageCount == index
                        ? '${DateFormat('MMMM yy').format(_getBaseDay(widget.calendarFormat!, index).add(Duration(days: 31)))}'
                        : '${DateFormat('MMMM yy').format(_getBaseDay(widget.calendarFormat!, index))}',
                    style: widget.headerStyle!.titleTextStyle,
                  ),
                ),
              );
            }),
      ),
    );
  }

  DateTime _getBaseDay(CalendarFormat format, int pageIndex) {
    DateTime day;

    switch (format) {
      case CalendarFormat.month:
        day = DateTime.utc(
            widget.firstDay.year, widget.firstDay.month + pageIndex);
        break;
      case CalendarFormat.twoWeeks:
        day = DateTime.utc(widget.firstDay.year, widget.firstDay.month,
            widget.firstDay.day + pageIndex * 14);
        break;
      case CalendarFormat.week:
        day = DateTime.utc(widget.firstDay.year, widget.firstDay.month,
            widget.firstDay.day + pageIndex * 7);
        break;
    }

    if (day.isBefore(widget.firstDay)) {
      day = widget.firstDay;
    } else if (day.isAfter(widget.lastDay)) {
      day = widget.lastDay;
    }

    return day;
  }
}
