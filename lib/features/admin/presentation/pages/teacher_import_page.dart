import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:excel/excel.dart' hide Border;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/utils/platform_helper.dart';

import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/import_shared_widgets.dart';
import '../widgets/import_step_indicator.dart';

enum ImportRowStatus { valid, error }

class _ImportRow {
  final int rowIndex;
  final String teacherId;
  final String fullName;
  final String email;
  final String department;
  final ImportRowStatus status;
  final String? errorReason;
  String? generatedPassword;

  _ImportRow({
    required this.rowIndex,
    required this.teacherId,
    required this.fullName,
    required this.email,
    required this.department,
    required this.status,
    this.errorReason,
    this.generatedPassword,
  });
}

enum _FilterMode { all, valid, error }

class TeacherImportPage extends StatefulWidget {
  const TeacherImportPage({super.key});

  @override
  State<TeacherImportPage> createState() => _TeacherImportPageState();
}

class _TeacherImportPageState extends State<TeacherImportPage> {
  int _currentStep = 0;
  bool _isProcessing = false;
  String? _selectedFileName;
  List<_ImportRow> _rows = [];
  _FilterMode _filterMode = _FilterMode.all;
  String? _resultMessage;
  String? _exportedFilePath;

  int get _validCount =>
      _rows.where((r) => r.status == ImportRowStatus.valid).length;
  int get _errorCount =>
      _rows.where((r) => r.status == ImportRowStatus.error).length;

