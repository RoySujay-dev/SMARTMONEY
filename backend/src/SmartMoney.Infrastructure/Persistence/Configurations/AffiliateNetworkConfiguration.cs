using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class AffiliateNetworkConfiguration
    : IEntityTypeConfiguration<AffiliateNetwork>
{
    public void Configure(EntityTypeBuilder<AffiliateNetwork> builder)
    {
        builder.ToTable("AffiliateNetworks");

        builder.HasKey(network => network.Id);

        builder.Property(network => network.Name)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(network => network.Code)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(network => network.IsActive)
            .HasDefaultValue(true);

        builder.Property(network => network.CreatedAt)
            .IsRequired();

        builder.HasIndex(network => network.Name)
            .IsUnique();

        builder.HasIndex(network => network.Code)
            .IsUnique();

        builder.HasIndex(network => network.IsActive);
    }
}