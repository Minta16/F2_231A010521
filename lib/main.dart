import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

/// [NC1] MyApp chuyển thành StatefulWidget để giữ ThemeMode (sáng/tối) trong State.
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // [NC1] trạng thái chế độ sáng/tối
  ThemeMode _themeMode = ThemeMode.light;

  // [NC1] hàm đổi sáng <-> tối, sẽ được truyền xuống làm callback
  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  // [NC1] Cùng một màu gốc, chỉ khác brightness -> Flutter sinh bảng màu sáng/tối tương ứng.
  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF0468D7),
        brightness: brightness,
      ),
      inputDecorationTheme:
          const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'F2_231A010521', // TODO: thay bằng MSSV của bạn
      debugShowCheckedModeBanner: false,
      // [NC1] theme sáng, theme tối và chế độ đang dùng
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: _themeMode,
      // [NC1] Truyền trạng thái và callback xuống cho màn hình con
      home: LoginPage(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  // [NC1] LoginPage nhận isDark + onToggleTheme để chuyển tiếp cho HeaderBanner
  const LoginPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _ghiNho = false;
  bool _anMatKhau = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // SingleChildScrollView: tránh lỗi tràn khi bàn phím hiện lên
       child: SingleChildScrollView(
          child: Column(
            children: [
              // [NC1] chuyển tiếp trạng thái và callback cho ảnh bìa
              HeaderBanner(
                isDark: widget.isDark,
                onToggleTheme: widget.onToggleTheme,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                // LayoutBuilder: biết được chiều rộng thực tế để chọn bố cục
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final manHinhRong = constraints.maxWidth >= 700;
                    if (!manHinhRong) {
                      return Column(
                        children: [
                          _buildForm(context),
                          const SizedBox(height: 24),
                          const ProfileCard(),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 3, child: _buildForm(context)),
                        const SizedBox(width: 24),
                        const Expanded(flex: 2, child: ProfileCard()),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Đăng nhập hệ thống',
            style: textTheme.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          'Nhập MSSV và mật khẩu để tiếp tục',
          style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Mã số sinh viên',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          obscureText: _anMatKhau,
          decoration: InputDecoration(
            labelText: 'Mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_anMatKhau ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _anMatKhau = !_anMatKhau),
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: _ghiNho,
              onChanged: (v) => setState(() => _ghiNho = v ?? false),
            ),
            const Text('Ghi nhớ đăng nhập'),
            const Spacer(), // đẩy nút sang phải
            TextButton(onPressed: () {}, child: const Text('Quên mật khẩu?')),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đăng nhập (mô phỏng) thành công')),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text('ĐĂNG NHẬP'),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('hoặc', style: TextStyle(color: scheme.outline)),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.school_outlined),
          label: const Text('Đăng nhập bằng tài khoản trường'),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Chưa có tài khoản?'),
            TextButton(onPressed: () {}, child: const Text('Đăng ký')),
          ],
        ),
      ],
    );
  }
}

/// Ảnh bìa: ảnh nền thật [NC3] + lớp phủ màu + nút đổi sáng/tối [NC1]
/// + avatar chồng lên bằng Stack/Positioned.
class HeaderBanner extends StatelessWidget {
  // [NC1] nhận isDark + onToggleTheme từ LoginPage
  const HeaderBanner({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 196,
      child: Stack(
        children: [
          Container(
            height: 150,
            decoration: BoxDecoration(
              // gradient chỉ hiện ra nếu ảnh nền không tải được
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // [NC3] ảnh nền thật (DecorationImage), phủ thêm một lớp màu
              // chủ đạo bằng colorFilter để chữ vẫn dễ đọc
              image: DecorationImage(
                image: const AssetImage('assets/images/cover.png'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  scheme.primary.withAlpha(150),
                  BlendMode.srcOver,
                ),
              ),
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INT4211 – LẬP TRÌNH DI ĐỘNG',
                  style: TextStyle(
                      color: scheme.onPrimary, fontSize: 12, letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Text(
                  'Cổng thực hành LTDD',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // [NC1] nút chuyển sáng/tối đặt ở góc phải trên của ảnh bìa
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              tooltip: isDark ? 'Chế độ sáng' : 'Chế độ tối',
              color: scheme.onPrimary,
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: onToggleTheme,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: CircleAvatar(
                radius: 46,
                backgroundColor: scheme.surface,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: scheme.primaryContainer,
                  child: Text(
                    'LT',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Thẻ thông tin sinh viên. [NC3] đổ bóng bằng BoxShadow bên ngoài Card.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // [NC3] Container ngoài chỉ để đổ bóng bằng boxShadow
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12), // khớp bo góc mặc định của Card
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withAlpha(70),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        elevation: 0, // [NC3] tắt bóng mặc định, dùng boxShadow ở trên
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                leading: CircleAvatar(child: Text('A')),
                title: Text('Lê Hoàng Thiện Nhân'), // TODO: họ tên của bạn
                subtitle: Text('MSSV: 231A010521'), // TODO: MSSV của bạn
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.class_outlined),
                title: Text('Lớp'),
                subtitle: Text('CNTT – LTDD'), // TODO: lớp của bạn
              ),
              const ListTile(
                leading: Icon(Icons.mail_outline),
                title: Text('Email'),
                subtitle: Text('231A010521@st.vhu.edu.vn'), // TODO: email của bạn
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: const [
                    Expanded(child: _StatBox(label: 'Lab đã nộp', value: '1')),
                    SizedBox(width: 12),
                    Expanded(child: _StatBox(label: 'Điểm TB lab', value: '8.5')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold, color: scheme.primary),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: scheme.outline)),
        ],
      ),
    );
  }
}