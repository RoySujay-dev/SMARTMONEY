-- Populates catalogue media for existing rows.
--
-- The store/offer seed scripts insert with NULL image columns and use
-- ON CONFLICT DO NOTHING, so they will not backfill an already-seeded
-- database. Run this script once to attach the media served from
-- SmartMoney.Api/wwwroot/media (exposed at /media/... by UseStaticFiles).
--
-- Store and offer paths are stored relative on purpose: the client resolves
-- them against its configured API base URL, so the same rows work across
-- environments without hardcoding a host.
--
-- Category icons are the exception. They live in the public `catalogue-media`
-- bucket in Supabase Storage and are stored as absolute URLs, so they are
-- served from Supabase's CDN rather than from the API process. The client
-- passes absolute http(s) URLs through untouched (see
-- NetworkImageWithFallback), so both forms coexist without a code change.
-- The project ref below is public (it is in every storage URL the app already
-- requests) and is not a credential.

-- Category icons. One UPDATE per slug rather than a generated
-- '.../categories/' || "Slug" || '.png' expression: a row must only get a URL
-- when the matching object actually exists in the bucket, otherwise the app
-- swaps a clean tinted initial for a broken-image icon. Slugs with no row in
-- this database are simply no-ops.
--
-- Source-of-truth PNGs are kept in SmartMoney.Api/wwwroot/media/categories.
-- Re-upload after changing them: see docs/database/README-media.md.
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/fashion.png'         WHERE "Slug" = 'fashion';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/electronics.png'     WHERE "Slug" = 'electronics';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/travel.png'          WHERE "Slug" = 'travel';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/food-dining.png'     WHERE "Slug" = 'food-dining';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/groceries.png'       WHERE "Slug" = 'groceries';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/beauty.png'          WHERE "Slug" = 'beauty';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/health-wellness.png' WHERE "Slug" = 'health-wellness';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/home-kitchen.png'       WHERE "Slug" = 'home-kitchen';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/mobile-accessories.png' WHERE "Slug" = 'mobile-accessories';
UPDATE "Categories" SET "IconUrl" = 'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/entertainment.png'      WHERE "Slug" = 'entertainment';

UPDATE "Stores"
SET "LogoUrl"   = '/media/stores/myntra.png',
    "BannerUrl" = '/media/stores/myntra-banner.png'
WHERE "Slug" = 'myntra';

UPDATE "Stores"
SET "LogoUrl"   = '/media/stores/flipkart.png',
    "BannerUrl" = '/media/stores/flipkart-banner.png'
WHERE "Slug" = 'flipkart';

-- No brand logo asset is bundled for MakeMyTrip, so LogoUrl stays NULL and the
-- app renders its tinted initial fallback. Only the banner is set.
UPDATE "Stores"
SET "BannerUrl" = '/media/stores/makemytrip-banner.png'
WHERE "Slug" = 'makemytrip';

UPDATE "Offers"
SET "ImageUrl" = '/media/offers/myntra-cashback.png'
WHERE "Slug" = 'myntra-up-to-10-percent-cashback';

UPDATE "Offers"
SET "ImageUrl" = '/media/offers/flipkart-cashback.png'
WHERE "Slug" = 'flipkart-up-to-7-percent-cashback';

UPDATE "Offers"
SET "ImageUrl" = '/media/offers/makemytrip-cashback.png'
WHERE "Slug" = 'makemytrip-flat-500-cashback';
