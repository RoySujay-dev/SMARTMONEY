using Microsoft.EntityFrameworkCore;
using SmartMoney.Application.Abstractions.Persistence;
using SmartMoney.Domain.Entities;

namespace SmartMoney.Infrastructure.Persistence.Context;

public sealed class SmartMoneyDbContext : DbContext, IUnitOfWork
{
    public SmartMoneyDbContext(
        DbContextOptions<SmartMoneyDbContext> options)
        : base(options)
    {
    }

    public DbSet<User> Users => Set<User>();

    public DbSet<Role> Roles => Set<Role>();

    public DbSet<Wallet> Wallets => Set<Wallet>();

    public DbSet<Cashback> Cashbacks => Set<Cashback>();

    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<EmailVerificationOtp> EmailVerificationOtps
    => Set<EmailVerificationOtp>();

    public DbSet<Category> Categories => Set<Category>();

    public DbSet<Store> Stores => Set<Store>();

    public DbSet<StoreCategory> StoreCategories => Set<StoreCategory>();

    public DbSet<Offer> Offers => Set<Offer>();

    public DbSet<AffiliateNetwork> AffiliateNetworks => Set<AffiliateNetwork>();

    public DbSet<StoreAffiliateMapping> StoreAffiliateMappings
        => Set<StoreAffiliateMapping>();

    public DbSet<Banner> Banners => Set<Banner>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.ApplyConfigurationsFromAssembly(
            typeof(SmartMoneyDbContext).Assembly);
    }
}