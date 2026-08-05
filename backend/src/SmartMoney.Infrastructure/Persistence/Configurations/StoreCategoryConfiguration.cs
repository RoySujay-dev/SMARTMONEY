using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Configurations;

public sealed class StoreCategoryConfiguration
    : IEntityTypeConfiguration<StoreCategory>
{
    public void Configure(EntityTypeBuilder<StoreCategory> builder)
    {
        builder.ToTable("StoreCategories");

        builder.HasKey(storeCategory => new
        {
            storeCategory.StoreId,
            storeCategory.CategoryId
        });

        builder.HasOne(storeCategory => storeCategory.Store)
            .WithMany(store => store.StoreCategories)
            .HasForeignKey(storeCategory => storeCategory.StoreId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(storeCategory => storeCategory.Category)
            .WithMany(category => category.StoreCategories)
            .HasForeignKey(storeCategory => storeCategory.CategoryId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(storeCategory => storeCategory.CategoryId);
    }
}