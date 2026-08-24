using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartMoney.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class StoreCashbackStatusAsString : Migration
    {
        // A plain AlterColumn would cast 6 -> '6', not 'AwaitingAdminReview',
        // so the type change carries an explicit value mapping for rows that
        // already exist. Values must match the CashbackStatus enum names.
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE "Cashbacks"
                ALTER COLUMN "Status" TYPE character varying(32)
                USING CASE "Status"
                    WHEN 1 THEN 'Pending'
                    WHEN 2 THEN 'Confirmed'
                    WHEN 3 THEN 'Rejected'
                    WHEN 4 THEN 'PaidOut'
                    WHEN 5 THEN 'Reversed'
                    WHEN 6 THEN 'AwaitingAdminReview'
                    ELSE "Status"::text
                END;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                """
                ALTER TABLE "Cashbacks"
                ALTER COLUMN "Status" TYPE integer
                USING CASE "Status"
                    WHEN 'Pending' THEN 1
                    WHEN 'Confirmed' THEN 2
                    WHEN 'Rejected' THEN 3
                    WHEN 'PaidOut' THEN 4
                    WHEN 'Reversed' THEN 5
                    WHEN 'AwaitingAdminReview' THEN 6
                    ELSE "Status"::integer
                END;
                """);
        }
    }
}
