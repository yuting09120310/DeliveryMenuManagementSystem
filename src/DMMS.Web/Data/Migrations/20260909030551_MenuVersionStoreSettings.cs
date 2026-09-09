using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DMMS.Web.Data.Migrations
{
    /// <inheritdoc />
    public partial class MenuVersionStoreSettings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "MenuDisplayName",
                schema: "dmms",
                table: "MenuVersions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "MenuExternalId",
                schema: "dmms",
                table: "MenuVersions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "OpenHours",
                schema: "dmms",
                table: "MenuVersions",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "StoreUuid",
                schema: "dmms",
                table: "MenuVersions",
                type: "nvarchar(max)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "MenuDisplayName",
                schema: "dmms",
                table: "MenuVersions");

            migrationBuilder.DropColumn(
                name: "MenuExternalId",
                schema: "dmms",
                table: "MenuVersions");

            migrationBuilder.DropColumn(
                name: "OpenHours",
                schema: "dmms",
                table: "MenuVersions");

            migrationBuilder.DropColumn(
                name: "StoreUuid",
                schema: "dmms",
                table: "MenuVersions");
        }
    }
}
