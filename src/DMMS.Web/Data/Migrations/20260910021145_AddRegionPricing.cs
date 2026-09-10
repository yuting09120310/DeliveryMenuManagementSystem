using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddRegionPricing : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "RegionId",
                schema: "dmms",
                table: "MenuVersions",
                type: "int",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Regions",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Regions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ProductRegionPrices",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    RegionId = table.Column<int>(type: "int", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: true),
                    PriceModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductRegionPrices", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ProductRegionPrices_Products_ProductId",
                        column: x => x.ProductId,
                        principalSchema: "dmms",
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ProductRegionPrices_Regions_RegionId",
                        column: x => x.RegionId,
                        principalSchema: "dmms",
                        principalTable: "Regions",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_MenuVersions_RegionId",
                schema: "dmms",
                table: "MenuVersions",
                column: "RegionId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductRegionPrices_ProductId_RegionId",
                schema: "dmms",
                table: "ProductRegionPrices",
                columns: new[] { "ProductId", "RegionId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ProductRegionPrices_RegionId",
                schema: "dmms",
                table: "ProductRegionPrices",
                column: "RegionId");

            migrationBuilder.AddForeignKey(
                name: "FK_MenuVersions_Regions_RegionId",
                schema: "dmms",
                table: "MenuVersions",
                column: "RegionId",
                principalSchema: "dmms",
                principalTable: "Regions",
                principalColumn: "Id");

            // ---- 資料播種：建立北區/南區；既有商品兩區地區價預填 BasePrice；既有菜單版本綁北區 ----
            migrationBuilder.Sql("""
                INSERT INTO dmms.Regions (Name, SortOrder, IsEnabled) VALUES (N'北區', 0, 1);
                INSERT INTO dmms.Regions (Name, SortOrder, IsEnabled) VALUES (N'南區', 1, 1);
                INSERT INTO dmms.ProductRegionPrices (ProductId, RegionId, Price, PriceModifiedAt)
                SELECT p.Id, r.Id, p.BasePrice, NULL FROM dmms.Products p CROSS JOIN dmms.Regions r;
                UPDATE dmms.MenuVersions SET RegionId = (SELECT MIN(Id) FROM dmms.Regions WHERE Name = N'北區')
                WHERE RegionId IS NULL;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_MenuVersions_Regions_RegionId",
                schema: "dmms",
                table: "MenuVersions");

            migrationBuilder.DropTable(
                name: "ProductRegionPrices",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "Regions",
                schema: "dmms");

            migrationBuilder.DropIndex(
                name: "IX_MenuVersions_RegionId",
                schema: "dmms",
                table: "MenuVersions");

            migrationBuilder.DropColumn(
                name: "RegionId",
                schema: "dmms",
                table: "MenuVersions");
        }
    }
}
