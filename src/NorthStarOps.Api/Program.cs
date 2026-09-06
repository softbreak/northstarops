var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/", () => Results.Ok(new
{
    service = "NorthStarOps.Api",
    status = "running"
}));

app.Run();
