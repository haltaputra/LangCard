import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> signUp(String name, String email, String password) async {
    try {
      if (name.trim().isEmpty) return 'Nama pengguna tidak boleh kosong';
      if (email.trim().isEmpty) return 'Email tidak boleh kosong';
      if (password.trim().isEmpty) return 'Password tidak boleh kosong';
      if (password.length < 6) return 'Password minimal 6 karakter';

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);

        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'points': 0,
        });
      }

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          return 'Password terlalu lemah';
        case 'email-already-in-use':
          return 'Email sudah digunakan';
        case 'invalid-email':
          return 'Format email tidak valid';
        default:
          return e.message ?? 'Terjadi kesalahan saat registrasi';
      }
    } catch (e) {
      return 'Terjadi kesalahan yang tidak terduga: $e';
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'Pengguna tidak ditemukan';
        case 'wrong-password':
          return 'Password salah';
        case 'invalid-email':
          return 'Format email tidak valid';
        default:
          return e.message ?? 'Terjadi kesalahan saat login';
      }
    } catch (e) {
      return 'Terjadi kesalahan yang tidak terduga: $e';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print("Error getting user data: $e");
      return null;
    }
  }

  Future<String?> updateProfile(String name, String? photoURL) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        if (photoURL != null) await user.updatePhotoURL(photoURL);

        await _firestore.collection('users').doc(user.uid).update({
          'name': name,
          if (photoURL != null) 'photoURL': photoURL,
        });

        return null;
      }
      return 'Tidak ada pengguna yang login';
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Terjadi kesalahan saat memperbarui profil';
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }
}