  List<_ImportRow> get _filteredRows {
    switch (_filterMode) {
      case _FilterMode.valid:
        return _rows.where((r) => r.status == ImportRowStatus.valid).toList();
      case _FilterMode.error:
        return _rows.where((r) => r.status == ImportRowStatus.error).toList();
      case _FilterMode.all:
        return _rows;
    }
  }

  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  String _generatePassword([int length = 8]) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(
      length,
      (_) => chars[rng.nextInt(chars.length)],
    ).join();
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isProcessing = true);
    try {
      final excel = Excel.createExcel();
      final sheet = excel['DanhSachGiangVien'];
      excel.delete('Sheet1');

      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#6366F1'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );

      final headers = ['Mã GV (*)', 'Họ tên (*)', 'Email (*)', 'Khoa'];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      final samples = [
        [
          'GV001',
          'Nguyễn Văn A',
          'nguyenvana@lms.edu.vn',
          'Công nghệ thông tin',
        ],
        ['GV002', 'Trần Thị B', 'tranthib@lms.edu.vn', 'Kinh tế'],
      ];
      for (var r = 0; r < samples.length; r++) {
        for (var c = 0; c < samples[r].length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
              .value = TextCellValue(
            samples[r][c],
          );
        }
      }

      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 25);
      sheet.setColumnWidth(2, 30);
      sheet.setColumnWidth(3, 25);

      final bytes = excel.save();
      if (bytes == null) throw Exception('Không thể tạo tệp');

      if (kIsWeb) {
        downloadFileWeb(Uint8List.fromList(bytes), 'MauImportGiangVien.xlsx');
        if (!mounted) return;
        _snack('Đã tạo tệp mẫu thành công!');
      } else {
        final dir = Directory('/storage/emulated/0/Download');
        final savePath = dir.existsSync()
            ? dir.path
            : (await getApplicationDocumentsDirectory()).path;
        final filePath = '$savePath/MauImportGiangVien.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        if (!mounted) return;
        _snack('Đã tạo tệp mẫu thành công!');
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            title: 'Tệp mẫu Import Giảng Viên',
          ),
        );
      }
    } catch (e) {
      _snack('Lỗi tạo tệp mẫu: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _pickAndParseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _selectedFileName = result.files.first.name;
    });

    try {
      final file = result.files.first;
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null && !kIsWeb) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) throw Exception('Không đọc được tệp');

      final excel = Excel.decodeBytes(bytes);
      final sheetName = excel.tables.keys.first;
      final sheet = excel.tables[sheetName]!;

      if (sheet.maxRows < 2) {
        throw Exception('Tệp không có dữ liệu (chỉ có header hoặc trống)');
      }

      final rows = <_ImportRow>[];
      final seenEmails = <String>{};

      for (var r = 1; r < sheet.maxRows; r++) {
        final row = sheet.row(r);
        final teacherId = _cellToString(row.isNotEmpty ? row[0] : null).trim();
        final fullName = _cellToString(row.length > 1 ? row[1] : null).trim();
        final email = _cellToString(
          row.length > 2 ? row[2] : null,
        ).trim().toLowerCase();
        final department = _cellToString(row.length > 3 ? row[3] : null).trim();

        if (teacherId.isEmpty && fullName.isEmpty && email.isEmpty) continue;

        final errors = <String>[];
        if (teacherId.isEmpty) errors.add('Thiếu mã GV');
        if (fullName.isEmpty) errors.add('Thiếu họ tên');
        if (email.isEmpty) {
          errors.add('Thiếu email');
        } else if (!_emailRegex.hasMatch(email)) {
          errors.add('Email không hợp lệ');
        } else if (seenEmails.contains(email)) {
          errors.add('Email trùng lặp trong file');
        }

        if (email.isNotEmpty) seenEmails.add(email);

        rows.add(
          _ImportRow(
            rowIndex: r + 1,
            teacherId: teacherId,
            fullName: fullName,
            email: email,
            department: department,
            status: errors.isEmpty
                ? ImportRowStatus.valid
                : ImportRowStatus.error,
            errorReason: errors.isEmpty ? null : errors.join('; '),
          ),
        );
      }

      if (rows.isEmpty) throw Exception('Không tìm thấy dữ liệu hợp lệ');

      setState(() {
        _rows = rows;
        _currentStep = 2;
        _filterMode = _FilterMode.all;
      });
    } catch (e) {
      _snack('Lỗi đọc tệp: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _cellToString(Data? cell) => cellToString(cell);

  Future<void> _confirmAndCreate() async {
    final validRows = _rows
        .where((r) => r.status == ImportRowStatus.valid)
        .toList();
    if (validRows.isEmpty) {
      _snack('Không có bản ghi hợp lệ để tạo tài khoản', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    for (final row in validRows) {
      row.generatedPassword = _generatePassword();
    }

    final teachers = validRows
        .map(
          (r) => {
            'teacherId': r.teacherId,
            'fullName': r.fullName,
            'email': r.email,
            'department': r.department,
            'password': r.generatedPassword,
          },
        )
        .toList();

    context.read<AdminBloc>().add(ImportTeachers({'teachers': teachers}));
  }

  Future<void> _exportResults() async {
    setState(() => _isProcessing = true);
    try {
      final validRows = _rows
          .where((r) => r.status == ImportRowStatus.valid)
          .toList();

      final excel = Excel.createExcel();
      final sheet = excel['KetQuaImport'];
      excel.delete('Sheet1');

      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#6366F1'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        horizontalAlign: HorizontalAlign.Center,
      );

      final headers = [
        'Mã GV',
        'Họ tên',
        'Email',
        'Mật khẩu',
        'Khoa',
        'Trạng thái',
      ];
      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      for (var r = 0; r < validRows.length; r++) {
        final row = validRows[r];
        final values = [
          row.teacherId,
          row.fullName,
          row.email,
          row.generatedPassword ?? '',
          row.department,
          'Đã tạo',
        ];
        for (var c = 0; c < values.length; c++) {
          sheet
              .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1))
              .value = TextCellValue(
            values[c],
          );
        }
      }

      sheet.setColumnWidth(0, 15);
      sheet.setColumnWidth(1, 25);
      sheet.setColumnWidth(2, 30);
      sheet.setColumnWidth(3, 15);
      sheet.setColumnWidth(4, 25);
      sheet.setColumnWidth(5, 12);

      final bytes = excel.save();
      if (bytes == null) throw Exception('Không thể tạo tệp');

      if (kIsWeb) {
        downloadFileWeb(Uint8List.fromList(bytes), 'KetQuaImportGV.xlsx');
        _snack('Đã xuất tệp kết quả thành công!');
      } else {
        final dir = Directory('/storage/emulated/0/Download');
        final savePath = dir.existsSync()
            ? dir.path
            : (await getApplicationDocumentsDirectory()).path;
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = '$savePath/KetQuaImportGV_$timestamp.xlsx';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        setState(() {
          _exportedFilePath = filePath;
        });

        _snack('Đã xuất tệp kết quả thành công!');
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(filePath)],
            title: 'Kết quả Import Giảng Viên',
          ),
        );
      }
    } catch (e) {
      _snack('Lỗi xuất tệp: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _resetFlow() {
    setState(() {
      _currentStep = 0;
      _rows = [];
      _selectedFileName = null;
      _resultMessage = null;
      _exportedFilePath = null;
      _filterMode = _FilterMode.all;
    });
  }

  void _snack(String message, {bool isError = false}) =>
      importSnack(context, message, isError: isError);

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AdminActionSuccess) {
          setState(() {
            _isProcessing = false;
            _resultMessage = state.message;
            _currentStep = 3;
          });
        } else if (state is AdminError) {
          setState(() => _isProcessing = false);
          _snack(state.message, isError: true);
        }
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          title: const Text('Import Giảng Viên'),
          centerTitle: true,
          elevation: 0,
        ),
        body: _isProcessing
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      _currentStep == 2
                          ? 'Đang tạo tài khoản...'
                          : 'Đang xử lý...',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepIndicator(isDark),
                    const SizedBox(height: 20),
                    if (_currentStep == 0 || _currentStep == 1)
                      _buildUploadSection(isDark),
                    if (_currentStep == 2) _buildPreviewSection(isDark),
                    if (_currentStep == 3) _buildResultSection(isDark),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUploadSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionCard(
          isDark: isDark,
          icon: Icons.description_outlined,
          iconColor: AppColors.info,
          title: '1. Tải Tệp Mẫu Chuẩn',
          subtitle:
              'Tệp Excel với các cột: Mã GV, Họ tên, Email, Khoa.\n'
              'Điền đầy đủ thông tin rồi tải lên ở bước 2.',
          action: FilledButton.icon(
            onPressed: _downloadTemplate,
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Tải Tệp Mẫu'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          isDark: isDark,
          icon: Icons.upload_file_rounded,
          iconColor: const Color(0xFF6366F1),
          title: '2. Tải Tệp Dữ Liệu',
          subtitle: _selectedFileName != null
              ? 'Đã chọn: $_selectedFileName'
              : 'Chọn tệp Excel (.xlsx) chứa danh sách giảng viên.',
          action: FilledButton.icon(
            onPressed: _pickAndParseFile,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: Text(
              _selectedFileName != null ? 'Chọn Tệp Khác' : 'Chọn Tệp',
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            _summaryCard(
              isDark,
              'Tổng',
              _rows.length,
              AppColors.info,
              Icons.list_alt_rounded,
            ),
            const SizedBox(width: 10),
            _summaryCard(
              isDark,
              'Hợp lệ',
              _validCount,
              AppColors.success,
              Icons.check_circle_rounded,
            ),
            const SizedBox(width: 10),
            _summaryCard(
              isDark,
              'Lỗi',
              _errorCount,
              AppColors.error,
              Icons.error_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _filterTab('Tất cả (${_rows.length})', _FilterMode.all, isDark),
              _filterTab('Hợp lệ ($_validCount)', _FilterMode.valid, isDark),
              _filterTab('Lỗi ($_errorCount)', _FilterMode.error, isDark),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width - 32,
                ),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    const Color(0xFF6366F1).withValues(alpha: 0.08),
                  ),
                  dataRowMinHeight: 48,
                  dataRowMaxHeight: 64,
                  columnSpacing: 16,
                  columns: const [
                    DataColumn(
                      label: Text(
                        '#',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Mã GV',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Họ tên',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Email',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Khoa',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Trạng thái',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  rows: _filteredRows.map((row) {
                    final isError = row.status == ImportRowStatus.error;
                    return DataRow(
                      color: WidgetStateProperty.all(
                        isError
                            ? AppColors.error.withValues(alpha: 0.06)
                            : Colors.transparent,
                      ),
                      cells: [
                        DataCell(Text('${row.rowIndex}')),
                        DataCell(
                          Text(
                            row.teacherId.isEmpty ? '—' : row.teacherId,
                            style: TextStyle(
                              color: row.teacherId.isEmpty
                                  ? AppColors.error
                                  : null,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.fullName.isEmpty ? '—' : row.fullName,
                            style: TextStyle(
                              color: row.fullName.isEmpty
                                  ? AppColors.error
                                  : null,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            row.email.isEmpty ? '—' : row.email,
                            style: TextStyle(
                              color:
                                  row.email.isEmpty ||
                                      (row.errorReason?.contains('email') ??
                                          false) ||
                                      (row.errorReason?.contains('Email') ??
                                          false)
                                  ? AppColors.error
                                  : null,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(row.department.isEmpty ? '—' : row.department),
                        ),
                        DataCell(
                          isError
                              ? Tooltip(
                                  message: row.errorReason ?? '',
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      row.errorReason ?? 'Lỗi',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Hợp lệ',
                                    style: TextStyle(
                                      color: AppColors.successDark,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _currentStep = 0;
                    _rows = [];
                    _selectedFileName = null;
                    _filterMode = _FilterMode.all;
                  });
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Quay lại'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: _validCount > 0 ? _confirmAndCreate : null,
                icon: const Icon(Icons.person_add_rounded, size: 18),
                label: Text('Tạo Tài Khoản ($_validCount GV)'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return ImportStepIndicator(currentStep: _currentStep, isDark: isDark);
  }

  Widget _buildResultSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Import Thành Công!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _resultMessage ?? 'Đã tạo tài khoản thành công',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _exportResults,
          icon: const Icon(Icons.download_rounded, size: 18),
          label: const Text('Xuất Kết Quả (Excel)'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (_exportedFilePath != null) ...[
          const SizedBox(height: 8),
          Text(
            'Đã lưu: $_exportedFilePath',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _resetFlow,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Import Mới'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget action,
  }) {
    return ImportSectionCard(
      isDark: isDark,
      icon: icon,
      iconColor: iconColor,
      title: title,
      subtitle: subtitle,
      action: action,
      fullWidthAction: true,
    );
  }

  Widget _summaryCard(
    bool isDark,
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return ImportSummaryCard(
      isDark: isDark,
      label: label,
      count: count,
      color: color,
      icon: icon,
    );
  }

  Widget _filterTab(String label, _FilterMode mode, bool isDark) {
    return ImportFilterTab(
      label: label,
      isActive: _filterMode == mode,
      isDark: isDark,
      onTap: () => setState(() => _filterMode = mode),
    );
  }
}
