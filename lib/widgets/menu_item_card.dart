import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import 'common_widgets.dart';

/// Widget hiển thị card món ăn trong danh sách
class MenuItemCard extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onAddToOrder;

  const MenuItemCard({
    Key? key,
    required this.item,
    this.onTap,
    this.onAddToOrder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hình ảnh
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.restaurant, size: 40),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant, size: 40),
                        ),
                ),
                // Badge hết món
                if (!item.isAvailable)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: UnavailableBadge(),
                  ),
                // Icons vegetarian/spicy
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      if (item.isVegetarian) ...[
                        const VegetarianIcon(size: 16),
                        const SizedBox(width: 4),
                      ],
                      if (item.isSpicy) const SpicyIcon(size: 16),
                    ],
                  ),
                ),
              ],
            ),
            // Thông tin món ăn
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên món
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Category
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Giá và rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_formatPrice(item.price)}đ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      RatingStars(rating: item.rating, size: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Widget hiển thị món ăn dạng list item (horizontal)
class MenuItemListTile extends StatelessWidget {
  final MenuItemModel item;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MenuItemListTile({
    Key? key,
    required this.item,
    this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 60,
          height: 60,
          child: item.imageUrl.isNotEmpty
              ? Image.network(
                  item.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant),
                    );
                  },
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.restaurant),
                ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                decoration: item.isAvailable ? null : TextDecoration.lineThrough,
                color: item.isAvailable ? null : Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.isVegetarian) const VegetarianIcon(size: 14),
          if (item.isSpicy) const SpicyIcon(size: 14),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.category,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${_formatPrice(item.price)}đ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              RatingStars(rating: item.rating, size: 12),
            ],
          ),
        ],
      ),
      trailing: trailing,
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
