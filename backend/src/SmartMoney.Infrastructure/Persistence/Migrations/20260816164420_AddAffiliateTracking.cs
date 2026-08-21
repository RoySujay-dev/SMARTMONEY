using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartMoney.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddAffiliateTracking : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AffiliateClicks",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    UserId = table.Column<Guid>(type: "uuid", nullable: false),
                    StoreId = table.Column<Guid>(type: "uuid", nullable: false),
                    OfferId = table.Column<Guid>(type: "uuid", nullable: true),
                    AffiliateNetworkId = table.Column<Guid>(type: "uuid", nullable: false),
                    TrackingReference = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    RedirectToken = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    DestinationUrl = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    TrackedUrl = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    RedirectedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AffiliateClicks", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AffiliateClicks_AffiliateNetworks_AffiliateNetworkId",
                        column: x => x.AffiliateNetworkId,
                        principalTable: "AffiliateNetworks",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AffiliateClicks_Offers_OfferId",
                        column: x => x.OfferId,
                        principalTable: "Offers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AffiliateClicks_Stores_StoreId",
                        column: x => x.StoreId,
                        principalTable: "Stores",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AffiliateClicks_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AffiliateConversions",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    AffiliateNetworkId = table.Column<Guid>(type: "uuid", nullable: false),
                    AffiliateClickId = table.Column<Guid>(type: "uuid", nullable: true),
                    NetworkTransactionId = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    TrackingReference = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: true),
                    NetworkStatus = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    OrderAmount = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    CommissionAmount = table.Column<decimal>(type: "numeric(18,2)", precision: 18, scale: 2, nullable: true),
                    Currency = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: true),
                    TransactionOccurredAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    NetworkUpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    RawPayload = table.Column<string>(type: "jsonb", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AffiliateConversions", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AffiliateConversions_AffiliateClicks_AffiliateClickId",
                        column: x => x.AffiliateClickId,
                        principalTable: "AffiliateClicks",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_AffiliateConversions_AffiliateNetworks_AffiliateNetworkId",
                        column: x => x.AffiliateNetworkId,
                        principalTable: "AffiliateNetworks",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateClicks_AffiliateNetworkId",
                table: "AffiliateClicks",
                column: "AffiliateNetworkId");

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateClicks_OfferId",
                table: "AffiliateClicks",
                column: "OfferId");

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateClicks_RedirectToken",
                table: "AffiliateClicks",
                column: "RedirectToken",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateClicks_StoreId",
                table: "AffiliateClicks",
                column: "StoreId");

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateClicks_TrackingReference",
                table: "AffiliateClicks",
                column: "TrackingReference",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateClicks_UserId_CreatedAt",
                table: "AffiliateClicks",
                columns: new[] { "UserId", "CreatedAt" });

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateConversions_AffiliateClickId",
                table: "AffiliateConversions",
                column: "AffiliateClickId");

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateConversions_AffiliateNetworkId_NetworkTransactionId",
                table: "AffiliateConversions",
                columns: new[] { "AffiliateNetworkId", "NetworkTransactionId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateConversions_NetworkStatus",
                table: "AffiliateConversions",
                column: "NetworkStatus");

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateConversions_NetworkUpdatedAt",
                table: "AffiliateConversions",
                column: "NetworkUpdatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_AffiliateConversions_TrackingReference",
                table: "AffiliateConversions",
                column: "TrackingReference");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AffiliateConversions");

            migrationBuilder.DropTable(
                name: "AffiliateClicks");
        }
    }
}
