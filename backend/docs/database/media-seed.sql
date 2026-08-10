-- Populates catalogue media for existing rows.
--
-- The store/offer seed scripts insert with NULL image columns and use
-- ON CONFLICT DO NOTHING, so they will not backfill an already-seeded
-- database. Run this script once to attach the media served from
-- SmartMoney.Api/wwwroot/media (exposed at /media/... by UseStaticFiles).
--
-- Paths are stored relative on purpose: the client resolves them against its
-- configured API base URL, so the same rows work across environments without
-- hardcoding a host.

-- Category icons. One UPDATE per slug rather than a generated
-- '/media/categories/' || "Slug" || '.png' expression: a row must only get a
-- URL when the matching file actually exists in wwwroot/media/categories,
-- otherwise the app swaps a clean tinted initial for a broken-image icon.
-- Slugs with no row in this database are simply no-ops.
UPDATE "Categories" SET "IconUrl" = '/media/categories/fashion.png'         WHERE "Slug" = 'fashion';
UPDATE "Categories" SET "IconUrl" = '/media/categories/electronics.png'     WHERE "Slug" = 'electronics';
UPDATE "Categories" SET "IconUrl" = '/media/categories/travel.png'          WHERE "Slug" = 'travel';
UPDATE "Categories" SET "IconUrl" = '/media/categories/food-dining.png'     WHERE "Slug" = 'food-dining';
UPDATE "Categories" SET "IconUrl" = '/media/categories/groceries.png'       WHERE "Slug" = 'groceries';
UPDATE "Categories" SET "IconUrl" = '/media/categories/beauty.png'          WHERE "Slug" = 'beauty';
UPDATE "Categories" SET "IconUrl" = '/media/categories/health-wellness.png' WHERE "Slug" = 'health-wellness';

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
