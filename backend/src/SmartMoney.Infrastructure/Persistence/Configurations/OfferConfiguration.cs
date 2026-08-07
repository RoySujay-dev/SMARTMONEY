using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class OfferConfiguration : IEntityTypeConfiguration<Offer>
{
    public void Configure(EntityTypeBuilder<Offer> builder)
    {
        builder.ToTable("Offers");

        builder.HasKey(offer => offer.Id);

        builder.Property(offer => offer.Title)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(offer => offer.Slug)
            .IsRequired()
            .HasMaxLength(220);

        builder.Property(offer => offer.OfferType)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(offer => offer.ShortDescription)
            .HasMaxLength(500);

        builder.Property(offer => offer.Description)
            .HasMaxLength(3000);

        builder.Property(offer => offer.TermsAndConditions)
            .HasMaxLength(5000);

        builder.Property(offer => offer.ImageUrl)
            .HasMaxLength(1000);

        builder.Property(offer => offer.CashbackType)
            .HasConversion<int>()
            .IsRequired();

        builder.Property(offer => offer.CashbackValue)
            .HasPrecision(12, 2);

        builder.Property(offer => offer.CashbackText)
            .HasMaxLength(150);

        builder.Property(offer => offer.CouponCode)
            .HasMaxLength(100);

        builder.Property(offer => offer.DestinationUrl)
            .IsRequired()
            .HasMaxLength(2000);

        builder.Property(offer => offer.IsFeatured)
            .HasDefaultValue(false);

        builder.Property(offer => offer.Priority)
            .HasDefaultValue(0);

        builder.Property(offer => offer.IsActive)
            .HasDefaultValue(true);

        builder.Property(offer => offer.CreatedAt)
            .IsRequired();

        builder.HasOne(offer => offer.Store)
            .WithMany(store => store.Offers)
            .HasForeignKey(offer => offer.StoreId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(offer => offer.Slug)
            .IsUnique();

        builder.HasIndex(offer => offer.StoreId);

        builder.HasIndex(offer => new
        {
            offer.IsActive,
            offer.IsFeatured,
            offer.Priority
        });

        builder.HasIndex(offer => new
        {
            offer.StartAt,
            offer.EndAt
        });
    }
}