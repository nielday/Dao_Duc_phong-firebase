import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuItemRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'menu_items';

  // 1. Thêm MenuItem
  Future<void> addMenuItem(MenuItemModel item) async {
    await _db.collection(_collection).add(item.toFirestore());
  }

  // 2. Lấy MenuItem theo ID
  Future<MenuItemModel?> getMenuItemById(String itemId) async {
    final doc = await _db.collection(_collection).doc(itemId).get();
    if (doc.exists) {
      return MenuItemModel.fromFirestore(doc);
    }
    return null;
  }

  // 3. Lấy tất cả MenuItems (Stream cho Realtime Updates)
  Stream<List<MenuItemModel>> getMenuItemsStream() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    });
  }

  // 4. Tìm kiếm MenuItems (Tìm trong name, description, ingredients)
  // Firestore không hỗ trợ full-text search mạnh mẽ, ta dùng where hoặc filter phía client cho đơn giản nếu list ít.
  // Ở đây demo search đơn giản theo name.
  Future<List<MenuItemModel>> searchMenuItems(String query) async {
    // Cách 1: Client side filter (đơn giản, hiệu quả với list nhỏ < vài ngàn)
    final snapshot = await _db.collection(_collection).get();
    final allItems = snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    
    return allItems.where((item) {
      final q = query.toLowerCase();
      return item.name.toLowerCase().contains(q) ||
             item.description.toLowerCase().contains(q) ||
             item.ingredients.any((ing) => ing.toLowerCase().contains(q));
    }).toList();
  }

  // 5. Lọc MenuItems
  Stream<List<MenuItemModel>> filterMenuItems({
    String? category,
    bool? isVegetarian,
    bool? isSpicy,
  }) {
    Query query = _db.collection(_collection);

    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (isVegetarian == true) {
      query = query.where('isVegetarian', isEqualTo: true);
    }
    if (isSpicy == true) {
      query = query.where('isSpicy', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MenuItemModel.fromFirestore(doc)).toList();
    });
  }
}
