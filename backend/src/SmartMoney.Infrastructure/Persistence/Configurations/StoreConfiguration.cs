using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class StoreConfiguration : IEntityTypeConfiguration<Store>
{
    public void Configure(EntityTypeBuilder<Store> builder)
    {
        builder.ToTable("Stores");

        builder.HasKey(store => store.Id);

        builder.Property(store => store.Name)
            .IsRequired()
            .HasMaxLength(150);

        builder.Property(store => store.Slug)
            .IsRequired()
            .HasMaxLength(170);

        builder.Property(store => store.ShortDescription)
            .HasMaxLength(300);

        builder.Property(store => store.Description)
            .HasMaxLength(2000);

        builder.Property(store => store.LogoUrl)
            .HasMaxLength(1000);

        builder.Property(store => store.BannerUrl)
            .HasMaxLength(1000);

        builder.Property(store => store.WebsiteUrl)
            .IsRequired()
            .HasMaxLength(1000);

        builder.Property(store => store.DefaultCashbackText)
            .HasMaxLength(150);

        builder.Property(store => store.IsFeatured)
            .HasDefaultValue(false);

        builder.Property(store => store.DisplayOrder)
            .HasDefaultValue(0);

        builder.Property(store => store.IsActive)
            .HasDefaultValue(true);

        builder.Property(store => store.CreatedAt)
            .IsRequired();

        builder.HasIndex(store => store.Name)
            .IsUnique();

        builder.HasIndex(store => store.Slug)
            .IsUnique();

        builder.HasIndex(store => new
        {
            store.IsActive,
            store.IsFeatured,
            store.DisplayOrder
        });
    }
}