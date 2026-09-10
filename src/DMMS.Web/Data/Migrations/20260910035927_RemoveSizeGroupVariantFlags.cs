using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class RemoveSizeGroupVariantFlags : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "HasSizeGroup",
                schema: "dmms",
                table: "Products");

            migrationBuilder.DropColumn(
                name: "SweetnessAtProductLevel",
                schema: "dmms",
                table: "Products");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "HasSizeGroup",
                schema: "dmms",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "SweetnessAtProductLevel",
                schema: "dmms",
                table: "Products",
                type: "bit",
                nullable: false,
                defaultValue: false);
        }
    }
}
