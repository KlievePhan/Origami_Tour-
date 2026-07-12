# Phân Tích Giao Diện & Cấu Trúc Flutter (Origami Tour Project)

Dưới đây là tài liệu phân tích chi tiết, kết hợp giữa **lý thuyết chuẩn của Flutter** và **bằng chứng thực tế** trích xuất từ các màn hình cốt lõi của dự án (sau khi đã trải qua các đợt cập nhật và refactor code).

---

### 1. Blind-test UI: Nhận diện Widget và Sửa đổi giao diện
**Lý thuyết:** Bất kỳ giao diện nào trong Flutter cũng được lắp ráp từ các Widget. Để đổi màu hoặc icon, ta phải tìm chính xác Widget hiển thị (như `Icon`, `Text`, `Container`) và can thiệp vào thuộc tính `color`, `icon` hoặc `decoration` của nó.

**Ví dụ thực tế trong dự án:**
- **Trong `model_details_screen.dart` (Nút Bookmark):**
  - Để thay đổi icon lưu trang (bookmark) nằm ở góc phải Header, hãy xem class `_Header`. Đang dùng `Icon(isFavorite ? Icons.bookmark : Icons.bookmark_add_outlined)`. Bạn có thể đổi `Icons.bookmark` thành icon khác tùy ý.
- **Trong `google_auth_button.dart` (Sửa lỗi RenderFlex Overflow):**
  - Trước đây dự án dùng `Image.network` để load ảnh SVG (Google Logo), điều này làm văng Exception và gây tràn viền (Overflow) ra khỏi container chứa nó. Lỗi này đã được khắc phục bằng cách đổi sang URL ảnh chuẩn PNG. Đồng thời thêm thuộc tính `errorBuilder` để fallback về một icon mặc định `Icon(Icons.g_mobiledata)` nếu đường truyền ảnh bị hỏng, đảm bảo UI luôn hiển thị đẹp mắt và không bị vỡ.

### 2. Tối ưu Layout: ListView.builder vs ListView/Column
**Lý thuyết:** Khi hiển thị danh sách dài, sử dụng `Column` hoặc `ListView` thường sẽ render toàn bộ các phần tử cùng một lúc, gây ngốn RAM và lag máy. `ListView.builder` (hoặc `ListView.separated`, `GridView.builder`) giải quyết việc này bằng cách chỉ tạo (build) các phần tử khi chúng cuộn tới vùng hiển thị của màn hình (Lazy Loading).

**Ví dụ thực tế trong dự án:**
- **Trong `collection_screen.dart` (Danh sách mô hình Origami):**
  - Không dùng Column, dự án sử dụng `GridView.builder` để vẽ lưới mô hình Origami 2 cột. Thuộc tính `itemBuilder: (context, index) => _ModelGridCard(...)` được gọi linh động để tối ưu RAM.
- **Trong `bookmark_screen.dart` (Danh sách yêu thích):**
  - Sử dụng `ListView.separated` để vẽ danh sách các mô hình yêu thích theo chiều dọc. Hàm `separatorBuilder` giúp tự động chèn khoảng trống `SizedBox(height: 16)` giữa các item mà không cần code thủ công chèn các khoảng cách ngắt quãng.

### 3. Xử lý tràn viền (Overflow) và Xung đột Widget
**Lý thuyết:** Khi nội dung văn bản (Text) hoặc thành phần con vượt quá kích thước vật lý của hộp chứa (Container, Row), Flutter sẽ văng lỗi RenderFlex Overflow (xuất hiện sọc cảnh báo đen vàng). Bên cạnh đó, các lỗi Runtime Assertion cũng thường xảy ra nếu cấu hình sai thuộc tính (VD: dùng `color` ngay ngoài Widget trong khi đã khai báo `BoxDecoration`).

**Ví dụ thực tế trong dự án:**
- **Trong `collection_screen.dart` (Tên mô hình trong lưới):**
  - Ở class `_ModelGridCard`, Text hiển thị tên mô hình được thiết lập: `maxLines: 1` và `overflow: TextOverflow.ellipsis`. Nếu tên quá dài, nó sẽ thu gọn chữ và hiển thị "Hạc giấy...".
