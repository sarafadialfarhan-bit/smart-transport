import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'role': data['role'] ?? 'user', // Default role
      'walletBalance': 0.0,
      'status': 'active',
    });
  }

  Future<void> createCompanyProfile(String uid, {
    required String email,
    required String nameAr,
    required String nameEn,
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'companyNameAr': nameAr,
      'companyNameEn': nameEn,
      'name': nameEn, // Fallback name
      'role': 'company',
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot> getUserProfile(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Future<String?> getUserRole(String uid) async {
    DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return (doc.data() as Map<String, dynamic>)['role'];
    }
    return null;
  }
}
