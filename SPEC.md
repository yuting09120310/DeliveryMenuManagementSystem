# DMMS — Delivery Menu Management System

## v0.1 開發規格

### 目標
建立以 Uber Eats 為第一階段平台的 Web Admin 菜單管理系統。使用者只維護商品基礎資料、尺寸品號、共用特口與加料關聯，由系統依現有 UE Excel 結構計算 ExternalData 並匯出。

### 技術
- ASP.NET Core 8 MVC / Razor
- SQL Server（正式資料庫：`neko-meow.com:1433` / `DMMS`）
- Entity Framework Core
- ClosedXML（UE Excel 匯入／匯出）
- xUnit

### 第一個垂直切片
- Product、Category、ProductSize、SpecialOptionGroup、SpecialOption、AddOn 核心模型
- Temperature：BaseCode + Suffix
- Sweetness：Standalone ExternalData
- Add-On：`@` ExternalData
- 商品 Validation 與 ExternalData Preview
- Dashboard 基礎統計
- 後台 Sidebar 與商品管理畫面

### 非目標
- 消費者前台
- Guest Checkout
- Foodpanda 實作
- Uber Eats API 直接同步

### 驗收重點
1. 商品可只有中杯、只有大杯，或中杯＋大杯。
2. 商品可只有冰飲、冰＋熱，且熱品號可留空但啟用熱選項時必須報錯。
3. 甜度選項輸出 `(05)` 等獨立代碼，不串商品品號。
4. 冰度／溫度輸出基礎品號加後綴。
5. Add-On 使用 `@IT...`，並可限制僅冰飲或尺寸。
6. 商品編輯頁能顯示組合後 ExternalData 預覽。
7. SQL Server 帳密只由環境設定提供，不進版控。

## Version History

### v0.1（開發中）
- 完成 UE Excel 實際格式分析，詳見 `EXCEL-ANALYSIS.md`。
- 建立 ASP.NET Core MVC、xUnit 與 EF Core 專案骨架。
