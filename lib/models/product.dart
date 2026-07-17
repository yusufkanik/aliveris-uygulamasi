import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String shortDescription;
  final String longDescription;
  final String colorHex;
  final String? imageUrl; // optional remote/local image URL

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.shortDescription,
    required this.longDescription,
    required this.colorHex,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Normalize fields coming from different demo APIs (FakeStore, DummyJSON, wantapi)
    final rawId = json['id'];
    final id = rawId is String ? int.parse(rawId) : (rawId as num).toInt();
    final name = (json['name'] as String?) ?? (json['title'] as String?) ?? '';
    final category = (json['category'] as String?) ?? '';
    final price = json['price'] != null ? (json['price'] as num).toDouble() : 0.0;
    final longDesc = (json['longDescription'] as String?) ?? (json['description'] as String?) ?? '';
    final shortDesc = (json['shortDescription'] as String?) ?? (longDesc.length > 80 ? '${longDesc.substring(0, 77)}...' : longDesc);
    String? color = json['colorHex'] as String?;
    // If no color provided, choose one deterministically from a small palette
    color ??= _palette[id % _palette.length];
    final image = (json['image'] as String?) ?? (json['imageUrl'] as String?);

    return Product(
      id: id,
      name: name,
      category: category,
      price: price,
      shortDescription: shortDesc,
      longDescription: longDesc,
      colorHex: color,
      imageUrl: image,
    );
  }

  // Small deterministic palette for fallback colors
  static const List<String> _palette = [
    '#3A8DFF',
    '#FF7A5C',
    '#56C596',
    '#FFCB47',
    '#6D5D6E',
    '#8E44AD',
    '#2ECC71',
    '#E67E22',
    '#3498DB',
    '#E74C3C',
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'shortDescription': shortDescription,
      'longDescription': longDescription,
      'colorHex': colorHex,
      'imageUrl': imageUrl,
    };
  }

  Color get color {
    final hex = colorHex.replaceFirst('#', '');
    try {
      return Color(int.parse('0xff$hex'));
    } catch (_) {
      return Colors.grey;
    }
  }
}
