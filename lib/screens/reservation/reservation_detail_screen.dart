import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reservation_model.dart';
import '../../models/menu_item_model.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/menu_item_repository.dart';

class ReservationDetailScreen extends StatefulWidget {
  final ReservationModel reservation;
  const ReservationDetailScreen({Key? key, required this.reservation}) : super(key: key);

  @override
  _ReservationDetailScreenState createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> {
  final ReservationRepository _resRepo = ReservationRepository();
  final MenuItemRepository _menuRepo = MenuItemRepository();

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'seated': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Chờ xác nhận';
      case 'confirmed': return 'Đã xác nhận';
      case 'seated': return 'Đang phục vụ';
      case 'completed': return 'Hoàn thành';
      case 'cancelled': return 'Đã hủy';
      default: return status;
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
  
  void _showAddItemDialog() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restaurant_menu, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        'Chọn món để thêm',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<MenuItemModel>>(
                    stream: _menuRepo.getMenuItemsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator(color: Colors.deepOrange));
                      }
                      final items = snapshot.data!.where((i) => i.isAvailable).toList();
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(item.imageUrl, fit: BoxFit.cover)
                                    : Container(color: Colors.grey.shade200, child: Icon(Icons.restaurant)),
                              ),
                            ),
                            title: Text(item.name, style: TextStyle(fontWeight: FontWeight.w600)),
                            subtitle: Text('${_formatPrice(item.price)}đ'),
                            trailing: Icon(Icons.add_circle, color: Colors.deepOrange),
                            onTap: () {
                              Navigator.pop(context);
                              _addItemToReservation(item);
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addItemToReservation(MenuItemModel item) async {
    if (widget.reservation.reservationId == null) return;
    
    int quantity = 1;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Số lượng"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, size: 32),
                  onPressed: () {},
                ),
                SizedBox(width: 16),
                Text('1', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, size: 32),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
            child: Text('Thêm'),
          ),
        ],
      )
    );

    try {
      await _resRepo.addItemToReservation(widget.reservation.reservationId!, item.itemId!, quantity);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm ${item.name}!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _pay() async {
    if (widget.reservation.reservationId == null) return;
    
    // Show payment method dialog
    String? method = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Chọn phương thức thanh toán'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.money, color: Colors.green),
              title: Text('Tiền mặt'),
              onTap: () => Navigator.pop(ctx, 'cash'),
            ),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.blue),
              title: Text('Thẻ'),
              onTap: () => Navigator.pop(ctx, 'card'),
            ),
            ListTile(
              leading: Icon(Icons.phone_android, color: Colors.purple),
              title: Text('Chuyển khoản'),
              onTap: () => Navigator.pop(ctx, 'online'),
            ),
          ],
        ),
      ),
    );
    
    if (method == null) return;
    
    try {
      await _resRepo.payReservation(widget.reservation.reservationId!, method);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Thanh toán thành công!'), backgroundColor: Colors.green),
      );
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('reservations').doc(widget.reservation.reservationId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.deepOrange),
            body: Center(child: CircularProgressIndicator(color: Colors.deepOrange)),
          );
        }
        
        final updatedRes = ReservationModel.fromFirestore(snapshot.data!);
        final statusColor = _getStatusColor(updatedRes.status);

        return Scaffold(
          backgroundColor: Colors.grey.shade100,
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            title: Text('Chi tiết đơn'),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: statusColor, size: 12),
                            SizedBox(width: 8),
                            Text(
                              _getStatusText(updatedRes.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildHeaderInfo(Icons.calendar_today, DateFormat('dd/MM/yyyy').format(updatedRes.reservationDate)),
                          _buildHeaderInfo(Icons.access_time, DateFormat('HH:mm').format(updatedRes.reservationDate)),
                          _buildHeaderInfo(Icons.people, '${updatedRes.numberOfGuests} khách'),
                          if (updatedRes.tableNumber != null)
                            _buildHeaderInfo(Icons.table_bar, 'Bàn ${updatedRes.tableNumber}'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),

                // Special Request Section
                if (updatedRes.specialRequests != null && updatedRes.specialRequests!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.note_alt, color: Colors.deepOrange),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Yêu cầu đặc biệt:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    updatedRes.specialRequests!,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                
                SizedBox(height: 16),
                
                // Order items section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: Colors.deepOrange),
                              SizedBox(width: 12),
                              Text(
                                'Danh sách món',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              if (updatedRes.status != 'completed' && updatedRes.status != 'cancelled')
                                TextButton.icon(
                                  onPressed: _showAddItemDialog,
                                  icon: Icon(Icons.add, color: Colors.deepOrange),
                                  label: Text('Thêm', style: TextStyle(color: Colors.deepOrange)),
                                ),
                            ],
                          ),
                        ),
                        Divider(height: 1),
                        if (updatedRes.orderItems.isEmpty)
                          Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              children: [
                                Icon(Icons.no_food, size: 48, color: Colors.grey.shade400),
                                SizedBox(height: 8),
                                Text('Chưa có món nào', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: updatedRes.orderItems.length,
                            separatorBuilder: (_, __) => Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = updatedRes.orderItems[index];
                              return ListTile(
                                title: Text(item.itemName, style: TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: Text('${_formatPrice(item.price)}đ x ${item.quantity}'),
                                trailing: Text(
                                  '${_formatPrice(item.price * item.quantity)}đ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Summary section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryRow('Tạm tính', '${_formatPrice(updatedRes.subtotal)}đ'),
                          SizedBox(height: 8),
                          _buildSummaryRow('Phí dịch vụ (10%)', '${_formatPrice(updatedRes.serviceCharge)}đ'),
                          if (updatedRes.discount > 0) ...[
                            SizedBox(height: 8),
                            _buildSummaryRow('Giảm giá', '-${_formatPrice(updatedRes.discount)}đ', isDiscount: true),
                          ],
                          SizedBox(height: 12),
                          Divider(),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                '${_formatPrice(updatedRes.total)}đ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: 24),
                
                // Payment button
                if (updatedRes.status == 'seated' && updatedRes.paymentStatus != 'paid')
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _pay,
                        icon: Icon(Icons.payment),
                        label: Text('THANH TOÁN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                
                if (updatedRes.paymentStatus == 'paid')
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'ĐÃ THANH TOÁN',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }
}
