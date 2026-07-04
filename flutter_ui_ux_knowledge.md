# Flutter UI/UX — Tổng hợp kiến thức cơ bản

> Tài liệu này bao gồm: Scaffold, Widget quan trọng, Screen lifecycle, Gesture, Animation cơ bản, và UI Components (Card, Form, Grid, Toggle, Select, Input).

---

## 1. Scaffold — Khung sườn của một màn hình

`Scaffold` là widget nền tảng cho mọi màn hình trong Flutter, cung cấp cấu trúc Material Design.

```dart
Scaffold(
  appBar: AppBar(
    title: Text('Tiêu đề'),
    leading: IconButton(icon: Icon(Icons.menu), onPressed: () {}),
    actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})],
    backgroundColor: Colors.indigo,
    elevation: 2,
  ),
  body: Center(child: Text('Nội dung')),
  floatingActionButton: FloatingActionButton(
    onPressed: () {},
    child: Icon(Icons.add),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  bottomNavigationBar: BottomNavigationBar(
    currentIndex: 0,
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ],
    onTap: (index) {},
  ),
  drawer: Drawer(child: ListView(children: [DrawerHeader(child: Text('Menu'))])),
  backgroundColor: Colors.grey[100],
)
```

### Các slot của Scaffold

| Slot | Mô tả |
|------|-------|
| `appBar` | Thanh tiêu đề trên cùng |
| `body` | Vùng nội dung chính |
| `floatingActionButton` | Nút hành động nổi |
| `bottomNavigationBar` | Tab bar dưới cùng |
| `drawer` / `endDrawer` | Ngăn kéo trái / phải |
| `bottomSheet` | Sheet cố định ở đáy |
| `backgroundColor` | Màu nền của Scaffold |

---

## 2. StatelessWidget vs StatefulWidget

### StatelessWidget — Không có trạng thái

Dùng khi UI không thay đổi sau khi build, phụ thuộc hoàn toàn vào dữ liệu truyền vào.

```dart
class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String imageUrl;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.network(imageUrl),
          Text(title),
          Text('\$$price'),
        ],
      ),
    );
  }
}
```

### StatefulWidget — Có trạng thái, có thể rebuild

Dùng khi UI cần thay đổi theo tương tác người dùng, dữ liệu async, animation...

```dart
class CounterWidget extends StatefulWidget {
  const CounterWidget({super.key});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _count = 0;                      // state nội bộ

  @override
  void initState() {
    super.initState();
    // Gọi 1 lần khi widget được tạo — fetch API, khởi tạo controller
  }

  @override
  void didUpdateWidget(CounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Gọi khi widget cha rebuild và truyền props mới
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên: controller, timer, stream subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Count: $_count'),
        ElevatedButton(
          onPressed: () => setState(() => _count++),  // trigger rebuild
          child: Text('Tăng'),
        ),
      ],
    );
  }
}
```

### Lifecycle tóm tắt

```
createState()
    ↓
initState()          ← khởi tạo: fetch data, controller, timer
    ↓
didChangeDependencies()  ← khi InheritedWidget thay đổi
    ↓
build()              ← vẽ UI (gọi lại mỗi setState)
    ↓
didUpdateWidget()    ← khi parent rebuild với props mới
    ↓
setState()  → build() lặp lại
    ↓
dispose()            ← cleanup khi widget bị remove khỏi cây
```

---

## 3. Layout Widgets — Bố cục

### Column & Row

```dart
Column(
  mainAxisAlignment: MainAxisAlignment.center,    // dọc (trục chính)
  crossAxisAlignment: CrossAxisAlignment.start,   // ngang (trục phụ)
  mainAxisSize: MainAxisSize.min,                 // co lại vừa nội dung
  children: [
    Text('Item 1'),
    SizedBox(height: 8),   // khoảng cách
    Text('Item 2'),
  ],
)

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Icon(Icons.star),
    Expanded(child: Text('Tên sản phẩm')),  // chiếm hết không gian còn lại
    Text('\$99'),
  ],
)
```

### Stack — Chồng lớp

```dart
Stack(
  alignment: Alignment.bottomCenter,
  children: [
    Image.network(imageUrl, fit: BoxFit.cover),
    Positioned(
      bottom: 16, right: 16,
      child: ElevatedButton(onPressed: () {}, child: Text('Xem thêm')),
    ),
    Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54],
          ),
        ),
      ),
    ),
  ],
)
```

### Container — Hộp đa năng

