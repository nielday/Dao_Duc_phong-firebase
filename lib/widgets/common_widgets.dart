import 'package:flutter/material.dart';

String translateCategory(String category) {
  final Map<String, String> labels = {
    "Appetizer": "🥗 Khai vị",
    "Main Course": "🍝 Món chính",
    "Dessert": "🍰 Tráng miệng",
    "Beverage": "🥤 Đồ uống",
    "Soup": "🍲 Súp",
  };
  return labels[category] ?? category;
}

/// Badge "Hết món" - Hiển thị khi món ăn không còn phục vụ
class UnavailableBadge extends StatelessWidget {
  const UnavailableBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'HẾT MÓN',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Icon hiển thị món chay
class VegetarianIcon extends StatelessWidget {
  final double size;
  const VegetarianIcon({Key? key, this.size = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Món chay',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.eco,
          color: Colors.green.shade700,
          size: size,
        ),
      ),
    );
  }
}

/// Icon hiển thị món cay
class SpicyIcon extends StatelessWidget {
  final double size;
  const SpicyIcon({Key? key, this.size = 20}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Món cay',
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.local_fire_department,
          color: Colors.red.shade700,
          size: size,
        ),
      ),
    );
  }
}

/// Widget hiển thị rating với sao
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 16,
    this.color = Colors.amber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star, color: color, size: size),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

/// Badge hiển thị trạng thái đặt bàn với màu sắc tương ứng
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  Color _getBackgroundColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'confirmed':
        return Colors.blue.shade100;
      case 'seated':
        return Colors.purple.shade100;
      case 'completed':
        return Colors.green.shade100;
      case 'cancelled':
        return Colors.red.shade100;
      case 'no_show':
        return Colors.grey.shade300;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'confirmed':
        return Colors.blue.shade800;
      case 'seated':
        return Colors.purple.shade800;
      case 'completed':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      case 'no_show':
        return Colors.grey.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getDisplayText() {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'seated':
        return 'Đang phục vụ';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      case 'no_show':
        return 'Không đến';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _getDisplayText(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Badge hiển thị trạng thái thanh toán
class PaymentStatusBadge extends StatelessWidget {
  final String paymentStatus;

  const PaymentStatusBadge({Key? key, required this.paymentStatus}) : super(key: key);

  Color _getBackgroundColor() {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade100;
      case 'paid':
        return Colors.green.shade100;
      case 'refunded':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getTextColor() {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return Colors.orange.shade800;
      case 'paid':
        return Colors.green.shade800;
      case 'refunded':
        return Colors.blue.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getDisplayText() {
    switch (paymentStatus.toLowerCase()) {
      case 'pending':
        return 'Chưa thanh toán';
      case 'paid':
        return 'Đã thanh toán';
      case 'refunded':
        return 'Đã hoàn tiền';
      default:
        return paymentStatus;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getDisplayText(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Loading indicator với message
class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget hiển thị lỗi
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 16,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget hiển thị khi không có dữ liệu
class EmptyDataWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyDataWidget({
    Key? key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
