# Panduan Sistem Autentikasi - MikroTik DHCP Monitor

## Gambaran Umum

Sistem autentikasi ini dibangun untuk aplikasi monitoring jaringan DHCP dengan MikroTik menggunakan Flutter dan REST API dari `https://apimikrotik.makelen.web.id/`.

## Fitur Utama

### ✅ **Komponen yang Sudah Diimplementasi**

1. **Model Data**

   - `User` - Model untuk data pengguna
   - `AuthResponse` - Response dari API login/register
   - `UserInfoResponse` - Response dari API user info

2. **Services**

   - `ApiService` - HTTP client untuk komunikasi dengan API
   - `AuthService` - Service untuk mengelola autentikasi

3. **State Management**

   - `AuthProvider` - Provider untuk mengelola state autentikasi
   - States: initial, loading, authenticated, unauthenticated, error

4. **Secure Storage**

   - Token dan data user disimpan dengan `flutter_secure_storage`
   - Enkripsi otomatis pada Android dan iOS

5. **UI Components**

   - `LoginScreen` - Halaman login dengan validasi
   - `RegisterScreen` - Halaman registrasi
   - `DashboardScreen` - Dashboard setelah login
   - `CustomTextField` & `CustomButton` - Komponen UI reusable

6. **Navigation & Route Guards**
   - Menggunakan `go_router` untuk navigation
   - Route protection otomatis berdasarkan status autentikasi
   - Auto-redirect ke login/dashboard

## API Endpoints yang Digunakan

### 🔐 **Login**

```
POST /api/auth/login
Body: { "email": "string", "password": "string" }
```

### 📝 **Register**

```
POST /api/auth/register
Body: { "name": "string", "email": "string", "password": "string" }
```

### 👤 **User Info**

```
GET /api/auth/me
Headers: { "Authorization": "Bearer <token>" }
```

### 🚪 **Logout**

```
POST /api/auth/logout
Headers: { "Authorization": "Bearer <token>" }
```

## Struktur Folder

```
lib/
├── models/
│   ├── user.dart
│   ├── auth_response.dart
│   └── *.g.dart (generated files)
├── services/
│   ├── api_service.dart
│   └── auth_service.dart
├── providers/
│   └── auth_provider.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── dashboard_screen.dart
├── widgets/
│   ├── custom_text_field.dart
│   └── custom_button.dart
├── utils/
│   ├── constants.dart
│   └── app_router.dart
└── main.dart
```

## Cara Penggunaan

### 1. **Inisialisasi**

```dart
// Di main.dart, AuthProvider otomatis menginisialisasi status auth
if (authProvider.state == AuthState.initial) {
  authProvider.initializeAuth();
}
```

### 2. **Login**

```dart
final success = await authProvider.login(
  email: 'user@example.com',
  password: 'password123',
);
```

### 3. **Register**

```dart
final success = await authProvider.register(
  name: 'John Doe',
  email: 'john@example.com',
  password: 'password123',
);
```

### 4. **Logout**

```dart
await authProvider.logout();
```

### 5. **Cek Status Auth**

```dart
if (authProvider.isAuthenticated) {
  // User sudah login
}
```

## Security Features

### 🔒 **Token Storage**

- Token disimpan dengan `flutter_secure_storage`
- Enkripsi hardware-backed di Android
- Keychain storage di iOS
- Automatic cleanup saat logout

### 🛡️ **Route Protection**

- Auto-redirect ke login jika belum authenticated
- Auto-redirect ke dashboard jika sudah authenticated
- Loading state selama pengecekan auth

### 🔐 **API Security**

- Bearer token authentication
- Automatic token attachment untuk protected endpoints
- Error handling untuk expired tokens

## Error Handling

### ⚠️ **Network Errors**

```dart
try {
  await authProvider.login(email, password);
} catch (e) {
  // Error message tersedia di authProvider.errorMessage
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authProvider.errorMessage ?? 'Error')),
  );
}
```

### 📱 **UI States**

- Loading indicators saat proses auth
- Error messages yang user-friendly
- Form validation real-time

## Customization

### 🎨 **Tema**

Aplikasi menggunakan Material 3 dengan tema biru. Dapat diubah di `main.dart`:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue, // Ubah warna utama
  ),
)
```

### 🌐 **API Configuration**

Base URL dan endpoints dapat diubah di `lib/utils/constants.dart`:

```dart
class ApiConstants {
  static const String baseUrl = 'https://apimikrotik.makelen.web.id';
  // ... endpoints lainnya
}
```

## Testing

### 🧪 **Manual Testing**

1. Jalankan aplikasi: `flutter run`
2. Test registrasi user baru
3. Test login dengan kredensial yang benar/salah
4. Test navigation antar screens
5. Test logout functionality

### 📊 **Debug Info**

- Auth state dapat dimonitor melalui `AuthProvider`
- Network requests dapat dilihat di debug console
- Secure storage dapat dicek dengan debug tools

## Troubleshooting

### ❌ **Common Issues**

1. **"Token tidak ditemukan"**

   - Pastikan user sudah login
   - Cek apakah token tersimpan dengan benar

2. **"Kesalahan jaringan"**

   - Cek koneksi internet
   - Pastikan API server berjalan
   - Verify base URL di constants

3. **"Build errors"**
   - Jalankan `flutter pub get`
   - Jalankan `dart run build_runner build`

### 🔧 **Reset Auth State**

```dart
await AuthService.clearAuthData();
authProvider.initializeAuth();
```

## Next Steps

Sistem autentikasi sudah lengkap dan siap digunakan. Selanjutnya Anda dapat:

1. Mengintegrasikan dengan API DHCP monitoring
2. Menambahkan fitur room management
3. Implementasi real-time monitoring
4. Menambahkan push notifications
5. Mengembangkan fitur admin panel

## Dependencies

```yaml
dependencies:
  http: ^1.1.0
  provider: ^6.1.1
  flutter_secure_storage: ^9.0.0
  json_annotation: ^4.9.0
  go_router: ^12.1.3

dev_dependencies:
  json_serializable: ^6.7.1
  build_runner: ^2.4.7
```

---

**Sistem autentikasi siap digunakan! 🚀**

Untuk pertanyaan lebih lanjut atau pengembangan fitur tambahan, silakan hubungi developer.
