using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class CategoryConfiguration : IEntityTypeConfiguration<Category>
{
    public void Configure(EntityTypeBuilder<Category> builder)
    {
        builder.ToTable("Categories");

        builder.HasKey(category => category.Id);

        builder.Property(category => category.Name)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(category => category.Slug)
            .IsRequired()
            .HasMaxLength(120);

        builder.Property(category => category.Description)
            .HasMaxLength(500);

        builder.Property(category => category.IconUrl)
            .HasMaxLength(1000);

        builder.Property(category => category.DisplayOrder)
            .HasDefaultValue(0);

        builder.Property(category => category.IsActive)
            .HasDefaultValue(true);

        builder.Property(category => category.CreatedAt)
            .IsRequired();

        builder.HasIndex(category => category.Name)
            .IsUnique();

        builder.HasIndex(category => category.Slug)
            .IsUnique();

        builder.HasIndex(category => new
        {
            category.IsActive,
            category.DisplayOrder
        });
    }
}