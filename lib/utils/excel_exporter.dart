import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';
import '../models/lecturer.dart';
import '../models/teaching_report.dart';

class ExcelExporter {
  static void exportLecturers(List<Lecturer> lecturers) {
    // Create a new Excel document
    final excel = Excel.createExcel();
    final defaultSheet = excel.getDefaultSheet() ?? 'Sheet1';
    final sheet = excel[defaultSheet];

    // Define headers
    final headers = [
      'STT',
      'Mã GV',
      'Họ và tên',
      'Email',
      'Thời gian đăng ký',
      'Trạng thái',
    ];

    // Add headers and style them
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        fontFamily: getFontFamily(FontFamily.Arial),
      );
    }

    // Add data rows
    for (var i = 0; i < lecturers.length; i++) {
      final lecturer = lecturers[i];
      final rowIndex = i + 1;

      // STT
      final sttCell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 0),
      );
      sttCell.value = TextCellValue((i + 1).toString());
      sttCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      // Mã GV
      final codeCell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 1),
      );
      codeCell.value = TextCellValue(lecturer.lecturerCode ?? '');
      codeCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

      // Họ và tên
      final nameCell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 2),
      );
      nameCell.value = TextCellValue(lecturer.fullName);
      nameCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

      // Email
      final emailCell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 3),
      );
      emailCell.value = TextCellValue(lecturer.email);
      emailCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

      // Thời gian đăng ký
      final timeCell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 4),
      );
      timeCell.value = TextCellValue('Thứ 3 - Ngày 23/09/2025 (Tiết 1-5)');
      timeCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      // Trạng thái
      final status = lecturer.role == 'admin' ? 'Đã duyệt' : 'Chưa duyệt';
      final statusCell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 5),
      );
      statusCell.value = TextCellValue(status);
      statusCell.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
    }

    // Set column widths
    final columnWidths = [10.0, 15.0, 25.0, 30.0, 25.0, 15.0];
    for (var i = 0; i < columnWidths.length; i++) {
      sheet.setColumnWidth(i, columnWidths[i]);
    }

    // Save and download
    final bytes = excel.encode();
    if (bytes != null) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'danh_sach_giang_vien_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        )
        ..click();

      html.Url.revokeObjectUrl(url);
    }
  }

  static void exportTeachingReports(List<TeachingReport> reports) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final excel = Excel.createExcel();
    final sheet = excel[excel.getDefaultSheet() ?? 'Sheet1'];

    // Headers
    final headers = [
      'STT',
      'Họ và tên',
      'Tổng số tiết',
      'Số tiết đã dạy',
      'Số buổi nghỉ',
      'Số buổi đã dạy bù',
    ];
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
        fontFamily: getFontFamily(FontFamily.Arial),
      );
    }

    // Data rows
    for (var i = 0; i < reports.length; i++) {
      final report = reports[i];
      final rowIndex = i + 1;

      // STT
      sheet.cell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 0))
        ..value = TextCellValue((i + 1).toString())
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      // Họ và tên
      sheet.cell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 1))
        ..value = TextCellValue(report.lecturerName)
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);

      // Tổng số tiết
      sheet.cell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 2))
        ..value = TextCellValue(report.totalRegisteredHours.toString())
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      // Số tiết đã dạy
      sheet.cell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 3))
        ..value = TextCellValue(report.totalActualHours.toString())
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      // Số buổi nghỉ
      sheet.cell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 4))
        ..value = TextCellValue(report.absences.length.toString())
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);

      // Số buổi đã dạy bù
      sheet.cell(CellIndex.indexByColumnRow(rowIndex: rowIndex, columnIndex: 5))
        ..value = TextCellValue(report.makeups.length.toString())
        ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Center);
    }

    // Thêm chi tiết nghỉ dạy và dạy bù cho mỗi giảng viên
    var currentRow = reports.length + 2;
    for (final report in reports) {
      // Tiêu đề giảng viên
      sheet.cell(
          CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
        )
        ..value = TextCellValue(report.lecturerName)
        ..cellStyle = CellStyle(bold: true);
      currentRow++;

      // Chi tiết nghỉ dạy
      if (report.absences.isNotEmpty) {
        sheet.cell(
            CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
          )
          ..value = TextCellValue('Danh sách buổi nghỉ:')
          ..cellStyle = CellStyle(bold: true);
        currentRow++;

        for (final absence in report.absences) {
          final absenceDetail =
              '${absence.subject} - ${dateFormat.format(absence.date)} '
              '(Tiết ${absence.startPeriod}-${absence.endPeriod}) - ${absence.reason}';
          sheet.cell(
              CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
            )
            ..value = TextCellValue(absenceDetail)
            ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
          currentRow++;
        }
      }

      // Chi tiết dạy bù
      if (report.makeups.isNotEmpty) {
        sheet.cell(
            CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
          )
          ..value = TextCellValue('Danh sách buổi dạy bù:')
          ..cellStyle = CellStyle(bold: true);
        currentRow++;

        for (final makeup in report.makeups) {
          final makeupDetail =
              '${makeup.subject} - ${dateFormat.format(makeup.date)} '
              '(Tiết ${makeup.startPeriod}-${makeup.endPeriod})';
          sheet.cell(
              CellIndex.indexByColumnRow(rowIndex: currentRow, columnIndex: 0),
            )
            ..value = TextCellValue(makeupDetail)
            ..cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
          currentRow++;
        }
      }

      currentRow++; // Thêm dòng trống giữa các giảng viên
    }

    // Set column widths
    final columnWidths = [10.0, 25.0, 15.0, 15.0, 15.0, 15.0];
    for (var i = 0; i < columnWidths.length; i++) {
      sheet.setColumnWidth(i, columnWidths[i]);
    }

    // Save and download
    final bytes = excel.encode();
    if (bytes != null) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute(
          'download',
          'bao_cao_giang_day_${DateTime.now().millisecondsSinceEpoch}.xlsx',
        )
        ..click();

      html.Url.revokeObjectUrl(url);
    }
  }
}
