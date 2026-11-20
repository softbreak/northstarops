using Microsoft.Extensions.DependencyInjection;
using NorthStarOps.Application.Features.Support.OpenTickets.Services;
using NorthStarOps.Application.Modules;

namespace NorthStarOps.Application.Features.Support.OpenTickets;

public sealed class OpenTicketsServiceModule : IServiceModule
{
    public void Register(IServiceCollection services)
    {
        services.AddScoped<IOpenTicketsService, OpenTicketsService>();
    }
}
