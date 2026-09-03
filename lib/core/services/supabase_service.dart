import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://eihdponvoqmctukulfgv.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVpaGRwb252b3FtY3R1a3VsZmd2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgzNzgyNDgsImV4cCI6MjEwMzk1NDI0OH0.tibcObHAseXgf-hEhOgOxj9ltaSEM31ONjwcLxpIJPE';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
    } catch (_) {
      // Gracefully continue offline if network unavailable
    }
  }
}
