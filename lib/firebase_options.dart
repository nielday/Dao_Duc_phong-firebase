import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Cấu hình Firebase cho các platform
/// Được tạo từ google-services.json và Firebase Console
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web Firebase Configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAhFia9e3c1HeZXfFJ6n_g87WeBzs0eGew',
    appId: '1:191495897550:web:18f9902498a352e78f6b9f',
    messagingSenderId: '191495897550',
    projectId: 'restaurant-app---1771020534',
    authDomain: 'restaurant-app---1771020534.firebaseapp.com',
    storageBucket: 'restaurant-app---1771020534.firebasestorage.app',
    measurementId: 'G-C4MP127067',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAH1KHNqCdgisQSEbeJXi8iq5loYl9sl9I',
    appId: '1:191495897550:android:1b793397e1e641e88f6b9f',
    messagingSenderId: '191495897550',
    projectId: 'restaurant-app---1771020534',
    storageBucket: 'restaurant-app---1771020534.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAH1KHNqCdgisQSEbeJXi8iq5loYl9sl9I',
    appId: '1:191495897550:ios:XXXXXXXXXXXXXXXX', // ⚠️ Cần lấy iOS App ID nếu có
    messagingSenderId: '191495897550',
    projectId: 'restaurant-app---1771020534',
    storageBucket: 'restaurant-app---1771020534.firebasestorage.app',
    iosBundleId: 'com.example.flutterApp1771020534',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAH1KHNqCdgisQSEbeJXi8iq5loYl9sl9I',
    appId: '1:191495897550:ios:XXXXXXXXXXXXXXXX',
    messagingSenderId: '191495897550',
    projectId: 'restaurant-app---1771020534',
    storageBucket: 'restaurant-app---1771020534.firebasestorage.app',
    iosBundleId: 'com.example.flutterApp1771020534',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAH1KHNqCdgisQSEbeJXi8iq5loYl9sl9I',
    appId: '1:191495897550:android:1b793397e1e641e88f6b9f', // Dùng Android App ID
    messagingSenderId: '191495897550',
    projectId: 'restaurant-app---1771020534',
    storageBucket: 'restaurant-app---1771020534.firebasestorage.app',
  );
}
