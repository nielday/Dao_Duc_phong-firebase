import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation_model.dart';
import '../models/menu_item_model.dart';

class ReservationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'reservations';

  // 1. Đặt Bàn
  Future<void> createReservation(String customerId, DateTime reservationDate, int numberOfGuests, String specialRequests) async {
    final reservation = ReservationModel(
      customerId: customerId,
      reservationDate: reservationDate,
      numberOfGuests: numberOfGuests,
      specialRequests: specialRequests,
      status: 'pending',
    );
    await _db.collection(_collection).add(reservation.toFirestore());
  }

  // 2. Thêm Món vào Đơn
  Future<void> addItemToReservation(String reservationId, String itemId, int quantity) async {
    // Cần dùng Transaction để đảm bảo tính nhất quán khi tính toán
    await _db.runTransaction((transaction) async {
      final reservationRef = _db.collection(_collection).doc(reservationId);
      final itemRef = _db.collection('menu_items').doc(itemId);

      final reservationDoc = await transaction.get(reservationRef);
      final itemDoc = await transaction.get(itemRef);

      if (!reservationDoc.exists || !itemDoc.exists) return;

      final reservation = ReservationModel.fromFirestore(reservationDoc);
      final item = MenuItemModel.fromFirestore(itemDoc);

      if (!item.isAvailable) throw Exception("Món ăn này hiện không phục vụ!");

      // Tạo OrderItem mới
      final newOrderItem = OrderItem(
        itemId: itemId,
        itemName: item.name,
        quantity: quantity,
        price: item.price,
      );

      // Cập nhật list items
      List<OrderItem> currentItems = List.from(reservation.orderItems);
      // Kiểm tra xem món đó đã có chưa để cộng dồn số lượng (Optional, đề không bắt buộc nhưng nên làm)
       int existingIndex = currentItems.indexWhere((i) => i.itemId == itemId);
      if (existingIndex != -1) {
         // Cộng dồn
         final existingItem = currentItems[existingIndex];
         currentItems[existingIndex] = OrderItem(
           itemId: itemId, 
           itemName: item.name, 
           quantity: existingItem.quantity + quantity, 
           price: item.price
         );
      } else {
        currentItems.add(newOrderItem);
      }

      // Tính toán lại
      double subtotal = 0;
      for (var i in currentItems) {
        subtotal += i.price * i.quantity;
      }
      double serviceCharge = subtotal * 0.10;
      double total = subtotal + serviceCharge - reservation.discount;

      transaction.update(reservationRef, {
        'orderItems': currentItems.map((e) => e.toMap()).toList(),
        'subtotal': subtotal,
        'serviceCharge': serviceCharge,
        'total': total,
      });
    });
  }

  // 3. Xác nhận Đặt Bàn
  Future<void> confirmReservation(String reservationId, String tableNumber) async {
    await _db.collection(_collection).doc(reservationId).update({
      'status': 'confirmed',
      'tableNumber': tableNumber,
    });
  }

  // 4. Thanh toán
  Future<void> payReservation(String reservationId, String paymentMethod) async {
    await _db.runTransaction((transaction) async {
      final reservationRef = _db.collection(_collection).doc(reservationId);
      final reservationDoc = await transaction.get(reservationRef);
      final reservation = ReservationModel.fromFirestore(reservationDoc);

      final customerRef = _db.collection('customers').doc(reservation.customerId);
      final customerDoc = await transaction.get(customerRef);
      // Customer có thể null nếu xoá, check an toàn
      
      // Tính loyalty points hiện có của khách
      int currentPoints = 0;
      if (customerDoc.exists) {
        currentPoints = (customerDoc.data() as Map<String, dynamic>)['loyaltyPoints'] ?? 0;
      }

      // Tính discount: 1 point = 1000đ, tối đa 50% total
      double maxDiscount = reservation.total * 0.5;
      double potentialDiscount = currentPoints * 1000.0;
      
      double actualDiscount = potentialDiscount > maxDiscount ? maxDiscount : potentialDiscount;
      int pointsUsed = (actualDiscount / 1000).ceil();

      double finalTotal = reservation.total - actualDiscount;

      // Cộng loyalty points mới (1% total)
      int pointsEarned = (finalTotal * 0.01).floor();

      // Update Reservation
      transaction.update(reservationRef, {
        'paymentMethod': paymentMethod,
        'paymentStatus': 'paid',
        'status': 'completed',
        'discount': actualDiscount,
        'total': finalTotal,
      });

      // Update Customer Points
      if (customerDoc.exists) {
        transaction.update(customerRef, {
          'loyaltyPoints': FieldValue.increment(pointsEarned - pointsUsed),
        });
      }
    });
  }

  // 5. Lấy Đặt Bàn
  Future<List<ReservationModel>> getReservationsByCustomer(String customerId) async {
    final snapshot = await _db.collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('reservationDate', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList();
  }
  
  // Stream cho danh sách của tôi (Realtime)
  Stream<List<ReservationModel>> getReservationsStreamByCustomer(String customerId) {
     return _db.collection(_collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('reservationDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList());
  }
    // Lấy đặt bàn theo ngày (format: "yyyy-MM-dd")
  Future<List<ReservationModel>> getReservationsByDate(String date) async {
    DateTime startOfDay = DateTime.parse(date);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    final snapshot = await _db.collection(_collection)
        .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('reservationDate', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('reservationDate')
        .get();
    return snapshot.docs.map((doc) => ReservationModel.fromFirestore(doc)).toList();
  }
}
