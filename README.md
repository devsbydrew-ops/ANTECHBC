# Antech Gadgets — production setup guide

This is a static site (`index.html` + `admin.html`) that talks directly to
a Supabase project for its database and admin login. There's no server to
run — Supabase *is* the backend, and you can host the two HTML files
anywhere that serves static files.

## 1. Create your Supabase project

1. Go to [supabase.com](https://supabase.com) and create a free account/project.
2. Pick a region close to Kenya (e.g. an EU or ME region) for faster loads.
3. Wait for the project to finish provisioning (a couple of minutes).

## 2. Set up the database

1. In your Supabase project, open **SQL Editor** → **New query**.
2. Paste the entire contents of `schema.sql` from this folder and click **Run**.
3. This creates the `products` table, locks it down with Row Level Security
   (public can read, only logged-in admins can write), and seeds it with
   your current 15-device catalog.

## 3. Create your admin login

1. In Supabase: **Authentication → Users → Add user**.
2. Enter your email and a password. Untick "Auto confirm" only if you want
   to verify by email first — for a single owner account, ticking "Auto
   confirm" is fine.
3. This is the email/password you'll use to sign in at `admin.html`.

You can add more staff accounts the same way later.

## 4. Connect the frontend to Supabase

1. In Supabase: **Settings → API**.
2. Copy the **Project URL** and the **anon public** key (never the
   `service_role` key — that one must stay secret and isn't used here).
3. Open both `index.html` and `admin.html` and fill in near the top of the
   `<script>` section:
   ```js
   const SUPABASE_URL = "https://your-project-ref.supabase.co";
   const SUPABASE_ANON_KEY = "your-anon-public-key";
   ```
4. In `index.html`, also set your real WhatsApp number:
   ```js
   const WHATSAPP_NUMBER = "2547XXXXXXXX"; // no + or spaces
   ```

The anon key is safe to expose in client-side code — Supabase is designed
this way. The Row Level Security policies in `schema.sql` are what
actually stop random visitors from editing your catalog.

## 5. Test it locally first

Just open `index.html` in a browser (or run a tiny local server, e.g.
`npx serve` in this folder) and confirm devices load and you can sign in
at `admin.html`.

## 6. Deploy

Easiest options, both free for a site like this:

**Vercel**
1. Push this folder to a GitHub repo (or use `vercel` CLI with `vercel deploy`).
2. Import the repo at [vercel.com/new](https://vercel.com/new).
3. No build command needed — it's static HTML. Deploy.

**Netlify**
1. Drag and drop this folder onto [app.netlify.com/drop](https://app.netlify.com/drop), or connect the GitHub repo.
2. Deploy — again, no build step required.

Either gives you a `*.vercel.app` / `*.netlify.app` URL immediately.

## 7. Connect your own domain

Once deployed, both Vercel and Netlify have a **Domains** tab where you
add your own domain (e.g. `antechgadgets.co.ke`) and update your DNS
records (usually just an A record or CNAME) at wherever you registered
the domain. They'll issue a free HTTPS certificate automatically.

## What you get

- **Storefront** (`index.html`) — live product data from Supabase, cart,
  compare, WhatsApp ordering, out-of-stock and low-stock badges.
- **Admin** (`admin.html`) — real email/password login via Supabase Auth,
  add devices, edit every field (not just price), delete devices, and a
  low-stock warning banner summarizing anything at or below its threshold.
- Changes made in admin are visible on the storefront as soon as the page
  is reloaded — no manual sync step, because both pages read the same
  Supabase table.

## Things to tighten up before real launch

- **Payments**: right now checkout hands off to WhatsApp / a placeholder
  M-Pesa button. If you want in-site M-Pesa (STK push), that needs a small
  server-side function (Supabase Edge Functions work well for this) — ask
  me if you want to build that next.
- **Order history**: there's currently no orders table — WhatsApp is your
  order log. I can add an `orders` table that records what's in the cart
  when someone checks out, if you want a proper order history.
- **Images**: seeded images point to Wikimedia Commons for demo purposes.
  For a real store, use your own product photos — Supabase Storage is a
  good place to host those.
- **Multiple staff accounts / roles**: right now any authenticated user
  can edit everything. If you'll have staff who should only view (not
  edit), that needs a small roles table plus a policy update — also happy
  to help with that when you're ready.
# ANTECH
# ANTECH
# ANTECHBC
