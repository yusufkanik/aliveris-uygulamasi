import 'dart:convert';
import 'dart:io';

import '../models/product.dart';

class ProductData {
  static const String _bannerUrl = 'https://wantapi.com/assets/banner.png';
  // Use Fake Store API as the remote product source (recommended)
  static const String _remoteProducts = 'https://fakestoreapi.com/products';

  // Local fallback data (kept for offline use)
  static const String _jsonData = '''
[
  {
    "id": 1,
    "name": "Smart Watch",
    "category": "Elektronik",
    "price": 6499.0,
    "shortDescription": "Kalp atış hızı ölçer ve bildirimler.",
    "longDescription": "Bu şık akıllı saat, sağlık takibi, uyku izleme ve anlık bildirimlerle günlük yaşamı kolaylaştırır.",
    "colorHex": "#3A8DFF",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Smart+Watch"
  },
  {
    "id": 2,
    "name": "Kablosuz Kulaklık",
    "category": "Ses",
    "price": 3299.0,
    "shortDescription": "Aktif gürültü engelleme ve uzun pil süresi.",
    "longDescription": "Her yerde rahat kullanım için hafif tasarım ve net ses kalitesi sunar.",
    "colorHex": "#FF7A5C",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Headphones"
  },
  {
    "id": 3,
    "name": "Sırt Çantası",
    "category": "Aksesuar",
    "price": 1899.0,
    "shortDescription": "Günlük kullanım için sağlam ve geniş hacimli.",
    "longDescription": "Suya dayanıklı malzemesi ve düzenli cepleri ile hem okul hem gezi için ideal.",
    "colorHex": "#56C596",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Backpack"
  },
  {
    "id": 4,
    "name": "Bluetooth Hoparlör",
    "category": "Ses",
    "price": 1599.0,
    "shortDescription": "Taşınabilir güçlü ses ve bas performansı.",
    "longDescription": "Parti ve dış mekan kullanımı için kompakt fakat yüksek sesli bir hoparlör.",
    "colorHex": "#FFCB47",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Speaker"
  },
  {
    "id": 5,
    "name": "Termos",
    "category": "Mutfak",
    "price": 499.0,
    "shortDescription": "Sıcak ve soğuk içecekleri saatlerce korur.",
    "longDescription": "Paslanmaz çelik yapısı ile dayanıklı, taşıması kolay bir termos.",
    "colorHex": "#6D5D6E",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Thermos"
  },
  {
    "id": 6,
    "name": "USB Şarj Kablosu",
    "category": "Elektronik",
    "price": 149.0,
    "shortDescription": "Hızlı şarj ve dayanıklı örgü kablo.",
    "longDescription": "3 metre uzunluğundaki bu kablo, cep telefonu, tablet ve diğer cihazlar için uygundur.",
    "colorHex": "#8E44AD",
    "imageUrl": "https://via.placeholder.com/400x300.png?text=Cable"
  }
]
''';

  /// Attempts to load products from the remote API. If any error occurs,
  /// the local fallback JSON is used.
  static Future<List<Product>> loadProducts() async {
    try {
      final uri = Uri.parse(_remoteProducts);
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);
      final request = await client.getUrl(uri);
      final response = await request.close().timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final decoded = json.decode(body) as List<dynamic>;
        return decoded
            .cast<Map<String, dynamic>>()
            .map((jsonItem) => Product.fromJson(jsonItem))
            .toList();
      } else {
        return _loadFromLocal();
      }
    } catch (_) {
      return _loadFromLocal();
    }
  }

  static List<Product> _loadFromLocal() {
    final List<dynamic> decoded = json.decode(_jsonData) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map((jsonItem) => Product.fromJson(jsonItem))
        .toList();
  }

  static String get bannerUrl => _bannerUrl;
}