```dart
Container(
  width: double.infinity,
  height: 120,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  padding: EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
    ],
    gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
    border: Border.all(color: Colors.blue.shade200),
  ),
  child: Text('Nội dung'),
)
```

### Padding & SizedBox

```dart
Padding(
  padding: EdgeInsets.symmetric(horizontal: 16),
  child: Text('Có padding ngang'),
)

SizedBox(width: 12)   // khoảng trắng ngang
SizedBox(height: 20)  // khoảng trắng dọc
SizedBox(width: 200, height: 50, child: ElevatedButton(...))
```

### Flexible & Expanded

```dart
Row(children: [
  Expanded(flex: 2, child: Container(color: Colors.blue)),  // 2/3 chiều rộng
  Expanded(flex: 1, child: Container(color: Colors.red)),   // 1/3 chiều rộng
])
```

### Wrap — Tự xuống dòng

```dart
Wrap(
  spacing: 8,     // khoảng cách ngang
  runSpacing: 8,  // khoảng cách dọc khi xuống dòng
  children: ['Flutter', 'Dart', 'UI', 'Mobile']
      .map((tag) => Chip(label: Text(tag)))
      .toList(),
)
```

---

## 4. Widget Hiển thị

### Text với style

```dart
Text(
  'Tiêu đề sản phẩm',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.grey[800],
    letterSpacing: 0.5,
    height: 1.4,                          // line-height
    overflow: TextOverflow.ellipsis,
  ),
  maxLines: 2,
  textAlign: TextAlign.center,
)

// RichText — nhiều style trong 1 dòng
RichText(
  text: TextSpan(
    style: TextStyle(color: Colors.black, fontSize: 14),
    children: [
      TextSpan(text: 'Giá: '),
      TextSpan(text: '299.000đ', style: TextStyle(
        color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16,
      )),
    ],
  ),
)
```

### Image

```dart
Image.network(
  'https://example.com/image.jpg',
  fit: BoxFit.cover,
  width: double.infinity,
  height: 200,
  loadingBuilder: (ctx, child, progress) =>
      progress == null ? child : CircularProgressIndicator(),
  errorBuilder: (ctx, error, stack) => Icon(Icons.broken_image),
)

// Ảnh tròn
CircleAvatar(
  radius: 30,
  backgroundImage: NetworkImage(avatarUrl),
  backgroundColor: Colors.grey[200],
)

// ClipRRect — ảnh bo góc
ClipRRect(
  borderRadius: BorderRadius.circular(12),
  child: Image.network(imageUrl, fit: BoxFit.cover),
)
```

### Icon

```dart
Icon(Icons.favorite, color: Colors.red, size: 24)
Icon(Icons.star, color: Colors.amber)

// Icon có badge
Badge(
  label: Text('3'),
  child: Icon(Icons.notifications),
)
```

---

## 5. Scrolling Widgets

### ListView

```dart
// Builder — hiệu quả cho danh sách dài
ListView.builder(
  itemCount: items.length,
  padding: EdgeInsets.all(16),
  itemBuilder: (context, index) => ProductCard(item: items[index]),
)

// Separated — có divider giữa các item
ListView.separated(
  itemCount: items.length,
  separatorBuilder: (_, __) => Divider(height: 1),
  itemBuilder: (context, index) => ListTile(
    leading: CircleAvatar(child: Text('${index + 1}')),
    title: Text(items[index].name),
    subtitle: Text(items[index].desc),
    trailing: Icon(Icons.chevron_right),
    onTap: () => Navigator.push(context, ...),
  ),
)
```

### GridView

```dart
GridView.builder(
  padding: EdgeInsets.all(16),
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,          // số cột
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.75,     // tỷ lệ width/height của mỗi cell
  ),
  itemCount: products.length,
  itemBuilder: (ctx, i) => ProductCard(product: products[i]),
)

// Grid với số cột tự động theo chiều rộng
GridView.builder(
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 200,    // cell tối đa 200px rộng
    childAspectRatio: 0.8,
    crossAxisSpacing: 8,
    mainAxisSpacing: 8,
  ),
  ...
)
```

### CustomScrollView & Sliver — Scroll phức tạp

