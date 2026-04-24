# ALARMM (AI-Powered LMS) - Hệ thống Quản lý Học tập Thông minh

ALARMM là một nền tảng Học trực tuyến (LMS) toàn diện được phát triển bằng **Flutter** (Frontend) và **Dart Frog** (Backend). Dự án tích hợp sâu các công nghệ Trí tuệ Nhân tạo (AI) tiên tiến nhất để mang lại trải nghiệm học tập cá nhân hóa, giám sát tự động và tương tác đa phương thức (Multi-modal).

---

## 🌟 TÍNH NĂNG NỔI BẬT (Core AI Features)

### 1. Giám sát Biểu cảm & Cảnh báo Bối rối (GNN Confusion Detection)
Thay vì giám sát thủ công, hệ thống sử dụng mạng đồ thị không gian-thời gian (Landmark GNN) để phân tích biểu cảm sinh viên:
- **Công nghệ:** PyTorch (Backend/Scripts), Google MediaPipe Face Mesh.
- **Cách hoạt động:** Trích xuất 478 tọa độ không gian 3D trên khuôn mặt, phân tích chuỗi chuyển động qua mạng Landmark Transformer + BiLSTM để phát hiện trạng thái "Bối rối" (Confusion).
- **Độ chính xác:** Đạt AUC 0.71 trên tập dữ liệu DAiSEE. Sử dụng cơ chế *Sliding Window* (yêu cầu 3 lần bối rối liên tục tại ngưỡng tự tin >85%) để loại bỏ 100% cảnh báo giả.
- **Tích hợp Frontend:** Tự động kích hoạt Assistant Popup khi sinh viên gặp khó khăn.

### 2. Định danh Sinh viên bằng AI (On-Device Face Verification)
Đảm bảo tính trung thực trong quá trình học tập và thi cử:
- **Công nghệ:** MobileFaceNet (Chạy trực tiếp trên thiết bị bằng TensorFlow Lite), Drift SQLite.
- **Cách hoạt động:** Liên tục quét khuôn mặt người đang xem video. So khớp vector đặc trưng (Embeddings) của khuôn mặt hiện tại với khuôn mặt chủ tài khoản đã đăng ký.
- **Xử lý Vi phạm:** Nếu phát hiện vắng mặt hoặc có người lạ học hộ, video sẽ **tự động tạm dừng** ngay lập tức và yêu cầu sinh viên chính chủ xác thực lại. Mọi vi phạm được lưu lịch sử xuống Database.

### 3. Gia sư AI Đa phương thức (Multi-Modal Video RAG)
Trợ lý học tập không chỉ nghe hiểu văn bản mà còn "nhìn" được bài giảng:
- **Công nghệ:** GPT-4o Vision API, `video_thumbnail`.
- **Cách hoạt động:** Sinh viên có thể chụp lại chính xác khung hình video đang xem và gửi cho AI. AI sẽ phân tích hình ảnh (ví dụ: một đoạn code, một đồ thị toán học) kết hợp với ngữ cảnh bài học để giải đáp thắc mắc chuyên sâu.

### 4. Tương tác Giọng nói Thời gian thực (Real-Time Voice Streaming)
Trò chuyện với AI mượt mà như người thật với độ trễ gần như bằng 0 (Zero-latency):
- **Công nghệ:** WebSockets, OpenAI Whisper (Speech-to-Text), GPT-4o (Text Streaming), OpenAI TTS Chunking.
- **Cách hoạt động:** 
  - Ghi âm giọng nói sinh viên (Chunking audio).
  - Gửi qua WebSocket để Whisper dịch sang text tức thì.
  - GPT-4o trả lời kiểu Streaming (từng từ một).
  - OpenAI TTS đọc các đoạn text ngay khi chúng được sinh ra, tạo cảm giác giao tiếp không ngắt quãng.

### 5. Cá nhân hóa Trải nghiệm Học (Hyper-Personalized AI)
- Dữ liệu học thuật (Chuyên ngành, Năm học) được cấu hình trên Profile và đồng bộ liên tục giữa Postgres/Drift.
- AI tự động điều chỉnh giọng văn (Sư phạm, Vui vẻ, Nghiêm túc) và độ phức tạp của câu trả lời sao cho phù hợp nhất với trình độ của người học (Ví dụ: Trả lời sinh viên năm 1 sẽ dễ hiểu hơn, trả lời sinh viên năm 4 sẽ đi sâu vào thuật toán học thuật).

