import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String itemId;
  final String itemName;
  final int quantity;
  final double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map['itemId'] ?? '',
      itemName: map['itemName'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}

class ReservationModel {
  final String? reservationId;
  final String customerId;
  final DateTime reservationDate;
  final int numberOfGuests;
  final String? tableNumber;
  final String status; // "pending", "confirmed", "seated", "completed", "cancelled"
  final String? specialRequests;
  final List<OrderItem> orderItems;
  final double subtotal;
  final double serviceCharge;
  final double discount;
  final double total;
  final String? paymentMethod;
  final String paymentStatus; // "pending", "paid", "refunded"
  final DateTime? createdAt;

  ReservationModel({
    this.reservationId,
    required this.customerId,
    required this.reservationDate,
    required this.numberOfGuests,
    this.tableNumber,
    this.status = 'pending',
    this.specialRequests,
    this.orderItems = const [],
    this.subtotal = 0.0,
    this.serviceCharge = 0.0,
    this.discount = 0.0,
    this.total = 0.0,
    this.paymentMethod,
    this.paymentStatus = 'pending',
    this.createdAt,
  });

  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ReservationModel(
      reservationId: doc.id,
      customerId: data['customerId'] ?? '',
      reservationDate: (data['reservationDate'] as Timestamp).toDate(),
      numberOfGuests: data['numberOfGuests'] ?? 0,
      tableNumber: data['tableNumber'],
      status: data['status'] ?? 'pending',
      specialRequests: data['specialRequests'],
      orderItems: (data['orderItems'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      serviceCharge: (data['serviceCharge'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      paymentMethod: data['paymentMethod'],
      paymentStatus: data['paymentStatus'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'customerId': customerId,
      'reservationDate': Timestamp.fromDate(reservationDate),
      'numberOfGuests': numberOfGuests,
      'tableNumber': tableNumber,
      'status': status,
      'specialRequests': specialRequests,
      'orderItems': orderItems.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'serviceCharge': serviceCharge,
      'discount': discount,
      'total': total,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
    };
  }
}
