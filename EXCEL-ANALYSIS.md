# Uber Eats Excel 實際格式分析

來源檔案：`天仁釀茶所 新莊店校稿20260723-5.xlsx`

分析目的：以目前實際交付 Uber Eats 的檔案為唯一格式依據，先確認 DMMS 的資料邏輯，不直接把 Excel 88 欄照抄成單一資料表。

## 1. 工作表總覽

| Sheet | Excel 宣告尺寸 | 實際用途 |
|---|---:|---|
| `GlobalSettings` | 1000 × 2 | 店舖 UUID、全域設定 |
| `Menus` | 1000 × 10 | 菜單名稱、每週供應時段 |
| `Categories&Items&Modifiers` | 2178 × 88 | 分類、商品、Modifier Group、Modifier Option 與 UE 匯出欄位 |

Excel 顯示的 1000 列是工作表格式範圍；不可直接當成實際資料筆數。`Categories&Items&Modifiers` 有 88 個欄位，實際有內容的主要資料列為 2031 列，另有空白／格式列。

## 2. GlobalSettings

目前內容：

| Key | Value |
|---|---|
| `StoreUUID` | `59d870fa-c045-5906-935c-9f8a6adc265e` |
| `DisableItemInstructions` | `TRUE` |
| `Tax(%)` | 空白 |
| `VatRate` | 空白 |

DMMS 應保留這些設定，但敏感或店舖可變資訊不應硬編碼在程式碼。

## 3. Menus

欄位順序為：

```text
ExternalID, Menu, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, ExternalNotes
```

目前有一個全日菜單：

- ExternalID：`全日菜單_Menu`
- Menu：`全日菜單 Menu`
- 每日：`10:30--20:00`
- ExternalNotes：空白

DMMS 的菜單匯出應維持此欄位名稱與順序。

## 4. Categories&Items&Modifiers 欄位

此 Sheet 共 88 欄，原始順序必須維持。前 52 欄為最常用的業務／UE 結構欄位，後 36 欄為 UE 商品特性欄位。

```text
ExternalID
Menu
Category
Item
Modifier Group
Modifier Option
Nesting Level
Delivery Price
Other Price
Offered Delivery (blank / null = TRUE)
Offered Other
Tax(%)
VatRate
Description
Min
Max
DefaultQuantity
Calories
Joules
HasSide
IsEntree
AlcoholicItemCount
HasAlcoholicItems
IsVegetarian
IsVegan
IsGlutenFree
ExternalData
ImageURL
ExternalNotes
Notes
GroupExternalID
EndorsementIcon
EndorsementText
SuspensionInterval
SuspendUntil
StartDate
EndDate
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
Sunday
UUID
External Product ID
External Product ID Type
Target Market
PricedByMeasurementType
PricedByUnitType
SoldByMeasurementType
SoldByUnitType
MinPermitted
MaxPermitted
Increment
DefaultQuantityV2
ConversionRate
additives
alcohol_by_volume
allergens
carbohydrates
caffeine_amount
coffee_bean_origin
container_deposit
country_of_origin
countries_of_origin
fat
food_business_operator.name
food_business_operator.address
ingredients
instructions_for_use
is_high_fat_salt_sugar
medical_prescription_required
net_quantity
number_of_servings
number_of_servings_interval
per_serving_calories
per_serving_kilojoules
pre_packaged
protein
reusable_packaging
salt
saturated_fatty_acids
storage_instructions
sugar
serving_size
uber_product_traits
uber_product_type
```

### 欄位使用統計

| 欄位 | 非空筆數 | 觀察 |
|---|---:|---|
| `ExternalID` | 2031 | 既是商品／群組／選項在 UE 的外部識別值，不能只當 DMMS 內部 ID |
| `Category` | 11 個分類值 | 分類列有值；後續商品列可能依 Excel 區段繼承分類，匯入需保留來源列上下文 |
| `Item` | 84 | 主要商品列；名稱去重後 80 個，代表有重複商品／不同區段或來源差異，不能盲目以名稱唯一 |
| `Modifier Group` | 459 | 商品下的 Modifier 群組／階層節點 |
| `Modifier Option` | 1622 | Modifier 選項列 |
| `Nesting Level` | 459 | 只有 `1`、`2`，但同一業務群組名稱在不同商品可落在不同層級 |
| `Delivery Price` | 1706 | 商品、尺寸、加料等都有價格用途；不可只放在 Product |
| `Other Price` | 0 | 本檔沒有使用 |
| `Min` | 382 | 非空值全部為 `1` |
| `Max` | 2014 | 主要為 `1`，另有 `2`（31 筆）、`3`（5 筆） |
| `DefaultQuantity` | 0 | 本檔未使用 |
| `Description` | 80 | 產品描述主要在 Item 列；有 6 筆內容為「甜度固定。」 |
| `ExternalData` | 1390 | 冰／熱品號、甜度代碼、加料代碼等核心欄位 |
| `ImageURL` | 6 | 5 個不同 URL；主要在商品列 |
| `UUID` | 2031 | UE 匯出識別資料，匯出時必須產生／保留穩定 UUID |
| `GroupExternalID` | 0 | 本檔未使用 |
| `Offered Delivery...` | 0 | 空白代表 TRUE，不能匯出成 FALSE |
| `Tax(%)`, `VatRate` | 0 | 本檔空白 |
| `SuspensionInterval` | 7 | 使用 `INDEFINITE` |
| `uber_product_traits` | 65 | 使用 `[]` |

