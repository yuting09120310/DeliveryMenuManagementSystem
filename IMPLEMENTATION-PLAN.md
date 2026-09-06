# DMMS 第一階段實作計畫

> 依 `EXCEL-ANALYSIS.md` 實作 Uber Eats 管理後台，不改寫成另一套 Excel 邏輯。

## Phase 1：核心模型與規則

- EF Core 正規化模型與 SQL Server DbContext
- ExternalData 組合器
- Product Validation
- xUnit 純邏輯測試

## Phase 2：Admin 基礎框架

- Traditional Chinese Sidebar
- Dashboard 統計卡片
- Category、Product、SpecialOption、AddOn 管理頁
- 商品編輯表單與 ExternalData Preview

## Phase 3：關聯與批次操作

- 商品尺寸與冷／熱 BaseCode
- 商品特口勾選
- 商品加料關聯
- 批次套用加料、搜尋、分類全選

## Phase 4：UE Excel

- 匯入三個現有 Sheet
- 匯入人工確認清單
- Categories&Items&Modifiers 樹狀輸出
- Min／Max／Nesting／ExternalData Validation
- Export History 與匯出檔下載

## Phase 5：實際部署驗證

- 建立 SQL Server DMMS database
- Migration 與代表資料驗證
- 啟動 Web Admin
- 實際瀏覽器流程驗證
- HTTP、DB、Excel round-trip 測試
- README、SPEC、版本紀錄與 Git commit
