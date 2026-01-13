# Flutter App 1771020534 - Restaurant Management

Project Flutter quản lý nhà hàng sử dụng Firebase Firestore cho môn Lập trình Mobile (Đề 05).

## Thông tin Sinh viên
- **Họ tên**: Đào Đức Phong
- **MSSV**: 1771020534
- **Lớp**: CNTT 17-07

## Tính năng
1. **Authentication**: Đăng ký, Đăng nhập (Lưu thông tin Customer vào Firestore).
2. **Menu**: Xem danh sách món ăn, tìm kiếm, lọc theo danh mục/ăn chay/cay.
3. **Đặt bàn**: Đặt bàn mới, xem lịch sử đặt bàn.
4. **Chi tiết Đặt bàn**: 
    - Thêm món ăn vào đơn đặt bàn (Realtime update).
    - Tự động tính tổng tiền, phí phục vụ.
    - Thanh toán (Sử dụng/Tích điểm Loyalty Points).
5. **Seeder**: Chức năng tạo dữ liệu mẫu nhanh (5 Customers, 20 Menu Items, 10 Reservations).

## Cài đặt & Chạy ứng dụng

### 1. Yêu cầu
- Flutter SDK
- Firebase Project đã tạo.

### 2. Cấu hình Firebase
1. Tạo project trên Firebase Console.
2. Tạo ứng dụng Android/iOS trong Firebase.
3. Tải file `google-services.json` (cho Android) và đặt vào thư mục `android/app/`.
4. (Nếu chạy iOS) Tải `GoogleService-Info.plist` và đặt vào `ios/Runner/`.

### 3. Chạy lệnh
```bash
# Cài đặt thư viện
flutter pub get

# Chạy ứng dụng
flutter run
```

## Cấu trúc thư mục
- `lib/models`: Chứa các class data model (`CustomerModel`, `MenuItemModel`, `ReservationModel`).
- `lib/repositories`: Chứa logic tương tác với Firestore.
- `lib/screens`: Chứa các màn hình UI.
    - `auth`: Đăng nhập, Đăng ký.
    - `home`: Màn hình chính, danh sách món.
    - `reservation`: Các màn hình liên quan đặt bàn.
- `lib/widgets`: Các widget dùng chung.

## Checklist hoàn thành
- [x] Project hoàn chỉnh, chạy được.
- [x] Firebase kết nối (Code đã sẵn sàng, chờ file config).
- [x] Chức năng Seeder tạo dữ liệu mẫu.
- [x] CRUD hoạt động (Customer, Reservation).
- [x] UI hiển thị dữ liệu từ Firestore (StreamBuilder).
- [x] Real-time updates (Menu, Reservation Detail).
- [x] Tổ chức code theo mô hình Repository.
