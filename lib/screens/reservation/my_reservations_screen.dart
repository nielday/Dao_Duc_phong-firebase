import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../repositories/reservation_repository.dart';
import 'reservation_detail_screen.dart';

class MyReservationsScreen extends StatelessWidget {
  final String customerId;
  const MyReservationsScreen({Key? key, required this.customerId}) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'seated': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'no_show': return Colors.grey;
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
      case 'no_show': return 'Không đến';
      default: return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending': return Icons.pending_outlined;
      case 'confirmed': return Icons.check_circle_outline;
      case 'seated': return Icons.restaurant;
      case 'completed': return Icons.done_all;
      case 'cancelled': return Icons.cancel_outlined;
      case 'no_show': return Icons.person_off_outlined;
      default: return Icons.info_outline;
    }
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final repo = ReservationRepository();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Đơn đặt bàn của tôi'),
        elevation: 0,
      ),
      body: StreamBuilder<List<ReservationModel>>(
        stream: repo.getReservationsStreamByCustomer(customerId),
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
                  Text('Đang tải...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final list = snapshot.data ?? [];
          
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'Chưa có đơn đặt bàn nào',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Hãy đặt bàn để trải nghiệm nhà hàng!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildReservationCard(context, item);
            },
          );
        },
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, ReservationModel item) {
    final statusColor = _getStatusColor(item.status);
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ReservationDetailScreen(reservation: item)),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_getStatusIcon(item.status), color: statusColor, size: 24),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE, dd/MM/yyyy', 'vi').format(item.reservationDate),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          DateFormat('HH:mm').format(item.reservationDate),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(item.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              Divider(height: 1),
              SizedBox(height: 12),
              
              // Info row
              Row(
                children: [
                  _buildInfoChip(Icons.people_outline, '${item.numberOfGuests} khách'),
                  SizedBox(width: 12),
                  if (item.tableNumber != null)
                    _buildInfoChip(Icons.table_bar, 'Bàn ${item.tableNumber}'),
                  Spacer(),
                  Text(
                    '${_formatPrice(item.total)}đ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              
              // Order items preview
              if (item.orderItems.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  '${item.orderItems.length} món: ${item.orderItems.take(2).map((e) => e.itemName).join(", ")}${item.orderItems.length > 2 ? "..." : ""}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Special request preview
              if (item.specialRequests != null && item.specialRequests!.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.note, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Ghi chú: ${item.specialRequests}',
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