```dart
CustomScrollView(
  slivers: [
    SliverAppBar(
      expandedHeight: 200,
      pinned: true,   // AppBar ghim khi scroll
      flexibleSpace: FlexibleSpaceBar(
        title: Text('App Title'),
        background: Image.network(bannerUrl, fit: BoxFit.cover),
      ),
    ),
    SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Danh sách sản phẩm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    ),
    SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => ProductCard(product: products[i]),
        childCount: products.length,
      ),
    ),
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (ctx, i) => ListTile(title: Text(items[i])),
        childCount: items.length,
      ),
    ),
  ],
)
```

---

## 6. Gesture & Tương tác

### GestureDetector — Toàn bộ gesture

```dart
GestureDetector(
  onTap: () => print('Tap'),
  onDoubleTap: () => print('Double tap'),
  onLongPress: () => print('Long press'),
  onPanUpdate: (details) => print('Drag: ${details.delta}'),   // kéo thả
  onScaleUpdate: (details) => print('Pinch: ${details.scale}'), // zoom
  child: Container(
    color: Colors.blue,
    width: 100, height: 100,
  ),
)
```

### InkWell — Gesture có hiệu ứng ripple Material

```dart
InkWell(
  onTap: () => Navigator.push(context, ...),
  onLongPress: () => showBottomSheet(...),
  borderRadius: BorderRadius.circular(12),
  splashColor: Colors.blue.withOpacity(0.2),
  highlightColor: Colors.blue.withOpacity(0.1),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Nhấn vào đây'),
  ),
)
```

### Dismissible — Vuốt để xóa

```dart
Dismissible(
  key: Key(item.id.toString()),
  direction: DismissDirection.endToStart,  // vuốt từ phải sang trái
  onDismissed: (direction) {
    setState(() => items.remove(item));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã xóa ${item.name}')),
    );
  },
  background: Container(
    color: Colors.red,
    alignment: Alignment.centerRight,
    padding: EdgeInsets.only(right: 16),
    child: Icon(Icons.delete, color: Colors.white),
  ),
  child: ListTile(title: Text(item.name)),
)
```

### Draggable & DragTarget

```dart
// Kéo
Draggable<String>(
  data: 'item_data',
  feedback: Material(
    elevation: 8,
    child: Container(width: 80, height: 80, color: Colors.blue.withOpacity(0.8)),
  ),
  childWhenDragging: Opacity(opacity: 0.4, child: myCard),
  child: myCard,
)

// Thả vào
DragTarget<String>(
  onAcceptWithDetails: (details) => setState(() => droppedData = details.data),
  builder: (context, candidateData, rejectedData) {
    return Container(
      color: candidateData.isNotEmpty ? Colors.green[100] : Colors.grey[200],
      child: Center(child: Text('Thả vào đây')),
    );
  },
)
```

---

## 7. Animation

### AnimatedContainer — Animation tự động

```dart
class _AnimatedBoxState extends State<AnimatedBox> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: _expanded ? 200 : 100,
        height: _expanded ? 200 : 100,
        color: _expanded ? Colors.blue : Colors.red,
        child: Center(child: Text(_expanded ? 'Lớn' : 'Nhỏ')),
      ),
    );
  }
}
```

### AnimatedOpacity & AnimatedSwitcher

```dart
AnimatedOpacity(
  opacity: _visible ? 1.0 : 0.0,
  duration: Duration(milliseconds: 400),
  child: Text('Ẩn hiện'),
)

// Chuyển đổi giữa 2 widget với animation
AnimatedSwitcher(
  duration: Duration(milliseconds: 300),
  transitionBuilder: (child, animation) =>
      FadeTransition(opacity: animation, child: child),
  child: _isLoading
      ? CircularProgressIndicator(key: ValueKey('loading'))
      : Text('Nội dung', key: ValueKey('content')),
)
```

### AnimationController — Kiểm soát thủ công

```dart
class _FadeInState extends State<FadeInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnim = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();  // chạy animation
  }

  @override
  void dispose() {
    _controller.dispose();   // bắt buộc dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: widget.child,
      ),
    );
  }
}
```

### Hero Animation — Chuyển màn hình mượt

```dart
// Màn hình nguồn
Hero(
  tag: 'product_${product.id}',  // tag phải unique
  child: Image.network(product.imageUrl, fit: BoxFit.cover),
)

// Màn hình đích
Hero(
  tag: 'product_${product.id}',
  child: Image.network(product.imageUrl, width: double.infinity, fit: BoxFit.cover),
)
```

### PageRouteBuilder — Custom transition khi navigate

```dart
Navigator.push(
  context,
  PageRouteBuilder(
    transitionDuration: Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => DetailScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(1.0, 0.0),  // từ phải trượt vào
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    },
  ),
);
```

