import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';

/// FirebaseService - Class quản lý kết nối Firebase
/// Phần 1.3: Tạo Service Class (3 điểm)
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase Firestore instance
  static FirebaseFirestore? _firestore;

  /// Khởi tạo Firebase với options cho từng platform
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    _firestore = FirebaseFirestore.instance;
    print('✅ Firebase initialized successfully!');
  }

  /// Lấy Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      throw Exception('Firebase chưa được khởi tạo! Hãy gọi FirebaseService.initialize() trước.');
    }
    return _firestore!;
  }

  /// Lấy reference đến một collection
  static CollectionReference<Map<String, dynamic>> collection(String name) {
    return firestore.collection(name);
  }

  /// Collection references cho các bảng chính
  static CollectionReference<Map<String, dynamic>> get customers => collection('customers');
  static CollectionReference<Map<String, dynamic>> get menuItems => collection('menu_items');
  static CollectionReference<Map<String, dynamic>> get reservations => collection('reservations');

  /// Kiểm tra kết nối Firestore
  static Future<bool> checkConnection() async {
    try {
      await firestore.collection('_test_connection').limit(1).get();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Tạo document ID mới
  static String generateId(String collectionName) {
    return firestore.collection(collectionName).doc().id;
  }
}
