import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:backend/database/database.dart';
Future<Response> onRequest(RequestContext context, String id) async {
  final request = context.request;
  final method = request.method;
  final fileId = int.tryParse(id);
  if (fileId == null) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: {'error': 'Invalid file ID'},
    );
  }
  if (method == HttpMethod.get) {
    return _getFile(context, fileId);
  } else if (method == HttpMethod.delete) {
    return _deleteFile(context, fileId);
  }
  return Response(statusCode: HttpStatus.methodNotAllowed);
}
Future<Response> _getFile(RequestContext context, int fileId) async {
  try {
    final db = context.read<AppDatabase>();
    final fileRecord = await (db.select(db.courseFiles)
          ..where((tbl) => tbl.id.equals(fileId)))
        .getSingleOrNull();
    if (fileRecord == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'File not found'},
      );
    }
    final file = File(fileRecord.filePath);
    if (!await file.exists()) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'File not found on disk'},
      );
    }
    final fileBytes = await file.readAsBytes();
    return Response.bytes(
      body: fileBytes,
      headers: {
        'Content-Type': fileRecord.mimeType,
        'Content-Disposition': 'inline; filename="${fileRecord.fileName}"',
        'Content-Length': fileRecord.fileSizeBytes.toString(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to get file: $e'},
    );
  }
}
Future<Response> _deleteFile(RequestContext context, int fileId) async {
  try {
    final db = context.read<AppDatabase>();
    final fileRecord = await (db.select(db.courseFiles)
          ..where((tbl) => tbl.id.equals(fileId)))
        .getSingleOrNull();
    if (fileRecord == null) {
      return Response.json(
        statusCode: HttpStatus.notFound,
        body: {'error': 'File not found'},
      );
    }
    final file = File(fileRecord.filePath);
    if (await file.exists()) {
      await file.delete();
    }
    await (db.delete(db.courseFiles)..where((tbl) => tbl.id.equals(fileId)))
        .go();
    return Response.json(body: {'message': 'File deleted successfully'});
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'error': 'Failed to delete file: $e'},
    );
  }
}