---

## 8. UI Components — Card & Layout Cards

### Card cơ bản

```dart
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  color: Colors.white,
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tiêu đề', style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        Text('Mô tả nội dung', style: TextStyle(color: Colors.grey[600])),
      ],
    ),
  ),
)
```

### Product Card hoàn chỉnh

```dart
class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,  // clip ảnh theo bo góc card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => ProductDetail(product: product),
        )),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh + Badge
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.network(product.imageUrl, fit: BoxFit.cover),
                ),
                if (product.isNew)
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('MỚI', style: TextStyle(color: Colors.white, fontSize: 10)),
                    ),
                  ),
              ],
            ),
            // Thông tin
            Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      Text(' ${product.rating}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      Spacer(),
                      Text('${product.price.toStringAsFixed(0)}đ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 9. Input & Form Widgets

### TextField cơ bản

```dart
final _controller = TextEditingController();
final _focusNode = FocusNode();

TextField(
  controller: _controller,
  focusNode: _focusNode,
  keyboardType: TextInputType.emailAddress,
  textInputAction: TextInputAction.next,      // nút "Next" trên bàn phím
  obscureText: false,                         // true cho password
  maxLines: 1,
  maxLength: 100,
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'example@email.com',
    prefixIcon: Icon(Icons.email_outlined),
    suffixIcon: IconButton(
      icon: Icon(Icons.clear),
      onPressed: () => _controller.clear(),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red),
    ),
    filled: true,
    fillColor: Colors.grey[50],
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  ),
  onChanged: (value) => print('Changed: $value'),
  onSubmitted: (value) => FocusScope.of(context).nextFocus(),
)
```

### Form với validation

```dart
final _formKey = GlobalKey<FormState>();
final _emailController = TextEditingController();
final _passwordController = TextEditingController();

Form(
  key: _formKey,
  child: Column(
    children: [
      TextFormField(
        controller: _emailController,
        decoration: InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
        validator: (value) {
          if (value == null || value.isEmpty) return 'Vui lòng nhập email';
          if (!value.contains('@')) return 'Email không hợp lệ';
          return null;  // hợp lệ
        },
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(labelText: 'Mật khẩu', prefixIcon: Icon(Icons.lock)),
        validator: (value) {
          if (value == null || value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
          return null;
        },
      ),
      SizedBox(height: 24),
      ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            // form hợp lệ → submit
          }
        },
        child: Text('Đăng nhập'),
      ),
    ],
  ),
)
```

---

## 10. Toggle, Select, Multi-select, Option

### Switch & Checkbox — Toggle đơn

```dart
// Switch
SwitchListTile(
  title: Text('Nhận thông báo'),
  subtitle: Text('Push notification khi có đơn hàng mới'),
  value: _notifyEnabled,
  onChanged: (val) => setState(() => _notifyEnabled = val),
  secondary: Icon(Icons.notifications_outlined),
  activeColor: Colors.blue,
)

