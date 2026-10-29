class SupabaseConfig {
    static const String supabaseUrl =
    'https://ooeomxdryypxjjymmama.supabase.co/rest/v1/';

    static String get normalizedUrl =>
        supabaseUrl.replaceAll(RegExp(r'/rest/v1/?$'), '');

    static const String supabaseAnonKey =
    'sb_publishable_qVYSPh018QZB4pohL92pdQ__WxE8G00';
}
