using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProjectOnProjects.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class project : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "BacDocuments",
                columns: table => new
                {
                    IdDocument = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NumeDocument = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    TipMaterie = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Continut = table.Column<byte[]>(type: "varbinary(max)", nullable: false),
                    DataAdaugare = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__BacDocum__BEAAD0BAD56E4F0E", x => x.IdDocument);
                });

            migrationBuilder.CreateTable(
                name: "Roluri",
                columns: table => new
                {
                    IdRol = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    NumeRol = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Roluri__2A49584C65FE7A4A", x => x.IdRol);
                });

            migrationBuilder.CreateTable(
                name: "Utilizatori",
                columns: table => new
                {
                    IdUtilizator = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Nume = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Prenume = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Username = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Mail = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Parola = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    NumarTelefon = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: true),
                    DataIncepere = table.Column<DateTime>(type: "datetime", nullable: true),
                    DataNastere = table.Column<DateTime>(type: "datetime", nullable: true),
                    IdRol = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: true, defaultValueSql: "((0))")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Utilizat__99101D6D31235E34", x => x.IdUtilizator);
                });

            migrationBuilder.CreateTable(
                name: "Proiecte",
                columns: table => new
                {
                    IdProject = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ProjectName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    StartDate = table.Column<DateTime>(type: "datetime", nullable: false),
                    Deadline = table.Column<DateTime>(type: "datetime", nullable: false),
                    ProjectDetails = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ProjectFile = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    FileFormat = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ContestCreator = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Organization = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    WebsiteLink = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    ContestRules = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    TimeStamp = table.Column<DateTime>(type: "datetime2", nullable: false),
                    IdUtilizatorNavigationIdUtilizator = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Proiecte__187B9AAFDE323DC0", x => x.IdProject);
                    table.ForeignKey(
                        name: "FK_Proiecte_Utilizatori_IdUtilizatorNavigationIdUtilizator",
                        column: x => x.IdUtilizatorNavigationIdUtilizator,
                        principalTable: "Utilizatori",
                        principalColumn: "IdUtilizator",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "SavedProjects",
                columns: table => new
                {
                    IdSavedProject = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IdUtilizator = table.Column<int>(type: "int", nullable: false),
                    IdProiect = table.Column<int>(type: "int", nullable: false),
                    DataSalvare = table.Column<DateTime>(type: "datetime", nullable: true, defaultValueSql: "(getdate())")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__SavedPro__E5878A3ADC55E572", x => x.IdSavedProject);
                    table.ForeignKey(
                        name: "FK__SavedProj__IdPro__46E78A0C",
                        column: x => x.IdProiect,
                        principalTable: "Proiecte",
                        principalColumn: "IdProject");
                    table.ForeignKey(
                        name: "FK__SavedProj__IdUti__45F365D3",
                        column: x => x.IdUtilizator,
                        principalTable: "Utilizatori",
                        principalColumn: "IdUtilizator");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Proiecte_IdUtilizatorNavigationIdUtilizator",
                table: "Proiecte",
                column: "IdUtilizatorNavigationIdUtilizator");

            migrationBuilder.CreateIndex(
                name: "IX_SavedProjects_IdProiect",
                table: "SavedProjects",
                column: "IdProiect");

            migrationBuilder.CreateIndex(
                name: "IX_SavedProjects_IdUtilizator",
                table: "SavedProjects",
                column: "IdUtilizator");

            migrationBuilder.CreateIndex(
                name: "UQ__Utilizat__536C85E4B4BA6916",
                table: "Utilizatori",
                column: "Username",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "BacDocuments");

            migrationBuilder.DropTable(
                name: "Roluri");

            migrationBuilder.DropTable(
                name: "SavedProjects");

            migrationBuilder.DropTable(
                name: "Proiecte");

            migrationBuilder.DropTable(
                name: "Utilizatori");
        }
    }
}
