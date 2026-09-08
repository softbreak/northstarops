using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Persistence.Database;

namespace NorthStarOps.Persistence;

public static class DependencyInjection
{
    public static IServiceCollection AddPersistence(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        var connectionString =
            configuration.GetConnectionString("NorthStarOps");

        if (string.IsNullOrWhiteSpace(connectionString))
        {
            throw new InvalidOperationException(
                "NorthStarOps veritabanı bağlantı bilgisi tanımlı değil. " +
                "ConnectionStrings:NorthStarOps değerini User Secrets " +
                "veya uygun bir configuration provider üzerinden tanımlayın.");
        }

        services.AddDbContext<NorthStarOpsDbContext>(options =>
            options.UseSqlServer(connectionString));

        return services;
    }
}