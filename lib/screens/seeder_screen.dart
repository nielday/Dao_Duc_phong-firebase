import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../models/menu_item_model.dart';
import '../models/reservation_model.dart';

class SeederScreen extends StatefulWidget {
  @override
  _SeederScreenState createState() => _SeederScreenState();
}

class _SeederScreenState extends State<SeederScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String _status = "Chờ thực hiện...";
  bool _isLoading = false;

  void _runSeeder() async {
    setState(() {
      _isLoading = true;
      _status = "Đang tạo dữ liệu mẫu...";
    });

    try {
      // 1. Create Customers
      for (int i = 1; i <= 5; i++) {
        await _db.collection('customers').add({
          'email': 'customer$i@example.com',
          'fullName': 'Khách Hàng $i',
          'phoneNumber': '090000000$i',
          'address': 'Địa chỉ $i',
          'preferences': ['vegetarian', 'spicy'],
          'loyaltyPoints': i * 10,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
      }
      _status += "\n- Đã tạo 5 Khách hàng.";

      // 2. Create Menu Items
      List<String> categories = ["Appetizer", "Main Course", "Dessert", "Beverage", "Soup"];
      for (int i = 1; i <= 20; i++) {
        await _db.collection('menu_items').add({
          'name': 'Món $i',
          'description': 'Mô tả ngon lành cho món $i',
          'category': categories[i % categories.length],
          'price': (i * 10000).toDouble(),
          'imageUrl': 'https://via.placeholder.com/150', // Placeholder image
          'ingredients': ['Nguyên liệu A', 'Nguyên liệu B'],
          'isVegetarian': i % 3 == 0,
          'isSpicy': i % 4 == 0,
          'preparationTime': 10 + i,
          'isAvailable': true,
          'rating': 4.5,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      _status += "\n- Đã tạo 20 Món ăn.";

      // 3. Create Reservations (Requires valid customer IDs, for simplicity we just create dummy ones or you need to fetch real ones)
      // Here we will just create 10 reservations linking to 'customer1@example.com' if existing, or just random strings if strict FK not enforced in code.
      // Better to query first.
      var cusSnapshot = await _db.collection('customers').limit(1).get();
      if(cusSnapshot.docs.isNotEmpty) {
          String cusId = cusSnapshot.docs.first.id;
          for(int i=1; i<=10; i++) {
               await _db.collection('reservations').add({
                'customerId': cusId,
                'reservationDate': Timestamp.now(),
                'numberOfGuests': 4,
                'status': i % 2 == 0 ? 'pending' : 'confirmed',
                'orderItems': [],
                'subtotal': 0,
                'serviceCharge': 0,
                'discount': 0,
                'total': 0,
                'paymentStatus': 'pending',
                'createdAt': FieldValue.serverTimestamp(),
              });
          }
          _status += "\n- Đã tạo 10 Đơn đặt bàn cho khách hàng đầu tiên.";
      } else {
         _status += "\n! Không tìm thấy Khách hàng để tạo Đơn đặt bàn.";
      }

      setState(() {
        _status += "\n=> HOÀN TẤT!";
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _status += "\nLỖI: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Data Seeder")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(_isLoading) CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(_status, textAlign: TextAlign.center),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _runSeeder,
              child: Text("Tạo Dữ Liệu Mẫu (Chỉ chạy 1 lần)"),
            ),
             SizedBox(height: 20),
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Đóng"))
          ],
        ),
      ),
    );
  }
}
