using Microsoft.Extensions.DependencyInjection;

namespace NorthStarOps.Application.Modules;

public interface IServiceModule
{
    void Register(IServiceCollection services);
}