class ApiConstants {
  static const String baseUrl = 'https://apimikrotik.makelen.web.id';
  static const String loginEndpoint = '/api/auth/login';
  static const String registerEndpoint = '/api/auth/register';
  static const String userInfoEndpoint = '/api/auth/me';
  static const String logoutEndpoint = '/api/auth/logout';
  
  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String userDataKey = 'user_data';
}

class AppStrings {
  static const String appTitle = 'MikroTik DHCP Monitor';
  static const String loginTitle = 'Masuk';
  static const String registerTitle = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String name = 'Nama';
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String logout = 'Keluar';
  static const String dontHaveAccount = 'Belum punya akun?';
  static const String alreadyHaveAccount = 'Sudah punya akun?';
  static const String loginSuccess = 'Berhasil masuk';
  static const String registerSuccess = 'Berhasil mendaftar';
  static const String logoutSuccess = 'Berhasil keluar';
  static const String loginError = 'Gagal masuk';
  static const String registerError = 'Gagal mendaftar';
  static const String networkError = 'Kesalahan jaringan';
  static const String unknownError = 'Terjadi kesalahan';
}