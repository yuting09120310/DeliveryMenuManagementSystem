using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class ProductOptionLinksRedesign : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ProductSpecialOptions_ProductSizes_ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ProductSpecialOptions",
                schema: "dmms",
                table: "ProductSpecialOptions");

            migrationBuilder.DropIndex(
                name: "IX_ProductSpecialOptions_ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions");

            migrationBuilder.DropColumn(
                name: "ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions");

            migrationBuilder.AddColumn<string>(
                name: "ExternalData",
                schema: "dmms",
                table: "ProductAddOns",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<int>(
                name: "Id",
                schema: "dmms",
                table: "ProductAddOns",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<bool>(
                name: "IsEnabled",
                schema: "dmms",
                table: "ProductAddOns",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<decimal>(
                name: "Price",
                schema: "dmms",
                table: "ProductAddOns",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddPrimaryKey(
                name: "PK_ProductSpecialOptions",
                schema: "dmms",
                table: "ProductSpecialOptions",
                columns: new[] { "ProductId", "SpecialOptionId" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropPrimaryKey(
                name: "PK_ProductSpecialOptions",
                schema: "dmms",
                table: "ProductSpecialOptions");

            migrationBuilder.DropColumn(
                name: "ExternalData",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "Id",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "IsEnabled",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "Price",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.AddColumn<int>(
                name: "ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK_ProductSpecialOptions",
                schema: "dmms",
                table: "ProductSpecialOptions",
                columns: new[] { "ProductId", "ProductSizeId", "SpecialOptionId" });

            migrationBuilder.CreateIndex(
                name: "IX_ProductSpecialOptions_ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions",
                column: "ProductSizeId");

            migrationBuilder.AddForeignKey(
                name: "FK_ProductSpecialOptions_ProductSizes_ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions",
                column: "ProductSizeId",
                principalSchema: "dmms",
                principalTable: "ProductSizes",
                principalColumn: "Id");
        }
    }
}