## 5. 實際資料分層

以欄位是否有值判斷，主要列型如下：

- Category：11 列
- Product／Item：84 列
- Modifier Group：459 列
- Modifier Option：1622 列
- 另有 1 列需人工確認的異常／不完整資料

不能只用 `ExternalID` 前綴猜測層級。正確匯入方式必須依列順序、欄位值與目前商品區段建立父子上下文：

```text
Category
└─ Item
   ├─ Modifier Group (Nesting Level 1)
   │  └─ Modifier Option (Nesting Level 0 / option row)
   └─ Modifier Group (Nesting Level 2)
      └─ Modifier Option
```

部分來源列的 `Category`、`Item`、`Modifier Group` 會留白，這是 UE 匯入最需要保留 row context 的地方，不能把空白直接當成「沒有父項目」。

## 6. 商品與分類

解析到的商品分類如下：

| 分類 | 商品數 |
|---|---:|
| 醇蜜系列 Honey Beverage | 16 |
| 香醇奶茶 Milk Tea | 14 |
| 純鮮奶茶 Fresh Milk Tea | 14 |
| 新鮮果茶 Fruit Tea | 11 |
| 經典原茶 Classic Tea | 10 |
| 人氣精選 Popular Items | 8 |
| 無咖啡因 Tea without Caffeine | 4 |
| 茶食小點 Snacks | 3 |
| 輕食小點 Light Snacks | 2 |
| 加購塑料袋 Plastic Bag | 1 |
| 加購塑膠吸管 Plastic Straw | 1 |

商品價格不是固定單一值，解析到 19 種實際 `Delivery Price` 值，包括 `45`、`50`、`60`、`65`、`70`、`75`、`80`、`85`、`90`、`95`、`100`、`105`、`110`、`115`、`15`、`20`、`1`、`260` 等。尺寸加價與獨立加料價格應分開建模。

## 7. Size／Temperature 的實際 Nesting

### 7.1 有尺寸的商品

常見實際結構：

```text
Item
└─ 份量 Size / 選項份量 Choose Size (Nesting Level 1)
   ├─ 中杯 Medium (Delivery Price 0 或尺寸價格)
   │  ├─ 飲料溫度 Beverage Temperature (Nesting Level 2)
   │  │  ├─ 標準冰 Regular/Standard Ice
   │  │  ├─ 少冰 Less Ice
   │  │  ├─ 去冰 Ice-Free
   │  │  ├─ 溫 Warm
   │  │  └─ 熱 Hot
   │  └─ 甜度 Sweetness Level (Nesting Level 1 或 2，依來源)
   └─ 大杯 Large (Delivery Price 常為 10 或 20)
      └─ 同類溫度／甜度群組
```

例如 `913 茶王 913 Tea` 實際有中杯與大杯，每個尺寸下各有飲料溫度與甜度，另有加點群組。

### 7.2 只有一種尺寸或沒有 Size 群組的商品

來源確實存在不建立尺寸選擇、直接把溫度作為第一層的商品：

```text
Item
└─ 飲料溫度 Beverage Temperature (Nesting Level 1)
   ├─ 標準冰 Standard Ice
   ├─ 少冰 Less Ice
   └─ 去冰 Ice-Free
```

例如 `多多綠茶 Probiotic Green Tea`、`多多洛神冰茶 Probiotic Roselle Green Tea` 便是這種形式。

因此 DMMS 必須允許：

1. 只有中杯
2. 只有大杯
3. 中杯＋大杯
4. 沒有 Size 選擇，直接以 Temperature 作第一層

不能強迫所有商品都有中杯／大杯，也不能在匯出時一律新增 Size 群組。

### 7.3 同一業務意義的名稱存在多種來源名稱

來源使用過以下同義但不同名稱：

