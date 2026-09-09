using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class SpecialOptionSizes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SpecialOptionSizes",
                schema: "dmms",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    SpecialOptionId = table.Column<int>(type: "int", nullable: false),
                    SizeName = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    ExternalData = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    Price = table.Column<decimal>(type: "decimal(18,2)", precision: 18, scale: 2, nullable: false),
                    IsEnabled = table.Column<bool>(type: "bit", nullable: false),
                    SortOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SpecialOptionSizes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SpecialOptionSizes_SpecialOptions_SpecialOptionId",
                        column: x => x.SpecialOptionId,
                        principalSchema: "dmms",
                        principalTable: "SpecialOptions",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_SpecialOptionSizes_SpecialOptionId",
                schema: "dmms",
                table: "SpecialOptionSizes",
                column: "SpecialOptionId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SpecialOptionSizes",
                schema: "dmms");
        }
    }
}
