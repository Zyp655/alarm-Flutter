import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as xl;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/platform_helper.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';

class SemesterComparisonPage extends StatefulWidget {
  final int teacherId;

  const SemesterComparisonPage({super.key, required this.teacherId});

  @override
  State<SemesterComparisonPage> createState() => _SemesterComparisonPageState();
}

class _SemesterComparisonPageState extends State<SemesterComparisonPage> {
  List<Map<String, dynamic>> _semesters = [];
  bool _isLoading = true;
  String _selectedMetric = 'avgProgress';

  final _metricLabels = {
    'avgProgress': 'Tiến độ TB (%)',
    'completionRate': 'Tỷ lệ hoàn thành (%)',
    'avgQuizScore': 'Điểm Quiz TB (%)',
    'avgAbsenceRate': 'Tỷ lệ vắng TB (%)',
    'avgLateRate': 'Tỷ lệ trễ BT TB (%)',
  };

  final _metricColors = {
    'avgProgress': const Color(0xFF6C63FF),
    'completionRate': const Color(0xFF00B894),
    'avgQuizScore': const Color(0xFFFFD93D),
    'avgAbsenceRate': const Color(0xFFFF6B6B),
    'avgLateRate': const Color(0xFFFF9A56),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final api = sl<ApiClient>();
      final res = await api.get(
        '/teacher/semester-comparison?teacherId=${widget.teacherId}',
      );
      final list = List<Map<String, dynamic>>.from(res['semesters'] ?? []);
      if (mounted) setState(() { _semesters = list; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('So sánh Học kỳ'),
        elevation: 0,
        actions: [
          if (_semesters.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: 'Xuất Excel',
              onPressed: _exportExcel,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _semesters.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildSummaryCards(isDark),
                      const SizedBox(height: 20),
                      _buildMetricSelector(isDark),
                      const SizedBox(height: 16),
                      _buildBarChart(isDark),
                      const SizedBox(height: 24),
                      _buildComparisonTable(isDark),
                      const SizedBox(height: 24),
                      _buildCourseBreakdown(isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64,
              color: AppColors.textSecondary(context)),
          const SizedBox(height: 16),
          Text('Chưa có dữ liệu học kỳ',
              style: TextStyle(color: AppColors.textSecondary(context), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(bool isDark) {
    final latest = _semesters.isNotEmpty ? _semesters.first : null;
    final previous = _semesters.length > 1 ? _semesters[1] : null;

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            'Học kỳ hiện tại',
            latest?['semesterName'] ?? '--',
            '${latest?['totalStudents'] ?? 0} SV',
            AppColors.primary,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            'Học kỳ trước',
            previous?['semesterName'] ?? '--',
            '${previous?['totalStudents'] ?? 0} SV',
            AppColors.accent,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      String label, String title, String subtitle, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(
            color: AppColors.textSecondary(context), fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(
            color: AppColors.textPrimary(context), fontSize: 16,
            fontWeight: FontWeight.bold),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(
            color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildMetricSelector(bool isDark) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _metricLabels.entries.map((e) {
          final isActive = _selectedMetric == e.key;
          final color = _metricColors[e.key]!;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isActive,
              label: Text(e.value, style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : AppColors.textSecondary(context),
              )),
              selectedColor: color,
              backgroundColor: AppColors.cardColor(context),
              side: BorderSide(color: isActive ? color : AppColors.border(context)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedMetric = e.key),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBarChart(bool isDark) {
    final color = _metricColors[_selectedMetric]!;
    final data = _semesters.reversed.toList();
    final maxVal = data.fold<double>(0, (m, s) {
      final v = (s[_selectedMetric] as num?)?.toDouble() ?? 0;
      return v > m ? v : m;
    });

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxVal * 1.2).clamp(10, 110),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final sem = data[group.x.toInt()];
                return BarTooltipItem(
                  '${sem['semesterName']}\n${rod.toY.toStringAsFixed(1)}%',
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w600,
                      fontSize: 12),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx >= data.length) return const SizedBox();
                  final sem = data[idx];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'HK${sem['term']}',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 10),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border(context).withAlpha(60),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: data.asMap().entries.map((entry) {
            final val = (entry.value[_selectedMetric] as num?)?.toDouble() ?? 0;
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: val,
                  color: color,
                  width: data.length <= 4 ? 28 : 18,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: (maxVal * 1.2).clamp(10, 110),
                    color: color.withAlpha(isDark ? 15 : 10),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildComparisonTable(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chi tiết theo học kỳ', style: TextStyle(
          color: AppColors.textPrimary(context), fontSize: 16,
          fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50),
              columnSpacing: 20,
              columns: const [
                DataColumn(label: Text('Học kỳ', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('SV', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Tiến độ', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Hoàn thành', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Quiz', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Vắng', style: TextStyle(fontWeight: FontWeight.bold))),
                DataColumn(label: Text('Trễ BT', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
              rows: _semesters.map((s) {
                return DataRow(cells: [
                  DataCell(Text(s['semesterName'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text('${s['totalStudents']}')),
                  DataCell(_coloredValue(s['avgProgress'], '%')),
                  DataCell(_coloredValue(s['completionRate'], '%')),
                  DataCell(_coloredValue(s['avgQuizScore'], '%')),
                  DataCell(_coloredValue(s['avgAbsenceRate'], '%',
                      invert: true)),
                  DataCell(_coloredValue(s['avgLateRate'], '%',
                      invert: true)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _coloredValue(dynamic value, String suffix, {bool invert = false}) {
    if (value == null) return Text('--', style: TextStyle(color: AppColors.textSecondary(context)));
    final v = (value as num).toDouble();
    Color color;
    if (invert) {
      color = v > 20 ? AppColors.error : v > 10 ? AppColors.warning : AppColors.success;
    } else {
      color = v >= 70 ? AppColors.success : v >= 40 ? AppColors.warning : AppColors.error;
    }
    return Text('${v.toStringAsFixed(1)}$suffix',
        style: TextStyle(color: color, fontWeight: FontWeight.w600));
  }

  Widget _buildCourseBreakdown(bool isDark) {
    final latest = _semesters.isNotEmpty ? _semesters.first : null;
    if (latest == null) return const SizedBox();
    final courses = List<Map<String, dynamic>>.from(latest['courses'] ?? []);
    if (courses.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Môn học — ${latest['semesterName']}', style: TextStyle(
          color: AppColors.textPrimary(context), fontSize: 16,
          fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...courses.map((c) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c['courseName'] ?? '', style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('${c['classCode']} • ${c['studentCount']} SV',
                        style: TextStyle(color: AppColors.textSecondary(context),
                            fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${c['avgProgress']}%', style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.bold,
                    fontSize: 16)),
                  Text('${c['completedCount']}/${c['studentCount']} xong',
                      style: TextStyle(color: AppColors.textSecondary(context),
                          fontSize: 11)),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }

  Future<void> _exportExcel() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Đang tạo báo cáo...'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 1)),
      );

      final excel = xl.Excel.createExcel();
      final sheet = excel['So sánh Học kỳ'];
      excel.delete('Sheet1');

      final headers = [
        'Học kỳ', 'Năm', 'Kỳ', 'Số SV', 'Số lớp',
        'Tiến độ TB (%)', 'Hoàn thành (%)', 'Quiz TB (%)',
        'Vắng TB (%)', 'Trễ BT TB (%)',
      ];

      final headerStyle = xl.CellStyle(
        bold: true,
        backgroundColorHex: xl.ExcelColor.fromHexString('#2D3436'),
        fontColorHex: xl.ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: xl.HorizontalAlign.Center,
      );

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
            xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = xl.TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      for (var i = 0; i < _semesters.length; i++) {
        final s = _semesters[i];
        final row = [
          xl.TextCellValue(s['semesterName'] ?? ''),
          xl.IntCellValue(s['year'] ?? 0),
          xl.IntCellValue(s['term'] ?? 0),
          xl.IntCellValue(s['totalStudents'] ?? 0),
          xl.IntCellValue(s['totalClasses'] ?? 0),
          xl.DoubleCellValue((s['avgProgress'] as num?)?.toDouble() ?? 0),
          xl.DoubleCellValue((s['completionRate'] as num?)?.toDouble() ?? 0),
          s['avgQuizScore'] != null
              ? xl.DoubleCellValue((s['avgQuizScore'] as num).toDouble())
              : xl.TextCellValue('--') as xl.CellValue,
          s['avgAbsenceRate'] != null
              ? xl.DoubleCellValue((s['avgAbsenceRate'] as num).toDouble())
              : xl.TextCellValue('--') as xl.CellValue,
          s['avgLateRate'] != null
              ? xl.DoubleCellValue((s['avgLateRate'] as num).toDouble())
              : xl.TextCellValue('--') as xl.CellValue,
        ];

        for (var j = 0; j < row.length; j++) {
          sheet.cell(xl.CellIndex.indexByColumnRow(
                  columnIndex: j, rowIndex: i + 1))
              .value = row[j];
        }
      }

      if (_semesters.isNotEmpty) {
        final detailSheet = excel['Chi tiết Môn học'];
        final dHeaders = ['Học kỳ', 'Môn học', 'Mã lớp', 'Số SV', 'Tiến độ TB (%)', 'Hoàn thành'];
        for (var i = 0; i < dHeaders.length; i++) {
          final cell = detailSheet.cell(
              xl.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
          cell.value = xl.TextCellValue(dHeaders[i]);
          cell.cellStyle = headerStyle;
        }

        var rowIdx = 1;
        for (final sem in _semesters) {
          final courses = List<Map<String, dynamic>>.from(sem['courses'] ?? []);
          for (final c in courses) {
            detailSheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIdx))
                .value = xl.TextCellValue(sem['semesterName'] ?? '');
            detailSheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIdx))
                .value = xl.TextCellValue(c['courseName'] ?? '');
            detailSheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIdx))
                .value = xl.TextCellValue(c['classCode'] ?? '');
            detailSheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIdx))
                .value = xl.IntCellValue(c['studentCount'] ?? 0);
            detailSheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIdx))
                .value = xl.DoubleCellValue((c['avgProgress'] as num?)?.toDouble() ?? 0);
            detailSheet.cell(xl.CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIdx))
                .value = xl.IntCellValue(c['completedCount'] ?? 0);
            rowIdx++;
          }
        }
      }

      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, i == 0 ? 20 : 14);
      }

      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception('Không thể tạo file');

      if (kIsWeb) {
        downloadFileWeb(Uint8List.fromList(fileBytes), 'Bao_cao_hoc_ky.xlsx');
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final timestamp = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
        final filePath = '${dir.path}/Bao_cao_hoc_ky_$timestamp.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            text: 'Báo cáo so sánh tiến độ giữa các học kỳ',
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Xuất báo cáo thành công!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi xuất: $e'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
        );
      }
    }
  }
}
