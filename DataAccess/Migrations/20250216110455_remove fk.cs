using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProjectOnProjects.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class removefk : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Proiecte_Utilizatori_IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte");

            migrationBuilder.DropIndex(
                name: "UQ__Utilizat__536C85E4B4BA6916",
                table: "Utilizatori");

            migrationBuilder.DropIndex(
                name: "IX_Proiecte_IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte");

            migrationBuilder.DropColumn(
                name: "IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte");

            migrationBuilder.AlterColumn<string>(
                name: "Username",
                table: "Utilizatori",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255);

            migrationBuilder.AddColumn<int>(
                name: "UtilizatoriIdUtilizator",
                table: "Proiecte",
                type: "int",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "UQ__Utilizat__536C85E4B4BA6916",
                table: "Utilizatori",
                column: "Username",
                unique: true,
                filter: "[Username] IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "IX_Proiecte_UtilizatoriIdUtilizator",
                table: "Proiecte",
                column: "UtilizatoriIdUtilizator");

            migrationBuilder.AddForeignKey(
                name: "FK_Proiecte_Utilizatori_UtilizatoriIdUtilizator",
                table: "Proiecte",
                column: "UtilizatoriIdUtilizator",
                principalTable: "Utilizatori",
                principalColumn: "IdUtilizator");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Proiecte_Utilizatori_UtilizatoriIdUtilizator",
                table: "Proiecte");

            migrationBuilder.DropIndex(
                name: "UQ__Utilizat__536C85E4B4BA6916",
                table: "Utilizatori");

            migrationBuilder.DropIndex(
                name: "IX_Proiecte_UtilizatoriIdUtilizator",
                table: "Proiecte");

            migrationBuilder.DropColumn(
                name: "UtilizatoriIdUtilizator",
                table: "Proiecte");

            migrationBuilder.AlterColumn<string>(
                name: "Username",
                table: "Utilizatori",
                type: "nvarchar(255)",
                maxLength: 255,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(255)",
                oldMaxLength: 255,
                oldNullable: true);

            migrationBuilder.AddColumn<int>(
                name: "IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "UQ__Utilizat__536C85E4B4BA6916",
                table: "Utilizatori",
                column: "Username",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Proiecte_IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte",
                column: "IdUtilizatorNavigationIdUtilizator");

            migrationBuilder.AddForeignKey(
                name: "FK_Proiecte_Utilizatori_IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte",
                column: "IdUtilizatorNavigationIdUtilizator",
                principalTable: "Utilizatori",
                principalColumn: "IdUtilizator",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
