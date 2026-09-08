using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Persistence;
using NorthStarOps.Persistence.Database;
using Xunit;

namespace NorthStarOps.Tests.DependencyInjection;

public sealed class PersistenceRegistrationTests
{
    [Fact]
    public void AddPersistence_RegistersNorthStarOpsDbContext()
    {
        const string testConnectionString =
            "Server=test-server;" +
            "Database=test-database;" +
            "User Id=test-user;" +
            "Password=test-password;";

        var configuration = new ConfigurationManager
        {
            ["ConnectionStrings:NorthStarOps"] = testConnectionString
        };

        var services = new ServiceCollection();

        services.AddPersistence(configuration);

        Assert.Contains(
            services,
            descriptor =>
                descriptor.ServiceType ==
                typeof(DbContextOptions<NorthStarOpsDbContext>));
    }

    [Fact]
    public void AddPersistence_Throws_WhenConnectionStringIsMissing()
    {
        var configuration = new ConfigurationManager();
        var services = new ServiceCollection();

        var exception = Assert.Throws<InvalidOperationException>(
            () => services.AddPersistence(configuration));

        Assert.Contains(
            "ConnectionStrings:NorthStarOps",
            exception.Message);
    }
}