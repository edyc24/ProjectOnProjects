using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ProjectOnProjects.DataAccess.Migrations
{
    /// <inheritdoc />
    public partial class test : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Favorites",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ProjectId = table.Column<int>(type: "int", nullable: false),
                    ListName = table.Column<string>(type: "nvarchar(max)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Favorites", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Favorites_Proiecte_ProjectId",
                        column: x => x.ProjectId,
                        principalTable: "Proiecte",
                        principalColumn: "IdProject");
                    table.ForeignKey(
                        name: "FK_Favorites_Utilizatori_UserId",
                        column: x => x.UserId,
                        principalTable: "Utilizatori",
                        principalColumn: "IdUtilizator");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Favorites_ProjectId",
                table: "Favorites",
                column: "ProjectId");

            migrationBuilder.CreateIndex(
                name: "IX_Favorites_UserId",
                table: "Favorites",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Favorites");
        }
    }
}
