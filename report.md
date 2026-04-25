# Báo cáo sửa lỗi Backend

## 1. Lỗi Drift (hơn 46.000 lỗi)
- **Lỗi/Bugs:** Hàng loạt lỗi `Undefined class 'Value'`, `Undefined name 'driftRuntimeOptions'` xuất hiện trong file sinh tự động `database.g.dart` và lỗi các class database không tồn tại.
- **Nguyên nhân:** Có một annotation `@DriftDatabase` bị sao chép nhầm ngay phía trên khai báo class `DailyLearningLogs extends Table` (dòng 691-746 trong `database.dart`). Do đó, `build_runner` đã nhận diện `DailyLearningLogs` là một lớp Database chính, dẫn đến file sinh tự động bị hỏng hoàn toàn.
- **Giải pháp:** 
  - Đã xóa khối `@DriftDatabase` thừa thãi trước class `DailyLearningLogs` trong file `lib/database/database.dart`.
  - Chạy lại lệnh `dart run build_runner build --delete-conflicting-outputs` để regenerate lại schema chính xác và sạch sẽ, dọn dẹp hơn 46.000 lỗi.

## 2. Lỗi truyền Stream vào Response của Dart Frog
- **Lỗi/Bugs:** Báo lỗi `The argument type 'Stream<List<int>>' can't be assigned to the parameter type 'String?'.` trong các file `routes/ai/stream-assistant.dart` và `routes/ai/stream-chat.dart`.
- **Nguyên nhân:** Lỗi khởi tạo HTTP Response để trả về dạng Server-Sent Events (SSE). Tham số `body` của `Response()` mặc định chỉ nhận chuỗi `String?`. Cú pháp truyền `Stream` đã bị sai (sử dụng constructor mặc định và sai phương thức `eventTransformed`).
- **Giải pháp:** Đã đổi sang sử dụng phương thức `Response.stream(body: controller.stream)` thay cho constructor tĩnh, và loại bỏ phương thức `eventTransformed` dư thừa cũng như class `_PassthroughSink` không cần thiết.

## 3. Lỗi thiếu thư viện Drift trong Embedding Service
- **Lỗi/Bugs:** `Undefined name 'Variable'` tại `lib/services/embedding_service.dart`.
- **Nguyên nhân:** File chứa tham chiếu tới `Variable` (được sử dụng cho parameterized queries của drift) nhưng thiếu khai báo thư viện drift ở đầu file.
- **Giải pháp:** Thêm dòng `import 'package:drift/drift.dart';` vào đầu file `lib/services/embedding_service.dart`.

**Kết quả:** Tất cả các lỗi syntax và lỗi build break trong backend đã được dọn sạch sẽ (Exit code của `dart analyze` đối với lỗi mức Error đã là 0). Backend có thể build và chạy bình thường.

## 4. Lỗi GitHub Actions build web thất bại (tflite_flutter / dart:ffi)
- **Lỗi/Bugs:** `flutter build web --release` thất bại với `Error: Only JS interop members may be 'external'` trong `tflite_flutter` package. Exit code 1.
- **Nguyên nhân:** `lesson_player_page.dart` import trực tiếp `face_verification_guard.dart` và `face_register_page.dart`, cả hai file này đều import `camera`, `google_mlkit_face_detection`, và `tflite_flutter` — các package sử dụng `dart:ffi` không tương thích với web platform. Dù code không chạy trên web, compiler vẫn phải phân tích toàn bộ import tree.
- **Giải pháp:**
  - Tạo `face_verification_guard_web.dart` (stub no-op cho web)
  - Tạo `face_register_page_web.dart` (stub hiển thị thông báo chỉ khả dụng trên mobile)
  - Sử dụng conditional import trong `lesson_player_page.dart`: `import 'web_stub.dart' if (dart.library.io) 'native.dart'`

## 5. Lỗi Wasm dry run warnings gây exit code 1
- **Lỗi/Bugs:** Build thành công (`√ Built build\web`) nhưng exit code vẫn là 1 do Wasm dry run warnings từ package `pdfx`.
- **Nguyên nhân:** Flutter 3.35.6 mặc định chạy Wasm compatibility check, `pdfx` có static interop warnings khiến process trả về exit code 1.
- **Giải pháp:** Thêm flag `--no-wasm-dry-run` vào lệnh build trong workflow.

## 6. Lỗi Node.js 16 deprecated trong GitHub Actions
- **Lỗi/Bugs:** Warning `Node.js 16 actions are deprecated` từ `FirebaseExtended/action-hosting-deploy@v0`.
- **Nguyên nhân:** Action version `@v0` sử dụng Node.js 16 đã bị deprecated, sẽ bị loại bỏ khỏi runner.
- **Giải pháp:** Upgrade lên `FirebaseExtended/action-hosting-deploy@v0.6.0` hỗ trợ Node.js 20.
