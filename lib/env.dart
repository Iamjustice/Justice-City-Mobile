/// Build-time environment configuration.
///
/// Prefer passing values with `--dart-define`.
///
/// Example:
/// flutter run --dart-define=SUPABASE_URL="..." --dart-define=SUPABASE_ANON_KEY="..." --dart-define=API_BASE_URL="https://justicecityltd.com"
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://justicecityltd.com');

  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError('Missing SUPABASE_URL or SUPABASE_ANON_KEY. Provide them via --dart-define.');
    }
  }
}
