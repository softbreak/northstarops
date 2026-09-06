var builder = WebApplication.CreateBuilder(args);

var connectionString = builder.Configuration.GetConnectionString("NorthStarOps");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "NorthStarOps veritabanı bağlantı bilgisi tanımlı değil. " +
        "ConnectionStrings:NorthStarOps değerini User Secrets veya uygun bir configuration provider üzerinden tanımlayın.");
}

var app = builder.Build();

app.MapGet("/", () => Results.Ok(new
{
    service = "NorthStarOps.Api",
    status = "running"
}));

app.Run();
