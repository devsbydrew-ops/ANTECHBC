-- ============================================================
-- Antech Gadgets — Supabase schema
-- Run this once in your Supabase project's SQL editor:
-- Dashboard → SQL Editor → New query → paste all of this → Run
-- ============================================================

create table if not exists products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  line text not null check (line in ('iPhone','Galaxy A','Galaxy S')),
  condition text not null check (condition in ('New','Refurbished')),
  grade text check (grade in ('A','B') or grade is null),
  battery integer not null default 100,
  price numeric not null check (price >= 0),
  storage text[] not null,
  storage_prices numeric[] not null default array[]::numeric[],
  screen text,
  camera text,
  chip text,
  image_url text not null,
  source_url text,
  stock_quantity integer not null default 0 check (stock_quantity >= 0),
  low_stock_threshold integer not null default 3,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- keep updated_at fresh on every edit
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_products_updated_at on products;
create trigger trg_products_updated_at
before update on products
for each row execute function set_updated_at();

-- ============================================================
-- Row Level Security
-- Anyone (your storefront) can READ products.
-- Only a logged-in Supabase Auth user (your admin account) can
-- add, edit, or delete. This is what makes admin.html secure —
-- the anon key alone is not enough to change anything.
-- ============================================================

alter table products enable row level security;

drop policy if exists "Public can read products" on products;
create policy "Public can read products"
  on products for select
  using (true);

drop policy if exists "Admins can insert products" on products;
create policy "Admins can insert products"
  on products for insert
  to authenticated
  with check (true);

drop policy if exists "Admins can update products" on products;
create policy "Admins can update products"
  on products for update
  to authenticated
  using (true);

drop policy if exists "Admins can delete products" on products;
create policy "Admins can delete products"
  on products for delete
  to authenticated
  using (true);

-- ============================================================
-- Seed data — your current catalog, with starter stock counts.
-- Feel free to edit quantities to match reality, or just add
-- everything through the admin panel instead and skip this.
-- ============================================================

