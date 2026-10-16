import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService({String baseUrl = 'http://10.0.2.2:8788', http.Client? client})
      : baseUrl = baseUrl,
        client = client ?? http.Client();

  /// Convenience for Flutter web local dev against the wrangler dev worker.
  static ApiService forWeb({String baseUrl = 'http://127.0.0.1:8788'}) {
    return ApiService(baseUrl: baseUrl, client: http.Client());
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is List) {
        return {
          'results': decoded.map((e) => e as Map<String, dynamic>).toList(),
        };
      }
      return {};
    }
    final decoded = jsonDecode(response.body);
    final err = (decoded is Map && decoded.containsKey('error')) ? decoded['error'] : null;
    throw ApiException(response.statusCode, err ?? 'request failed');
  }

  Future<http.Response> _rawGet(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return client.get(uri);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final response = await _rawGet(path);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> _put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  // ---- Foods ----

  Future<List<Map<String, dynamic>>> getRestaurants() async {
    final body = await _get('/api/restaurants');
    final list = body['results'] as List? ?? body.values.cast<Map<String, dynamic>>().toList();
    return list.cast<Map<String, dynamic>>().toList();
  }

  Future<List<Map<String, dynamic>>> getMenu({required int restaurantId}) async {
    final body = await _get('/api/menu?restaurant_id=$restaurantId');
    final list = body['results'] as List? ?? body.values.cast<Map<String, dynamic>>().toList();
    return list.cast<Map<String, dynamic>>().map((item) {
      return {
        'id': item['id'] as int,
        'name': item['name'] as String,
        'price': (item['price'] as num).toDouble(),
      };
    }).toList();
  }

  Future<Map<String, dynamic>> createFoodOrder({
    required int restaurantId,
    required List<Map<String, dynamic>> items,
    required String pickupAddress,
  }) async {
    final body = await _post('/api/food/orders', {
      'restaurant_id': restaurantId,
      'items': items,
      'pickup_address': pickupAddress,
    });
    return {
      'id': body['id'] as int,
      'restaurant_id': body['restaurant_id'] as int,
      'items': (body['items'] as List).cast<Map<String, dynamic>>(),
      'total_kes': (body['total_kes'] as num).toDouble(),
      'delivery_fee_kes': (body['delivery_fee_kes'] as num).toDouble(),
      'status': body['status'] as String,
      'pickup_address': body['pickup_address'] as String,
      'created_at': body['created_at'] as String,
    };
  }

  Future<Map<String, dynamic>> getFoodOrder(int orderId) async {
    final body = await _get('/api/food/orders/$orderId');
    return toFoodOrder(body);
  }

  Future<Map<String, dynamic>> updateFoodOrder({
    required int orderId,
    required String status,
  }) async {
    final body = await _put('/api/food/orders/$orderId', {'status': status});
    return {'id': int.parse(body['id'].toString()), 'status': body['status'] as String};
  }

  Future<List<Map<String, dynamic>>> listFoodOrders({String? status}) async {
    final query = status != null ? '/api/food/orders?status=$status' : '/api/food/orders';
    final body = await _get(query);
    final list = body['results'] as List? ?? body.values.cast<Map<String, dynamic>>().toList();
    return list.cast<Map<String, dynamic>>().map(toFoodOrder).toList();
  }

  // ---- Deliveries ----

  Future<Map<String, dynamic>> createDelivery({
    required String pickupAddress,
    required String dropoffAddress,
    required String receiverName,
    required String receiverPhone,
    required String parcelType,
  }) async {
    final body = await _post('/api/deliveries', {
      'pickup_address': pickupAddress,
      'dropoff_address': dropoffAddress,
      'receiver_name': receiverName,
      'receiver_phone': receiverPhone,
      'parcel_type': parcelType,
    });
    return toDelivery(body);
  }

  Future<Map<String, dynamic>> getDelivery(int deliveryId) async {
    final body = await _get('/api/deliveries/$deliveryId');
    return toDelivery(body);
  }

  Future<Map<String, dynamic>> updateDelivery({
    required int deliveryId,
    required String status,
  }) async {
    final body = await _put('/api/deliveries/$deliveryId', {'status': status});
    return {'id': int.parse(body['id'].toString()), 'status': body['status'] as String};
  }

  Future<List<Map<String, dynamic>>> listDeliveries({String? status}) async {
    final query = status != null ? '/api/deliveries?status=$status' : '/api/deliveries';
    final body = await _get(query);
    final list = body['results'] as List? ?? body.values.cast<Map<String, dynamic>>().toList();
    return list.cast<Map<String, dynamic>>().map(toDelivery).toList();
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

Map<String, dynamic> toFoodOrder(Map<String, dynamic> row) {
  return {
    'id': row['id'] as int,
    'restaurant_id': row['restaurant_id'] as int,
    'items': (row['items'] as List).cast<Map<String, dynamic>>(),
    'total_kes': (row['total_kes'] as num).toDouble(),
    'delivery_fee_kes': (row['delivery_fee_kes'] as num).toDouble(),
    'status': row['status'] as String,
    'pickup_address': row['pickup_address'] as String,
    'created_at': row['created_at'] as String,
  };
}

Map<String, dynamic> toDelivery(Map<String, dynamic> row) {
  return {
    'id': row['id'] as int,
    'pickup_address': row['pickup_address'] as String,
    'dropoff_address': row['dropoff_address'] as String,
    'receiver_name': row['receiver_name'] as String,
    'receiver_phone': row['receiver_phone'] as String,
    'parcel_type': row['parcel_type'] as String,
    'parcel_price_kes': (row['parcel_price_kes'] as num).toDouble(),
    'status': row['status'] as String,
    'created_at': row['created_at'] as String,
  };
}