- `份量 Size`
- `選項份量 Choose Size`
- `選擇份量 Choose Size`
- `份量選項 Size Option`
- `飲料溫度 Beverage Temperature`
- `飲品溫度 Beverage Temperature`
- `飲品溫度`
- `冰量選擇 Choose Ice Level`
- `甜度 Sweetness Level`
- `選項甜度 Sweetness Level`
- `飲品甜度 Beverage Sweetness Level`
- `加點 Add-Ons`
- `飲品加料 Add-Ons`
- `加料 Add-Ons`
- `加購 Add On`
- `選擇加料 Add-Ons`

DMMS 可以在內部以標準化類型管理，但匯出／匯入必須保留原始 UE 顯示名稱或讓管理者選擇匯出模板，不可假設來源永遠只有一個固定拼法。

## 8. ExternalData 實際規則

統計到的非空 `ExternalData` 型態：

| 型態 | 筆數 | 實例 | 業務意義 |
|---|---:|---|---|
| BaseCode + suffix | 476 | `IT0005-U(02)`, `IT6005-U(10)` | 冰度／溫度使用商品或尺寸基礎品號加後綴 |
| Standalone ExternalData | 393 | `(05)`, `(06)`, `(07)`, `(08)` | 甜度直接輸出代碼，不串接飲品品號 |
| Add-on `@` code | 367 | `@IT1810(19)`, `@IT1815(27)` | 加料獨立品號，使用 `@` 開頭 |
| 其他／無後綴 | 154 | `IT0005-U` | 標準冰等沒有後綴的基礎品號 |

### 8.1 冰度／溫度

實際規則符合：

```text
冷飲選項 = ColdBaseCode + Suffix
熱飲選項 = HotBaseCode + Suffix
```

典型後綴：

| 選項 | 飲品類型 | 後綴 |
|---|---|---|
| 標準冰 Regular/Standard Ice | Cold | 空白 |
| 少冰 Less Ice | Cold | `(02)` |
| 去冰 Ice-Free | Cold | `(03)` |
| 溫 Warm | Hot | `(10)` |
| 熱 Hot | Hot | `(11)` |

因此以 `IT0005-U` 與 `IT6005-U` 為例：

```text
標準冰 → IT0005-U
少冰   → IT0005-U(02)
去冰   → IT0005-U(03)
溫     → IT6005-U(10)
熱     → IT6005-U(11)
```

來源顯示的基礎品號因商品／尺寸而不同，不能用一個全域 IT code 取代 ProductSize 的冷／熱品號。

### 8.2 甜度

實際規則為獨立 ExternalData：

```text
標準甜 → 空白
7 分甜 → (05)
5 分甜 → (06)
3 分甜 → (07)
無糖   → (08)
```

必須支援 `Standalone ExternalData`，不可錯誤產出 `IT0005-U(05)`。

### 8.3 加料

實際使用 `@` 開頭的獨立代碼，例如：

| 加料 | Delivery Price | ExternalData |
|---|---:|---|
| 珍珠 Tapioca | 10 | `@IT1810(19)` |
| 仙草 Grass Jelly／Mesona | 15 | `@IT1815(27)` |
| 六條／麥茶凍（限冰飲） | 15 | `@IT1839(45)` |
| 茉香／茉莉茶凍（限冰飲） | 15 | `@IT1845(302)` |
| 醇香蜂蜜（固定比例，尺寸限制） | 10 或 15 | `@IT1812(20)`／`@IT1836(40)` |

其中醇香蜂蜜不是一般可任意調整的加料，而是來源明確標示「比例固定」並限制中杯或大杯，DMMS 應支援尺寸／溫度適用限制及固定比例備註。

## 9. Min／Max／Delivery Price

來源常見規則：

- Temperature group：`Min=1`, `Max=1`
- Sweetness group：通常 `Min=1`, `Max=1`
- Size group：`Min=1`, `Max=1`
- 一般 Add-On group：依來源為 `Max=1`、`Max=2` 或 `Max=3`
- Add-On option：常見 `Delivery Price=10` 或 `15`
- Size option：常見 `Delivery Price=0`、`10` 或 `20`
- 商品 Item：`Delivery Price` 是商品基礎配送價

DMMS 預覽與匯出時必須逐層輸出 Min／Max，不可只在主檔保存一個全域值。

## 10. Description／ImageURL

### Description

- 商品列有 80 筆非空描述，去重後 71 種。
- 描述包含營養資訊、原產地、茶葉說明等實際營運文字。
- 部分商品 Description 是 `甜度固定。`，這是重要的業務語意，不可在匯入時丟棄。
- Modifier option 通常沒有 Description。

DMMS 商品基本資料應保存完整 Description；甜度模式可由匯入時的 `甜度固定。` 輔助標記，但不能只依文字猜測，需提供「需要人工確認」。

### ImageURL

目前僅 6 筆非空、5 個不同的 Uber CDN URL，主要位於商品列。DMMS 應保存原始 URL，不應把圖片下載後才視為唯一來源；若 URL 失效，匯出前需顯示提醒。

