import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // تسجيل الدخول
  Future<AuthResponse> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // إنشاء حساب (بدون تحقق من البريد الإلكتروني)
  Future<AuthResponse> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: null, // تعطيل التحقق من البريد الإلكتروني
    );
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
    await supabase.from('user').insert({
      'id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'gender': gender,
      'email': email,
    });
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // الحصول على البريد الحالي
  String? getCurrentUserEmail() {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  // الحصول على ID المستخدم الحالي
  String? getCurrentUserId() {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }

  // جلب بيانات المستخدم من جدول user
  Future<Map<String, dynamic>?> getUserDataById(String userId) async {
    final response = await supabase
        .from('user')
        .select()
        .eq('id', userId)
        .maybeSingle();

    return response;
  }

  // التحقق إذا المستخدم أنهى اختبار PHQ-9
  Future<bool> hasCompletedPhq9(String userId) async {
    final response = await supabase
        .from('users')
        .select('phq9_score')
        .eq('id', userId)
        .maybeSingle();

    // إذا المستخدم غير موجود أو النتيجة غير موجودة
    if (response == null || response['phq9_score'] == null) {
      return false;
    }

    final score = response['phq9_score'] as int;
    return score > 0;
  }

  Future<void> savePhq9Score(String userId, int score) async {
    final response = await supabase
        .from('users')
        .update({'phq9_score': score})
        .eq('id', userId);

    if (response.error != null) {
      print('خطأ في تحديث النتيجة: ${response.error!.message}');
    } else {
      print('تم حفظ النتيجة بنجاح ✅');
    }
  }
}
