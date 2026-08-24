using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class CashbackSettingsConfiguration : IEntityTypeConfiguration<CashbackSettings>
{
    public void Configure(EntityTypeBuilder<CashbackSettings> builder)
    {
        builder.ToTable("CashbackSettings");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.UserSharePercent)
            .HasPrecision(5, 2)
            .IsRequired();

        builder.Property(x => x.ConfirmationWindowDays)
            .IsRequired();
    }
}
