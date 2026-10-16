const JSON_HEADER = { 'Content-Type': 'application/json' };
const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
};

function json(res, status = 200, body = null) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...JSON_HEADER, ...CORS },
  });
}

function parseJson(req) {
  return req.json().catch(() => null);
}

function route(method, url) {
  const u = new URL(url);
  const path = u.pathname;
  const query = u.searchParams;
  if (method === 'OPTIONS') return 'options';
  if (path === '/health') return 'health';
  if (path === '/api/restaurants' && method === 'GET') return 'restaurants';
  if (path === '/api/menu' && method === 'GET') return 'menu';
  if (path === '/api/food/orders' && method === 'POST') return 'createFoodOrder';
  if (path.startsWith('/api/food/orders/') && method === 'GET') return 'getFoodOrder';
  if (path.startsWith('/api/food/orders/') && method === 'PUT') return 'updateFoodOrder';
  if (path === '/api/food/orders' && method === 'GET') return 'listFoodOrders';
  if (path === '/api/deliveries' && method === 'POST') return 'createDelivery';
  if (path.startsWith('/api/deliveries/') && method === 'GET') return 'getDelivery';
  if (path.startsWith('/api/deliveries/') && method === 'PUT') return 'updateDelivery';
  if (path === '/api/deliveries' && method === 'GET') return 'listDeliveries';
  return 'notFound';
}

export default {
  async fetch(request, env, ctx) {
    const method = request.method;
    const url = request.url;
    const r = route(method, url);

    if (r === 'options') {
      return new Response(null, { headers: CORS });
    }
    if (r === 'notFound') {
      return json(request, 404, { error: 'not_found' });
    }

    try {
      switch (r) {
        case 'health':
          return json(request, 200, { ok: true });

        case 'restaurants':
          return handleRestaurants(env);
        case 'menu':
          return handleMenu(env, request);
        case 'createFoodOrder':
          return handleCreateFoodOrder(env, request);
        case 'getFoodOrder':
          return handleGetFoodOrder(env, request);
        case 'updateFoodOrder':
          return handleUpdateFoodOrder(env, request);
        case 'listFoodOrders':
          return handleListFoodOrders(env, request);
        case 'createDelivery':
          return handleCreateDelivery(env, request);
        case 'getDelivery':
          return handleGetDelivery(env, request);
        case 'updateDelivery':
          return handleUpdateDelivery(env, request);
        case 'listDeliveries':
          return handleListDeliveries(env, request);
        default:
          return json(request, 404, { error: 'not_found' });
      }
    } catch (e) {
      return json(request, 500, { error: 'internal', detail: String(e) });
    }
  },
};

async function handleRestaurants(env) {
  const rows = await env.DB.prepare(
    'SELECT id, name, address, rating, eta_min FROM restaurants WHERE active = 1 ORDER BY rating DESC'
  ).all();
  return json(null, 200, rows.results.map(r => ({
    id: r.id,
    name: r.name,
    address: r.address,
    rating: r.rating,
    eta: `${r.eta_min} min`,
  })));
}

async function handleMenu(env, request) {
  const url = new URL(request.url);
  const restaurantId = url.searchParams.get('restaurant_id');
  if (!restaurantId) {
    return json(request, 400, { error: 'restaurant_id required' });
  }
  const rows = await env.DB.prepare(
    'SELECT id, name, price_kes FROM menu_items WHERE restaurant_id = ? AND active = 1 ORDER BY id'
  ).bind(restaurantId).all();
  return json(null, 200, rows.results.map(r => ({
    id: r.id,
    name: r.name,
    price: r.price_kes,
  })));
}

async function handleCreateFoodOrder(env, request) {
  const body = await parseJson(request);
  if (!body || !body.restaurant_id || !body.items || !body.pickup_address) {
    return json(request, 400, { error: 'restaurant_id, items, pickup_address required' });
  }
  const items = Array.isArray(body.items) ? body.items : [];
  if (items.length === 0) {
    return json(request, 400, { error: 'items must not be empty' });
  }
  const menu = await env.DB.prepare(
    'SELECT id, price_kes FROM menu_items WHERE id = ? AND active = 1'
  );
  let total = 0;
  const orderedItems = [];
  for (const it of items) {
    const mid = it.id;
    const qty = Math.max(1, Number(it.qty) || 1);
    const row = await menu.bind(mid).first();
    if (!row) {
      return json(request, 400, { error: `menu item ${mid} not found` });
    }
    total += row.price_kes * qty;
    orderedItems.push({ id: mid, name: null, qty, price: row.price_kes });
  }
  const deliveryFee = 100.0;
  const totalWithFee = total + deliveryFee;
  const result = await env.DB.prepare(
    'INSERT INTO food_orders (restaurant_id, items_json, total_kes, delivery_fee_kes, status, pickup_address) VALUES (?, ?, ?, ?, ?, ?)'
  ).bind(
    body.restaurant_id,
    JSON.stringify(orderedItems.map(it => ({ id: it.id, qty: it.qty, price: it.price }))),
    totalWithFee,
    deliveryFee,
    'pending',
    body.pickup_address
  ).run();
  const orderId = result.success ? result.lastErrorObject?.changes ? 0 : 0 : 0;
  // fetch the inserted row by returning id from insert
  const inserted = await env.DB.prepare(
    'SELECT id, restaurant_id, items_json, total_kes, delivery_fee_kes, status, pickup_address, created_at FROM food_orders WHERE rowid = last_insert_rowid()'
  ).all();
  const order = inserted.results[0];
  return json(null, 201, toFoodOrder(order));
}

