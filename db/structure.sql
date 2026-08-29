CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "sessions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "ip_address" varchar, "user_agent" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "token" varchar /*application='Mykiosk'*/, CONSTRAINT "fk_rails_758836b4f0"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_sessions_on_user_id" ON "sessions" ("user_id") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "products" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "price" decimal(8,2) NOT NULL, "unit" varchar DEFAULT 'kg' NOT NULL, "stock" integer DEFAULT 0 NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "image" varchar /*application='Mykiosk'*/, "mrp" decimal(8,2) /*application='Mykiosk'*/);
CREATE TABLE IF NOT EXISTS "order_items" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "order_id" integer NOT NULL, "product_id" integer NOT NULL, "quantity" integer NOT NULL, "price" decimal(8,2) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_e3cb28f071"
FOREIGN KEY ("order_id")
  REFERENCES "orders" ("id")
, CONSTRAINT "fk_rails_f1a29ddd47"
FOREIGN KEY ("product_id")
  REFERENCES "products" ("id")
);
CREATE INDEX "index_order_items_on_order_id" ON "order_items" ("order_id") /*application='Mykiosk'*/;
CREATE INDEX "index_order_items_on_product_id" ON "order_items" ("product_id") /*application='Mykiosk'*/;
CREATE UNIQUE INDEX "index_sessions_on_token" ON "sessions" ("token") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "users" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "email_address" varchar, "password_digest" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "owner" boolean DEFAULT 0 NOT NULL, "phone_number" varchar /*application='Mykiosk'*/, "otp_digest" varchar /*application='Mykiosk'*/, "otp_sent_at" datetime(6) /*application='Mykiosk'*/);
CREATE UNIQUE INDEX "index_users_on_email_address" ON "users" ("email_address") /*application='Mykiosk'*/;
CREATE UNIQUE INDEX "index_users_on_phone_number" ON "users" ("phone_number") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "device_tokens" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "token" varchar NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_e99e290457"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_device_tokens_on_user_id" ON "device_tokens" ("user_id") /*application='Mykiosk'*/;
CREATE UNIQUE INDEX "index_device_tokens_on_token" ON "device_tokens" ("token") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "orders" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" integer NOT NULL, "status" varchar DEFAULT 'placed' NOT NULL, "total" decimal(8,2) NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, "recipient_name" varchar NOT NULL, "phone_number" varchar NOT NULL, "pincode" varchar NOT NULL, "line1" varchar NOT NULL, "line2" varchar NOT NULL, "landmark" varchar, "city" varchar NOT NULL, "state" varchar NOT NULL, "delivery_option" varchar DEFAULT 'instant' NOT NULL /*application='Mykiosk'*/, CONSTRAINT "fk_rails_f868b47f6a"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_orders_on_user_id" ON "orders" ("user_id") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "active_storage_blobs" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "key" varchar NOT NULL, "filename" varchar NOT NULL, "content_type" varchar, "metadata" text, "service_name" varchar NOT NULL, "byte_size" bigint NOT NULL, "checksum" varchar, "created_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_active_storage_blobs_on_key" ON "active_storage_blobs" ("key") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "active_storage_attachments" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "name" varchar NOT NULL, "record_type" varchar NOT NULL, "record_id" bigint NOT NULL, "blob_id" bigint NOT NULL, "created_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_c3b3935057"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE INDEX "index_active_storage_attachments_on_blob_id" ON "active_storage_attachments" ("blob_id") /*application='Mykiosk'*/;
CREATE UNIQUE INDEX "index_active_storage_attachments_uniqueness" ON "active_storage_attachments" ("record_type", "record_id", "name", "blob_id") /*application='Mykiosk'*/;
CREATE TABLE IF NOT EXISTS "active_storage_variant_records" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "blob_id" bigint NOT NULL, "variation_digest" varchar NOT NULL, CONSTRAINT "fk_rails_993965df05"
FOREIGN KEY ("blob_id")
  REFERENCES "active_storage_blobs" ("id")
);
CREATE UNIQUE INDEX "index_active_storage_variant_records_uniqueness" ON "active_storage_variant_records" ("blob_id", "variation_digest") /*application='Mykiosk'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20260829172014'),
('20260829171106'),
('20260829170449'),
('20260829165753'),
('20260829162938'),
('20260829162421'),
('20260829162233'),
('20260829162232'),
('20260829162231'),
('20260829162222'),
('20260829162221');