// Checkbox
CheckboxListTile(
  title: Text('Nhớ đăng nhập'),
  value: _rememberMe,
  onChanged: (val) => setState(() => _rememberMe = val ?? false),
  controlAffinity: ListTileControlAffinity.leading,  // checkbox bên trái
)
```

### Radio — Chọn 1 trong nhiều (Select)

```dart
Column(
  children: PaymentMethod.values.map((method) =>
    RadioListTile<PaymentMethod>(
      title: Text(method.label),
      subtitle: Text(method.description),
      secondary: Icon(method.icon),
      value: method,
      groupValue: _selectedPayment,
      onChanged: (val) => setState(() => _selectedPayment = val!),
    )
  ).toList(),
)
```

### DropdownButton — Dropdown Select

```dart
DropdownButtonFormField<String>(
  value: _selectedCategory,
  decoration: InputDecoration(
    labelText: 'Danh mục',
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    prefixIcon: Icon(Icons.category_outlined),
  ),
  items: categories.map((cat) =>
    DropdownMenuItem(
      value: cat.id,
      child: Row(children: [
        Icon(cat.icon, size: 18, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(cat.name),
      ]),
    )
  ).toList(),
  onChanged: (val) => setState(() => _selectedCategory = val),
  validator: (val) => val == null ? 'Vui lòng chọn danh mục' : null,
)
```

### Chip — Multi-select / Tag

```dart
class MultiSelectChips extends StatefulWidget { ... }

class _MultiSelectChipsState extends State<MultiSelectChips> {
  final List<String> _allTags = ['Flutter', 'Dart', 'Mobile', 'UI', 'API', 'Firebase'];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allTags.map((tag) {
        final isSelected = _selected.contains(tag);
        return FilterChip(
          label: Text(tag),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) _selected.add(tag);
              else _selected.remove(tag);
            });
          },
          selectedColor: Colors.blue[100],
          checkmarkColor: Colors.blue[700],
          labelStyle: TextStyle(
            color: isSelected ? Colors.blue[700] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
          ),
        );
      }).toList(),
    );
  }
}
```

### ToggleButtons — Chọn 1 hoặc nhiều từ nhóm nhỏ

```dart
ToggleButtons(
  isSelected: _viewModes,  // [true, false, false]
  onPressed: (index) {
    setState(() {
      for (int i = 0; i < _viewModes.length; i++) {
        _viewModes[i] = i == index;  // single select
      }
    });
  },
  borderRadius: BorderRadius.circular(8),
  selectedColor: Colors.white,
  fillColor: Colors.blue,
  color: Colors.grey[600],
  children: [
    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.grid_view)),
    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.list)),
    Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.map)),
  ],
)
```

### Slider & RangeSlider

```dart
// Slider đơn
Slider(
  value: _price,
  min: 0,
  max: 10000000,
  divisions: 100,
  label: '${_price.toStringAsFixed(0)}đ',
  onChanged: (val) => setState(() => _price = val),
)

// Range slider — bộ lọc giá từ...đến...
RangeSlider(
  values: _priceRange,
  min: 0,
  max: 10000000,
  divisions: 100,
  labels: RangeLabels(
    '${_priceRange.start.toStringAsFixed(0)}đ',
    '${_priceRange.end.toStringAsFixed(0)}đ',
  ),
  onChanged: (range) => setState(() => _priceRange = range),
)
```

---

## 11. DataGrid / DataTable

```dart
SingleChildScrollView(
  scrollDirection: Axis.horizontal,  // scroll ngang nếu nhiều cột
  child: DataTable(
    sortColumnIndex: _sortColumnIndex,
    sortAscending: _sortAscending,
    columnSpacing: 24,
    headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
    columns: [
      DataColumn(
        label: Text('Tên', style: TextStyle(fontWeight: FontWeight.bold)),
        onSort: (colIndex, ascending) {
          setState(() {
            _sortColumnIndex = colIndex;
            _sortAscending = ascending;
            // sort logic
          });
        },
      ),
      DataColumn(label: Text('Trạng thái'), numeric: false),
      DataColumn(label: Text('Giá'), numeric: true),
    ],
    rows: orders.map((order) =>
      DataRow(
        selected: _selectedOrders.contains(order.id),
        onSelectChanged: (selected) {
          setState(() {
            if (selected == true) _selectedOrders.add(order.id);
            else _selectedOrders.remove(order.id);
          });
        },
        cells: [
          DataCell(Text(order.customerName)),
          DataCell(
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: order.statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(order.statusLabel,
                  style: TextStyle(color: order.statusColor, fontWeight: FontWeight.w600)),
            ),
          ),
          DataCell(Text('${order.total.toStringAsFixed(0)}đ')),
        ],
      )
    ).toList(),
  ),
)
```

---

## 12. Bottom Sheet, Dialog, Snackbar

### Bottom Sheet

```dart
// Modal Bottom Sheet
showModalBottomSheet(
  context: context,
  isScrollControlled: true,           // full height nếu cần
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
  builder: (ctx) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.5,
    minChildSize: 0.3,
    maxChildSize: 0.9,
    builder: (_, controller) => ListView(
      controller: controller,
      padding: EdgeInsets.all(16),
      children: [
        Center(
          child: Container(
            width: 40, height: 4,
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Text('Tùy chọn', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...options.map((opt) => ListTile(
          leading: Icon(opt.icon),
          title: Text(opt.label),
          onTap: () { Navigator.pop(ctx); opt.action(); },
        )),
      ],
    ),
  ),
);
```

### Alert Dialog

```dart
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    title: Row(children: [
      Icon(Icons.warning_amber, color: Colors.orange),
      SizedBox(width: 8),
      Text('Xác nhận xóa'),
    ]),
    content: Text('Bạn có chắc muốn xóa đơn hàng này không? Hành động không thể hoàn tác.'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text('Hủy'),
      ),
      ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () { Navigator.pop(ctx); onConfirmDelete(); },
        child: Text('Xóa', style: TextStyle(color: Colors.white)),
      ),
    ],
  ),
);
```

### SnackBar

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Row(children: [
      Icon(Icons.check_circle, color: Colors.white),
      SizedBox(width: 8),
      Text('Thêm vào giỏ hàng thành công'),
    ]),
    backgroundColor: Colors.green[700],
    duration: Duration(seconds: 3),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    action: SnackBarAction(
      label: 'Xem giỏ',
      textColor: Colors.white,
      onPressed: () => Navigator.pushNamed(context, '/cart'),
    ),
  ),
);
```

