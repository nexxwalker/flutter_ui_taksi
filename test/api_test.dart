import 'dart:convert';
import 'dart:io' show Platform;

import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

const defaultBaseUrl = 'http://127.0.0.1:8788';

/// These tests drive the real Worker in `api/` over HTTP, so they only run when
/// a backend is reachable. Start it with `npx wrangler dev --port 8788` from
/// `api/` and export `API_BASE_URL`; CI does both automatically.
void main() {
  final baseUrl = Platform.environment['API_BASE_URL'] ?? defaultBaseUrl;
  final skipReason = Platform.environment['API_BASE_URL'] == null
      ? 'Start the API (cd api && npx wrangler dev --port 8788) and set API_BASE_URL to run the integration tests'
      : null;

  void apiTest(String description, Future<void> Function() body) {
    test(description, body, skip: skipReason);
  }

  http.Client client = http.Client();

  Map<String, dynamic> decodeGet(String body) {
    if (body.isEmpty) return {};
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is List) return {'results': decoded.map((e) => e as Map<String, dynamic>).toList()};
    return {};
  }

  Future<Map<String, dynamic>> get(String path) async {
    final res = await client.get(Uri.parse('$baseUrl$path'));
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return decodeGet(res.body);
    }
    throw Exception('GET $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final res = await client.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('POST $path returned non-JSON-object: ${res.body}');
      }
      return decoded;
    }
    throw Exception('POST $path failed: ${res.statusCode} ${res.body}');
  }

  Future<Map<String, dynamic>> put(String path, Map<String, dynamic> body) async {
    final res = await client.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw Exception('PUT $path returned non-JSON-object: ${res.body}');
      }
      return decoded;
    }
    throw Exception('PUT $path failed: ${res.statusCode} ${res.body}');
  }

  setUp(() {
    // fresh client per test for isolation where helpful
  });

  apiTest('health endpoint is reachable', () async {
    final body = await get('/health');
    expect(body['ok'], isTrue);
  });

  apiTest('restaurants returns at least one restaurant in Nyeri', () async {
    final restaurants = await get('/api/restaurants');
    final list = restaurants['results'] as List? ?? [];
    expect(list, isNotEmpty);
    final names = list.map((r) => (r['name'] as String)).toList();
    final ok = names.any((n) => n.startsWith('Gakere') || n.startsWith('Kimathi') || n.startsWith('Nyeri'));
    expect(ok, isTrue);
    for (final r in list) {
      expect(r['rating'], isA<num>());
      expect(r['eta'], isA<String>());
    }
  });

  apiTest('menu returns items for a restaurant', () async {
    final menu = await get('/api/menu?restaurant_id=1');
    final items = menu['results'] as List? ?? [];
    expect(items, isNotEmpty);
    final prices = items.map((it) => it['price'] as num).toList();
    expect(prices, contains(450));
  });

  apiTest('create food order computes total with delivery fee', () async {
    final order = await post('/api/food/orders', {
      'restaurant_id': 1,
      'items': [
        {'id': 1, 'qty': 2},
        {'id': 2, 'qty': 1},
      ],
      'pickup_address': 'Kenyatta Avenue, Nyeri',
    });
    expect(order['total_kes'], equals(1250.0));
    expect(order['delivery_fee_kes'], equals(100.0));
    expect(order['status'], equals('pending'));
    expect(order['pickup_address'], equals('Kenyatta Avenue, Nyeri'));
    expect(order['id'], isA<int>());
    expect(order['restaurant_id'], equals(1));
  });

  apiTest('update food order status transitions', () async {
    final order = await post('/api/food/orders', {
      'restaurant_id': 2,
      'items': [
        {'id': 1, 'qty': 1},
      ],
      'pickup_address': 'Kimathi Street, Nyeri',
    });
    final orderId = order['id'] as int;
    final updated = await put('/api/food/orders/$orderId', {'status': 'delivered'});
    expect(updated['status'], equals('delivered'));
    final fetched = await get('/api/food/orders/$orderId');
    expect(fetched['status'], equals('delivered'));
  });

  apiTest('create delivery records pickup, dropoff, receiver and parcel price', () async {
    final d = await post('/api/deliveries', {
      'pickup_address': 'Kenyatta Avenue, Nyeri',
      'dropoff_address': 'Nyeri County Referral Hospital',
      'receiver_name': 'Jane Wambui',
      'receiver_phone': '0712 345 678',
      'parcel_type': 'small_box',
    });
    expect(d['pickup_address'], equals('Kenyatta Avenue, Nyeri'));
    expect(d['dropoff_address'], equals('Nyeri County Referral Hospital'));
    expect(d['receiver_name'], equals('Jane Wambui'));
    expect(d['receiver_phone'], equals('0712 345 678'));
    expect(d['parcel_type'], equals('small_box'));
    expect(d['parcel_price_kes'], equals(350.0));
    expect(d['status'], equals('pending'));
    expect(d['id'], isA<int>());
    final deliveryId = d['id'] as int;
    final fetched = await get('/api/deliveries/$deliveryId');
    expect(fetched['parcel_type'], equals('small_box'));
  });

  apiTest('update delivery status transitions', () async {
    final d = await post('/api/deliveries', {
      'pickup_address': 'Kimathi Street, Nyeri',
      'dropoff_address': 'Central Avenue, Nyeri',
      'receiver_name': 'Andi Wijaya',
      'receiver_phone': '0712 987 654',
      'parcel_type': 'envelope',
    });
    final deliveryId = d['id'] as int;
    final updated = await put('/api/deliveries/$deliveryId', {'status': 'delivered'});
    expect(updated['status'], equals('delivered'));
    final fetched = await get('/api/deliveries/$deliveryId');
    expect(fetched['status'], equals('delivered'));
  });

  apiTest('list endpoints return created records', () async {
    final order = await post('/api/food/orders', {
      'restaurant_id': 3,
      'items': [
        {'id': 1, 'qty': 1},
      ],
      'pickup_address': 'Central Avenue, Nyeri',
    });
    final createdOrder = await get('/api/food/orders/${order['id']}');
    expect(createdOrder['restaurant_id'], equals(3));
    final deliveries = await get('/api/deliveries');
    final deliveryList = deliveries['results'] as List? ?? [];
    expect(deliveryList, isNotEmpty);
    final lastDelivery = deliveryList.first as Map<String, dynamic>;
    expect(lastDelivery['pickup_address'], isA<String>());
  });
}
