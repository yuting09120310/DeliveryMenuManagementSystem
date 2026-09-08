using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddOnSizeDefinitions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_ProductAddOns_ProductSizes_ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ProductAddOns",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropIndex(
                name: "IX_ProductAddOns_ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "ExternalData",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "Id",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "Price",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "SizeOnlyId",
                schema: "dmms",
                table: "AddOns");

            migrationBuilder.AddColumn<int>(
                name: "SortOrder",
                schema: "dmms",
                table: "AddOns",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddPrimaryKey(
                name: "PK_ProductAddOns",
                schema: "dmms",
                table: "ProductAddOns",
                columns: new[] { "ProductId", "AddOnId" });

            migrationBuilder.CreateTable(
                name: "AddOnSizes",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AddOnId = table.Column<int>(type: "int", nullable: false),
                    SizeName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ExternalData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AddOnSizes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AddOnSizes_AddOns_AddOnId",
                        column: x => x.AddOnId,
                        principalSchema: "dmms",
                        principalTable: "AddOns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AddOnSizes_AddOnId",
                schema: "dmms",
                table: "AddOnSizes",
                column: "AddOnId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AddOnSizes",
                schema: "dmms");

            migrationBuilder.DropPrimaryKey(
                name: "PK_ProductAddOns",
                schema: "dmms",
                table: "ProductAddOns");

            migrationBuilder.DropColumn(
                name: "SortOrder",
                schema: "dmms",
                table: "AddOns");

            migrationBuilder.AddColumn<int>(
                name: "ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns",
                type: "int",
                nullable: false,
                defaultValue: 0);

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

            migrationBuilder.AddColumn<decimal>(
                name: "Price",
                schema: "dmms",
                table: "ProductAddOns",
                type: "decimal(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<int>(
                name: "SizeOnlyId",
                schema: "dmms",
                table: "AddOns",
                type: "int",
                nullable: true);

            migrationBuilder.AddPrimaryKey(
                name: "PK_ProductAddOns",
                schema: "dmms",
                table: "ProductAddOns",
                columns: new[] { "ProductId", "AddOnId", "ProductSizeId" });

            migrationBuilder.CreateIndex(
                name: "IX_ProductAddOns_ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns",
                column: "ProductSizeId");

            migrationBuilder.AddForeignKey(
                name: "FK_ProductAddOns_ProductSizes_ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns",
                column: "ProductSizeId",
                principalSchema: "dmms",
                principalTable: "ProductSizes",
                principalColumn: "Id");
        }
    }
}
