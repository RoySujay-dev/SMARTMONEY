# Catalogue media

Where the images behind categories, stores and offers come from, and how to
change them.

## Two hosting paths

| Media | Stored in | URL form in the database |
| --- | --- | --- |
| Category icons | Supabase Storage, public bucket `catalogue-media`, prefix `categories/` | absolute `https://<project-ref>.supabase.co/storage/v1/object/public/catalogue-media/categories/<slug>.png` |
| Store logos / banners, offer images | `SmartMoney.Api/wwwroot/media/`, served at `/media/...` by `UseStaticFiles` | relative `/media/stores/<file>.png` |

The client handles both: `NetworkImageWithFallback` passes absolute `http(s)`
URLs through untouched and resolves relative ones against the configured API
base URL. So the two can coexist, and store/offer media can move to Supabase
later without a client change.

Category icons moved to Supabase so they are served from a CDN instead of the
API process, and so they survive a redeploy that rebuilds `wwwroot`. The PNGs
stay committed under `wwwroot/media/categories` as the source of truth — the
bucket is a mirror, not the original.

## Replacing a category icon

1. Drop the new PNG over the old one in
   `backend/src/SmartMoney.Api/wwwroot/media/categories/<slug>.png`.

   Keep the format the assets already use: square, 256×256, transparent
   background, artwork cropped tight to its own bounding box. The tile insets
   the image by 10% of the circle diameter, so a PNG with its own baked-in
   margin renders noticeably small.

2. Mirror it to the bucket:

   ```powershell
   $env:SUPABASE_URL = 'https://<project-ref>.supabase.co'
   $env:SUPABASE_SERVICE_ROLE_KEY = '<service role key>'
   node backend/tools/upload-category-media.mjs
   ```

   The upload overwrites in place, so the public URL does not change and no SQL
   has to run again. Objects are served with `cache-control: public, 3600`, so
   a replaced icon can take up to an hour to propagate.

## Adding a new category icon

Add the PNG, run the upload script, then add a matching `UPDATE` line to
[`media-seed.sql`](media-seed.sql) and run it against the database. A category
only gets an `IconUrl` once its object exists — a row pointing at a missing
object renders a broken image, whereas a `NULL` renders the tinted initial
fallback, which looks deliberate.

## Credentials

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are the same values the API
reads from user-secrets as `SupabaseStorage:Url` and
`SupabaseStorage:ServiceRoleKey`. The service role key bypasses row-level
security — keep it out of the repo and out of any client bundle.