---

## 📚 TỔNG QUAN TÍNH NĂNG LMS (Core Modules)

### 👨‍🎓 Dành cho Sinh viên (Student Role)
| Tính năng | Mô tả chi tiết |
|---|---|
| **Course & Video** | Xem bài giảng Video (Sử dụng `chewie` và `video_player`), lưu tiến độ học tập (Progress Tracking). |
| **Offline Mode** | Tải trước nội dung bài giảng, lưu DB vào SQLite qua Drift để học khi không có mạng. Đồng bộ trạng thái tự động khi có kết nối lại. |
| **Schedule/Calendar** | Xem Thời khóa biểu bằng giao diện Syncfusion Calendar, hỗ trợ Import trực tiếp từ file Excel của trường. |
| **Task Management** | Quản lý công việc cá nhân, Kanban board, To-do list. |
| **Analytics Dashboard** | Thống kê học tập cá nhân: Biểu đồ Heatmap (Tần suất học), Velocity (Tốc độ học), Benchmark (So sánh với lớp). |
| **Roadmap** | Cung cấp lộ trình học theo từng ngành (Ví dụ: Backend Developer, Frontend Developer). |

### 👨‍🏫 Dành cho Giảng viên (Teacher Role)
| Tính năng | Mô tả chi tiết |
|---|---|
| **Teaching Dashboard** | Quản lý tổng quan các lớp môn học đang phụ trách. |
| **Content Management**| Tạo bài giảng mới, Upload Video, tài liệu đính kèm. |
| **Quiz & Assessment** | Tạo bài thi trắc nghiệm trực tuyến. Hỗ trợ hệ thống thi Real-time (Nhiều sinh viên thi cùng lúc qua WebSocket). |
| **Attendance & Submissions** | Điểm danh tự động qua AI hoặc thủ công, thu thập và chấm điểm bài tập. |
| **Notifications** | Gửi Push Notifications (FCM) thông báo đột xuất cho toàn bộ lớp học. |

### 👮‍♂️ Dành cho Quản trị viên (Admin Role)
| Tính năng | Mô tả chi tiết |
|---|---|
| **User Management** | Quản lý Sinh viên/Giảng viên (Cấp quyền, Ban/Unban tài khoản). |
| **Academic Structure** | Xây dựng hệ thống đào tạo: Quản lý Khoa -> Bộ Môn -> Lớp Hành Chính -> Môn Học. |
| **Import Tool** | Nhập danh sách sinh viên, giảng viên và môn học hàng loạt từ file Excel. |

---

## 🏗️ KIẾN TRÚC HỆ THỐNG (Architecture)

Dự án áp dụng **Clean Architecture** kết hợp với **BLoC/Cubit** Pattern cho Frontend, giúp phân tách logic và giao diện một cách hoàn hảo.

```text
├── lib/
│   ├── core/                    # Shared logic
│   │   ├── api/                 # HTTP client, interceptors, error handling
│   │   ├── route/               # GoRouter configuration
│   │   ├── theme/               # Design tokens, màu sắc, font chữ
│   │   ├── services/            # FCM, local notifications, IdentityGuard
│   │   ├── widgets/             # Reusable UI components
│   │   └── utils/               # Formatters, Helpers
│   │
│   ├── features/                # 18 Feature Modules (Course, Chat, Quiz, Auth...)
│   │   └── [feature_name]/
│   │       ├── data/            # Models, DataSources (Drift/REST), Repositories Impl
│   │       ├── domain/          # Entities, Repositories (abstract), UseCases
│   │       └── presentation/    # BLoC/Cubit, Pages, Screens
│   │
│   ├── di/                      # Dependency Injection (GetIt) setup
│   └── main.dart                # Entry point ứng dụng
│
├── backend/                     # Dart Frog API Server
│   ├── routes/                  # ~160 REST endpoints (chia làm 34 route groups)
│   │   ├── auth/                # Login, signup, password reset, JWT
│   │   ├── ai/                  # WebSockets, RAG, OpenAI integration
│   │   ├── courses/             # Quản lý khóa học, enrollment
│   │   ├── notifications/       # Gửi và lưu lịch sử Push Notification FCM
│   │   └── ...
│   ├── lib/                     # Database Prisma/PostgreSQL, Middleware
│   └── prisma/                  # Prisma Schema cho Database
│
├── scripts/
│   └── confusion_model/         # PyTorch Workspace (Huấn luyện Landmark GNN)
│
└── test/                        # Unit tests & Widget tests cho Frontend
```

