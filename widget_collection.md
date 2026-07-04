# Danh Sách Các Widget Trong Flutter UI

Tài liệu này tổng hợp và phân loại các thẻ Widget thông dụng trong Flutter dựa trên mục đích sử dụng, giúp dễ dàng tra cứu khi thiết kế và phát triển ứng dụng.

---

## 1. Nhóm Nhập Liệu & Form (Handle Input Widgets)
Các widget dùng để nhận dữ liệu từ người dùng nhập vào.

| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`TextField`** | [cite_start]Ô nhập văn bản cơ bản[cite: 9]. | [cite_start]Nhập Email, mật khẩu, tìm kiếm[cite: 9]. |
| **`TextFormField`** | [cite_start]`TextField` tích hợp sẵn với `Form` và bộ `validator`[cite: 9]. | [cite_start]Form đăng ký, đăng nhập cần kiểm tra dữ liệu[cite: 9]. |
| **`Form`** | [cite_start]Widget bọc ngoài nhóm `FormField` để quản lý việc validate toàn bộ form[cite: 9]. | [cite_start]Sign Up, Sign In form[cite: 9]. |

---

## 2. Nhóm Công Tắc & Lựa Chọn (Toggle & Selection Widgets)
Các widget dùng để người dùng bật/tắt trạng thái hoặc lựa chọn các giá trị có sẵn.

| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`Checkbox`** | [cite_start]Ô tích chọn[cite: 9]. | [cite_start]Đồng ý điều khoản, chọn nhiều mục[cite: 9]. |
| **`Switch`** | [cite_start]Công tắc gạt bật/tắt[cite: 9]. | [cite_start]Cài đặt thông báo, đổi chế độ Dark Mode/Light Mode[cite: 9]. |
| **`Radio`** | [cite_start]Nút chọn một trong nhiều lựa chọn[cite: 9]. | [cite_start]Chọn giới tính, bộ lọc đơn[cite: 9]. |
| **`Slider`** | [cite_start]Thanh kéo thay đổi giá trị theo khoảng[cite: 9]. | [cite_start]Thay đổi âm lượng, khoảng giá, rating[cite: 9]. |
| **`DropdownButton`** | [cite_start]Menu xổ xuống để chọn một giá trị[cite: 9]. | [cite_start]Chọn quốc gia, múi giờ, bảng đấu[cite: 9]. |

---

## 3. Nhóm Hiển Thị Giao Diện & Tiện Ích UI (UI Display & Utility Widgets)
Các widget hỗ trợ trang trí, tạo bố cục và cung cấp thông tin trực quan cho giao diện.

### 🔹 Thành phần UI cơ bản
| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`Text`** | [cite_start]Hiển thị chuỗi văn bản[cite: 5]. | [cite_start]Mọi chữ trong app[cite: 5]. |
| **`RichText`** | [cite_start]Nhiều style trong một đoạn văn[cite: 5]. | [cite_start]Bold một từ, chèn link inline, trộn nhiều màu[cite: 5]. |
| **`Card`** | [cite_start]Thẻ nổi có shadow nhẹ góc bo[cite: 19]. | [cite_start]Hiển thị Match card, stat card, khối thông tin[cite: 19]. |
| **`Chip`** | [cite_start]Nhãn nhỏ có thể bấm hoặc xóa[cite: 19]. | [cite_start]Làm tag đội bóng, filter nhanh bảng đấu[cite: 19]. |
| **`Badge`** | [cite_start]Chấm/số thông báo trên icon[cite: 19]. | [cite_start]Hiển thị số thông báo chưa đọc, giỏ hàng[cite: 19]. |
| **`Divider`** | [cite_start]Đường kẻ ngang phân cách[cite: 19]. | [cite_start]Chia các section, phân cách giữa các list item[cite: 19]. |
| **`VerticalDivider`** | [cite_start]Đường kẻ dọc phân cách[cite: 19]. | [cite_start]Chia các cột số liệu thống kê[cite: 19]. |

### 🔹 Trạng thái tải dữ liệu (Indicators)
| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`CircularProgressIndicator`** | [cite_start]Vòng tròn xoay loading[cite: 19]. | [cite_start]Chờ gọi API, loading ảnh[cite: 19]. |
| **`LinearProgressIndicator`** | [cite_start]Thanh ngang chạy loading[cite: 19]. | [cite_start]Đo độ mạnh mật khẩu (Password strength), thanh tiến trình upload[cite: 19]. |

---

## 4. Nhóm Hiển Thị Hình Ảnh (Images Display Widgets)
Các widget chuyên dụng để xử lý, hiển thị và bo góc hình ảnh.

| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`Image.asset`** | [cite_start]Ảnh lấy từ thư mục assets nội bộ của dự án[cite: 11]. | [cite_start]Hiển thị Logo, ảnh minh họa tĩnh[cite: 11]. |
| **`Image.network`** | [cite_start]Ảnh tải từ đường dẫn URL internet[cite: 11]. | [cite_start]Hiển thị Avatar người dùng, cờ đội, ảnh bìa từ server[cite: 11]. |
| **`Image.file`** | [cite_start]Ảnh lấy từ bộ nhớ vật lý của thiết bị[cite: 11]. | [cite_start]Ảnh người dùng vừa chụp hoặc chọn từ gallery[cite: 11]. |
| **`Icon`** | [cite_start]Hiển thị icon từ bộ font (Icons.*)[cite: 11]. | [cite_start]Làm tab bar, nút bấm icon, badge[cite: 11]. |
| **`CircleAvatar`** | [cite_start]Cắt ảnh thành hình tròn chuyên làm avatar[cite: 11]. | [cite_start]Ảnh người dùng, cờ đội bo tròn[cite: 11]. |
| **`FadeInImage`** | [cite_start]Tải ảnh từ mạng kèm hiệu ứng mờ dần (placeholder)[cite: 11]. | [cite_start]Giúp giao diện mượt mà khi đợi tải ảnh từ URL[cite: 11]. |
| **`ClipRRect`** | [cite_start]Cắt bo góc bất kỳ widget con nào bên trong[cite: 11]. | [cite_start]Ảnh bo góc, card bo góc custom[cite: 11]. |
| **`ClipOval`** | [cite_start]Cắt widget con thành hình oval hoặc hình tròn[cite: 11]. | [cite_start]Làm avatar tròn từ một ảnh hình chữ nhật bất kỳ[cite: 11]. |

---

## 5. Nhóm Hoạt Họa (Animation Widgets)
Các widget giúp giao diện chuyển động mượt mà và sinh động hơn.

### 🔹 Implicit Animations (Tự động chạy khi đổi thuộc tính)
| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`AnimatedContainer`** | [cite_start]Container tự chuyển động khi đổi size, màu, border... [cite: 17] | [cite_start]Làm dấu chấm chuyển trang (dot indicator), mở rộng card[cite: 17]. |
| **`AnimatedOpacity`** | [cite_start]Tự động làm mờ hoặc hiện rõ (Fade in/out)[cite: 17]. | [cite_start]Slogan, text xuất hiện dần khi vào màn hình[cite: 17]. |
| **`AnimatedScale`** | [cite_start]Tự động phóng to/thu nhỏ kích thước[cite: 17]. | [cite_start]Hiệu ứng nhấn nút, logo scale up[cite: 17]. |
| **`AnimatedSlide`** | [cite_start]Tự động trượt vị trí theo tỉ lệ trục X/Y[cite: 17]. | [cite_start]Text slide up, custom bottom sheet[cite: 17]. |
| **`AnimatedSwitcher`** | [cite_start]Chuyển đổi mượt mà giữa hai widget khác nhau[cite: 17]. | [cite_start]Đổi icon từ active sang inactive, đổi màn hình con[cite: 17]. |

### 🔹 Explicit Animations & Transitions (Điều khiển thủ công bằng Controller)
| Widget | Mô tả | Dùng khi nào |
| :--- | :--- | :--- |
| **`TweenAnimationBuilder`** | [cite_start]Tạo animation tùy chỉnh dựa trên khoảng giá trị Tween[cite: 17]. | [cite_start]Làm vòng tròn đếm ngược (countdown), thanh tiến trình custom[cite: 17]. |
| **`AnimationController`** | [cite_start]Bộ điều khiển trạng thái và thời gian của animation[cite: 17]. | [cite_start]Làm bong bóng bay, logo chuyển động lặp đi lặp lại vô hạn[cite: 17]. |
| **`FadeTransition`** | [cite_start]Hiệu ứng mờ/rõ phối hợp với Controller[cite: 17]. | [cite_start]Chuyển màn hình dạng fade in/out[cite: 17]. |
| **`SlideTransition`** | [cite_start]Hiệu ứng trượt phối hợp với Controller[cite: 17]. | [cite_start]Chuyển màn hình trượt từ dưới lên hoặc từ bên cạnh sang[cite: 17]. |
| **`ScaleTransition`** | [cite_start]Hiệu ứng phóng to/thu nhỏ phối hợp với Controller[cite: 17]. | [cite_start]Các hiệu ứng logo co giãn phức tạp[cite: 17]. |
| **`Hero`** | [cite_start]Bay widget mượt mà nối liền giữa 2 màn hình khác nhau[cite: 17]. | [cite_start]Di chuyển Logo/Ảnh sản phẩm từ màn hình danh sách sang màn chi tiết[cite: 17]. |