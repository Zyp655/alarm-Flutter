import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../domain/enitities/schedule_entity.dart';
import 'schedule_data_source.dart';

class ScheduleCalendarView extends StatelessWidget {
  final List<ScheduleEntity> appointments;
  final CalendarController calendarController;
  final Function(ScheduleEntity) onEdit;
  final Function(ScheduleEntity) onDelete;

  const ScheduleCalendarView({
    super.key,
    required this.appointments,
    required this.calendarController,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      controller: calendarController,
      view: CalendarView.week,
      firstDayOfWeek: 1,
      dataSource: ScheduleDataSource(appointments),
      timeSlotViewSettings: const TimeSlotViewSettings(
        startHour: 6,
        endHour: 23,
        timeFormat: 'H:mm',
      ),
      headerStyle: const CalendarHeaderStyle(
        textAlign: TextAlign.center,
        backgroundColor: Colors.white,
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
      onTap: (CalendarTapDetails details) {
        if (details.appointments != null && details.appointments!.isNotEmpty) {
          final dynamic appointment = details.appointments!.first;

          if (appointment is ScheduleEntity) {
            if (appointment.classCode != null &&
                appointment.classCode!.isNotEmpty) {
              _showReadOnlyDialog(context, appointment);
            } else {
              _showActionBottomSheet(context, appointment);
            }
          }
        }
      },
    );
  }

  void _showReadOnlyDialog(BuildContext context, ScheduleEntity item) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    final isAbsenceWarning = item.currentAbsences >= item.maxAbsences;
    final absenceColor = isAbsenceWarning ? Colors.red : Colors.black87;

    bool showMidterm = item.credits >= 3;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.school, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(item.subject, style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              Icons.vpn_key,
              "Mã lớp: ${item.classCode}",
              Colors.grey[700],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.room, "Phòng: ${item.room}", Colors.grey[700]),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.calendar_today,
              "Ngày: ${dateFormat.format(item.start)}",
              Colors.grey[700],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.access_time,
              "Giờ: ${timeFormat.format(item.start)} - ${timeFormat.format(item.end)}",
              Colors.grey[700],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.star,
              "Số tín chỉ: ${item.credits}",
              Colors.grey[700],
            ),
            const Divider(height: 24, thickness: 1),
            const Text(
              "Kết quả học tập:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event_busy, size: 20, color: absenceColor),
                const SizedBox(width: 8),
                Text(
                  "Vắng: ",
                  style: TextStyle(fontSize: 15, color: Colors.grey[800]),
                ),
                Text(
                  "${item.currentAbsences} / ${item.maxAbsences} tiết",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: absenceColor,
                  ),
                ),
                if (isAbsenceWarning)
                  const Text(
                    " (Cấm thi!)",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (showMidterm) _buildScoreRow("Điểm giữa kỳ:", item.midtermScore),
            if (showMidterm) const SizedBox(height: 10),
            _buildScoreRow("Điểm cuối kỳ:", item.finalScore),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      "Dữ liệu được cập nhật từ giảng viên.",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String label, double? score) {
    Color scoreColor = Colors.black87;
    String scoreText = "Chưa cập nhật";

    if (score != null) {
      scoreText = score.toString();
      if (score < 4.0) {
        scoreColor = Colors.red;
      } else if (score >= 8.5) {
        scoreColor = Colors.green[700]!;
      }
    }

    return Row(
      children: [
        Icon(Icons.grade, size: 20, color: Colors.orange[700]),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[800])),
        const Spacer(),
        Text(
          scoreText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: scoreColor,
          ),
        ),
      ],
    );
  }

  void _showActionBottomSheet(BuildContext context, ScheduleEntity item) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.edit_calendar, color: Colors.blue),
                const SizedBox(width: 10),
                Text(
                  item.subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Chỉnh sửa'),
            onTap: () {
              Navigator.pop(ctx);
              onEdit(item);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa lịch này'),
            onTap: () {
              Navigator.pop(ctx);
              onDelete(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color? color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