---

## 🛠️ TECH STACK CHI TIẾT

| Lớp (Layer) | Công nghệ / Package cốt lõi |
| :--- | :--- |
| **Frontend Framework** | Flutter (Dart SDK ^3.9.2) |
| **State Management** | `flutter_bloc`, `cubit` |
| **Routing & DI** | `go_router`, `get_it` |
| **Database (Offline)** | `drift` (SQLite), `shared_preferences` |
| **Backend Server** | Dart Frog |
| **Database (Online)** | PostgreSQL (via Prisma ORM / Dart SQL) |
| **Networking** | `http`, `web_socket_channel` |
| **Video Player** | `video_player`, `chewie`, `video_thumbnail` |
| **AI / ML (Local)** | TensorFlow Lite (`tflite_flutter`), Google MediaPipe |
| **AI / ML (Cloud)**| OpenAI API (GPT-4o, Whisper, TTS-1) |
| **Push Notifications** | `firebase_messaging`, Firebase HTTP v1 API |
| **UI & Animations** | `flutter_animate`, `rive`, `fl_chart`, `syncfusion_flutter_calendar` |

---

## 🚀 HƯỚNG DẪN CÀI ĐẶT & CHẠY DỰ ÁN

### Yêu cầu hệ thống
- Flutter SDK `^3.9.2`
- PostgreSQL (Cài đặt local hoặc Docker)
- Python 3.10+ (Nếu có nhu cầu nghiên cứu/train AI model)

### 1. Cấu hình & Khởi chạy Backend (Dart Frog)

Backend chịu trách nhiệm xử lý logic nghiệp vụ và bảo mật API qua JWT.

```bash
cd backend
dart pub get

# Tạo file .env dựa trên cấu hình dự án
# DATABASE_URL=postgresql://user:password@localhost:5432/alarmm
# JWT_SECRET=chuoi_ki_tu_bi_mat_cua_ban
# OPENAI_API_KEY=sk-...

# Khởi chạy server tại localhost:8080
dart_frog dev
```

### 2. Cấu hình & Khởi chạy Frontend (Mobile App)

```bash
# Trở về thư mục gốc của dự án
flutter pub get

# Generate lại các file liên quan đến Drift Database, Freezed và JSON Serializable
dart run build_runner build -d

# Khởi chạy ứng dụng trên Emulator hoặc Device
flutter run
```

### 3. (Tùy chọn) Chạy Hệ thống AI Confusion Detection (Local Python)

Đây là hệ thống thử nghiệm mô hình GNN độc lập trước khi build ra file TorchScript/TFLite.

```bash
cd scripts/confusion_model
# Cài đặt môi trường Python
pip install torch torchvision torchaudio
pip install mediapipe opencv-python pandas scikit-learn

# Chạy hệ thống Test Webcam Realtime (Yêu cầu có Webcam)
# AI sẽ phân tích 478 điểm trên mặt bạn để cảnh báo "Bối rối"
python test_webcam_v3.py
```

---

## 🛡️ HỆ THỐNG DATABASE & ĐỒNG BỘ CỤC BỘ (Offline-First)

Ứng dụng sử dụng kiến trúc **Offline-First**. 
Toàn bộ dữ liệu bài giảng, khóa học và thông báo được tải về và lưu trữ vào SQLite thông qua thư viện `Drift`. 
Khi sinh viên ngắt kết nối mạng, họ vẫn có thể xem được nội dung. Khi có mạng trở lại, ứng dụng sẽ đồng bộ tiến trình học (Progress Sync) và các Task lên Server PostgreSQL một cách tự động và trong suốt.

---

## 📜 GIẤY PHÉP (License)

Dự án bản quyền cá nhân. Không được sao chép hoặc tái sử dụng mục đích thương mại mà không có sự cho phép.
