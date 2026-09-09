-- ===================================================
-- DMMS (外送菜單管理系統) 資料庫備份
-- 產生時間: 2026-09-09 16:14:11
-- 資料庫:   DMMS (schema: dmms)
-- 還原:     sqlcmd -S <server> -U sa -P <pwd> -C -d DMMS -i DMMS-backup-20260909.sql
-- ===================================================
SET NOCOUNT ON;
GO
IF SCHEMA_ID('dmms') IS NULL EXEC('CREATE SCHEMA dmms');
GO

IF OBJECT_ID('dmms.[AddOns]', 'U') IS NOT NULL DROP TABLE dmms.[AddOns];
IF OBJECT_ID('dmms.[Categories]', 'U') IS NOT NULL DROP TABLE dmms.[Categories];
IF OBJECT_ID('dmms.[ExportHistories]', 'U') IS NOT NULL DROP TABLE dmms.[ExportHistories];
IF OBJECT_ID('dmms.[PlatformProductMappings]', 'U') IS NOT NULL DROP TABLE dmms.[PlatformProductMappings];
IF OBJECT_ID('dmms.[Products]', 'U') IS NOT NULL DROP TABLE dmms.[Products];
IF OBJECT_ID('dmms.[SpecialOptionGroups]', 'U') IS NOT NULL DROP TABLE dmms.[SpecialOptionGroups];
IF OBJECT_ID('dmms.[ProductCategories]', 'U') IS NOT NULL DROP TABLE dmms.[ProductCategories];
IF OBJECT_ID('dmms.[ProductSizes]', 'U') IS NOT NULL DROP TABLE dmms.[ProductSizes];
IF OBJECT_ID('dmms.[SpecialOptions]', 'U') IS NOT NULL DROP TABLE dmms.[SpecialOptions];
IF OBJECT_ID('dmms.[ProductAddOns]', 'U') IS NOT NULL DROP TABLE dmms.[ProductAddOns];
IF OBJECT_ID('dmms.[ProductSpecialOptions]', 'U') IS NOT NULL DROP TABLE dmms.[ProductSpecialOptions];
IF OBJECT_ID('dmms.[MenuVersions]', 'U') IS NOT NULL DROP TABLE dmms.[MenuVersions];
IF OBJECT_ID('dmms.[MenuVersionProducts]', 'U') IS NOT NULL DROP TABLE dmms.[MenuVersionProducts];
IF OBJECT_ID('dmms.[AddOnSizes]', 'U') IS NOT NULL DROP TABLE dmms.[AddOnSizes];
GO

CREATE TABLE dmms.[ProductAddOns] (
    [ProductId] int NOT NULL,
    [AddOnId] int NOT NULL,
    [IsEnabled] bit NOT NULL DEFAULT (CONVERT([bit],(0))),
    CONSTRAINT [PK_ProductAddOns] PRIMARY KEY ([AddOnId], [ProductId])
);
CREATE TABLE dmms.[AddOnSizes] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [AddOnId] int NOT NULL,
    [SizeName] nvarchar(max) NOT NULL,
    [ExternalData] nvarchar(max) NOT NULL,
    [Price] decimal(18,2) NOT NULL,
    [IsEnabled] bit NOT NULL,
    [SortOrder] int NOT NULL,
    CONSTRAINT [PK_AddOnSizes] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[AddOns] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [EnglishName] nvarchar(max) NULL,
    [Price] decimal(18,2) NOT NULL,
    [ExternalData] nvarchar(max) NOT NULL,
    [IcedOnly] bit NOT NULL,
    [FixedRatio] bit NOT NULL,
    [IsEnabled] bit NOT NULL,
    [SortOrder] int NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_AddOns] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[ProductCategories] (
    [ProductId] int NOT NULL,
    [CategoryId] int NOT NULL,
    CONSTRAINT [PK_ProductCategories] PRIMARY KEY ([CategoryId], [ProductId])
);
CREATE TABLE dmms.[Categories] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [EnglishName] nvarchar(max) NULL,
    [SortOrder] int NOT NULL DEFAULT ((0)),
    [SourceExternalId] nvarchar(max) NULL,
    CONSTRAINT [PK_Categories] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[ExportHistories] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [CreatedAt] datetime2(7) NOT NULL,
    [Platform] nvarchar(max) NOT NULL,
    CONSTRAINT [PK_ExportHistories] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[PlatformProductMappings] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [Platform] nvarchar(max) NOT NULL,
    [OriginalExternalId] nvarchar(max) NULL,
    [Uuid] nvarchar(max) NULL,
    [OriginalName] nvarchar(max) NULL,
    [SourceMetadata] nvarchar(max) NULL,
    CONSTRAINT [PK_PlatformProductMappings] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[ProductSizes] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [ProductId] int NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [PriceAdjustment] decimal(18,2) NOT NULL,
    [ColdBaseCode] nvarchar(max) NULL,
    [HotBaseCode] nvarchar(max) NULL,
    [IsEnabled] bit NOT NULL,
    [SortOrder] int NOT NULL,
    CONSTRAINT [PK_ProductSizes] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[ProductSpecialOptions] (
    [ProductId] int NOT NULL,
    [SpecialOptionId] int NOT NULL,
    [IsEnabled] bit NOT NULL,
    CONSTRAINT [PK_ProductSpecialOptions] PRIMARY KEY ([ProductId], [SpecialOptionId])
);
CREATE TABLE dmms.[MenuVersionProducts] (
    [MenuVersionId] int NOT NULL,
    [ProductId] int NOT NULL,
    CONSTRAINT [PK_MenuVersionProducts] PRIMARY KEY ([MenuVersionId], [ProductId])
);
CREATE TABLE dmms.[Products] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [EnglishName] nvarchar(max) NULL,
    [Description] nvarchar(max) NULL,
    [ImageUrl] nvarchar(max) NULL,
    [BasePrice] decimal(18,2) NOT NULL,
    [IsEnabled] bit NOT NULL,
    [SortOrder] int NOT NULL,
    [SourceExternalId] nvarchar(max) NULL,
    [SourceUuid] nvarchar(max) NULL,
    [HasSizeGroup] bit NOT NULL DEFAULT (CONVERT([bit],(0))),
    [SweetnessAtProductLevel] bit NOT NULL DEFAULT (CONVERT([bit],(0))),
    CONSTRAINT [PK_Products] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[SpecialOptions] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [SpecialOptionGroupId] int NULL,
    [Kind] int NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [EnglishName] nvarchar(max) NULL,
    [ExternalDataMode] int NOT NULL,
    [Suffix] nvarchar(max) NULL,
    [StandaloneExternalData] nvarchar(max) NULL,
    [BeverageTemperature] int NULL,
    [IsEnabled] bit NOT NULL,
    CONSTRAINT [PK_SpecialOptions] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[SpecialOptionGroups] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [Min] int NOT NULL,
    [Max] int NOT NULL,
    CONSTRAINT [PK_SpecialOptionGroups] PRIMARY KEY ([Id])
);
CREATE TABLE dmms.[MenuVersions] (
    [Id] int IDENTITY(1,1) NOT NULL,
    [Name] nvarchar(max) NOT NULL,
    [Platform] nvarchar(max) NOT NULL,
    [Status] nvarchar(max) NOT NULL,
    [CreatedAt] datetime2(7) NOT NULL,
    [ExportedAt] datetime2(7) NULL,
    [MenuDisplayName] nvarchar(max) NOT NULL DEFAULT (N''),
    [MenuExternalId] nvarchar(max) NOT NULL DEFAULT (N''),
    [OpenHours] nvarchar(max) NOT NULL DEFAULT (N''),
    [StoreUuid] nvarchar(max) NULL,
    CONSTRAINT [PK_MenuVersions] PRIMARY KEY ([Id])
);
GO

