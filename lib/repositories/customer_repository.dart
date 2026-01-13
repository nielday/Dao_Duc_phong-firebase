import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'customers';

  // 1. Thêm Customer
  Future<void> addCustomer(CustomerModel customer) async {
    // Nếu customerId đã có, dùng set(), nếu chưa thì add() hoặc dùng doc().set()
    if (customer.customerId != null && customer.customerId!.isNotEmpty) {
      await _db.collection(_collection).doc(customer.customerId).set(customer.toFirestore());
    } else {
      await _db.collection(_collection).add(customer.toFirestore());
    }
  }

  // 2. Lấy Customer theo ID
  Future<CustomerModel?> getCustomerById(String customerId) async {
    final doc = await _db.collection(_collection).doc(customerId).get();
    if (doc.exists) {
      return CustomerModel.fromFirestore(doc);
    }
    return null;
  }

  // 3. Lấy tất cả Customers
  Future<List<CustomerModel>> getAllCustomers() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
  }

  // 4. Cập nhật Customer
  Future<void> updateCustomer(CustomerModel customer) async {
    if (customer.customerId == null) return;
    await _db.collection(_collection).doc(customer.customerId).update(customer.toFirestore());
  }

  // 5. Cập nhật Loyalty Points
  Future<void> updateLoyaltyPoints(String customerId, int points) async {
    await _db.collection(_collection).doc(customerId).update({
      'loyaltyPoints': FieldValue.increment(points),
    });
  }
}
