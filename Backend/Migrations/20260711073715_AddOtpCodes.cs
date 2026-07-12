using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Backend.Migrations
{
    /// <inheritdoc />
    public partial class AddOtpCodes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "OtpCodes",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Email = table.Column<string>(type: "nvarchar(450)", nullable: false),
                    Code = table.Column<string>(type: "nvarchar(6)", maxLength: 6, nullable: false),
                    Purpose = table.Column<string>(type: "nvarchar(20)", maxLength: 20, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OtpCodes", x => x.Id);
                });

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 2,
                column: "RequiredExp",
                value: 20);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 3,
                column: "RequiredExp",
                value: 60);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 4,
                column: "RequiredExp",
                value: 130);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 5,
                column: "RequiredExp",
                value: 250);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 6,
                column: "RequiredExp",
                value: 450);

            migrationBuilder.CreateIndex(
                name: "IX_OtpCodes_Email_Purpose_Code",
                table: "OtpCodes",
                columns: new[] { "Email", "Purpose", "Code" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "OtpCodes");

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 2,
                column: "RequiredExp",
                value: 100);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 3,
                column: "RequiredExp",
                value: 250);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 4,
                column: "RequiredExp",
                value: 500);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 5,
                column: "RequiredExp",
                value: 800);

            migrationBuilder.UpdateData(
                table: "LevelDefinitions",
                keyColumn: "Level",
                keyValue: 6,
                column: "RequiredExp",
                value: 1200);
        }
    }
}
