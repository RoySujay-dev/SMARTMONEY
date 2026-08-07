using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class StoreAffiliateMappingConfiguration
    : IEntityTypeConfiguration<StoreAffiliateMapping>
{
    public void Configure(EntityTypeBuilder<StoreAffiliateMapping> builder)
    {
        builder.ToTable("StoreAffiliateMappings");

        builder.HasKey(mapping => mapping.Id);

        builder.Property(mapping => mapping.ExternalMerchantId)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(mapping => mapping.ExternalMerchantName)
            .HasMaxLength(200);

        builder.Property(mapping => mapping.MerchantUrl)
            .HasMaxLength(2000);

        builder.Property(mapping => mapping.IsActive)
            .HasDefaultValue(true);

        builder.Property(mapping => mapping.CreatedAt)
            .IsRequired();

        builder.HasOne(mapping => mapping.Store)
            .WithMany(store => store.AffiliateMappings)
            .HasForeignKey(mapping => mapping.StoreId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(mapping => mapping.AffiliateNetwork)
            .WithMany(network => network.StoreMappings)
            .HasForeignKey(mapping => mapping.AffiliateNetworkId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(mapping => new
        {
            mapping.StoreId,
            mapping.AffiliateNetworkId
        })
        .IsUnique();

        builder.HasIndex(mapping => new
        {
            mapping.AffiliateNetworkId,
            mapping.ExternalMerchantId
        })
        .IsUnique();

        builder.HasIndex(mapping => mapping.IsActive);
    }
}