using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartMoney.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class RefactorCashbackAndAddCashbackSettings : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Cashbacks_UserId",
                table: "Cashbacks");

            migrationBuilder.DropColumn(
                name: "CommissionAmount",
                table: "Cashbacks");

            migrationBuilder.DropColumn(
                name: "PurchaseDate",
                table: "Cashbacks");

            migrationBuilder.RenameColumn(
                name: "TransactionId",
                table: "Cashbacks",
                newName: "AffiliateConversionId");

            migrationBuilder.CreateTable(
                name: "CashbackSettings",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserSharePercent = table.Column<decimal>(type: "numeric(5,2)", precision: 5, scale: 2, nullable: false),
                    ConfirmationWindowDays = table.Column<int>(type: "integer", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CashbackSettings", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Cashbacks_AffiliateConversionId",
                table: "Cashbacks",
                column: "AffiliateConversionId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cashbacks_UserId_Status",
                table: "Cashbacks",
                columns: new[] { "UserId", "Status" });

            migrationBuilder.AddForeignKey(
                name: "FK_Cashbacks_AffiliateConversions_AffiliateConversionId",
                table: "Cashbacks",
                column: "AffiliateConversionId",
                principalTable: "AffiliateConversions",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Cashbacks_AffiliateConversions_AffiliateConversionId",
                table: "Cashbacks");

            migrationBuilder.DropTable(
                name: "CashbackSettings");

            migrationBuilder.DropIndex(
                name: "IX_Cashbacks_AffiliateConversionId",
                table: "Cashbacks");

            migrationBuilder.DropIndex(
                name: "IX_Cashbacks_UserId_Status",
                table: "Cashbacks");

            migrationBuilder.RenameColumn(
                name: "AffiliateConversionId",
                table: "Cashbacks",
                newName: "TransactionId");

            migrationBuilder.AddColumn<decimal>(
                name: "CommissionAmount",
                table: "Cashbacks",
                type: "numeric(18,2)",
                precision: 18,
                scale: 2,
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<DateTime>(
                name: "PurchaseDate",
                table: "Cashbacks",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateIndex(
                name: "IX_Cashbacks_UserId",
                table: "Cashbacks",
                column: "UserId");
        }
    }
}
