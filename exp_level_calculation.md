# Kế Hoạch Triển Khai: Hệ Thống Cấp Độ (Leveling) & Đếm Thời Gian

Mục tiêu: Xây dựng hệ thống tính điểm kinh nghiệm (EXP), cấp độ (Level) dựa trên độ khó và tốc độ hoàn thành. Thêm bộ đếm thời gian thực (Timer) vào màn hình `ProcessViewScreen` và chặn việc hoàn thành trước 1 phút.

## 1. Cấu trúc Quản lý Trạng thái (State Management)
### [NEW] `Frontend/lib/providers/profile_provider.dart`
- Tạo `ProfileProvider` kế thừa `ChangeNotifier` để lưu trữ `totalExp`.
- Viết logic tính toán Level dựa trên tổng EXP như sau (cộng dồn):
  - **Level 1**: 0 - 19 exp
  - **Level 2**: 20 - 59 exp (cần thêm 20)
  - **Level 3**: 60 - 129 exp (cần thêm 40)
  - **Level 4**: 130 - 249 exp (cần thêm 70)
  - **Level 5**: 250 - 449 exp (cần thêm 120)
  - **Level 6**: Từ 450 exp trở lên (cần thêm 200)
- Các hàm tiện ích: `addExp(int amount)`, `currentLevel`, `expToNextLevel`, `progressToNextLevel`.

### [MODIFY] `Frontend/lib/main.dart`
- Thêm `ChangeNotifierProvider(create: (_) => ProfileProvider())` vào cấu hình gốc.

## 2. Tính năng Thời gian và Tính điểm
### [MODIFY] `Frontend/lib/screens/process_view/process_view_screen.dart`
- **Timer (Bộ đếm thời gian)**: Khởi tạo `Stopwatch` và `Timer.periodic` (mỗi 1 giây) khi bắt đầu vào màn hình. 
- **Giao diện (UI)**: Thêm text hiển thị `MM:SS` (Phút:Giây) lên thanh Header (phía trên cùng màn hình).
- **Chặn hoàn thành sớm**: Nút "Finish Tutorial" sẽ tự động **bị mờ (disable)** nếu thời gian hiện tại `< 60 giây`.
- **Tính toán EXP khi hoàn thành**:
  - `Base EXP = Tổng số bước * Hệ số độ khó` (Easy = x1.5, Medium = x2, Hard = x3).
  - `Hệ số thời gian`: 
    - Hoàn thành < 5 phút: `Base EXP * 1.2`
    - Hoàn thành từ 5 - 10 phút: `Base EXP * 1.1`
    - Trở lên: `Base EXP * 1.0`
  - Sau khi tính xong, làm tròn xuống (round/floor), gọi `ProfileProvider.addExp()` và truyền các thông số thực tế vào màn hình `FinishScreen`.

## 3. Cập nhật Giao diện Thông số Thực
### [MODIFY] `Frontend/lib/screens/finish/finish_screen.dart`
- Gỡ bỏ dữ liệu giả (mocked) của EXP và thời gian.
- Nhận dữ liệu thực tế từ `ProcessViewScreen` (như `expGained`, `elapsedSeconds`, `currentExp`) và render ra thẻ "Mastery Earned".

### [MODIFY] `Frontend/lib/screens/profile/profile_screen.dart`
- Liên kết với `ProfileProvider` để thay thế biểu đồ vòng cung hiển thị EXP, Cấp độ, tiến trình lên cấp cho đúng với dữ liệu hiện tại thay vì Hardcode.

## User Review Required
- Bạn có muốn lưu trữ `totalExp` này xuống local storage (`shared_preferences`) để không bị mất khi khởi động lại app không? Nếu có, mình sẽ thêm package `shared_preferences`.
- Nếu bạn đồng ý với kế hoạch, hãy nhấn **Proceed** để mình bắt tay vào lập trình!
