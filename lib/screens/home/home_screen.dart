import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/menu_item_repository.dart';
import '../../widgets/common_widgets.dart'; // Import common_widgets
import '../reservation/my_reservations_screen.dart';
import '../reservation/create_reservation_screen.dart';
import 'menu_item_detail_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String customerId;
  const HomeScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuItemRepository _repo = MenuItemRepository();
  
  // Filters
  String? _selectedCategory;
  bool _isVegetarian = false;
  bool _isSpicy = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = "";

  final List<String> _categories = ["Appetizer", "Main Course", "Dessert", "Beverage", "Soup"];
  // Removed local map, using global translateCategory

  void _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => LoginScreen()),
      (route) => false,
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepOrange,
        title: Row(
          children: [
            Icon(Icons.restaurant_menu, color: Colors.white),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Restaurant App',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '1771020534',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long, color: Colors.white),
            tooltip: 'Đơn của tôi',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => MyReservationsScreen(customerId: widget.customerId)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            tooltip: 'Đăng xuất',
            onPressed: () => _logout(context),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CreateReservationScreen(customerId: widget.customerId)),
          );
        },
        backgroundColor: Colors.deepOrange,
        icon: Icon(Icons.table_restaurant),
        label: Text('Đặt Bàn', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm món ăn...',
                    prefixIcon: Icon(Icons.search, color: Colors.deepOrange),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
                SizedBox(height: 12),
                
                // Category chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // All category chip
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Tất cả'),
                          selected: _selectedCategory == null,
                          selectedColor: Colors.deepOrange.shade100,
                          labelStyle: TextStyle(
                            color: _selectedCategory == null ? Colors.deepOrange : Colors.grey.shade700,
                            fontWeight: _selectedCategory == null ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (v) => setState(() => _selectedCategory = null),
                        ),
                      ),
                      // Category chips
                      ..._categories.map((cat) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(translateCategory(cat)),
                          selected: _selectedCategory == cat,
                          selectedColor: Colors.deepOrange.shade100,
                          labelStyle: TextStyle(
                            color: _selectedCategory == cat ? Colors.deepOrange : Colors.grey.shade700,
                            fontWeight: _selectedCategory == cat ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (v) => setState(() => _selectedCategory = v ? cat : null),
                        ),
                      )).toList(),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                
                // Filter chips
                Row(
                  children: [
                    FilterChip(
                      avatar: Icon(Icons.eco, size: 18, color: _isVegetarian ? Colors.green : Colors.grey),
                      label: Text('Món chay'),
                      selected: _isVegetarian,
                      selectedColor: Colors.green.shade100,
                      checkmarkColor: Colors.green,
                      onSelected: (v) => setState(() => _isVegetarian = v),
                    ),
                    SizedBox(width: 8),
                    FilterChip(
                      avatar: Icon(Icons.local_fire_department, size: 18, color: _isSpicy ? Colors.red : Colors.grey),
                      label: Text('Món cay'),
                      selected: _isSpicy,
                      selectedColor: Colors.red.shade100,
                      checkmarkColor: Colors.red,
                      onSelected: (v) => setState(() => _isSpicy = v),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Menu List
          Expanded(
            child: StreamBuilder<List<MenuItemModel>>(
              stream: _repo.filterMenuItems(
                category: _selectedCategory,
                isVegetarian: _isVegetarian,
                isSpicy: _isSpicy,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        SizedBox(height: 16),
                        Text('Lỗi: ${snapshot.error}', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.deepOrange),
                        SizedBox(height: 16),
                        Text('Đang tải menu...', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                var items = snapshot.data ?? [];

                // Filter search query client-side
                if (_searchQuery.isNotEmpty) {
                  items = items.where((i) => 
                    i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    i.description.toLowerCase().contains(_searchQuery.toLowerCase())
                  ).toList();
                }

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_food, size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text('Không tìm thấy món nào', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildMenuCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(MenuItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MenuItemDetailScreen(item: item)),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            color: Colors.grey.shade200,
                            child: Icon(Icons.restaurant, size: 40, color: Colors.grey),
                          ),
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(Icons.restaurant, size: 40, color: Colors.grey),
                        ),
                  
                  // Unavailable badge
                  if (!item.isAvailable)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'HẾT MÓN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  // Vegetarian/Spicy icons
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Row(
                      children: [
                        if (item.isVegetarian)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.eco, color: Colors.white, size: 14),
                          ),
                        if (item.isVegetarian && item.isSpicy) SizedBox(width: 4),
                        if (item.isSpicy)
                          Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.local_fire_department, color: Colors.white, size: 14),
                          ),
                      ],
                    ),
                  ),
                  
                  // Rating
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.white, size: 12),
                          SizedBox(width: 2),
                          Text(
                            item.rating.toStringAsFixed(1),
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      translateCategory(item.category),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                    Spacer(),
                    Text(
                      '${_formatPrice(item.price)}đ',
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
