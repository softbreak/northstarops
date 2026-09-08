using System.Reflection;
using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Application.Modules;

namespace NorthStarOps.Application;

public static class DependencyInjection
{
    public static IServiceCollection AddApplication(
        this IServiceCollection services,
        params Assembly[] assemblies)
    {
        if (assemblies.Length == 0)
        {
            assemblies = [typeof(DependencyInjection).Assembly];
        }

        var moduleTypes = assemblies
            .SelectMany(assembly => assembly.GetTypes())
            .Where(type =>
                typeof(IServiceModule).IsAssignableFrom(type) &&
                !type.IsInterface &&
                !type.IsAbstract)
            .OrderBy(type => type.FullName);

        foreach (var moduleType in moduleTypes)
        {
            if (Activator.CreateInstance(moduleType) is not IServiceModule module)
            {
                throw new InvalidOperationException(
                    $"Application modülü oluşturulamadı: {moduleType.FullName}");
            }

            module.Register(services);
        }

        return services;
    }
}