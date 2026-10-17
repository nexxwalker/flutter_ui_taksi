import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http/src/base_request.dart' show BaseRequest;
import 'package:http/src/streamed_response.dart' show StreamedResponse;
import 'package:http/src/request.dart' show Request;
import 'package:flutter_ui_taksi/services/api_service.dart';

class ApiStub {
  final Map<int, dynamic> _restaurants;
  final Map<int, List<Map<String, dynamic>>> _menu;
  final List<Map<String, dynamic>> _foodOrders = [];
  final List<Map<String, dynamic>> _deliveries = [];
  int _nextFoodOrderId = 1;
  int _nextDeliveryId = 1;

  ApiStub({
    required Map<int, dynamic> restaurants,
    required Map<int, List<Map<String, dynamic>>> menu,
  })      : _restaurants = restaurants,
        _menu = menu;

  ApiService build() {
    return ApiService(
      baseUrl: 'http://stub.local',
      client: _Client(_respond),
    );
  }

  Future<http.Response> _respond(http.Request request) async {
    final method = request.method;
    final path = request.url.path;
    final query = request.url.queryParameters;

    switch (method) {
      case 'GET':
        return _handleGet(path, query);
      case 'POST':
        return _handlePost(path, request);
      case 'PUT':
        return _handlePut(path, request);
      default:
        return http.Response('{"error":"not_found"}', 404);
    }
  }

  http.Response _handleGet(String path, Map<String, String> query) {
    if (path == '/health') {
      return http.Response('{"ok":true}', 200);
    }
    if (path == '/api/restaurants') {
      return http.Response(jsonEncode(_restaurants.values.toList()), 200);
    }
    if (path == '/api/menu') {
      final rid = int.tryParse(query['restaurant_id'] ?? '') ?? 0;
      final items = _menu[rid] ?? [];
      return http.Response(jsonEncode(items), 200);
    }
    final foodOrderMatch = RegExp(r'^/api/food/orders/(\d+)$').firstMatch(path);
    if (foodOrderMatch != null) {
      final id = int.parse(foodOrderMatch.group(1)!);
      final order = _foodOrders.cast<Map<String, dynamic>>().firstWhere(
        (o) => o['id'] == id,
        orElse: () => throw StateError('no such food order'),
      );
      return http.Response(jsonEncode(order), 200);
    }
    if (path == '/api/food/orders') {
      return http.Response(jsonEncode(_foodOrders.cast<Map<String, dynamic>>().toList()), 200);
    }
    final deliveryMatch = RegExp(r'^/api/deliveries/(\d+)$').firstMatch(path);
    if (deliveryMatch != null) {
      final id = int.parse(deliveryMatch.group(1)!);
      final d = _deliveries.cast<Map<String, dynamic>>().firstWhere(
        (o) => o['id'] == id,
        orElse: () => throw StateError('no such delivery'),
      );
      return http.Response(jsonEncode(d), 200);
    }
    if (path == '/api/deliveries') {
      return http.Response(jsonEncode(_deliveries.cast<Map<String, dynamic>>().toList()), 200);
    }
    return http.Response('{"error":"not_found"}', 404);
  }

