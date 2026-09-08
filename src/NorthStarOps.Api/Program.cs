using NorthStarOps.Api;
using NorthStarOps.Application;
using NorthStarOps.Persistence;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddApplication()
    .AddPersistence(builder.Configuration);

var app = builder.Build();

app.MapApplicationEndpoints();

app.MapGet("/", () => Results.Ok(new
{
    service = "NorthStarOps.Api",
    status = "running"
}));

app.Run();