-- ProductAddOns: 313 列
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (3, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (3, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (3, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (3, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (3, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (4, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (4, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (4, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (4, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (4, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (5, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (5, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (5, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (5, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (5, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (6, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (6, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (6, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (6, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (6, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (7, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (7, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (7, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (7, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (7, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (8, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (8, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (8, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (8, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (8, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (9, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (9, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (9, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (9, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (9, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (10, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (10, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (10, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (10, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (10, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (11, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (11, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (11, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (11, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (11, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (12, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (12, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (12, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (12, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (13, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (13, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (13, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (13, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (14, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (14, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (14, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (14, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (14, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (15, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (15, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (15, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (15, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (16, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (16, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (16, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (16, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (16, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (17, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (17, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (17, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (17, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (18, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (18, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (18, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (18, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (18, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (19, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (19, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (19, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (19, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (19, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (20, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (20, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (20, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (20, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (20, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (21, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (21, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (22, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (22, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (22, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (23, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (23, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (23, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (24, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (24, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (24, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (24, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (24, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (25, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (25, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (25, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (25, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (25, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (26, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (26, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (26, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (26, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (26, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (27, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (27, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (27, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (27, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (27, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (28, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (28, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (28, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (28, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (28, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (29, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (29, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (29, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (29, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (29, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (30, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (30, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (30, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (31, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (31, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (31, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (31, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (31, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (32, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (32, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (32, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (32, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (32, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (33, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (33, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (33, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (33, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (34, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (34, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (34, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (34, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (35, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (35, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (35, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (35, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (36, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (36, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (36, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (36, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (37, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (37, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (37, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (38, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (38, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (38, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (39, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (39, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (39, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (40, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (40, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (40, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (41, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (41, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (41, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (42, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (42, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (42, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (43, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (43, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (43, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (44, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (44, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (44, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (45, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (45, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (45, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (45, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (46, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (46, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (46, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (46, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (47, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (47, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (47, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (47, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (48, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (48, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (48, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (48, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (49, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (49, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (49, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (49, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (49, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (50, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (50, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (50, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (51, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (51, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (51, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (52, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (52, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (52, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (53, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (53, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (53, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (54, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (54, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (54, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (54, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (54, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (55, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (55, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (55, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (55, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (55, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (56, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (56, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (56, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (56, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (57, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (57, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (57, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (57, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (57, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (58, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (58, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (58, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (58, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (58, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (59, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (59, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (59, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (59, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (60, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (60, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (60, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (60, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (60, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (61, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (61, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (61, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (61, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (61, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (62, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (62, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (62, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (62, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (62, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (63, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (63, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (63, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (63, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (64, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (64, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (64, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (64, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (65, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (65, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (65, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (65, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (65, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (66, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (66, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (66, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (66, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (66, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (67, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (67, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (67, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (67, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (68, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (68, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (68, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (68, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (68, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (69, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (69, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (69, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (69, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (69, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (70, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (70, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (70, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (70, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (70, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (71, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (71, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (71, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (71, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (72, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (72, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (72, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (72, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (72, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (73, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (73, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (73, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (73, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (73, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (74, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (74, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (74, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (74, 5, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (74, 6, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (75, 2, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (75, 3, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (75, 4, 1);
INSERT INTO dmms.[ProductAddOns] ([ProductId], [AddOnId], [IsEnabled]) VALUES (75, 6, 1);

-- AddOnSizes: 2 列
SET IDENTITY_INSERT dmms.[AddOnSizes] ON;
INSERT INTO dmms.[AddOnSizes] ([Id], [AddOnId], [SizeName], [ExternalData], [Price], [IsEnabled], [SortOrder]) VALUES (1, 5, N'中杯', N'@IT1812(20)', 10.00, 1, 0);
INSERT INTO dmms.[AddOnSizes] ([Id], [AddOnId], [SizeName], [ExternalData], [Price], [IsEnabled], [SortOrder]) VALUES (2, 5, N'大杯', N'@IT1836(40)', 15.00, 1, 1);
SET IDENTITY_INSERT dmms.[AddOnSizes] OFF;

-- AddOns: 5 列
SET IDENTITY_INSERT dmms.[AddOns] ON;
INSERT INTO dmms.[AddOns] ([Id], [Name], [EnglishName], [Price], [ExternalData], [IcedOnly], [FixedRatio], [IsEnabled], [SortOrder]) VALUES (2, N'珍珠', N'Tapioca', 10.00, N'@IT1810(19)', 0, 0, 1, 0);
INSERT INTO dmms.[AddOns] ([Id], [Name], [EnglishName], [Price], [ExternalData], [IcedOnly], [FixedRatio], [IsEnabled], [SortOrder]) VALUES (3, N'仙草', N'Grass Jelly', 15.00, N'@IT1815(27)', 0, 0, 1, 0);
INSERT INTO dmms.[AddOns] ([Id], [Name], [EnglishName], [Price], [ExternalData], [IcedOnly], [FixedRatio], [IsEnabled], [SortOrder]) VALUES (4, N'茉香茶凍', N'Jasmine Jelly', 15.00, N'@IT1845(302)', 1, 0, 1, 0);
INSERT INTO dmms.[AddOns] ([Id], [Name], [EnglishName], [Price], [ExternalData], [IcedOnly], [FixedRatio], [IsEnabled], [SortOrder]) VALUES (5, N'醇香蜂蜜', N'Honey', 10.00, N'@IT1812(20)', 0, 1, 1, 0);
INSERT INTO dmms.[AddOns] ([Id], [Name], [EnglishName], [Price], [ExternalData], [IcedOnly], [FixedRatio], [IsEnabled], [SortOrder]) VALUES (6, N'六條麥茶凍', N'Wheat Tea Jelly', 15.00, N'@IT1839(45)', 1, 0, 1, 3);
SET IDENTITY_INSERT dmms.[AddOns] OFF;

-- ProductCategories: 77 列
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (3, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (4, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (5, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (6, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (7, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (8, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (9, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (10, 1);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (4, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (11, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (12, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (13, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (14, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (15, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (16, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (17, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (18, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (19, 2);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (5, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (20, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (21, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (22, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (23, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (24, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (25, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (26, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (27, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (28, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (29, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (30, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (31, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (32, 3);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (33, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (34, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (35, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (36, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (37, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (38, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (39, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (40, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (41, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (42, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (43, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (44, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (45, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (46, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (47, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (48, 4);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (6, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (49, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (50, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (51, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (52, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (53, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (54, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (55, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (56, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (57, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (58, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (59, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (60, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (61, 5);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (9, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (62, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (63, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (64, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (65, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (66, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (67, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (68, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (69, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (70, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (71, 6);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (72, 7);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (73, 7);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (74, 7);
INSERT INTO dmms.[ProductCategories] ([ProductId], [CategoryId]) VALUES (75, 7);

-- Categories: 7 列
SET IDENTITY_INSERT dmms.[Categories] ON;
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (1, N'人氣精選', N'Popular Items', 0, NULL);
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (2, N'經典原茶', N'Classic Tea', 1, NULL);
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (3, N'香醇奶茶', N'Milk Tea', 2, NULL);
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (4, N'醇蜜系列', N'Honey Beverage', 3, NULL);
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (5, N'純鮮奶茶', N'Fresh Milk Tea', 4, NULL);
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (6, N'新鮮果茶', N'Fruit Tea', 5, NULL);
INSERT INTO dmms.[Categories] ([Id], [Name], [EnglishName], [SortOrder], [SourceExternalId]) VALUES (7, N'無咖啡因', N'Tea without Caffeine', 6, NULL);
SET IDENTITY_INSERT dmms.[Categories] OFF;

-- ExportHistories: 0 列
SET IDENTITY_INSERT dmms.[ExportHistories] ON;
SET IDENTITY_INSERT dmms.[ExportHistories] OFF;

-- PlatformProductMappings: 0 列
SET IDENTITY_INSERT dmms.[PlatformProductMappings] ON;
SET IDENTITY_INSERT dmms.[PlatformProductMappings] OFF;

-- ProductSizes: 138 列
SET IDENTITY_INSERT dmms.[ProductSizes] ON;
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (291, 3, N'中杯', 0.00, N'IT0005-U', N'IT6005-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (292, 3, N'大杯', 10.00, N'IT0903-U', N'IT6903-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (294, 5, N'大杯', 0.00, N'IT1932-U', N'IT7925-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (295, 6, N'大杯', 0.00, N'IT2961-U', N'IT8936-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (296, 7, N'大杯', 0.00, N'IT0955-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (297, 8, N'大杯', 0.00, N'IT0956-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (298, 9, N'中杯', 0.00, N'IT3084-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (299, 9, N'大杯', 20.00, N'IT3973-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (300, 10, N'大杯', 0.00, N'IT3974-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (301, 11, N'中杯', 0.00, N'IT0059-U', N'IT6050-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (302, 11, N'大杯', 10.00, N'IT0954-U', N'IT6937-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (303, 12, N'中杯', 0.00, N'IT0001-U', N'IT6001-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (304, 12, N'大杯', 10.00, N'IT0901-U', N'IT6901-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (305, 13, N'中杯', 0.00, N'IT0002-U', N'IT6002-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (306, 13, N'大杯', 10.00, N'IT0902-U', N'IT6902-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (307, 14, N'中杯', 0.00, N'IT0011-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (308, 14, N'大杯', 20.00, N'IT0919-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (309, 15, N'中杯', 0.00, N'IT0016-U', N'IT6015-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (310, 15, N'大杯', 10.00, N'IT0914-U', N'IT6907-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (311, 16, N'中杯', 0.00, N'IT0021-U', N'IT6023-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (312, 16, N'大杯', 10.00, N'IT0921-U', N'IT6909-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (313, 17, N'中杯', 0.00, N'IT0034-U', N'IT6030-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (314, 17, N'大杯', 10.00, N'IT0928-U', N'IT6916-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (315, 18, N'中杯', 0.00, N'IT0007-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (316, 18, N'大杯', 10.00, N'IT0911-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (317, 19, N'中杯', 0.00, N'IT0060-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (318, 19, N'大杯', 10.00, N'IT0961-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (319, 20, N'中杯', 0.00, N'IT1048-U', N'IT7041-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (320, 20, N'大杯', 15.00, N'IT1934-U', N'IT7928-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (321, 21, N'中杯', 0.00, N'IT1001-U', N'IT7001-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (322, 21, N'大杯', 10.00, N'IT1910-U', N'IT7901-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (323, 22, N'中杯', 0.00, N'IT1002-U', N'IT7002-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (324, 22, N'大杯', 10.00, N'IT1909-U', N'IT7902-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (325, 23, N'中杯', 0.00, N'IT1003-U', N'IT7003-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (326, 23, N'大杯', 10.00, N'IT1901-U', N'IT7903-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (327, 24, N'中杯', 0.00, N'IT1005-U', N'IT7005-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (328, 24, N'大杯', 10.00, N'IT1911-U', N'IT7905-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (329, 25, N'中杯', 0.00, N'IT1014-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (330, 26, N'中杯', 0.00, N'IT1020-U', N'IT7017-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (331, 26, N'大杯', 10.00, N'IT1912-U', N'IT7906-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (332, 27, N'中杯', 0.00, N'IT1021-U', N'IT7018-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (333, 27, N'大杯', 10.00, N'IT1913-U', N'IT7907-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (334, 28, N'中杯', 0.00, N'IT1030-U', N'IT7025-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (335, 28, N'大杯', 10.00, N'IT1918-U', N'IT7909-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (336, 29, N'中杯', 0.00, N'IT1010-U', N'IT7010-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (337, 29, N'大杯', 20.00, N'IT1903-U', N'IT7908-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (338, 30, N'中杯', 0.00, N'IT1004-U', N'IT7004-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (339, 30, N'大杯', 10.00, N'IT1902-U', N'IT7904-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (340, 31, N'中杯', 0.00, N'IT1049-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (341, 31, N'大杯', 10.00, N'IT1935-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (342, 32, N'中杯', 0.00, N'IT1050-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (343, 32, N'大杯', 10.00, N'IT1936-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (344, 33, N'中杯', 0.00, N'IT0003-U', N'IT6040-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (345, 33, N'大杯', 15.00, N'IT0904-U', N'IT6927-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (346, 34, N'中杯', 0.00, N'IT0004-U', N'IT6041-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (347, 34, N'大杯', 15.00, N'IT0905-U', N'IT6928-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (348, 35, N'中杯', 0.00, N'IT0018-U', N'IT6042-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (349, 35, N'大杯', 15.00, N'IT0915-U', N'IT6929-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (350, 36, N'中杯', 0.00, N'IT0047-U', N'IT6043-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (351, 36, N'大杯', 15.00, N'IT0942-U', N'IT6930-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (352, 37, N'中杯', 0.00, N'IT1007-U', N'IT7032-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (353, 37, N'大杯', 15.00, N'IT1915-U', N'IT7916-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (354, 38, N'中杯', 0.00, N'IT1008-U', N'IT7033-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (355, 38, N'大杯', 15.00, N'IT1914-U', N'IT7917-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (356, 39, N'中杯', 0.00, N'IT1023-U', N'IT7034-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (357, 39, N'大杯', 15.00, N'IT1916-U', N'IT7920-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (358, 40, N'中杯', 0.00, N'IT1024-U', N'IT7035-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (359, 40, N'大杯', 15.00, N'IT1917-U', N'IT7921-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (360, 41, N'中杯', 0.00, N'IT2020-U', N'IT8041-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (361, 41, N'大杯', 30.00, N'IT2915-U', N'IT8928-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (362, 42, N'中杯', 0.00, N'IT2021-U', N'IT8040-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (363, 42, N'大杯', 30.00, N'IT2916-U', N'IT8927-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (364, 43, N'中杯', 0.00, N'IT2022-U', N'IT8042-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (365, 43, N'大杯', 30.00, N'IT2917-U', N'IT8932-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (366, 44, N'中杯', 0.00, N'IT2023-U', N'IT8043-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (367, 44, N'大杯', 30.00, N'IT2918-U', N'IT8931-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (368, 45, N'中杯', 0.00, N'IT2063-U', N'IT8039-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (369, 45, N'大杯', 30.00, N'IT2950-U', N'IT8926-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (370, 46, N'中杯', 0.00, N'IT3003-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (371, 46, N'大杯', 30.00, N'IT3910-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (372, 47, N'中杯', 0.00, N'IT3004-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (373, 47, N'大杯', 30.00, N'IT3911-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (374, 48, N'中杯', 0.00, N'IT3077-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (375, 48, N'大杯', 30.00, N'IT3924-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (376, 49, N'中杯', 0.00, N'IT2074-U', N'IT8050-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (377, 49, N'大杯', 20.00, N'IT2967-U', N'IT8938-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (378, 50, N'中杯', 0.00, N'IT2001-U', N'IT8001-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (379, 50, N'大杯', 25.00, N'IT2902-U', N'IT8904-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (380, 51, N'中杯', 0.00, N'IT2002-U', N'IT8002-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (381, 51, N'大杯', 25.00, N'IT2901-U', N'IT8903-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (382, 52, N'中杯', 0.00, N'IT2003-U', N'IT8003-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (383, 52, N'大杯', 25.00, N'IT2903-U', N'IT8907-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (384, 53, N'中杯', 0.00, N'IT2004-U', N'IT8004-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (385, 53, N'大杯', 25.00, N'IT2904-U', N'IT8906-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (386, 54, N'中杯', 0.00, N'IT2006-U', N'IT8006-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (387, 54, N'大杯', 25.00, N'IT2923-U', N'IT8910-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (388, 55, N'中杯', 0.00, N'IT2008-U', N'IT8009-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (389, 55, N'大杯', 25.00, N'IT2911-U', N'IT8912-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (390, 56, N'中杯', 0.00, N'IT2044-U', N'IT8027-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (391, 56, N'大杯', 25.00, N'IT2928-U', N'IT8914-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (392, 57, N'中杯', 0.00, N'IT2012-U', N'IT8012-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (393, 57, N'大杯', 25.00, N'IT2909-U', N'IT8908-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (394, 58, N'中杯', 0.00, N'IT2013-U', N'IT8013-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (395, 58, N'大杯', 25.00, N'IT2913-U', N'IT8909-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (396, 59, N'中杯', 0.00, N'IT2030-U', N'IT8021-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (397, 59, N'大杯', 25.00, N'IT2922-U', N'IT8913-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (398, 60, N'中杯', 0.00, N'IT2075-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (399, 60, N'大杯', 15.00, N'IT2968-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (400, 61, N'中杯', 0.00, N'IT2076-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (401, 61, N'大杯', 15.00, N'IT2969-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (402, 62, N'中杯', 0.00, N'IT3085-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (403, 62, N'大杯', 20.00, N'IT3976-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (404, 63, N'中杯', 0.00, N'IT3001-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (405, 63, N'大杯', 25.00, N'IT3901-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (406, 64, N'中杯', 0.00, N'IT3002-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (407, 64, N'大杯', 25.00, N'IT3902-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (408, 65, N'中杯', 0.00, N'IT3006-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (409, 65, N'大杯', 25.00, N'IT3903-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (410, 66, N'中杯', 0.00, N'IT3074-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (411, 66, N'大杯', 25.00, N'IT3960-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (412, 67, N'中杯', 0.00, N'IT3007-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (413, 67, N'大杯', 25.00, N'IT3904-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (414, 68, N'中杯', 0.00, N'IT3008-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (415, 68, N'大杯', 25.00, N'IT3912-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (416, 69, N'中杯', 0.00, N'IT3080-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (417, 69, N'大杯', 25.00, N'IT3967-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (418, 70, N'中杯', 0.00, N'IT3081-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (419, 70, N'大杯', 25.00, N'IT3970-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (420, 71, N'中杯', 0.00, N'IT3083-U', NULL, 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (421, 71, N'大杯', 25.00, N'IT3972-U', NULL, 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (422, 72, N'中杯', 0.00, N'IT9104-U', N'IT9016-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (423, 72, N'大杯', 10.00, N'IT9107-U', N'IT9019-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (424, 73, N'中杯', 0.00, N'IT9105-U', N'IT9017-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (425, 73, N'大杯', 25.00, N'IT9109-U', N'IT9021-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (426, 74, N'中杯', 0.00, N'IT9106-U', N'IT9018-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (427, 74, N'大杯', 25.00, N'IT9110-U', N'IT9022-U', 1, 1);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (428, 75, N'大杯', 0.00, N'IT9108-U', N'IT9020-U', 1, 0);
INSERT INTO dmms.[ProductSizes] ([Id], [ProductId], [Name], [PriceAdjustment], [ColdBaseCode], [HotBaseCode], [IsEnabled], [SortOrder]) VALUES (430, 4, N'&amp;#x5927;&amp;#x676F;', 0.00, N'IT0953-U', N'IT6935-U', 1, 0);
SET IDENTITY_INSERT dmms.[ProductSizes] OFF;

-- ProductSpecialOptions: 597 列
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (3, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (4, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (5, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (6, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (7, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (8, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (9, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (10, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (11, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (12, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (13, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (14, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (15, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (16, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (17, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (18, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (19, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (20, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (21, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (22, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (23, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (24, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (25, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (26, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (27, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (28, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (29, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (30, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (31, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (32, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (33, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (33, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (33, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (33, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (33, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (34, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (34, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (34, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (34, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (34, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (35, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (35, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (35, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (35, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (35, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (36, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (36, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (36, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (36, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (36, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (37, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (37, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (37, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (37, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (37, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (38, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (38, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (38, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (38, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (38, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (39, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (39, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (39, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (39, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (39, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (40, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (40, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (40, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (40, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (40, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (41, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (41, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (41, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (41, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (41, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (42, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (42, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (42, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (42, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (42, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (43, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (43, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (43, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (43, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (43, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (44, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (44, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (44, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (44, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (44, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (45, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (45, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (45, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (45, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (45, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (46, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (46, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (46, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (47, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (47, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (47, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (48, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (48, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (48, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (49, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (50, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (51, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (52, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (53, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (54, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (55, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (56, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (57, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (58, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (59, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (60, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (61, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (62, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (63, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (64, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (65, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (66, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (67, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (68, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (69, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (70, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (71, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (72, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (73, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 9, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 10, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 11, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (74, 12, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 3, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 4, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 5, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 6, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 7, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 8, 1);
INSERT INTO dmms.[ProductSpecialOptions] ([ProductId], [SpecialOptionId], [IsEnabled]) VALUES (75, 13, 1);

-- MenuVersionProducts: 73 列
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 3);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 4);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 5);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 6);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 7);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 8);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 9);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 10);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 11);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 12);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 13);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 14);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 15);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 16);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 17);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 18);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 19);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 20);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 21);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 22);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 23);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 24);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 25);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 26);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 27);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 28);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 29);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 30);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 31);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 32);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 33);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 34);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 35);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 36);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 37);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 38);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 39);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 40);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 41);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 42);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 43);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 44);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 45);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 46);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 47);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 48);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 49);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 50);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 51);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 52);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 53);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 54);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 55);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 56);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 57);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 58);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 59);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 60);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 61);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 62);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 63);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 64);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 65);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 66);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 67);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 68);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 69);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 70);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 71);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 72);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 73);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 74);
INSERT INTO dmms.[MenuVersionProducts] ([MenuVersionId], [ProductId]) VALUES (1, 75);

-- Products: 73 列
SET IDENTITY_INSERT dmms.[Products] ON;
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (3, N'913 茶王', N'913 Tea', N'天仁招牌茶, 採用高山烏龍茶薰製美國花旗蔘, 自然回甘, 請您細細品嘗。中杯總糖量: 32 公克。中杯總熱量: 140 大卡。中杯咖啡因: 121 毫克。大杯總糖量: 54 公克。大杯總熱量: 233 大卡。大杯咖啡因: 156 毫克。原產地: 台灣。', N'https://tb-static.uber.com/prod/image-proc/processed_images/f90bc63e464b26f4b8519c1929a56924/d03e52b3c8af19d8fa8222e23efd9cfa.jpeg', 70.00, 1, 0, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (4, N'茶王', NULL, NULL, NULL, 65.00, 1, 3, NULL, NULL, 0, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (5, N'茶王 1953 奶茶', N'King''s Oolong 1953 Milk Tea', N'採用天仁限定烏龍茶調製而成的奶茶, 自然濃郁甘醇。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 448 大卡。大杯冰飲咖啡因: 140 毫克。茶產地: 台灣。', NULL, 75.00, 1, 2, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (6, N'茶王 1953 鮮奶茶', N'King''s Oolong 1953 Tea Latte', N'天仁限店烏龍茶與香濃鮮奶的新組合, 為你帶來濃郁又甘醇的滋味。大杯冰飲總糖量: 63 公克。大杯冰飲總熱量: 356 大卡。大杯冰飲咖啡因: 145 毫克。茶產地: 台灣。', NULL, 110.00, 1, 3, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (7, N'多多綠茶', N'Probiotic Green Tea', N'經典天仁綠茶, 搭配多多飲品, 熟悉滋味與綠茶的清爽相融, 入口清新解渴。大杯冰飲總糖量: 93 公克。大杯冰飲總熱量: 416 大卡。大杯冰飲咖啡因: 113 毫克。茶產地: 台灣。', NULL, 75.00, 1, 4, NULL, NULL, 0, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (8, N'多多洛神冰茶', N'Probiotic Roselle Green Tea', N'每日新鮮熬煮洛神原汁, 釋放洛神的酸甜風味與鮮紅色澤, 搭配天仁優質綠茶與優多飲品, 洛神果韻酸甜有層次。大杯冰飲總糖量: 90 公克。大杯冰飲總熱量: 414 大卡。大杯冰飲咖啡因: 57 毫克。原產地: 台灣。', NULL, 80.00, 1, 5, NULL, NULL, 0, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (9, N'913 桑葚果釀', N'913 King''s Oolong Mulberry Vinegar Tea', N'以 913 茶王基底, 醇厚茶韻, 搭配台灣在地桑椹果釀, 經過長時間靜置手工發酵釀造熟成, 無添加糖, 時間淬鍊下散發極致自然原味, 天然全新風味。中杯冰飲總糖量: 76 公克。中杯冰飲總熱量: 328 大卡。咖啡因含量: 87 毫克。大杯冰飲總糖量: 109 公克。大杯冰飲總熱量: 475 大卡。咖啡因含量: 87 毫克。茶產地: 台灣。', NULL, 105.00, 1, 6, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (10, N'多多檸檬綠茶', N'Probiotic Lemon Green Tea', N'以清新綠茶為基底, 加入 HPP 台灣檸檬汁, 完整保留檸檬的鮮香與營養, 搭配多多飲品, 酸甜熟悉的滋味在口中綻放。大杯冰飲總糖量: 107 公克。大杯冰飲總熱量: 491 大卡。大杯冰飲咖啡因: 28 毫克。茶產地: 台灣。', NULL, 115.00, 1, 7, NULL, NULL, 0, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (11, N'一茉綠', N'Jasmine Green Tea', N'以綠茶的清新為底, 揉捻茉莉花的芬芳, 茶香與花香交織出淡雅時光。中杯冰飲總糖量: 143 公克。中杯冰飲總熱量: 32 大卡。中杯冰飲咖啡因: 207 毫克。大杯冰飲總糖量: 237 公克。大杯冰飲總熱量: 54 大卡。大杯冰飲咖啡因: 266 毫克。茶產地：越南。', NULL, 45.00, 1, 8, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (12, N'經典綠茶', N'Classic Green Tea', N'新鮮, 甘醇的綠茶是一年四季皆可品飲的最優茶。中杯總糖量: 32 公克。中杯總熱量: 143 大卡。中杯咖啡因: 158 毫克。大杯總糖量: 54 公克。大杯總熱量: 237 大卡。大杯咖啡因: 204 毫克。原產地: 台灣。', NULL, 50.00, 1, 9, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (13, N'經典紅茶', N'Classic Black Tea', N'阿薩姆紅茶醇厚紮實的風味, 飲用時順入口喉, 立即回甘。中杯總糖量: 32 公克。中杯總熱量: 138 大卡。中杯咖啡因: 178 毫克。大杯總糖量: 54 公克。大杯總熱量: 230 大卡。大杯咖啡因: 229 毫克。原產地: 印度。', NULL, 50.00, 1, 10, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (14, N'桂花金萱冰茶', N'Jinxuan Iced Tea with Osmanthus', N'金萱的牛奶香味薰以秋天桂花的香氣, 茶湯透澈, 滋味清雅。中杯冰飲總糖量: 32  公克, 中杯冰飲總熱量: 141 大卡。大杯冰飲總糖量: 54 公克, 大杯冰飲總熱量: 235 大卡。原產地: 台灣。', NULL, 80.00, 1, 11, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (15, N'菊花普洱茶', N'Pu-Er Tea with Chrysanthemum', N'普洱湯色栗紅, 滋味醇厚圓滑, 加上菊花香氣, 獨特的風韻是茶中極品。中杯總糖量: 32 公克。中杯總熱量: 140 大卡。中杯咖啡因: 327 毫克。大杯總糖量: 54 公克。大杯總熱量: 233 大卡。大杯咖啡因: 421 毫克。原產地: 中國。', NULL, 70.00, 1, 12, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (16, N'炟客烏龍茶', N'Roasted Oolong', N'限店茶飲。透過烘焙技巧, 使茶葉及茶湯色澤加深, 口感濃厚, 喉韻濃洌甘醇。中杯總糖量: 32 公克。中杯總熱量: 140 大卡。中杯咖啡因: 271 毫克。大杯總糖量: 54 公克。大杯總熱量: 233 大卡。大杯咖啡因: 349 毫克。原產地: 台灣。', NULL, 70.00, 1, 13, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (17, N'四季烏龍', N'Sihji Oolong Tea', N'以當季的上等烏龍茶所調製, 喉韻甘醇濃郁。中杯總糖量: 32 公克。中杯總熱量: 140 大卡。中杯咖啡因: 159 毫克。大杯總糖量: 54 公克。大杯總熱量: 233 大卡。大杯咖啡因: 204 毫克。原產地: 台灣。', NULL, 60.00, 1, 14, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (18, N'洛神冰茶', N'Roselle Iced Tea', N'洛神加上甘醇的綠茶, 酸澀又帶點香甜的滋味。中杯總糖量: 65 公克。中杯總熱量: 291 大卡。中杯咖啡因: 57 毫克。大杯總糖量: 93 公克。大杯總熱量: 419 大卡。大杯咖啡因: 74 毫克。原產地: 台灣。', N'https://tb-static.uber.com/prod/image-proc/processed_images/ee17f9e4e00b86e229d151c66744aa8c/d03e52b3c8af19d8fa8222e23efd9cfa.jpeg', 60.00, 1, 15, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (19, N'紅烏龍', N'Red Oolong', N'嚴選紅烏龍茶葉沖泡, 兼具紅茶的甘甜與烏龍茶的醇厚, 茶湯帶有天然熟果香與蜜香, 入口溫潤順口, 尾韻回甘, 是一款層次豐富, 耐人回味的特色茶飲。中杯冰飲總糖量: 32 公克。中杯冰飲總熱量: 138 大卡。咖啡因含量: 69 毫克。大杯冰飲總糖量: 47 公克。大杯冰飲總熱量: 199 大卡。咖啡因含量: 91 毫克。原產地: 台灣。', NULL, 45.00, 1, 16, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (20, N'茉香奶綠', N'Jasmine Milk Green Tea', N'以嚴選茉莉綠茶為基底, 融合細緻奶香, 茶湯中帶有淡雅花香與濃郁滑順口感。入口柔和順口, 甜而不膩, 是經典不敗的奶茶選擇, 適合喜愛香濃風味的族群。中杯冰飲總糖量: 288 公克。中杯冰飲總熱量: 37 大卡。中杯冰飲咖啡因: 207 毫克。大杯冰飲總糖量: 453 公克。大杯冰飲總熱量: 61 大卡。大杯冰飲咖啡因: 266 毫克。茶產地：越南。', NULL, 55.00, 1, 17, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (21, N'茶香奶綠', N'Jasmine Milk Green Tea', N'天仁的濃郁奶綠, 包含著清新與濃醇的好滋味。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 288 大卡。中杯冰飲咖啡因: 158 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 453 大卡。大杯冰飲咖啡因: 204 毫克。中杯熱飲總糖量: 41 公克。中杯熱飲總熱量: 432 大卡。中杯熱飲咖啡因: 158 毫克。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 597 大卡。大杯咖啡因: 204 毫克。原產地: 台灣。', NULL, 60.00, 1, 18, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (22, N'金香奶茶', N'Assam Black Tea with Milk', N'阿薩姆紅茶搭配濃厚的奶香, 香醇濃郁美味可口。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 282 大卡。中杯冰飲咖啡因: 178 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 446 大卡。大杯冰飲咖啡因: 229 毫克。中杯熱飲總糖量: 41 公克。中杯熱飲總熱量: 426 大卡。中杯熱飲咖啡因: 178 毫克。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 590 大卡。大杯熱飲咖啡因: 229 毫克。原產地: 印度。', NULL, 60.00, 1, 19, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (23, N'珍珠奶綠', N'Milk Green Tea with Tapioca', N'特調綠茶調製而成的奶綠, 加上香 Q 的珍珠, 清香自然又濃郁。中杯冰飲總糖量: 44 公克。中杯冰飲總熱量: 410 大卡。中杯冰飲咖啡因: 113 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 592 大卡。大杯冰飲咖啡因: 141 毫克。中杯熱飲總糖量: 48 公克。中杯熱飲總熱量: 555 大卡。中杯熱飲咖啡因: 113 毫克。大杯熱飲總糖量: 66 公克。大杯熱飲總熱量: 736 大卡。大杯熱飲咖啡因: 141 毫克。原產地: 台灣。', NULL, 60.00, 1, 20, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (24, N'913 奶茶', N'913 Milk Tea', N'採用天仁的招牌烏龍茶調製而成的奶茶, 自然濃郁甘醇。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 285 大卡。中杯冰飲咖啡因: 121 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 449 大卡。大杯冰飲咖啡因: 156 毫克。中杯熱飲總糖量: 41 公克。中杯熱飲總熱量: 429 大卡。中杯熱飲咖啡因: 121 毫克。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 594 大卡。大杯熱飲咖啡因: 156 毫克。原產地: 台灣。', NULL, 80.00, 1, 21, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (25, N'抹茶冰淇淋奶綠', N'Milk Green Tea with Matcha Ice Cream', N'限店茶飲。抹茶冰淇淋加上香濃滑順的奶綠, 搭配出豐富口感。中杯冰飲總糖量: 48 公克。中杯冰飲總熱量: 464 大卡。咖啡因: 125 毫克。原產地: 台灣。', NULL, 100.00, 1, 22, NULL, NULL, 0, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (26, N'普洱奶茶', N'Pu-Er Milk Tea', N'醇厚回甘的菊花普洱茶調製而成的奶茶, 獨特風味, 值得一嚐再嚐。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 285 大卡。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 449 大卡。中杯熱飲總糖量: 41 公克。中杯熱飲總熱量: 429 大卡。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 594 大卡。中杯咖啡因: 327 毫克、大杯咖啡因: 421 毫克。原產地: 中國。', NULL, 80.00, 1, 23, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (27, N'炟客奶茶', N'Roasted Milk Tea', N'限店茶飲。以重焙火的烏龍喉韻製成的醇厚奶茶, 濃郁口感, 是夏日裡的沁涼茶飲。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 285 大卡。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 449 大卡。中杯熱飲總糖量: 41 公克。中杯熱飲總熱量: 429 大卡。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 594 大卡。中杯咖啡因: 271 毫克、大杯咖啡因: 349 毫克。原產地: 台灣。', NULL, 80.00, 1, 24, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (28, N'四季烏龍奶茶', N'Sihji Oolong Milk Tea', N'以四季春烏龍茶所調製的烏龍奶茶, 口感濃郁清香。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 285 大卡。中杯冰飲咖啡因: 159 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 449 大卡。大杯冰飲咖啡因: 204 毫克。中杯熱飲總糖量: 41 公克。中杯熱飲總熱量: 429 大卡。中杯熱飲咖啡因: 159 毫克。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 594 大卡。大杯熱飲咖啡因: 204 毫克。原產地: 台灣。', NULL, 70.00, 1, 25, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (29, N'香芋奶綠', N'Milk Green Tea with Taro', N'每日新鮮現煮芋頭讓您每一口都品嘗到濃濃的芋香。中杯冰飲總糖量: 52 公克。中杯冰飲總熱量: 379 大卡。大杯冰飲總糖量: 65 公克。大杯冰飲總熱量: 500 大卡。中杯熱飲總糖量: 57 公克。中杯熱飲總熱量: 523 大卡。大杯熱飲總糖量: 70 公克。大杯熱飲總熱量: 645 大卡。中杯咖啡因: 113 毫克、大杯咖啡因: 141 毫克。原產地: 台灣。', N'https://tb-static.uber.com/prod/image-proc/processed_images/21e38be5ddc38d4a84bdb8d04ffb4f39/d03e52b3c8af19d8fa8222e23efd9cfa.jpeg', 85.00, 1, 26, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (30, N'珍珠奶茶', N'Milk Tea with Tapioca', N'嚴選阿薩姆紅茶調製而成的奶茶, 加上香 Q 的珍珠, 香醇濃郁超好喝。中杯冰飲總糖量: 44 公克。中杯冰飲總熱量: 406 大卡。中杯冰飲咖啡因: 127 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 587 大卡。大杯咖啡因: 159 毫克。中杯熱飲總糖量: 48 公克。中杯熱飲總熱量: 551 大卡。中杯熱飲咖啡因: 127 毫克。大杯熱飲總糖量: 66 公克。大杯熱飲總熱量: 731 大卡。大杯熱飲咖啡因: 159 毫克。原產地: 印度。', N'https://tb-static.uber.com/prod/image-proc/processed_images/23a74d002b096d55da63e743b1bec4a0/d03e52b3c8af19d8fa8222e23efd9cfa.jpeg', 60.00, 1, 27, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (31, N'甜漾紅烏龍奶茶', N'Red Ooloong Milk Tea', N'以香醇紅烏龍為基底, 搭配濃郁奶香調製, 茶香與奶香完美融合, 口感滑順細緻, 保留紅烏龍獨特的焙香與甘甜, 每一口都香濃不膩。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 282 大卡。咖啡因含量: 55 毫克。大杯冰飲總糖量: 53 公克。大杯冰飲總熱量: 415 大卡。咖啡因含量: 73 毫克。原產地: 台灣。', NULL, 55.00, 1, 28, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (32, N'甜漾奶綠', N'Green Milk Tea', N'以茉香綠茶為茶底, 融合香濃奶香, 散發淡雅茉莉花香與清新茶韻。入口滑順, 茶香清雅, 奶香柔和, 清爽不甜膩, 是經典耐喝的奶茶選擇。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 284 大卡。咖啡因含量: 89 毫克。大杯冰飲總糖量: 53 公克。大杯冰飲總熱量: 418 大卡。咖啡因含量: 118 毫克。原產地: 越南。', NULL, 55.00, 1, 29, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (33, N'醇蜜綠茶', N'Green Tea with Honey', N'甜度固定。嚴選真蜂蜜，綿延的甜蜜與綠茶香完美結合。
中杯冰/熱飲總糖量：23公克。中杯冰/熱飲總熱量：109大卡。咖啡因含量：113毫克。
大杯冰/熱飲總糖量：37公克。大杯冰/熱飲總熱量：168大卡。咖啡因含量：159毫克。
原產地：台灣', NULL, 60.00, 1, 30, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (34, N'醇蜜紅茶', N'Black Tea with Honey', N'甜度固定。嚴選真蜂蜜，綿延的甜蜜與紅茶香完美結合。
中杯冰/熱飲總糖量：23公克。中杯冰/熱飲總熱量：105大卡。咖啡因含量：127毫克。
大杯冰/熱飲總糖量：37公克。大杯冰/熱飲總熱量：168大卡。咖啡因含量：159毫克。
原產地：台灣', NULL, 60.00, 1, 31, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (35, N'醇蜜菊普茶', N'Chrysanthemum and Pu-er Tea with Honey', N'甜度固定。嚴選真蜂蜜，綿延的甜蜜與菊普茶香完美結合。
中杯冰/熱飲總糖量：23公克。中杯冰/熱飲總熱量：107大卡。咖啡因含量：234毫克。
大杯冰/熱飲總糖量：37公克。大杯冰/熱飲總熱量：171大卡。咖啡因含量：292毫克。
原產地：台灣', NULL, 80.00, 1, 32, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (36, N'醇蜜四季烏龍', N'Sihji Oolong with Honey', N'甜度固定。嚴選真蜂蜜，綿延的甜蜜與四季烏龍茶香完美結合。
中杯冰/熱飲總糖量：23公克。中杯冰/熱飲總熱量：107大卡。咖啡因含量：113毫克。
大杯冰/熱飲總糖量：37公克。大杯冰/熱飲總熱量：171大卡。咖啡因含量：142毫克。
原產地：台灣', NULL, 70.00, 1, 33, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (37, N'醇蜜奶綠', N'Milk Green Tea with Honey', N'甜度固定。', NULL, 70.00, 1, 34, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (38, N'醇蜜奶茶', N'Milk Tea with Honey', N'甜度固定。', NULL, 70.00, 1, 35, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (39, N'醇蜜珍珠奶茶', N'Tapioca Milk Tea with Honey', N'甜度固定。', NULL, 70.00, 1, 36, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (40, N'醇蜜珍珠奶綠', N'Tapioca Milk Green Tea with Honey', N'甜度固定。', NULL, 70.00, 1, 37, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (41, N'醇蜜鮮奶茶', N'Fresh Milk Tea with Hoeny', N'甜度固定。濃醇蜜香搭配香濃的鮮奶茶，入口滑順，完美調和。
中杯冰/熱飲總糖量：29公克。中杯冰/熱飲總熱量：193大卡。咖啡因含量：96毫克。
大杯冰/熱飲總糖量：47公克。大杯冰/熱飲總熱量：303大卡。咖啡因含量：142毫克。
原產地：台灣', NULL, 95.00, 1, 38, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (42, N'醇蜜鮮奶綠', N'Fresh Milk Green Tea with Honey', N'甜度固定。濃醇蜜香搭配香濃的鮮奶綠，入口滑順，完美調和。
中杯冰/熱飲總糖量：29公克。中杯冰/熱飲總熱量：193大卡。咖啡因含量：96毫克。
大杯冰/熱飲總糖量：47公克。大杯冰/熱飲總熱量：303大卡。咖啡因含量：142毫克。
原產地：台灣', NULL, 95.00, 1, 39, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (43, N'醇蜜珍珠鮮奶茶', N'Tapioca Fresh Milk Tea with Honey', N'甜度固定。', NULL, 95.00, 1, 40, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (44, N'醇蜜珍珠鮮奶綠', N'Tapioca Fresh Milk Green Tea with Honey', N'甜度固定。', NULL, 95.00, 1, 41, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (45, N'醇蜜四季鮮奶茶', N'Sihji Fresh Milk Tea with Honey', N'甜度固定。濃醇蜜香搭配香濃的四季烏龍鮮奶茶，入口滑順，完美調和。
中杯冰/熱飲總糖量：29公克。中杯冰飲總熱量：193大卡。咖啡因含量：96毫克。
大杯冰飲總糖量：47公克。大杯冰飲總熱量：303大卡。咖啡因含量：142毫克。
原產地：台灣', NULL, 105.00, 1, 42, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (46, N'醇蜜檸檬綠茶', N'Green Tea with Hoeny and Lemon', N'甜度固定。蜂蜜與檸檬的相遇，再搭配綠茶，帶給您清爽的酸甜好滋味。
中杯冰飲總糖量：37公克。中杯冰飲總熱量：177大卡。咖啡因含量：102毫克。
大杯冰飲總糖量：45公克。大杯冰飲總熱量：218大卡。咖啡因含量：136毫克。
原產地：台灣', NULL, 95.00, 1, 43, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (47, N'醇蜜檸檬紅茶', N'Black Tea with Hoeny and Lemon', N'甜度固定。蜂蜜與檸檬的相遇，再搭配紅茶，帶給您清爽的酸甜好滋味。
中杯冰飲總糖量：37公克。中杯冰飲總熱量：174大卡。咖啡因含量：114毫克。
大杯冰飲總糖量：45公克。大杯冰飲總熱量：213大卡。咖啡因含量：152毫克。
原產地：台灣', NULL, 95.00, 1, 44, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (48, N'醇蜜檸檬四季烏龍', N'Sihji Oolong with Honey and Lemon', N'甜度固定。蜂蜜與檸檬的相遇，帶給您清爽的酸甜好滋味。
中杯冰飲總糖量：37公克。中杯冰飲總熱量：175大卡。咖啡因含量：102毫克。
大杯冰飲總糖量：45公克。大杯冰飲總熱量：216大卡。咖啡因含量：136毫克。
原產地：台灣', NULL, 105.00, 1, 45, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (49, N'茉香鮮奶綠', N'Jasmine  Green Tea Latte', N'選用清香茉莉綠茶, 搭配新鮮牛奶調製而成, 保留茶葉本身的自然花香, 同時增添溫潤奶香。整體口感清爽不厚重, 風味純淨, 是追求清新口感的理想選擇。中杯冰飲總糖量: 219 公克。中杯冰飲總熱量: 38 大卡。中杯冰飲咖啡因: 133 毫克。大杯冰飲總糖量: 358 公克。大杯冰飲總熱量: 63 大卡。大杯冰飲咖啡因: 192 毫克。茶產地：越南。', NULL, 80.00, 1, 46, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (50, N'鮮奶綠', N'Fresh Milk Green Tea', N'香濃的鮮奶加上糖香濃郁的優等綠茶, 香濃綿密的鮮奶泡中不失鮮採綠茶的茶香。中杯冰飲總糖量: 38 公克。中杯冰飲總熱量: 227 大卡。中杯冰飲咖啡因: 96 毫克。大杯冰飲總糖量: 63 公克。大杯冰飲總熱量: 367 大卡。大杯冰飲咖啡因: 141 毫克。中杯熱飲總糖量: 39 公克。中杯熱飲總熱量: 241 大卡。中杯熱飲咖啡因: 113 毫克。大杯熱飲總糖量: 64 公克。大杯熱飲總熱量: 381 大卡。大杯熱飲咖啡因: 158 毫克。原產地: 台灣。', NULL, 85.00, 1, 47, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (51, N'鮮奶茶', N'Fresh Milk Tea', N'香濃的鮮奶加上糖香濃郁的優等紅茶, 香濃綿密的鮮奶泡中不失鮮採茶的茶香。中杯冰飲總糖量: 38 公克。中杯冰飲總熱量: 224 大卡。中杯冰飲咖啡因: 108 毫克。大杯冰飲總糖量: 63 公克。大杯冰飲總熱量: 362 大卡。大杯冰飲咖啡因: 159 毫克。中杯熱飲總糖量: 39 公克。中杯熱飲總熱量: 237 大卡。中杯熱飲咖啡因: 127 毫克。大杯熱飲總糖量: 64 公克。大杯熱飲總熱量: 375 大卡。大杯熱飲咖啡因: 178 毫克。原產地: 印度。', NULL, 85.00, 1, 48, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (52, N'珍珠鮮奶茶', N'Fresh Milk Tea with Tapioca', N'香濃鮮奶與紅茶調製成新鮮奶茶, 搭配香 Q 的珍珠, 是您更加健康的新選擇, 享受美味也能輕鬆無負擔。中杯冰飲總糖量: 44 公克。中杯冰飲總熱量: 335 大卡。中杯冰飲咖啡因: 102 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 470 大卡。大杯冰飲咖啡因: 127 毫克。中杯熱飲總糖量: 45 公克。中杯熱飲總熱量: 349 大卡。中杯熱飲咖啡因: 114 毫克。大杯熱飲總糖量: 63 公克。大杯熱飲總熱量: 491 大卡。大杯熱飲咖啡因: 140 毫克。原產地: 印度。', NULL, 85.00, 1, 49, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (53, N'珍珠鮮奶綠', N'Fresh Milk Green Tea with Tapioca', N'香濃鮮奶與綠茶調製成新鮮奶綠, 搭配香 Q 的珍珠, 是您更加健康的新選擇, 享受美味也能輕鬆無負擔。中杯冰飲總糖量: 44 公克。中杯冰飲總熱量: 338 大卡。中杯冰飲咖啡因: 91 毫克。大杯冰飲總糖量: 61 公克。大杯冰飲總熱量: 474 大卡。大杯冰飲咖啡因: 113 毫克。中杯熱飲總糖量: 45 公克。中杯熱飲總熱量: 352 大卡。中杯熱飲咖啡因: 102 毫克。大杯熱飲總糖量: 63 公克。大杯熱飲總熱量: 494 大卡。大杯熱飲咖啡因: 124 毫克。原產地: 台灣。', NULL, 85.00, 1, 50, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (54, N'香芋鮮奶綠', N'Fresh Milk Green Tea with Taro', N'使用現煮新鮮芋頭和頂級鮮奶調配而成, 有濃濃的芋頭香, 奶香, 絕對讓你念念不忘。中杯冰飲總糖量: 53 公克。中杯冰飲總熱量: 307 大卡。中杯冰飲咖啡因: 91 毫克。大杯冰飲總糖量: 65 公克。大杯冰飲總熱量: 382 大卡。大杯冰飲咖啡因: 113 毫克。中杯熱飲總糖量: 54 公克。中杯熱飲總熱量: 320 大卡。中杯冰飲咖啡因: 102 毫克。大杯熱飲總糖量: 65 公克。大杯熱飲總熱量: 391 大卡。大杯熱飲咖啡因: 124 毫克。原產地: 台灣。', NULL, 110.00, 1, 51, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (55, N'913 鮮奶茶', N'913 Fresh Milk Tea', N'天仁的招牌烏龍茶與香濃鮮奶的新組合, 為你帶來濃郁又甘醇的滋味。中杯冰飲總糖量: 38 公克。中杯冰飲總熱量: 225 大卡。中杯冰飲咖啡因: 74 毫克。大杯冰飲總糖量: 63 公克。大杯冰飲總熱量: 364 大卡。大杯冰飲咖啡因: 108 毫克。中杯熱飲總糖量: 39 公克。中杯熱飲總熱量: 239 大卡。中杯熱飲咖啡因: 87 毫克。大杯熱飲總糖量: 64 公克。大杯熱飲總熱量: 378 大卡。大杯熱飲咖啡因: 121 毫克。原產地: 台灣。', NULL, 105.00, 1, 52, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (56, N'四季烏龍鮮奶茶', N'Sihji Oolong Fresh Milk Tea', N'以四季春烏龍結合鮮乳所調製, 入口濃醇奶香中透出了清新茶香。中杯冰飲總糖量: 38 公克。中杯冰飲總熱量: 225 大卡。中杯冰飲咖啡因: 96 毫克。大杯冰飲總糖量: 63 公克。大杯冰飲總熱量: 364 大卡。大杯冰飲咖啡因: 142 毫克。中杯熱飲總糖量: 39 公克。中杯熱飲總熱量: 239 大卡。中杯熱飲咖啡因: 113 毫克。大杯熱飲總糖量: 64 公克。大杯熱飲總熱量: 378 大卡。大杯熱飲咖啡因: 159 毫克。原產地: 台灣。', NULL, 95.00, 1, 53, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (57, N'普洱拿鐵', N'Pu-Er Latte', N'香濃鮮奶加上醇厚回甘的菊花普洱茶, 是您嚐鮮的最佳選擇。中杯冰飲總糖量: 38 公克。中杯冰飲總熱量: 225 大卡。中杯冰飲咖啡因: 199 毫克。大杯冰飲總糖量: 63 公克。大杯冰飲總熱量: 364 大卡。大杯冰飲咖啡因: 292 毫克。中杯熱飲總糖量: 39 公克。中杯熱飲總熱量: 239 大卡。中杯熱飲咖啡因: 234 毫克。大杯熱飲總糖量: 64 公克。大杯熱飲總熱量: 378 大卡。大杯熱飲咖啡因: 327 毫克。原產地: 中國。', NULL, 105.00, 1, 54, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (58, N'炟客拿鐵', N'Roasted Latte', N'限店茶飲。香濃鮮奶加上重焙火的烏龍喉韻, 茶香奶香一飲而下, 絕對齒頰留香。中杯冰飲總糖量 : 38  公克。中杯冰飲總熱量 : 231  大卡。大杯冰飲總糖量 : 53  公克。大杯冰飲總熱量 : 323  大卡。原產地 : 台灣。', NULL, 105.00, 1, 55, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (59, N'仙草鮮奶茶', N'Fresh Milk Tea', N'限店茶飲。古早味的仙草滑順又 Q 彈, 搭配濃香鮮奶茶是最懷舊的新茶飲。中杯冰飲總糖量: 42 公克。中杯冰飲總熱量: 235 大卡。中杯冰飲咖啡因: 108 毫克。大杯冰飲總糖量: 52 公克。大杯冰飲總熱量:317 大卡。大杯冰飲咖啡因: 133 毫克。中杯熱飲總糖量: 43 公克。中杯熱飲總熱量:248 大卡。中杯熱飲咖啡因: 121 毫克。大杯熱飲總糖量: 54 公克。大杯熱飲總熱量: 317 大卡。大杯熱飲咖啡因: 146 毫克。原產地: 印度。', NULL, 90.00, 1, 56, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (60, N'甜漾紅烏龍鮮奶茶', N'Red Oolong Fresh Milk Tea', N'選用紅烏龍茶搭配新鮮鮮奶, 呈現自然純粹的風味。鮮奶的濃醇襯托出紅烏龍的蜜香與回甘, 口感更加清爽柔順, 享受茶與鮮奶最純粹的比例。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 196 大卡。咖啡因含量: 46 毫克。大杯冰飲總糖量: 52 公克。大杯冰飲總熱量: 277 大卡。咖啡因含量: 64 毫克。原產地: 台灣。', NULL, 70.00, 1, 57, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (61, N'甜漾鮮奶綠', N'Green Fresh Milk Tea', N'選用茉香綠茶搭配新鮮鮮奶調製, 茉莉花香自然淡雅, 茶感清新, 鮮奶香醇順口, 層次細膩且口感輕盈, 呈現清爽又富有質感的鮮奶茶風味。中杯冰飲總糖量: 37 公克。中杯冰飲總熱量: 198 大卡。咖啡因含量: 74 毫克。大杯冰飲總糖量: 52 公克。大杯冰飲總熱量: 280 大卡。咖啡因含量: 103 毫克。原產地: 越南。', NULL, 70.00, 1, 58, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (62, N'茉莉百香果釀', N'Jasmine Passionfruit Vinegar Green Tea', N'以茉莉綠茶為底, 加入香氣濃郁的百香果醋, 交織出清新花香與酸甜果韻。口感輕盈爽口, 層次豐富, 特別適合炎熱天氣飲用, 帶來沁涼解渴的享受。中杯冰飲總糖量: 286 公克。中杯冰飲總熱量: 66 大卡。中杯冰飲咖啡因: 148 毫克。大杯冰飲總糖量: 412 公克。大杯冰飲總熱量: 95 大卡。大杯冰飲咖啡因: 199 毫克。茶產地：越南。', NULL, 105.00, 1, 59, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (63, N'檸檬綠茶', N'Lemon Green Tea', N'新鮮現榨檸檬汁加上綠茶, 酸酸甜甜天然好滋味。中杯冰飲總糖量: 65 公克。中杯冰飲總熱量: 288 大卡。中杯冰飲咖啡因: 113 毫克。大杯冰飲總糖量: 93 公克。大杯冰飲總熱量: 412 大卡。大杯冰飲咖啡因: 158 毫克。原產地: 台灣。', NULL, 85.00, 1, 60, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (64, N'檸檬紅茶', N'Lemon Black Tea', N'新鮮現榨檸檬汁加上紅茶, 酸酸甜甜天然好滋味。中杯冰飲總糖量: 65 公克。中杯冰飲總熱量: 284 大卡。中杯冰飲咖啡因: 127 毫克。大杯冰飲總糖量: 93 公克。大杯冰飲總熱量: 407 大卡。大杯冰飲咖啡因: 178 毫克。原產地: 台灣。', NULL, 85.00, 1, 61, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (65, N'香橙綠茶', N'Orange Green Tea', N'使用 HPP 台灣鮮榨柳丁汁搭配綠茶, 保有新鮮柳丁風味的果茶。中杯冰飲總糖量: 47 公克。中杯冰飲總熱量: 219 大卡。中杯冰飲咖啡因: 57 毫克。大杯冰飲總糖量: 76 公克。大杯冰飲總熱量: 354 大卡。大杯冰飲咖啡因: 91 毫克。原產地: 台灣。', NULL, 85.00, 1, 62, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (66, N'香橙四季烏龍', N'Sihji Oolong with Orange', N'使用 HPP 台灣鮮榨柳丁汁搭配四季烏龍茶, 保有新鮮柳丁風味的果茶。中杯冰飲總糖量: 47 公克。中杯冰飲總熱量: 218 大卡。中杯冰飲咖啡因: 57 毫克。大杯冰飲總糖量: 76 公克。大杯冰飲總熱量: 353 大卡。大杯冰飲咖啡因: 91 毫克。原產地: 台灣。', NULL, 95.00, 1, 63, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (67, N'金桔綠茶', N'Kumquat Green Tea', N'飲品含有蜂蜜。清新的綠茶加上新鮮的金桔, 檸檬, 茶味清新, 口感解膩。中杯冰飲總糖量: 56 公克。中杯冰飲總熱量: 257 大卡。中杯冰飲咖啡因: 113 毫克。大杯冰飲總糖量: 92 公克。大杯冰飲總熱量: 422 大卡。大杯冰飲咖啡因: 158 毫克。原產地: 台灣。', NULL, 85.00, 1, 64, NULL, NULL, 1, 1);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (68, N'梅子綠茶', N'Plum Green Tea', N'特別調製的酸梅原汁消暑祕方, 絕對讚不絕口。中杯冰飲總糖量: 50 公克。中杯冰飲總熱量: 239 大卡。中杯冰飲咖啡因: 113 毫克。大杯冰飲總糖量: 90 公克。大杯冰飲總熱量: 430 大卡。大杯冰飲咖啡因: 158 毫克。原產地: 台灣。', NULL, 85.00, 1, 65, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (69, N'金橙綠果茶', N'Kumquat Green Tea with Orange', N'結合金桔的清酸, 柳橙的果香甜韻, 加上綠茶的清爽底味, 呈現酸甜層次, 完美平衡。中杯冰飲總糖量: 47 公克。中杯冰飲總熱量: 222 大卡。咖啡因含量: 57 毫克。大杯冰飲總糖量: 76 公克。大杯冰飲總熱量: 360 大卡。咖啡因含量: 91 毫克。茶產地: 台灣。', NULL, 110.00, 1, 66, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (70, N'西西里冰茶', N'Sicilian Iced Tea', N'不含咖啡, 以火味十足的炟客烏龍取代咖啡基底, 透過與檸檬酸甜結合完美比例, 還原西西里的特色, 在炙熱夏日上市, 急速解熱! 中杯冰飲總糖量: 94 公克。中杯冰飲總熱量: 412 大卡。咖啡因含量: 194 毫克。大杯冰飲總糖量: 112 公克。大杯冰飲總熱量: 495 大卡。咖啡因含量: 271 毫克。茶產地: 台灣。', NULL, 110.00, 1, 67, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (71, N'西西里凍飲', N'Sicilian Iced Drink', N'不含咖啡, 以火味十足的炟客烏龍取代咖啡基底, 與檸檬酸甜結合完美比例, 再加上麥茶凍增加豐富層次, 在炙熱夏日上市, 急速解熱。中杯冰飲總糖量: 76 公克。中杯冰飲總熱量: 328 大卡。咖啡因含量：136 毫克。大杯冰飲總糖量: 109 公克。大杯冰飲總熱量: 475 大卡。咖啡因含量: 194 毫克。茶產地: 台灣。', NULL, 110.00, 1, 68, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (72, N'六条麥茶', N'Signature Wheat Tea', N'無咖啡因日本六条麥茶, 焙香適口恰到好處, 清爽無負擔。中杯冰及熱飲總糖量: 32 公克。中杯冰及熱飲總熱量: 138 大卡。咖啡因含量: 0 毫克。大杯冰及熱飲總糖量: 54 公克。大杯冰及熱飲總熱量: 230 大卡。咖啡因含量: 0 毫克。原產地: 日本靜岡。', NULL, 60.00, 1, 69, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (73, N'六条麥桔茶', N'Signature Kumquat Wheat Tea', N'無咖啡因日本六条麥茶結合酸香金桔汁, 絕妙新品超乎想像好喝。中杯冰及熱飲總糖量: 47 公克。中杯冰及熱飲總熱量: 202 大卡。咖啡因含量: 0 毫克。大杯冰及熱飲總糖量: 65 公克。大杯冰及熱飲總熱量: 281 大卡。咖啡因含量: 0 毫克。原產地: 日本靜岡。', NULL, 85.00, 1, 70, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (74, N'六条麥茶鮮奶', N'Signature Fresh Milk Wheat Tea', N'無咖啡因日本六条麥茶搭配小農鮮乳, 濃醇奶味散發煎焙麥香 中杯冰及熱飲總糖量: 37 公克。中杯冰及熱飲總熱量: 204 大卡。咖啡因含量: 0 毫克。大杯冰及熱飲總糖量: 54 公克。大杯冰及熱飲總熱量: 298 大卡。咖啡因含量: 0 毫克。原產地: 日本靜岡。', NULL, 95.00, 1, 71, NULL, NULL, 1, 0);
INSERT INTO dmms.[Products] ([Id], [Name], [EnglishName], [Description], [ImageUrl], [BasePrice], [IsEnabled], [SortOrder], [SourceExternalId], [SourceUuid], [HasSizeGroup], [SweetnessAtProductLevel]) VALUES (75, N'六条麥茶冬露', N'Signature Wheat Tea with White Gourd Drink', N'限大杯。無咖啡因日本六条麥茶加入冬瓜茶, 香甜好喝是夏日最佳選擇。大杯冰及熱飲總糖量: 55 公克。大杯冰及熱飲總熱量: 235 大卡。咖啡因含量: 0 毫克。原產地: 日本靜岡。', NULL, 80.00, 1, 72, NULL, NULL, 0, 0);
SET IDENTITY_INSERT dmms.[Products] OFF;

-- SpecialOptions: 11 列
SET IDENTITY_INSERT dmms.[SpecialOptions] ON;
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (3, 2, 0, N'標準冰', N'Regular Ice', 0, NULL, NULL, 0, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (4, 2, 0, N'少冰', N'Less Ice', 0, N'(02)', NULL, 0, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (5, 2, 0, N'去冰', N'Ice-Free', 0, N'(03)', NULL, 0, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (6, 2, 0, N'溫', N'Warm', 0, N'(10)', NULL, 1, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (7, 2, 0, N'熱', N'Hot', 0, N'(11)', NULL, 1, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (8, 3, 1, N'標準甜', N'Regular Sugar', 1, NULL, NULL, NULL, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (9, 3, 1, N'7 分甜', N'70% Sugar', 1, NULL, N'(05)', NULL, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (10, 3, 1, N'5 分甜', N'Half Sugar', 1, NULL, N'(06)', NULL, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (11, 3, 1, N'3 分甜', N'30% Sugar', 1, NULL, N'(07)', NULL, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (12, 3, 1, N'無糖', N'Sugar-Free', 1, NULL, N'(08)', NULL, 1);
INSERT INTO dmms.[SpecialOptions] ([Id], [SpecialOptionGroupId], [Kind], [Name], [EnglishName], [ExternalDataMode], [Suffix], [StandaloneExternalData], [BeverageTemperature], [IsEnabled]) VALUES (13, 3, 1, N'減冬瓜', NULL, 1, NULL, N'(39)', NULL, 1);
SET IDENTITY_INSERT dmms.[SpecialOptions] OFF;

-- SpecialOptionGroups: 2 列
SET IDENTITY_INSERT dmms.[SpecialOptionGroups] ON;
INSERT INTO dmms.[SpecialOptionGroups] ([Id], [Name], [Min], [Max]) VALUES (2, N'飲料溫度 Beverage Temperature', 1, 1);
INSERT INTO dmms.[SpecialOptionGroups] ([Id], [Name], [Min], [Max]) VALUES (3, N'甜度 Sweetness Level', 1, 1);
SET IDENTITY_INSERT dmms.[SpecialOptionGroups] OFF;

-- MenuVersions: 1 列
SET IDENTITY_INSERT dmms.[MenuVersions] ON;
INSERT INTO dmms.[MenuVersions] ([Id], [Name], [Platform], [Status], [CreatedAt], [ExportedAt], [MenuDisplayName], [MenuExternalId], [OpenHours], [StoreUuid]) VALUES (1, N'UE 菜單 V1', N'UberEats', N'Exported', '2026-09-07 18:22:27.451762', '2026-09-09 07:24:20.428085', N'全日菜單 Menu', N'全日菜單_Menu', N'10:30--20:00', N'59d870fa-c045-5906-935c-9f8a6adc265e');
SET IDENTITY_INSERT dmms.[MenuVersions] OFF;

GO

-- 備份完成