insert into products (name, line, condition, grade, battery, price, storage, screen, camera, chip, image_url, source_url, stock_quantity, low_stock_threshold) values
('iPhone 11', 'iPhone', 'Refurbished', 'B', 80, 24999, array['64GB','128GB'], '6.1″', '12MP dual', 'A13 Bionic', 'https://commons.wikimedia.org/wiki/Special:FilePath/IPhone 11 Product RED.jpg', 'https://commons.wikimedia.org/wiki/File:IPhone_11_Product_RED.jpg', 6, 3),
('iPhone 12', 'iPhone', 'Refurbished', 'B', 85, 34999, array['64GB','128GB'], '6.1″', '12MP dual', 'A14 Bionic', 'https://commons.wikimedia.org/wiki/Special:FilePath/Iphone-12-product--red.png', 'https://commons.wikimedia.org/wiki/File:Iphone-12-product--red.png', 5, 3),
('iPhone 13', 'iPhone', 'Refurbished', 'A', 90, 54999, array['128GB','256GB'], '6.1″', '12MP dual', 'A15 Bionic', 'https://commons.wikimedia.org/wiki/Special:FilePath/IPhone 13.jpg', 'https://commons.wikimedia.org/wiki/File:IPhone_13.jpg', 8, 3),
('iPhone 14', 'iPhone', 'Refurbished', 'A', 92, 74999, array['128GB','256GB'], '6.1″', '12MP dual', 'A15 Bionic', 'https://commons.wikimedia.org/wiki/Special:FilePath/Back view of iPhone 14 Blue.jpg', 'https://commons.wikimedia.org/wiki/Category:IPhone_14', 2, 3),
('iPhone 15', 'iPhone', 'New', null, 100, 119999, array['128GB','256GB'], '6.1″', '48MP dual', 'A16 Bionic', 'https://commons.wikimedia.org/wiki/Special:FilePath/Apple_iPhone_15.png', 'https://commons.wikimedia.org/wiki/File:Apple_iPhone_15.png', 10, 3),
('iPhone 16', 'iPhone', 'New', null, 100, 149999, array['128GB','256GB'], '6.1″', '48MP dual', 'A18', 'https://commons.wikimedia.org/wiki/Special:FilePath/Back of iPhone 16.jpg', 'https://commons.wikimedia.org/wiki/File:Back_of_iPhone_16.jpg', 7, 3),
('iPhone 17', 'iPhone', 'New', null, 100, 169999, array['256GB','512GB'], '6.3″', '48MP dual', 'A19', 'https://commons.wikimedia.org/wiki/Special:FilePath/White iPhone 17 (cropped).jpg', 'https://commons.wikimedia.org/wiki/File:White_iPhone_17_(cropped).jpg', 4, 3),
('iPhone 17 Pro Max', 'iPhone', 'New', null, 100, 249999, array['256GB','512GB','1TB'], '6.9″', '48MP triple', 'A19 Pro', 'https://commons.wikimedia.org/wiki/Special:FilePath/Deep Blue iPhone 17 Pro Max (cropped).jpg', 'https://commons.wikimedia.org/wiki/File:Deep_Blue_iPhone_17_Pro_Max_(cropped).jpg', 3, 3),
('Galaxy A15', 'Galaxy A', 'New', null, 100, 24999, array['64GB','128GB'], '6.5″', '50MP triple', 'Helio G99', 'https://commons.wikimedia.org/wiki/Special:FilePath/Samsung Galaxy A15 20240529 HOF7502 RAW-Export cens.png', 'https://commons.wikimedia.org/wiki/Category:Samsung_Galaxy_A15', 9, 3),
('Galaxy A35', 'Galaxy A', 'New', null, 100, 38999, array['128GB','256GB'], '6.6″', '50MP triple', 'Exynos 1380', 'https://commons.wikimedia.org/wiki/Special:FilePath/Samsung Galaxy A35 5G 2024 (1).jpg', 'https://commons.wikimedia.org/wiki/File:Samsung_Galaxy_A35_5G_2024_(1).jpg', 6, 3),
('Galaxy A55', 'Galaxy A', 'New', null, 100, 54999, array['128GB','256GB'], '6.6″', '50MP triple', 'Exynos 1480', 'https://commons.wikimedia.org/wiki/Special:FilePath/Samsung Galaxy A55 5G 2024 (cropped).jpg', 'https://commons.wikimedia.org/wiki/File:Samsung_Galaxy_A55_5G_2024_(cropped).jpg', 0, 3),
('Galaxy S21', 'Galaxy S', 'Refurbished', 'A', 88, 32999, array['128GB'], '6.2″', '64MP triple', 'Snapdragon 888', 'https://commons.wikimedia.org/wiki/Special:FilePath/GalaxyS21 (cropped).png', 'https://commons.wikimedia.org/wiki/File:GalaxyS21_(cropped).png', 4, 3),
('Galaxy S23', 'Galaxy S', 'New', null, 100, 99999, array['256GB'], '6.1″', '50MP triple', 'Snapdragon 8 Gen 2', 'https://commons.wikimedia.org/wiki/Special:FilePath/Galaxy S23 (cropped).png', 'https://commons.wikimedia.org/wiki/File:Galaxy_S23_(cropped).png', 5, 3),
('Galaxy S24', 'Galaxy S', 'New', null, 100, 129999, array['256GB','512GB'], '6.2″', '50MP triple', 'Snapdragon 8 Gen 3', 'https://commons.wikimedia.org/wiki/Special:FilePath/Samsung Galaxy S24.jpg', 'https://commons.wikimedia.org/wiki/File:Samsung_Galaxy_S24.jpg', 6, 3),
('Galaxy S25', 'Galaxy S', 'New', null, 100, 159999, array['256GB','512GB'], '6.2″', '50MP triple', 'Snapdragon 8 Elite', 'https://commons.wikimedia.org/wiki/Special:FilePath/Galaxy S25 Black (front).png', 'https://commons.wikimedia.org/wiki/File:Galaxy_S25_Black_(front).png', 8, 3);
