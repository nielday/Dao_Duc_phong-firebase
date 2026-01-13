# 🍽️ Flutter Firebase Restaurant Management

Dự án ứng dụng Flutter quản lý nhà hàng sử dụng Firebase Firestore - Bài kiểm tra môn Lập trình Mobile (Đề 05).

---

## 👤 Thông tin Sinh viên

| Thông tin | Chi tiết |
|-----------|----------|
| **Họ tên** | Đào Đức Phong |
| **MSSV** | 1771020534 |
| **Lớp** | CNTT 17-07 |

---

## 📋 Mô tả Dự án

Ứng dụng Flutter cho phép khách hàng nhà hàng:
- Đăng ký và đăng nhập tài khoản
- Xem thực đơn với chức năng tìm kiếm, lọc
- Đặt bàn và thêm món ăn vào đơn
- Thanh toán với hệ thống điểm tích lũy (Loyalty Points)

### Tính năng chính:
- ✅ Authentication (Đăng ký, Đăng nhập)
- ✅ Quản lý Thực đơn (Tìm kiếm, lọc theo danh mục/chay/cay)
- ✅ Đặt bàn (Tạo đơn, xem lịch sử)
- ✅ Chi tiết Đặt bàn (Thêm món, tính tiền realtime)
- ✅ Thanh toán (Sử dụng/Tích điểm Loyalty Points)
- ✅ Seeder (Tạo dữ liệu mẫu nhanh)
- ✅ Real-time Updates với Firebase Firestore

---

## 🚀 Cài đặt và Chạy

### 1. Yêu cầu
- Flutter SDK (phiên bản mới nhất)
- Firebase Project đã tạo
- Android Studio / VS Code

### 2. Cấu hình Firebase

```bash
# Bước 1: Tạo project trên Firebase Console
# https://console.firebase.google.com

# Bước 2: Thêm ứng dụng Android/iOS

# Bước 3: Tải file config
# - Android: google-services.json → android/app/
# - iOS: GoogleService-Info.plist → ios/Runner/

# Bước 4: Bật Firestore Database trong Firebase Console
```

### 3. Chạy ứng dụng

```bash
# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run

# Hoặc chạy trên Chrome
flutter run -d chrome

# Hoặc chạy trên thiết bị cụ thể
flutter run -d <device_id>
```

---

## 🗄️ Firestore Collections

| Collection | Mô tả |
|------------|-------|
| `customers` | Thông tin khách hàng (email, full_name, loyalty_points, ...) |
| `menu_items` | Thực đơn món ăn (name, price, category, is_vegetarian, ...) |
| `reservations` | Đơn đặt bàn (customer_id, items, status, total, ...) |

---

## 📱 Các màn hình

| Màn hình | Mô tả |
|----------|-------|
| **Đăng ký** | Form đăng ký tài khoản mới |
| **Đăng nhập** | Form đăng nhập với email/password |
| **Trang chủ** | Danh sách món ăn, tìm kiếm, lọc |
| **Chi tiết món** | Thông tin chi tiết món ăn |
| **Danh sách đặt bàn** | Lịch sử các đơn đặt bàn |
| **Tạo đặt bàn** | Form tạo đơn đặt bàn mới |
| **Chi tiết đặt bàn** | Xem/thêm món, thanh toán |
| **Seeder** | Tạo dữ liệu mẫu nhanh |

---

## 📁 Cấu trúc thư mục

```
lib/
├── main.dart                    # Entry point
├── firebase_options.dart        # Firebase config
│
├── models/                      # Data Models
│   ├── customer_model.dart      # Model khách hàng
│   ├── menu_item_model.dart     # Model món ăn
│   └── reservation_model.dart   # Model đặt bàn
│
├── repositories/                # Firebase Logic
│   ├── customer_repository.dart      # CRUD khách hàng
│   ├── menu_item_repository.dart     # CRUD món ăn
│   └── reservation_repository.dart   # CRUD đặt bàn
│
├── screens/                     # UI Screens
│   ├── auth/                    # Đăng nhập, Đăng ký
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/                    # Trang chủ, Menu
│   │   ├── home_screen.dart
│   │   └── menu_item_detail_screen.dart
│   ├── reservation/             # Đặt bàn
│   │   ├── reservation_list_screen.dart
│   │   ├── create_reservation_screen.dart
│   │   └── reservation_detail_screen.dart
│   └── seeder_screen.dart       # Tạo dữ liệu mẫu
│
├── services/                    # Services
│   └── auth_service.dart        # Authentication logic
│
└── widgets/                     # Reusable Widgets
    └── ...
```

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  provider: ^6.1.1
  intl: ^0.18.1
```

---

## 🔥 Dữ liệu mẫu (Seeder)

Ứng dụng có chức năng **Seeder** để tạo dữ liệu mẫu nhanh:

| Loại | Số lượng |
|------|----------|
| Customers (Khách hàng) | 5 |
| Menu Items (Món ăn) | 20 |
| Reservations (Đặt bàn) | 10 |

**Tài khoản mẫu sau khi seed:**
| Email | Mật khẩu |
|-------|----------|
| admin@restaurant.com | 123456 |
| nguyenvana@gmail.com | 123456 |
| tranthib@gmail.com | 123456 |

---

## ✅ Checklist hoàn thành

- [x] Project Flutter hoàn chỉnh, chạy được
- [x] Kết nối Firebase Firestore
- [x] Authentication (Đăng ký, Đăng nhập)
- [x] Hiển thị danh sách món ăn (StreamBuilder)
- [x] Tìm kiếm và lọc món ăn
- [x] Tạo đơn đặt bàn
- [x] Thêm món vào đơn (Realtime update)
- [x] Tính tổng tiền, phí phục vụ
- [x] Thanh toán với Loyalty Points
- [x] Chức năng Seeder tạo dữ liệu mẫu
- [x] Tổ chức code theo mô hình Repository

---

## 📝 Ghi chú

- Ứng dụng sử dụng **StreamBuilder** để cập nhật dữ liệu realtime từ Firestore
- Mô hình **Repository Pattern** tách biệt logic Firebase khỏi UI
- **Loyalty Points**: 1 điểm = 1.000đ, tối đa sử dụng 50% tổng tiền

---

## 👨‍💻 Tác giả

**Đào Đức Phong**  
MSSV: 1771020534  
Lớp: CNTT 17-07

---

*Dự án được thực hiện cho môn Lập trình Mobile - Đề 05*