async function handleGetFoodOrder(env, request) {
  const orderId = request.url.split('/').pop();
  const row = await env.DB.prepare(
    'SELECT id, restaurant_id, items_json, total_kes, delivery_fee_kes, status, pickup_address, created_at FROM food_orders WHERE id = ?'
  ).bind(orderId).first();
  if (!row) return json(request, 404, { error: 'order not found' });
  return json(null, 200, toFoodOrder(row));
}

async function handleUpdateFoodOrder(env, request) {
  const orderId = request.url.split('/').pop();
  const body = await parseJson(request);
  if (!body || !body.status) {
    return json(request, 400, { error: 'status required' });
  }
  const allowed = ['pending', 'accepted', 'preparing', 'on_the_way', 'delivered', 'cancelled'];
  if (!allowed.includes(body.status)) {
    return json(request, 400, { error: 'invalid status' });
  }
  const row = await env.DB.prepare(
    'UPDATE food_orders SET status = ? WHERE id = ? RETURNING id, status'
  ).bind(body.status, orderId).all();
  if (!row.results || row.results.length === 0) {
    return json(request, 404, { error: 'order not found' });
  }
  return json(null, 200, { id: orderId, status: body.status });
}

async function handleListFoodOrders(env, request) {
  const url = new URL(request.url);
  const status = url.searchParams.get('status');
  const stmt = status
    ? env.DB.prepare('SELECT id, restaurant_id, items_json, total_kes, delivery_fee_kes, status, pickup_address, created_at FROM food_orders WHERE status = ? ORDER BY id DESC')
    : env.DB.prepare('SELECT id, restaurant_id, items_json, total_kes, delivery_fee_kes, status, pickup_address, created_at FROM food_orders ORDER BY id DESC');
  const rows = status ? await stmt.bind(status).all() : await stmt.all();
  return json(null, 200, rows.results.map(toFoodOrder));
}

function toFoodOrder(row) {
  let items = [];
  try { items = JSON.parse(row.items_json); } catch (e) { items = []; }
  return {
    id: row.id,
    restaurant_id: row.restaurant_id,
    items: items,
    total_kes: row.total_kes,
    delivery_fee_kes: row.delivery_fee_kes,
    status: row.status,
    pickup_address: row.pickup_address,
    created_at: row.created_at,
  };
}

async function handleCreateDelivery(env, request) {
  const body = await parseJson(request);
  if (!body || !body.pickup_address || !body.dropoff_address || !body.receiver_name || !body.receiver_phone || !body.parcel_type) {
    return json(request, 400, { error: 'pickup_address, dropoff_address, receiver_name, receiver_phone, parcel_type required' });
  }
  const parcelMap = { envelope: 200.0, small_box: 350.0, big_box: 600.0 };
  const price = parcelMap[body.parcel_type] || 350.0;
  const result = await env.DB.prepare(
    'INSERT INTO deliveries (pickup_address, dropoff_address, receiver_name, receiver_phone, parcel_type, parcel_price_kes, status) VALUES (?, ?, ?, ?, ?, ?, ?)'
  ).bind(
    body.pickup_address,
    body.dropoff_address,
    body.receiver_name,
    body.receiver_phone,
    body.parcel_type,
    price,
    'pending'
  ).run();
  const inserted = await env.DB.prepare(
    'SELECT id, pickup_address, dropoff_address, receiver_name, receiver_phone, parcel_type, parcel_price_kes, status, created_at FROM deliveries WHERE rowid = last_insert_rowid()'
  ).all();
  const d = inserted.results[0];
  return json(null, 201, toDelivery(d));
}

async function handleGetDelivery(env, request) {
  const deliveryId = request.url.split('/').pop();
  const row = await env.DB.prepare(
    'SELECT id, pickup_address, dropoff_address, receiver_name, receiver_phone, parcel_type, parcel_price_kes, status, created_at FROM deliveries WHERE id = ?'
  ).bind(deliveryId).first();
  if (!row) return json(request, 404, { error: 'delivery not found' });
  return json(null, 200, toDelivery(row));
}

async function handleUpdateDelivery(env, request) {
  const deliveryId = request.url.split('/').pop();
  const body = await parseJson(request);
  if (!body || !body.status) {
    return json(request, 400, { error: 'status required' });
  }
  const allowed = ['pending', 'assigned', 'picked_up', 'out_for_delivery', 'delivered', 'cancelled'];
  if (!allowed.includes(body.status)) {
    return json(request, 400, { error: 'invalid status' });
  }
  const row = await env.DB.prepare(
    'UPDATE deliveries SET status = ? WHERE id = ? RETURNING id, status'
  ).bind(body.status, deliveryId).all();
  if (!row.results || row.results.length === 0) {
    return json(request, 404, { error: 'delivery not found' });
  }
  return json(null, 200, { id: deliveryId, status: body.status });
}

async function handleListDeliveries(env, request) {
  const url = new URL(request.url);
  const status = url.searchParams.get('status');
  const stmt = status
    ? env.DB.prepare('SELECT id, pickup_address, dropoff_address, receiver_name, receiver_phone, parcel_type, parcel_price_kes, status, created_at FROM deliveries WHERE status = ? ORDER BY id DESC')
    : env.DB.prepare('SELECT id, pickup_address, dropoff_address, receiver_name, receiver_phone, parcel_type, parcel_price_kes, status, created_at FROM deliveries ORDER BY id DESC');
  const rows = status ? await stmt.bind(status).all() : await stmt.all();
  return json(null, 200, rows.results.map(toDelivery));
}

function toDelivery(row) {
  return {
    id: row.id,
    pickup_address: row.pickup_address,
    dropoff_address: row.dropoff_address,
    receiver_name: row.receiver_name,
    receiver_phone: row.receiver_phone,
    parcel_type: row.parcel_type,
    parcel_price_kes: row.parcel_price_kes,
    status: row.status,
    created_at: row.created_at,
  };
}
