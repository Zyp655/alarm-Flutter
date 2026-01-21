import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../../domain/enitities/schedule_entity.dart';

class ExcelScheduleParser {
  static Future<List<ScheduleEntity>> parse(String filePath) async {
    List<ScheduleEntity> parsedList = [];

    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      for (var table in excel.tables.keys) {
        var rows = excel.tables[table]!.rows;

        for (int i = 1; i < rows.length; i++) {
          var row = rows[i];
          if (row.isEmpty || row[0] == null) continue;

          String subject = row[0]?.value.toString() ?? "Môn học";
          String room = "";

          DateTime? startDateTime;
          DateTime? endDateTime;

          try {
            String dateStr = row[1]?.value.toString() ?? "";
            String timeStart = row[2]?.value.toString() ?? "";
            String timeEnd = row[3]?.value.toString() ?? "";

            if (timeStart.length > 5) timeStart = timeStart.substring(0, 5);
            if (timeEnd.length > 5) timeEnd = timeEnd.substring(0, 5);

            DateFormat format = DateFormat("d/M/yyyy H:m");
            startDateTime = format.parse("$dateStr $timeStart");
            endDateTime = format.parse("$dateStr $timeEnd");
            room = "";
          } catch (e) {
            startDateTime = null;
          }

          if (startDateTime == null) {
            try {
              room = row[1]?.value.toString() ?? "";
              String startStr = row[2]?.value.toString() ?? "";
              String endStr = row[3]?.value.toString() ?? "";

              DateFormat formatOld = DateFormat("yyyy-MM-dd HH:mm");
              startDateTime = formatOld.parse(startStr);
              endDateTime = formatOld.parse(endStr);
            } catch (e) {
              continue;
            }
          }

          if (startDateTime != null && endDateTime != null) {
            parsedList.add(ScheduleEntity(
              subject: subject,
              room: room,
              start: startDateTime,
              end: endDateTime,
            ));
          }
        }
      }
    } catch (e) {
      print("Lỗi đọc file Excel: $e");
    }

    return parsedList;
  }
}