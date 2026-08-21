using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class AffiliateClickConfiguration
    : IEntityTypeConfiguration<AffiliateClick>
{
    public void Configure(EntityTypeBuilder<AffiliateClick> builder)
    {
        builder.ToTable("AffiliateClicks");

        builder.HasKey(click => click.Id);

        builder.Property(click => click.TrackingReference)
            .IsRequired()
            .HasMaxLength(64);

        builder.Property(click => click.RedirectToken)
            .IsRequired()
            .HasMaxLength(64);

        builder.Property(click => click.DestinationUrl)
            .IsRequired()
            .HasMaxLength(2000);

        builder.Property(click => click.TrackedUrl)
            .HasMaxLength(2000);

        builder.Property(click => click.CreatedAt)
            .IsRequired();

        builder.HasOne(click => click.User)
            .WithMany()
            .HasForeignKey(click => click.UserId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(click => click.Store)
            .WithMany()
            .HasForeignKey(click => click.StoreId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(click => click.Offer)
            .WithMany()
            .HasForeignKey(click => click.OfferId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(click => click.AffiliateNetwork)
            .WithMany()
            .HasForeignKey(click => click.AffiliateNetworkId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(click => click.TrackingReference)
            .IsUnique();

        builder.HasIndex(click => click.RedirectToken)
            .IsUnique();

        builder.HasIndex(click => new
        {
            click.UserId,
            click.CreatedAt
        });

        builder.HasIndex(click => click.StoreId);

        builder.HasIndex(click => click.OfferId);

        builder.HasIndex(click => click.AffiliateNetworkId);
    }
}
