using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.EnsureSchema(
                name: "dmms");

            migrationBuilder.CreateTable(
                name: "AddOns",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EnglishName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    ExternalData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    IcedOnly = table.Column<bool>(type: "bit", nullable: false),
                    SizeOnlyId = table.Column<int>(type: "int", nullable: true),
                    FixedRatio = table.Column<bool>(type: "bit", nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AddOns", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Categories",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Categories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ExportHistories",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    Platform = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ExportHistories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "PlatformProductMappings",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Platform = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    OriginalExternalId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Uuid = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    OriginalName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SourceMetadata = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PlatformProductMappings", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Products",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EnglishName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BasePrice = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false),
                    SourceExternalId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    SourceUuid = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Products", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SpecialOptionGroups",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Min = table.Column<int>(type: "int", nullable: false),
                    Max = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SpecialOptionGroups", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "ProductCategories",
                schema: "dmms",
                columns: table => new
                {
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    CategoryId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductCategories", x => new { x.ProductId, x.CategoryId });
                    table.ForeignKey(
                        name: "FK_ProductCategories_Categories_CategoryId",
                        column: x => x.CategoryId,
                        principalSchema: "dmms",
                        principalTable: "Categories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ProductCategories_Products_ProductId",
                        column: x => x.ProductId,
                        principalSchema: "dmms",
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "ProductSizes",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    PriceAdjustment = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    ColdBaseCode = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    HotBaseCode = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductSizes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_ProductSizes_Products_ProductId",
                        column: x => x.ProductId,
                        principalSchema: "dmms",
                        principalTable: "Products",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SpecialOptions",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SpecialOptionGroupId = table.Column<int>(type: "int", nullable: true),
                    Kind = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    EnglishName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ExternalDataMode = table.Column<int>(type: "int", nullable: false),
                    Suffix = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    StandaloneExternalData = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BeverageTemperature = table.Column<int>(type: "int", nullable: true),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SpecialOptions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SpecialOptions_SpecialOptionGroups_SpecialOptionGroupId",
                        column: x => x.SpecialOptionGroupId,
                        principalSchema: "dmms",
                        principalTable: "SpecialOptionGroups",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ProductAddOns",
                schema: "dmms",
                columns: table => new
                {
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    AddOnId = table.Column<int>(type: "int", nullable: false),
                    ProductSizeId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductAddOns", x => new { x.ProductId, x.AddOnId, x.ProductSizeId });
                    table.ForeignKey(
                        name: "FK_ProductAddOns_AddOns_AddOnId",
                        column: x => x.AddOnId,
                        principalSchema: "dmms",
                        principalTable: "AddOns",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_ProductAddOns_ProductSizes_ProductSizeId",
                        column: x => x.ProductSizeId,
                        principalSchema: "dmms",
                        principalTable: "ProductSizes",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ProductAddOns_Products_ProductId",
                        column: x => x.ProductId,
                        principalSchema: "dmms",
                        principalTable: "Products",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ProductSpecialOptions",
                schema: "dmms",
                columns: table => new
                {
                    ProductId = table.Column<int>(type: "int", nullable: false),
                    ProductSizeId = table.Column<int>(type: "int", nullable: false),
                    SpecialOptionId = table.Column<int>(type: "int", nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ProductSpecialOptions", x => new { x.ProductId, x.ProductSizeId, x.SpecialOptionId });
                    table.ForeignKey(
                        name: "FK_ProductSpecialOptions_ProductSizes_ProductSizeId",
                        column: x => x.ProductSizeId,
                        principalSchema: "dmms",
                        principalTable: "ProductSizes",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ProductSpecialOptions_Products_ProductId",
                        column: x => x.ProductId,
                        principalSchema: "dmms",
                        principalTable: "Products",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ProductSpecialOptions_SpecialOptions_SpecialOptionId",
                        column: x => x.SpecialOptionId,
                        principalSchema: "dmms",
                        principalTable: "SpecialOptions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_ProductAddOns_AddOnId",
                schema: "dmms",
                table: "ProductAddOns",
                column: "AddOnId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductAddOns_ProductSizeId",
                schema: "dmms",
                table: "ProductAddOns",
                column: "ProductSizeId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductCategories_CategoryId",
                schema: "dmms",
                table: "ProductCategories",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductSizes_ProductId",
                schema: "dmms",
                table: "ProductSizes",
                column: "ProductId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductSpecialOptions_ProductSizeId",
                schema: "dmms",
                table: "ProductSpecialOptions",
                column: "ProductSizeId");

            migrationBuilder.CreateIndex(
                name: "IX_ProductSpecialOptions_SpecialOptionId",
                schema: "dmms",
                table: "ProductSpecialOptions",
                column: "SpecialOptionId");

            migrationBuilder.CreateIndex(
                name: "IX_SpecialOptions_SpecialOptionGroupId",
                schema: "dmms",
                table: "SpecialOptions",
                column: "SpecialOptionGroupId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "ExportHistories",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "PlatformProductMappings",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "ProductAddOns",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "ProductCategories",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "ProductSpecialOptions",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "AddOns",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "Categories",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "ProductSizes",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "SpecialOptions",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "Products",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "SpecialOptionGroups",
                schema: "dmms");
        }
    }
}
