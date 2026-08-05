START TRANSACTION;
CREATE TABLE "AffiliateNetworks" (
    "Id" uuid NOT NULL,
    "Name" character varying(150) NOT NULL,
    "Code" character varying(50) NOT NULL,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "PK_AffiliateNetworks" PRIMARY KEY ("Id")
);

CREATE TABLE "Categories" (
    "Id" uuid NOT NULL,
    "Name" character varying(100) NOT NULL,
    "Slug" character varying(120) NOT NULL,
    "Description" character varying(500),
    "IconUrl" character varying(1000),
    "DisplayOrder" integer NOT NULL DEFAULT 0,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "PK_Categories" PRIMARY KEY ("Id")
);

CREATE TABLE "Stores" (
    "Id" uuid NOT NULL,
    "Name" character varying(150) NOT NULL,
    "Slug" character varying(170) NOT NULL,
    "ShortDescription" character varying(300),
    "Description" character varying(2000),
    "LogoUrl" character varying(1000),
    "BannerUrl" character varying(1000),
    "WebsiteUrl" character varying(1000) NOT NULL,
    "DefaultCashbackText" character varying(150),
    "IsFeatured" boolean NOT NULL DEFAULT FALSE,
    "DisplayOrder" integer NOT NULL DEFAULT 0,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "PK_Stores" PRIMARY KEY ("Id")
);

CREATE TABLE "Offers" (
    "Id" uuid NOT NULL,
    "StoreId" uuid NOT NULL,
    "Title" character varying(200) NOT NULL,
    "Slug" character varying(220) NOT NULL,
    "OfferType" integer NOT NULL,
    "ShortDescription" character varying(500),
    "Description" character varying(3000),
    "TermsAndConditions" character varying(5000),
    "ImageUrl" character varying(1000),
    "CashbackType" integer NOT NULL,
    "CashbackValue" numeric(12,2),
    "CashbackText" character varying(150),
    "CouponCode" character varying(100),
    "DestinationUrl" character varying(2000) NOT NULL,
    "StartAt" timestamp with time zone,
    "EndAt" timestamp with time zone,
    "IsFeatured" boolean NOT NULL DEFAULT FALSE,
    "Priority" integer NOT NULL DEFAULT 0,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "PK_Offers" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Offers_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES "Stores" ("Id") ON DELETE RESTRICT
);

CREATE TABLE "StoreAffiliateMappings" (
    "Id" uuid NOT NULL,
    "StoreId" uuid NOT NULL,
    "AffiliateNetworkId" uuid NOT NULL,
    "ExternalMerchantId" character varying(200) NOT NULL,
    "ExternalMerchantName" character varying(200),
    "MerchantUrl" character varying(2000),
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "LastSyncedAt" timestamp with time zone,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "PK_StoreAffiliateMappings" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_StoreAffiliateMappings_AffiliateNetworks_AffiliateNetworkId" FOREIGN KEY ("AffiliateNetworkId") REFERENCES "AffiliateNetworks" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_StoreAffiliateMappings_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES "Stores" ("Id") ON DELETE CASCADE
);

CREATE TABLE "StoreCategories" (
    "StoreId" uuid NOT NULL,
    "CategoryId" uuid NOT NULL,
    CONSTRAINT "PK_StoreCategories" PRIMARY KEY ("StoreId", "CategoryId"),
    CONSTRAINT "FK_StoreCategories_Categories_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES "Categories" ("Id") ON DELETE CASCADE,
    CONSTRAINT "FK_StoreCategories_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES "Stores" ("Id") ON DELETE CASCADE
);

CREATE TABLE "Banners" (
    "Id" uuid NOT NULL,
    "Title" character varying(200) NOT NULL,
    "Subtitle" character varying(300),
    "ImageUrl" character varying(1000) NOT NULL,
    "TargetType" integer NOT NULL,
    "StoreId" uuid,
    "OfferId" uuid,
    "CategoryId" uuid,
    "ExternalUrl" character varying(2000),
    "DisplayOrder" integer NOT NULL DEFAULT 0,
    "StartAt" timestamp with time zone,
    "EndAt" timestamp with time zone,
    "IsActive" boolean NOT NULL DEFAULT TRUE,
    "CreatedAt" timestamp with time zone NOT NULL,
    "UpdatedAt" timestamp with time zone,
    CONSTRAINT "PK_Banners" PRIMARY KEY ("Id"),
    CONSTRAINT "FK_Banners_Categories_CategoryId" FOREIGN KEY ("CategoryId") REFERENCES "Categories" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Banners_Offers_OfferId" FOREIGN KEY ("OfferId") REFERENCES "Offers" ("Id") ON DELETE RESTRICT,
    CONSTRAINT "FK_Banners_Stores_StoreId" FOREIGN KEY ("StoreId") REFERENCES "Stores" ("Id") ON DELETE RESTRICT
);

CREATE UNIQUE INDEX "IX_AffiliateNetworks_Code" ON "AffiliateNetworks" ("Code");

CREATE INDEX "IX_AffiliateNetworks_IsActive" ON "AffiliateNetworks" ("IsActive");

CREATE UNIQUE INDEX "IX_AffiliateNetworks_Name" ON "AffiliateNetworks" ("Name");

CREATE INDEX "IX_Banners_CategoryId" ON "Banners" ("CategoryId");

CREATE INDEX "IX_Banners_IsActive_DisplayOrder" ON "Banners" ("IsActive", "DisplayOrder");

CREATE INDEX "IX_Banners_OfferId" ON "Banners" ("OfferId");

CREATE INDEX "IX_Banners_StartAt_EndAt" ON "Banners" ("StartAt", "EndAt");

CREATE INDEX "IX_Banners_StoreId" ON "Banners" ("StoreId");

CREATE INDEX "IX_Categories_IsActive_DisplayOrder" ON "Categories" ("IsActive", "DisplayOrder");

CREATE UNIQUE INDEX "IX_Categories_Name" ON "Categories" ("Name");

CREATE UNIQUE INDEX "IX_Categories_Slug" ON "Categories" ("Slug");

CREATE INDEX "IX_Offers_IsActive_IsFeatured_Priority" ON "Offers" ("IsActive", "IsFeatured", "Priority");

CREATE UNIQUE INDEX "IX_Offers_Slug" ON "Offers" ("Slug");

CREATE INDEX "IX_Offers_StartAt_EndAt" ON "Offers" ("StartAt", "EndAt");

CREATE INDEX "IX_Offers_StoreId" ON "Offers" ("StoreId");

CREATE UNIQUE INDEX "IX_StoreAffiliateMappings_AffiliateNetworkId_ExternalMerchantId" ON "StoreAffiliateMappings" ("AffiliateNetworkId", "ExternalMerchantId");

CREATE INDEX "IX_StoreAffiliateMappings_IsActive" ON "StoreAffiliateMappings" ("IsActive");

CREATE UNIQUE INDEX "IX_StoreAffiliateMappings_StoreId_AffiliateNetworkId" ON "StoreAffiliateMappings" ("StoreId", "AffiliateNetworkId");

CREATE INDEX "IX_StoreCategories_CategoryId" ON "StoreCategories" ("CategoryId");

CREATE INDEX "IX_Stores_IsActive_IsFeatured_DisplayOrder" ON "Stores" ("IsActive", "IsFeatured", "DisplayOrder");

CREATE UNIQUE INDEX "IX_Stores_Name" ON "Stores" ("Name");

CREATE UNIQUE INDEX "IX_Stores_Slug" ON "Stores" ("Slug");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20260805085836_AddOffersCategoriesStores', '10.0.9');

COMMIT;