- **Trong `bookmark_screen.dart` (Lỗi xung đột thuộc tính màu):**
  - Giao diện từng dính lỗi Assertion Runtime *"Cannot provide both a color and a decoration"*. Điều này xảy ra do lập trình viên truyền cả tham số `color` và `decoration: BoxDecoration(...)` vào một `Container`. Code mới hiện tại đã được dọn dẹp bằng cách đưa toàn bộ `color` vào bên trong class `BoxDecoration` để giải quyết sự nhập nhằng trong lúc Render.

### 4. Responsive (Thích ứng đa màn hình)
**Lý thuyết:** Khi xoay ngang màn hình thiết bị hoặc chạy trên màn hình lớn (Tablet, PC, Web), chiều rộng tăng lên đáng kể. Nếu thiết lập cứng số lượng cột hoặc không giới hạn chiều rộng, giao diện sẽ bị bè ra hoặc phình to thô kệch.

**Ví dụ thực tế trong dự án (Đã khắc phục hoàn toàn):**
- **Cấu hình số cột động bằng `MediaQuery` (`collection_screen.dart`, `profile_screen.dart`):**
  - Bằng cách bắt kích thước `MediaQuery.sizeOf(context).width`, giao diện tự động nhân đôi số cột (từ 2 lên 4 ở lưới mô hình, từ 3 lên 6 ở lưới thành tựu) khi không gian `> 600px`:
    ```dart
    crossAxisCount: MediaQuery.sizeOf(context).width > 600 ? 4 : 2,
    ```
- **Sử dụng `ConstrainedBox` để chặn chiều rộng tối đa (`bookmark_screen.dart`, `model_details_screen.dart`, `process_view_screen.dart`):**
  - Để tránh giao diện dàn trải dài loằng ngoằng trên màn hình ngang, các vùng hiển thị chính được gói gọn vào giữa với ranh giới tối đa 800px:
    ```dart
    Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Column(...), // Hoặc ListView
      ),
    )
    ```

### 5. Nguồn dữ liệu, API & Xác thực (Authentication)
**Lý thuyết:** Dữ liệu có thể lấy từ Local hoặc qua API (HTTP request). Cần xử lý mọi trạng thái (Loading, Error, Data), cũng như tích hợp bảo mật (OAuth, JWT).

**Ví dụ thực tế trong dự án:**
- **Cấu hình Google Sign-In (Web Support):** 
  - Tại `google_auth_button.dart`, tham số `clientId` được thiết lập trực tiếp trong `GoogleSignIn.instance.initialize(...)` để dứt điểm lỗi khởi tạo SDK trên Web do thư viện `google_sign_in_web` yêu cầu bắt buộc.
- **Tối ưu Backend API Query (`BookmarkRepository.cs`):** 
  - Đã khắc phục cảnh báo *MultipleCollectionIncludeWarning* của Entity Framework bằng hậu tố `.AsSplitQuery()`, giúp gỡ bỏ hiện tượng Cartesian Explosion và tăng tốc độ trả API gấp nhiều lần cho Front-end.
- **Cơ chế Load State UI (`bookmark_screen.dart`):** 
  - Dùng lệnh `switch (bookmarks.status)` để vẽ màn hình: trả về `CircularProgressIndicator` khi Loading, trả về Widget báo lỗi kèm nút Retry khi có sự cố mạng, và trả về ListView khi có Data.

### 6. Vòng đời Widget (Lifecycle)
**Lý thuyết:** 
- `initState()`: Chạy 1 lần duy nhất để thiết lập Listeners, Controllers, Timers.
- `dispose()`: Chạy khi màn hình bị phá hủy, dùng để dọn dẹp bộ nhớ (giải phóng RAM, ngắt Timer).

**Ví dụ thực tế trong dự án:**
- **Bộ đếm thời gian (`process_view_screen.dart`):** 
  - Tại `initState()`, dự án khởi chạy `_stopwatch.start()` và thiết lập `Timer.periodic` mỗi giây để đếm thời gian người dùng gập giấy. Tại `dispose()`, chúng được gọi `.stop()` và `.cancel()` cực kỳ an toàn để tránh sập app.
