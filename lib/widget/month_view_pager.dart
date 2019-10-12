import 'package:flutter/material.dart';
import 'package:flutter_custom_calendar/calendar_provider.dart';
import 'package:flutter_custom_calendar/configuration.dart';
import 'package:flutter_custom_calendar/constants/constants.dart';
import 'package:flutter_custom_calendar/model/date_model.dart';
import 'package:flutter_custom_calendar/utils/LogUtil.dart';
import 'package:flutter_custom_calendar/utils/date_util.dart';
import 'package:flutter_custom_calendar/widget/month_view.dart';
import 'package:provider/provider.dart';

class MonthViewPager extends StatefulWidget {
  const MonthViewPager({Key key}) : super(key: key);

  @override
  _MonthViewPagerState createState() => _MonthViewPagerState();
}

class _MonthViewPagerState extends State<MonthViewPager> {
  CalendarProvider calendarProvider;

  @override
  void initState() {
    LogUtil.log(TAG: this.runtimeType, message: "MonthViewPager initState");

    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);

//    //计算当前月视图的index
//    DateModel dateModel = calendarProvider.lastClickDateModel;
//    List<DateModel> monthList =
//        calendarProvider.calendarConfiguration.monthList;
//    int index = 0;
//    for (int i = 0; i < monthList.length; i++) {
//      DateModel firstDayOfMonth = monthList[i];
//      DateModel lastDayOfMonth = DateModel.fromDateTime(firstDayOfMonth
//          .getDateTime()
//          .add(Duration(
//              days: DateUtil.getMonthDaysCount(
//                  firstDayOfMonth.year, firstDayOfMonth.month))));
//
//      if ((dateModel.isAfter(firstDayOfMonth) ||
//              dateModel.isSameWith(firstDayOfMonth)) &&
//          dateModel.isBefore(lastDayOfMonth)) {
//        index = i;
//        break;
//      }
//    }
//    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//      calendarProvider.calendarConfiguration.monthController.jumpToPage(index);
//    });
  }

  @override
  void dispose() {
    LogUtil.log(TAG: this.runtimeType, message: "MonthViewPager dispose");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    获取到当前的CalendarProvider对象,设置listen为false，不需要刷新
    calendarProvider = Provider.of<CalendarProvider>(context, listen: false);
    CalendarConfiguration configuration =
        calendarProvider.calendarConfiguration;

    return PageView.builder(
      onPageChanged: (position) {
        if (calendarProvider.expandStatus.value == false) {
          return;
        }
        //月份的变化
        DateModel dateModel = configuration.monthList[position];
        configuration.monthChange(dateModel.year, dateModel.month);
        //用来保存临时变量，用于月视图切换到周视图的时候，默认是显示中间的一周
        if (calendarProvider.lastClickDateModel != null ||
            calendarProvider.lastClickDateModel.month != dateModel.month) {
          DateModel temp = new DateModel();
          temp.year = configuration.monthList[position].year;
          temp.month = configuration.monthList[position].month;
          temp.day = configuration.monthList[position].day + 14;
          calendarProvider.lastClickDateModel = temp;
        }

        //计算下高度，使PageView自适应高度
        if (calendarProvider.calendarConfiguration.showMode !=
            Constants.MODE_SHOW_ONLY_WEEK) {
          //月份切换的时候，如果高度发生变化的话，需要setState使高度整体自适应
          int lineCount =
              DateUtil.getMonthViewLineCount(dateModel.year, dateModel.month);
          double newHeight = (calendarProvider.calendarConfiguration.itemSize ??
                      MediaQuery.of(context).size.width / 7) *
                  lineCount +
              calendarProvider.calendarConfiguration.verticalSpacing *
                  (lineCount - 1);
          if (calendarProvider.totalHeight.toInt() != newHeight.toInt()) {
            LogUtil.log(TAG: this.runtimeType, message: "月份视图高度发生变化");
            calendarProvider.totalHeight = newHeight;
//          calendarProvider.changeTotalHeight(newHeight);
          }
        }
      },
      controller: configuration.monthController,
      itemBuilder: (context, index) {
        final DateModel dateModel = configuration.monthList[index];
        return new MonthView(
            configuration: configuration,
            year: dateModel.year,
            month: dateModel.month,
            mainSpacing: configuration.verticalSpacing);
      },
      itemCount: configuration.monthList.length,
    );
  }
}
