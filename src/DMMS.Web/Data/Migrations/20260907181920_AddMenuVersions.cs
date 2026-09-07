using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class AddMenuVersions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "MenuVersions",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Platform = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Status = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExportedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenuVersions", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "MenuVersionProducts",
                schema: "dmms",
                columns: table => new
                {
                    MenuVersionId = table.Column<int>(type: "int", nullable: false),
                    ProductId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MenuVersionProducts", x => new { x.MenuVersionId, x.ProductId });
                    table.ForeignKey(
                        name: "FK_MenuVersionProducts_MenuVersions_MenuVersionId",
                        column: x => x.MenuVersionId,
                        principalSchema: "dmms",
                        principalTable: "MenuVersions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MenuVersionProducts_Products_ProductId",
                        column: x => x.ProductId,
                        principalSchema: "dmms",
                        principalTable: "Products",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_MenuVersionProducts_ProductId",
                schema: "dmms",
                table: "MenuVersionProducts",
                column: "ProductId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "MenuVersionProducts",
                schema: "dmms");

            migrationBuilder.DropTable(
                name: "MenuVersions",
                schema: "dmms");
        }
    }
}
