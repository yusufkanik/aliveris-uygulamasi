import 'package:flutter/material.dart';
import '../models/product.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.itemsMap, required this.products, this.onRemove});

  final Map<int, int> itemsMap; // productId -> quantity
  final List<Product> products;
  final void Function(int)? onRemove;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get total {
    double s = 0;
    for (final entry in widget.itemsMap.entries) {
      final p = widget.products.firstWhere(
        (e) => e.id == entry.key,
        orElse: () => Product(
          id: entry.key,
          name: 'Ürün',
          category: '',
          price: 0.0,
          shortDescription: '',
          longDescription: '',
          colorHex: '#CCCCCC',
        ),
      );
      s += p.price * entry.value;
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final ids = widget.itemsMap.keys.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepet'),
      ),
      body: ids.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Sepetin boş', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Ürün eklemek için ürün detayından "Sepete Ekle" butonuna basın.'),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final id = ids[index];
                final qty = widget.itemsMap[id] ?? 0;
                final p = widget.products.firstWhere(
                  (e) => e.id == id,
                  orElse: () => Product(
                    id: id,
                    name: 'Ürün',
                    category: '',
                    price: 0.0,
                    shortDescription: '',
                    longDescription: '',
                    colorHex: '#CCCCCC',
                  ),
                );
                return Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: p.color.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: p.imageUrl != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(p.imageUrl!, fit: BoxFit.cover))
                          : Icon(Icons.shopping_bag, color: p.color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(p.category, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Text('₺${(p.price * qty).toStringAsFixed(0)}'),
                        const SizedBox(height: 6),
                        // Quantity display (no +/- controls as requested)
                        Text('Adet: $qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        // Kaldır (remove) button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                          onPressed: widget.onRemove != null
                              ? () {
                                  widget.onRemove!(id);
                                  setState(() {});
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ürün sepetten kaldırıldı')));
                                }
                              : null,
                          child: const Text('Kaldır', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    )
                  ],
                );
              },
              separatorBuilder: (context, index) => const Divider(),
              itemCount: ids.length,
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toplam', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('₺${total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: ids.isEmpty ? null : () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Text('Ödeme Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
