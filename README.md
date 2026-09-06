# DMMS — Delivery Menu Management System

Uber Eats 外送平台菜單管理系統。第一階段以目前實際使用中的 UE Excel 為匯入／匯出規格，後台集中管理商品、尺寸品號、冰熱、甜度與加料。

## 目前狀態

目前已完成：

- 實際 UE Excel 完整結構分析：`EXCEL-ANALYSIS.md`
- ASP.NET Core 8 MVC 專案骨架
- xUnit 測試專案
- EF Core SQL Server、ClosedXML 依賴
- SQL Server `DMMS` Database 建立並確認 ONLINE，使用獨立 `dmms` schema 避免覆蓋既有 dbo 舊表
- 第一個核心垂直切片：ExternalData 計算、商品驗證、EF Core Migration
- Dashboard、商品管理列表、商品建立／編輯表單與繁體中文 Sidebar
- 第一階段實作規格：`SPEC.md`
- 開發計畫：`IMPLEMENTATION-PLAN.md`

## 技術

- .NET 8 / ASP.NET Core MVC
- Entity Framework Core 8
- SQL Server
- ClosedXML
- xUnit

## 啟動

將連線字串放在未進版控的 `src/DMMS.Web/appsettings.Development.json` 或環境變數：

```bash
cd /home/alexvm/projects/DeliveryMenuManagementSystem
ASPNETCORE_URLS=http://0.0.0.0:5290 dotnet run --project src/DMMS.Web
```

## 測試與建置

```bash
dotnet test DMMS.slnx
dotnet build DMMS.slnx
```

## 設計原則

- Temperature：`BaseCode + Suffix`
- Sweetness：Standalone ExternalData，例如 `(05)`
- Add-On：`@` ExternalData，例如 `@IT1810(19)`
- 商品可只有中杯、只有大杯，或中杯＋大杯
- 依商品實際結構決定是否產生 Size Modifier Group
- 匯出保留 UE 原始欄位名稱、順序與 Nesting Level
- 不實作 Guest Checkout
