import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Sign in
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign up
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  // حفظ بيانات المستخدم في جدول user
  Future<void> saveUserData({
    required String userId,
    required String firstName,
    required String lastName,
    required int age,
    required String gender,
    required String email,
  }) async {
    await _supabase.from('user').insert({
      'id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'gender': gender,
      'email': email,
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // Get current user ID
  String? getCurrentUserId() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }

  // Get user data from Supabase by user ID
  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    final response = await _supabase
        .from('user')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }
}
