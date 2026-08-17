INSERT INTO "Categories"
(
    "Id",
    "Name",
    "Slug",
    "Description",
    "IconUrl",
    "DisplayOrder",
    "IsActive",
    "CreatedAt",
    "UpdatedAt"
)
VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'Fashion',
    'fashion',
    'Fashion stores and cashback offers',
    'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/fashion.png',
    1,
    TRUE,
    CURRENT_TIMESTAMP,
    NULL
),
(
    '22222222-2222-2222-2222-222222222222',
    'Electronics',
    'electronics',
    'Electronics stores and cashback offers',
    'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/electronics.png',
    2,
    TRUE,
    CURRENT_TIMESTAMP,
    NULL
),
(
    '33333333-3333-3333-3333-333333333333',
    'Travel',
    'travel',
    'Travel bookings and cashback offers',
    'https://cvabvlhzfcfkownpeiat.supabase.co/storage/v1/object/public/catalogue-media/categories/travel.png',
    3,
    TRUE,
    CURRENT_TIMESTAMP,
    NULL
)
ON CONFLICT ("Slug") DO NOTHING;