- **Giải phóng Bộ Lọc & Tìm kiếm (`collection_screen.dart`):**
  - Ở `dispose()`, `_searchController` thực hiện `removeListener(...)` trước rồi mới `dispose()`, đây là một best-practice kinh điển nhằm không rò rỉ bộ nhớ.

### 7. Cấu trúc UI Tree & Sự kiện tương tác
**Lý thuyết:** Việc chia nhỏ Widget (Phân rã) giúp Flutter tối ưu Rebuild và làm code dễ đọc. Sự kiện chạm, vuốt được bắt bởi các Gesture chuyên dụng.

**Ví dụ thực tế trong dự án:**
- **Phân rã Widget (`model_details_screen.dart`):**
  - Thay vì dồn mọi thứ vào 1 hàm build khổng lồ, giao diện phân cấp thành: `_Header`, `_HeroImage`, `_StatsRow`, `_RatingCard`, `_BottomAction`. Nhờ vậy, khi nhấn nút Favorite, chỉ phần Header bị cập nhật mà không làm giật lag bức ảnh Hero.
- **Vuốt để Xóa - Swipe to Delete (`bookmark_screen.dart`):**
  - Các phần tử danh sách được bọc bởi Widget `Dismissible(direction: DismissDirection.endToStart)`. Khi người dùng vuốt sang trái, hàm `onDismissed` sẽ được kích hoạt để thực thi API `removeProgress()` xóa mục đó đi.

### 8. Quản lý Theme & Tích hợp Dark Mode (Theme Management)
**Lý thuyết:** Flutter mạnh mẽ nhờ khả năng khai báo Theme động thông qua `Theme.of(context)`. Lý tưởng nhất là khai báo toàn bộ màu sắc vào `ThemeData` ở `main.dart` để tái sử dụng. Tuy nhiên, trong thực tế, các biến màu không nên bị hardcode (gán cứng) mà phải linh hoạt.

**Tình trạng thực tế trong dự án (Vẫn phải sửa theo từng file):**
- **Giải thích:** Mặc dù dự án đã cấu hình `ThemeData` cơ bản ở `theme_provider.dart`, nhưng **phần Dark Mode hiện tại vẫn đang được xử lý thủ công bên trong từng file màn hình riêng lẻ** bằng toán tử 3 ngôi (VD: `isDark ? màu_tối : màu_sáng`).
- **Nguyên nhân:** Thiết kế UI ban đầu từ Figma có quá nhiều màu sắc tuỳ chỉnh phức tạp (Custom Hex Colors, bóng đổ đa tầng, viền thẻ riêng biệt, màu nền phụ) không khớp với cấu trúc bảng màu chuẩn (`ColorScheme`) của Material Design 3. Việc ép toàn bộ các mã màu đặc thù này vào `ThemeData` tổng sẽ cực kỳ cồng kềnh. Do đó, dự án chọn cách bắt biến `isDark` ở từng màn hình để tuỳ biến sâu hơn.

**Cách các màn hình áp dụng (Đoạn code cụ thể):**
- Ở dòng đầu tiên của hàm `build()` bên trong tất cả các màn hình chính (`bookmark_screen.dart`, `profile_screen.dart`, `model_details_screen.dart`, `finish_screen.dart`, `collection_screen.dart`), hệ thống gọi truy vấn độ sáng để lắng nghe thiết bị, sau đó gán logic vào các Widget:
  ```dart
  @override
  Widget build(BuildContext context) {
    // 1. Kiểm tra theme hiện tại của thiết bị (Được gọi ở tất cả màn hình)
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 2. Tự động đổi màu giao diện dựa vào biến isDark
    return Scaffold(
      // Đổi nền Scaffold (Nền tổng của app)
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: Container(
        decoration: ShapeDecoration(
          // Đổi nền thẻ (Card Background)
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF4F2FC),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1, 
              // Đổi màu viền (Border) và giảm Opacity ở chế độ tối để không loá mắt
              color: isDark ? const Color(0xFF333333) : const Color(0x33C5C5D4),
            ),
          ),
        ),
        child: Text(
          'Mastery',
          // Đổi màu chữ phụ (Subtitle) sang màu trắng đục để duy trì chuẩn trợ năng
          style: TextStyle(
            color: isDark ? Colors.white70 : const Color(0xFF454652),
          ),
        ),
      ),
    );
  }
  ```
