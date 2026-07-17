import 'package:flutter/material.dart';

import 'data/product_data.dart';
import 'models/product.dart';
import 'screens/product_detail.dart';
import 'screens/cart_screen.dart';

void main() {
  runApp(const MiniCatalogApp());
}

class MiniCatalogApp extends StatelessWidget {
  const MiniCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alışveriş Uygulaması',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Use named routes with onGenerateRoute to demonstrate Route Arguments
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute<void>(builder: (_) => const HomePage());
        }
        if (settings.name == '/product') {
          final args = settings.arguments as Product;
          return MaterialPageRoute<bool>(builder: (_) => ProductDetailScreen(product: args));
        }
        if (settings.name == '/cart') {
          final args = settings.arguments as Map<String, dynamic>?;
        // Pass the original map reference so remove callback affects the same map instance
        final items = args != null && args['items'] is Map<int, int> ? args['items'] as Map<int,int> : <int, int>{};
        final products = args != null && args['products'] is List<Product> ? args['products'] as List<Product> : <Product>[];
        final void Function(int)? onRemove = args != null && args['onRemove'] is Function ? args['onRemove'] as void Function(int) : null;
        return MaterialPageRoute<dynamic>(builder: (_) => CartScreen(itemsMap: items, products: products, onRemove: onRemove));
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Product> _products = [];
  String _searchText = '';
  int _cartCount = 0;
  // Cart state: map productId -> quantity
  final Map<int, int> _cartMap = {};
  // Keep product references to show in cart
  final List<Product> _cartProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final loaded = await ProductData.loadProducts();
    setState(() {
      _products = loaded;
    });
  }

  List<Product> get _filteredProducts {
    if (_searchText.isEmpty) {
      return _products;
    }
    final query = _searchText.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.shortDescription.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _openProductDetail(Product product) async {
    // Use named route and pass Product as Route Argument
    final added = await Navigator.of(context).pushNamed<bool>('/product', arguments: product);
    if (added == true) {
      _addToCart(product);
    }
  }

  void _addToCart(Product product, {int quantity = 1}) {
    setState(() {
      _cartMap.update(product.id, (q) => q + quantity, ifAbsent: () => quantity);
      if (!_cartProducts.any((p) => p.id == product.id)) _cartProducts.add(product);
      _cartCount = _cartMap.values.fold<int>(0, (prev, q) => prev + q);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alışveriş'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      // Navigate to cart using named route and pass cart map + products and a remove callback
                      Navigator.of(context).pushNamed('/cart', arguments: {
                        'items': _cartMap,
                        'products': _cartProducts,
                        'onRemove': (int id) { setState(() {
                          _cartMap.remove(id);
                          _cartProducts.removeWhere((p) => p.id == id);
                          _cartCount = _cartMap.values.fold<int>(0, (prev, q) => prev + q);
                        }); },
                      });
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Icon(Icons.shopping_cart_outlined, size: 28),
                    ),
                  ),

                  if (_cartCount > 0)
                    Positioned(
                      right: 0,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$_cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  ProductData.bannerUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image, size: 36, color: Colors.grey)),
                  ),
                ),
              ),
            ),
            const Text(
              'Yeni Ürünler',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mini katalog uygulaması ile ürünleri keşfedin ve detayları görüntüleyin.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ürün ara',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _filteredProducts.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
                ),
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return GestureDetector(
                    onTap: () => _openProductDetail(product),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 96,
                            decoration: BoxDecoration(
                              color: product.color.withAlpha(51),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(18),
                                topRight: Radius.circular(18),
                              ),
                            ),
                          child: product.imageUrl != null
                             ? ClipRRect(
                                 borderRadius: const BorderRadius.only(
                                   topLeft: Radius.circular(18),
                                   topRight: Radius.circular(18),
                                 ),
                                 child: Image.network(
                                   product.imageUrl!,
                                   width: double.infinity,
                                   height: 96,
                                   fit: BoxFit.cover,
                                   errorBuilder: (context, error, stack) => Center(
                                     child: Icon(Icons.broken_image, size: 36, color: product.color),
                                   ),
                                   loadingBuilder: (context, child, progress) {
                                     if (progress == null) return child;
                                     return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                                   },
                                 ),
                               )
                             : Center(
                                 child: Icon(
                                   Icons.shopping_bag,
                                   size: 44,
                                   color: product.color,
                                 ),
                               ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.category,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.shortDescription,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '₺${product.price.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: product.color,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'DETAY',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