## 11. 匯入 DMMS 的安全策略

### 可以可靠解析

- Category、Item、Modifier Group、Modifier Option 的列順序與父子區段
- Size 是否存在及中杯／大杯選項
- Temperature／Ice 選項
- Sweetness option 與獨立代碼
- Add-On 價格與 `@` ExternalData
- Nesting Level、Min、Max、Delivery Price
- Description、ImageURL、UUID、原始 ExternalID

### 不應自動猜測

- 空白 Category／Item 是否表示沿用上一個父項目（雖然多數區段可由列順序推定，仍應保存來源列號）
- 同名但不同英文／ExternalID 的選項是否為同一業務資料
- `甜度固定。` 是否代表 Fixed，或只是備註
- `只有冰飲` 限制是由選項名稱、溫度群組還是店內規則造成
- 來源中的少數異常／不完整列

匯入記錄應包含：`SourceFile`、`SourceSheet`、`SourceRowNumber`、原始 `ExternalID`、原始 `UUID`、解析狀態與 `NeedsManualReview`。

## 12. 建議的正規化核心資料模型

不要建立 88 欄巨大主表。建議至少：

```text
Category
Product
ProductCategory
ProductSize
ProductTemperatureOption
SpecialOptionGroup
SpecialOption
ProductSpecialOption
AddOn
ProductAddOn
Platform
PlatformProductMapping
PlatformExportProfile
ExportHistory
ExportRowSnapshot
ImportBatch
ImportReviewItem
```

### 關鍵欄位設計

- `Product`：中文名、英文名、描述、ImageURL、基礎商品價格、啟用、排序、來源 ExternalID／UUID
- `ProductSize`：Size 名稱、是否啟用、加價、ColdBaseCode、HotBaseCode、排序
- `SpecialOption`：類型（Temperature／Sweetness／其他）、中文、英文、輸出模式、Suffix 或 StandaloneExternalData、飲品類型、啟用、排序
- `ProductSpecialOption`：Product／Size 適用關聯、是否可用、適用限制
- `AddOn`：中文、英文、價格、ExternalData、限制（IcedOnly／SizeOnly／固定比例）、啟用、排序
- `ProductAddOn`：商品與加料關聯，可再加尺寸／飲品類型限制
- `PlatformProductMapping`：平台、原始 ExternalID、UUID、原始名稱、來源 Metadata
- `ExportRowSnapshot`：每次實際輸出的完整 88 欄值，方便稽核與回溯，不讓核心模型被 Excel 欄位污染

## 13. DMMS 第一階段必要驗證

1. 啟用 Warm／Hot 時，對應 ProductSize 必須有 HotBaseCode。
2. 啟用 Regular／Less／Ice-Free 時，對應 ProductSize 必須有 ColdBaseCode。
3. 只有一個尺寸時不得自動新增 Size group。
4. 有兩個尺寸時，每個尺寸的溫度與甜度群組要掛在正確父節點下。
5. Sweetness 只能輸出 `(05)` 等 standalone code，不得與飲品品號串接。
6. Add-On 必須以 `@` ExternalData 輸出，且受 IcedOnly／尺寸限制控制。
7. 所有輸出 Modifier row 不得產生空白或無法解讀的 ExternalData。
8. Min／Max／Delivery Price 必須逐列驗證。
9. 匯出前重新執行完整 validation，產生可下載前的錯誤清單。
10. 匯出檔必須保留 `GlobalSettings`、`Menus`、`Categories&Items&Modifiers` 的欄位名稱與欄位順序。

## 14. 目前需要人工確認的資料

本次分析確認來源存在少量不完整／異常資料列，且相同業務類型出現多套歷史名稱（例如 Regular／Standard、飲品／飲料、加點／加購／加料）。DMMS 匯入畫面應將這些列列入「需要人工確認」，而不是靜默合併。

人工確認完成前：

- 保留原始值
- 不覆寫原始 ExternalID／UUID
- 不自動刪除重複名稱
- 匯出時顯示阻擋或警告清單

---

## 結論

這份 Excel 明確證實 DMMS 的核心不是一般商品 CRUD，而是「商品／尺寸品號」搭配「共用特口規則」再依商品建立關聯，最後按 UE 的實際父子階層展開匯出。

最重要的三個實作決策：

1. `ProductSize` 必須保存 ColdBaseCode 與 HotBaseCode，因為同一商品不同 Size 會有不同 IT 品號。
2. Temperature 與 Sweetness 的 ExternalData 輸出模式必須分開：前者 BaseCode + Suffix，後者 Standalone ExternalData。
3. 匯出引擎必須根據商品實際是否有 Size 以及來源 Nesting Level 組裝樹狀結構，不能把所有 Modifier 平鋪，也不能強迫所有商品產生中杯／大杯。
