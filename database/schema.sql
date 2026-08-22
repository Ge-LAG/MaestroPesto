PRAGMA foreign_keys = ON;

CREATE TABLE recipes (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  servings INTEGER NOT NULL DEFAULT 4,
  prep_time_min INTEGER NOT NULL DEFAULT 0,
  cook_time_min INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT
);

CREATE TABLE recipe_steps (
  id TEXT PRIMARY KEY,
  recipe_id TEXT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  body TEXT NOT NULL
);

CREATE TABLE tags (
  id TEXT PRIMARY KEY,
  label TEXT NOT NULL UNIQUE
);

CREATE TABLE recipe_tags (
  recipe_id TEXT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  PRIMARY KEY (recipe_id, tag_id)
);

CREATE TABLE ciqual_foods (
  code TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  group_code TEXT
);

CREATE TABLE ciqual_nutrients (
  food_code TEXT NOT NULL REFERENCES ciqual_foods(code) ON DELETE CASCADE,
  nutrient_key TEXT NOT NULL,
  value_per_100g REAL NOT NULL,
  PRIMARY KEY (food_code, nutrient_key)
);

CREATE TABLE recipe_items (
  id TEXT PRIMARY KEY,
  recipe_id TEXT NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
  position INTEGER NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('ciqual', 'recipe', 'free')),
  label TEXT NOT NULL,
  quantity_g REAL NOT NULL,
  ciqual_code TEXT REFERENCES ciqual_foods(code),
  child_recipe_id TEXT REFERENCES recipes(id)
);

CREATE TABLE sync_events (
  id TEXT PRIMARY KEY,
  device_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  payload_json TEXT NOT NULL,
  created_at TEXT NOT NULL,
  applied_at TEXT
);