  Future<http.Response> _handlePost(String path, http.Request request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    if (path == '/api/food/orders') {
      final raw = body['items'];
      if (raw is! List) return http.Response('{"error":"invalid_items"}', 400);
      final items = raw.cast<dynamic>();
      double total = 0;
      final ordered = <Map<String, dynamic>>[];
      for (final it in items) {
        final mid = it['id'] as int;
        final qty = (it['qty'] as num?)?.toInt() ?? 1;
        final menuItem = _findMenuItem(mid);
        final price = menuItem['price'] as double;
        total += price * qty;
        ordered.add({'id': mid, 'qty': qty, 'price': price});
      }
      final order = {
        'id': _nextFoodOrderId++,
        'restaurant_id': body['restaurant_id'] as int,
        'items': ordered,
        'total_kes': total + 100.0,
        'delivery_fee_kes': 100.0,
        'status': 'pending',
        'pickup_address': body['pickup_address'] as String? ?? '',
        'created_at': '2026-01-01 00:00:00',
      };
      _foodOrders.add(order);
      return http.Response(jsonEncode(order), 201);
    }
    if (path == '/api/deliveries') {
      final parcelMap = {
        'envelope': 200.0,
        'small_box': 350.0,
        'big_box': 600.0,
      };
      final price = parcelMap[body['parcel_type'] as String?] ?? 350.0;
      final delivery = {
        'id': _nextDeliveryId++,
        'pickup_address': body['pickup_address'] as String? ?? '',
        'dropoff_address': body['dropoff_address'] as String? ?? '',
        'receiver_name': body['receiver_name'] as String? ?? '',
        'receiver_phone': body['receiver_phone'] as String? ?? '',
        'parcel_type': body['parcel_type'] as String? ?? '',
        'parcel_price_kes': price,
        'status': 'pending',
        'created_at': '2026-01-01 00:00:00',
      };
      _deliveries.add(delivery);
      return http.Response(jsonEncode(delivery), 201);
    }
    return http.Response('{"error":"not_found"}', 404);
  }

  Future<http.Response> _handlePut(String path, http.Request request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final m = RegExp(r'^/api/(food/orders|deliveries)/(\d+)$').firstMatch(path);
    if (m == null) return http.Response('{"error":"not_found"}', 404);
    final collection = m.group(1)!;
    final id = int.parse(m.group(2)!);
    final list = collection == 'food/orders' ? _foodOrders : _deliveries;
    final idx = list.cast<Map<String, dynamic>>().indexWhere((o) => o['id'] == id);
    if (idx < 0) return http.Response('{"error":"not_found"}', 404);
    list[idx]['status'] = body['status'] as String;
    return http.Response(jsonEncode({'id': id, 'status': body['status']}), 200);
  }

  Map<String, dynamic> _findMenuItem(int id) {
    for (final list in _menu.values) {
      for (final item in list) {
        if (item['id'] == id) return item;
      }
    }
    throw StateError('no such menu item $id');
  }
}

class _Client implements http.Client {
  final Future<http.Response> Function(http.Request) _handler;
  _Client(this._handler);

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final req = Request('GET', url);
    if (headers != null) req.headers.addAll(headers);
    return _handler(req);
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final req = Request('POST', url)
      ..headers.addAll(headers ?? {})
      ..body = body?.toString() ?? '';
    if (encoding != null) req.encoding = encoding;
    return _handler(req);
  }

  @override
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final req = Request('PUT', url)
      ..headers.addAll(headers ?? {})
      ..body = body?.toString() ?? '';
    if (encoding != null) req.encoding = encoding;
    return _handler(req);
  }

  @override
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final req = Request('DELETE', url)
      ..headers.addAll(headers ?? {})
      ..body = body?.toString() ?? '';
    if (encoding != null) req.encoding = encoding;
    return _handler(req);
  }

  @override
  Future<http.Response> head(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final req = Request('HEAD', url);
    if (headers != null) req.headers.addAll(headers);
    return _handler(req);
  }

  @override
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final req = Request('PATCH', url)
      ..headers.addAll(headers ?? {})
      ..body = body?.toString() ?? '';
    if (encoding != null) req.encoding = encoding;
    return _handler(req);
  }

  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) async {
    final res = await get(url, headers: headers);
    return res.bodyBytes;
  }

  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) async {
    final res = await get(url, headers: headers);
    return res.body;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    final req = request is Request ? request : Request(request.method, request.url);
    final res = await _handler(req);
    final stream = res.bodyBytes.isEmpty
        ? const Stream<List<int>>.empty()
        : Stream<List<int>>.value(res.bodyBytes);
    return StreamedResponse(
      stream,
      res.statusCode,
    );
  }

  @override
  void close() {}
}
