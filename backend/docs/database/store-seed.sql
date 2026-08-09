INSERT INTO "Stores"
(
    "Id",
    "Name",
    "Slug",
    "ShortDescription",
    "Description",
    "LogoUrl",
    "BannerUrl",
    "WebsiteUrl",
    "DefaultCashbackText",
    "IsFeatured",
    "DisplayOrder",
    "IsActive",
    "CreatedAt",
    "UpdatedAt"
)
VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'Myntra',
    'myntra',
    'Fashion and lifestyle shopping',
    'Shop fashion, beauty and lifestyle products.',
    '/media/stores/myntra.png',
    '/media/stores/myntra-banner.png',
    'https://www.myntra.com',
    'Up to 10% Cashback',
    TRUE,
    1,
    TRUE,
    CURRENT_TIMESTAMP,
    NULL
),
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    'Flipkart',
    'flipkart',
    'Electronics, fashion and more',
    'Shop electronics, fashion and household products.',
    '/media/stores/flipkart.png',
    '/media/stores/flipkart-banner.png',
    'https://www.flipkart.com',
    'Up to 7% Cashback',
    TRUE,
    2,
    TRUE,
    CURRENT_TIMESTAMP,
    NULL
),
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    'MakeMyTrip',
    'makemytrip',
    'Flights, hotels and holiday bookings',
    'Book travel, hotels, flights and holiday packages.',
    NULL,
    '/media/stores/makemytrip-banner.png',
    'https://www.makemytrip.com',
    'Up to ₹500 Cashback',
    FALSE,
    3,
    TRUE,
    CURRENT_TIMESTAMP,
    NULL
)
ON CONFLICT ("Slug") DO NOTHING;

INSERT INTO "StoreCategories"
(
    "StoreId",
    "CategoryId"
)
VALUES
(
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    '11111111-1111-1111-1111-111111111111'
),
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '11111111-1111-1111-1111-111111111111'
),
(
    'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
    '22222222-2222-2222-2222-222222222222'
),
(
    'cccccccc-cccc-cccc-cccc-cccccccccccc',
    '33333333-3333-3333-3333-333333333333'
)
ON CONFLICT ("StoreId", "CategoryId") DO NOTHING;