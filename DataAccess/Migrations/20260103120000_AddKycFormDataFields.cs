using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MoneyShop.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class AddKycFormDataFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "Cnp",
                table: "KycSessions",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Address",
                table: "KycSessions",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "City",
                table: "KycSessions",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "County",
                table: "KycSessions",
                type: "nvarchar(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "PostalCode",
                table: "KycSessions",
                type: "nvarchar(10)",
                maxLength: 10,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Cnp",
                table: "KycSessions");

            migrationBuilder.DropColumn(
                name: "Address",
                table: "KycSessions");

            migrationBuilder.DropColumn(
                name: "City",
                table: "KycSessions");

            migrationBuilder.DropColumn(
                name: "County",
                table: "KycSessions");

            migrationBuilder.DropColumn(
                name: "PostalCode",
                table: "KycSessions");
        }
    }
}

