-- Foods: restaurant catalog + menu items
CREATE TABLE IF NOT EXISTS restaurants (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  address TEXT NOT NULL,
  rating REAL NOT NULL,
  eta_min INTEGER NOT NULL,
  active INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurant_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  price_kes REAL NOT NULL,
  active INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Food orders
CREATE TABLE IF NOT EXISTS food_orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  restaurant_id INTEGER NOT NULL,
  items_json TEXT NOT NULL,
  total_kes REAL NOT NULL,
  delivery_fee_kes REAL NOT NULL DEFAULT 100.0,
  status TEXT NOT NULL DEFAULT 'pending',
  pickup_address TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (restaurant_id) REFERENCES restaurants(id)
);

-- Deliveries (parcels / couriers)
CREATE TABLE IF NOT EXISTS deliveries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  pickup_address TEXT NOT NULL,
  dropoff_address TEXT NOT NULL,
  receiver_name TEXT NOT NULL,
  receiver_phone TEXT NOT NULL,
  parcel_type TEXT NOT NULL,
  parcel_price_kes REAL NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending',
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Seed data (idempotent via INSERT OR IGNORE on a unique name column where possible)
INSERT OR IGNORE INTO restaurants (id, name, address, rating, eta_min) VALUES
  (1, 'Gakere Road Kitchen', 'Gakere Road, Nyeri', 4.6, 25),
  (2, 'Kimathi Street Cafe', 'Kimathi Street, Nyeri', 4.4, 15),
  (3, 'Nyeri Choma Corner', 'Central Avenue, Nyeri', 4.8, 35);

INSERT OR IGNORE INTO menu_items (id, restaurant_id, name, price_kes) VALUES
  (1, 1, 'Ugali & nyama choma', 450.0),
  (2, 1, 'Githeri special', 250.0),
  (3, 1, 'Pilau nyama', 400.0),
  (4, 1, 'Chapati & beans', 120.0),
  (5, 1, 'Maziwa lala', 80.0);