---

## 13. Navigation

### Basic Navigation

```dart
// Push
Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(id: itemId)));

// Pop với kết quả
Navigator.pop(context, 'result_data');

// Pop và nhận kết quả
final result = await Navigator.push<String>(context, ...);
if (result != null) print('Nhận được: $result');

// Named routes
Navigator.pushNamed(context, '/detail', arguments: {'id': 1});

// Replace — không thể back về trang trước
Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));

// Clear toàn bộ stack
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => HomeScreen()),
  (route) => false,
);
```

### GoRouter (package khuyến nghị)

```dart
// pubspec.yaml: go_router: ^13.0.0

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (ctx, state) => HomeScreen()),
    GoRoute(
      path: '/product/:id',
      builder: (ctx, state) => ProductDetail(id: state.pathParameters['id']!),
    ),
    ShellRoute(
      builder: (ctx, state, child) => MainShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (ctx, state) => HomeTab()),
        GoRoute(path: '/profile', builder: (ctx, state) => ProfileTab()),
      ],
    ),
  ],
);

// Dùng trong widget
context.go('/product/123');
context.push('/detail');
context.pop();
```

---

## 14. Theme & Style nhất quán

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.light,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
  ),
  home: HomeScreen(),
)

// Dùng theme trong widget
Theme.of(context).colorScheme.primary
Theme.of(context).textTheme.titleMedium
```

---

## 15. Những method & Pattern quan trọng

### context.mounted — Tránh setState sau async

```dart
Future<void> _loadData() async {
  final data = await apiService.fetchProducts();
  if (!mounted) return;          // widget có thể đã bị dispose
  setState(() => _products = data);
}
```

### MediaQuery — Responsive theo màn hình

```dart
final size = MediaQuery.of(context).size;
final padding = MediaQuery.of(context).padding;  // safe area
final isTablet = size.width > 600;

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: isTablet ? 3 : 2,
  ),
  ...
)
```

### LayoutBuilder — Responsive theo parent

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return Row(children: [...]);   // layout ngang trên tablet
    }
    return Column(children: [...]);  // layout dọc trên phone
  },
)
```

### FutureBuilder & StreamBuilder

```dart
FutureBuilder<List<Product>>(
  future: _productsFuture,   // Future được tạo trong initState
  builder: (ctx, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    if (snapshot.hasError) {
      return Center(child: Text('Lỗi: ${snapshot.error}'));
    }
    final products = snapshot.data ?? [];
    if (products.isEmpty) {
      return Center(child: Text('Chưa có sản phẩm'));
    }
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (_, i) => ProductCard(product: products[i]),
    );
  },
)
```

### RefreshIndicator — Pull to refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    await _loadData();
  },
  color: Colors.blue,
  child: ListView.builder(...),
)
```

---

## 16. Checklist UX tốt

| Hạng mục | Thực hiện |
|----------|-----------|
| Loading state | `CircularProgressIndicator` hoặc skeleton shimmer |
| Empty state | Illustration + text hướng dẫn + action button |
| Error state | Message rõ ràng + nút retry |
| Pull to refresh | `RefreshIndicator` wrapping list |
| Haptic feedback | `HapticFeedback.lightImpact()` khi tap quan trọng |
| Ripple effect | Dùng `InkWell` thay vì `GestureDetector` trên Material |
| Keyboard safe | `resizeToAvoidBottomInset: true` trên Scaffold |
| Safe area | `SafeArea` wrapping body hoặc dùng `padding` từ MediaQuery |
| Hero transition | Dùng cho ảnh/element nổi bật khi navigate |
| Dismiss để xóa | `Dismissible` trên danh sách có thể xóa |
| Confirm nguy hiểm | Dialog confirm trước khi xóa/logout |
| Snackbar phản hồi | Mọi action thành công/thất bại đều có feedback |
