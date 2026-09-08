using System.Reflection;
using NorthStarOps.Api.Modules;

namespace NorthStarOps.Api;

public static class EndpointRegistration
{
    public static IEndpointRouteBuilder MapApplicationEndpoints(
        this IEndpointRouteBuilder endpoints,
        params Assembly[] assemblies)
    {
        if (assemblies.Length == 0)
        {
            assemblies = [typeof(EndpointRegistration).Assembly];
        }

        var moduleTypes = assemblies
            .SelectMany(assembly => assembly.GetTypes())
            .Where(type =>
                typeof(IEndpointModule).IsAssignableFrom(type) &&
                !type.IsInterface &&
                !type.IsAbstract)
            .OrderBy(type => type.FullName);

        foreach (var moduleType in moduleTypes)
        {
            if (Activator.CreateInstance(moduleType) is not IEndpointModule module)
            {
                throw new InvalidOperationException(
                    $"Endpoint modülü oluşturulamadı: {moduleType.FullName}");
            }

            module.MapEndpoints(endpoints);
        }

        return endpoints;
    }
}