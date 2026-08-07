using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class BannerConfiguration : IEntityTypeConfiguration<Banner>
{
    public void Configure(EntityTypeBuilder<Banner> builder)
    {
        builder.ToTable("Banners");

        builder.HasKey(banner => banner.Id);

        builder.Property(banner => banner.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(banner => banner.Subtitle)
            .HasMaxLength(300);

        builder.Property(banner => banner.ImageUrl)
            .IsRequired()
            .HasMaxLength(1000);

        builder.Property(banner => banner.TargetType)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(banner => banner.ExternalUrl)
            .HasMaxLength(2000);

        builder.Property(banner => banner.DisplayOrder)
            .HasDefaultValue(0);

        builder.Property(banner => banner.IsActive)
            .HasDefaultValue(true);

        builder.Property(banner => banner.CreatedAt)
            .IsRequired();

        builder.HasOne(banner => banner.Store)
            .WithMany(store => store.Banners)
            .HasForeignKey(banner => banner.StoreId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(banner => banner.Offer)
            .WithMany(offer => offer.Banners)
            .HasForeignKey(banner => banner.OfferId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(banner => banner.Category)
            .WithMany(category => category.Banners)
            .HasForeignKey(banner => banner.CategoryId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(banner => banner.StoreId);

        builder.HasIndex(banner => banner.OfferId);

        builder.HasIndex(banner => banner.CategoryId);

        builder.HasIndex(banner => new
        {
            banner.IsActive,
            banner.DisplayOrder
        });

        builder.HasIndex(banner => new
        {
            banner.StartAt,
            banner.EndAt
        });
    }
}