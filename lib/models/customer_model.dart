import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String? customerId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final List<String> preferences;
  final int loyaltyPoints;
  final DateTime? createdAt;
  final bool isActive;

  CustomerModel({
    this.customerId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    this.preferences = const [],
    this.loyaltyPoints = 0,
    this.createdAt,
    this.isActive = true,
  });

  // Convert from Firestore DocumentSnapshot to CustomerModel
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      customerId: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      preferences: List<String>.from(data['preferences'] ?? []),
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Convert from CustomerModel to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'preferences': preferences,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'isActive': isActive,
    };
  }

  CustomerModel copyWith({
    String? customerId,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? address,
    List<String>? preferences,
    int? loyaltyPoints,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return CustomerModel(
      customerId: customerId ?? this.customerId,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
