using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Application;
using NorthStarOps.Application.Modules;
using Xunit;

namespace NorthStarOps.Tests.DependencyInjection;

public sealed class ApplicationRegistrationTests
{
    [Fact]
    public void AddApplication_RegistersDiscoveredModules()
    {
        var services = new ServiceCollection();

        services.AddApplication(typeof(ApplicationRegistrationTests).Assembly);

        Assert.Contains(
            services,
            descriptor =>
                descriptor.ServiceType == typeof(ITestService));
    }

    private interface ITestService;

    private sealed class TestService : ITestService;

    private sealed class TestModule : IServiceModule
    {
        public void Register(IServiceCollection services)
        {
            services.AddSingleton<ITestService, TestService>();
        }
    }
}