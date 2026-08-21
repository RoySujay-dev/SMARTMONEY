using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class AffiliateConversionConfiguration
    : IEntityTypeConfiguration<AffiliateConversion>
{
    public void Configure(EntityTypeBuilder<AffiliateConversion> builder)
    {
        builder.ToTable("AffiliateConversions");

        builder.HasKey(conversion => conversion.Id);

        builder.Property(conversion => conversion.NetworkTransactionId)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(conversion => conversion.TrackingReference)
            .HasMaxLength(64);

        builder.Property(conversion => conversion.NetworkStatus)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(conversion => conversion.OrderAmount)
            .HasPrecision(18, 2);

        builder.Property(conversion => conversion.CommissionAmount)
            .HasPrecision(18, 2);

        builder.Property(conversion => conversion.Currency)
            .HasMaxLength(10);

        builder.Property(conversion => conversion.RawPayload)
            .HasColumnType("jsonb");

        builder.Property(conversion => conversion.CreatedAt)
            .IsRequired();

        builder.HasOne(conversion => conversion.AffiliateNetwork)
            .WithMany()
            .HasForeignKey(conversion => conversion.AffiliateNetworkId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(conversion => conversion.AffiliateClick)
            .WithMany()
            .HasForeignKey(conversion => conversion.AffiliateClickId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(conversion => new
        {
            conversion.AffiliateNetworkId,
            conversion.NetworkTransactionId
        })
        .IsUnique();

        builder.HasIndex(conversion => conversion.AffiliateClickId);

        builder.HasIndex(conversion => conversion.TrackingReference);

        builder.HasIndex(conversion => conversion.NetworkStatus);

        builder.HasIndex(conversion => conversion.NetworkUpdatedAt);
    }
}
