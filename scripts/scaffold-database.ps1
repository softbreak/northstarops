param(
    [string]$ConnectionString = $env:NORTHSTAROPS_CONNECTION_STRING
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ConnectionString)) {
    throw "NORTHSTAROPS_CONNECTION_STRING is not set. Provide -ConnectionString or set the environment variable before running the scaffold script."
}

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$persistenceProject = Join-Path $repoRoot "src/NorthStarOps.Persistence/NorthStarOps.Persistence.csproj"
$startupProject = Join-Path $repoRoot "src/NorthStarOps.Api/NorthStarOps.Api.csproj"

Push-Location $repoRoot
try {
    dotnet tool restore
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet tool restore failed."
    }

    dotnet restore
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet restore failed."
    }

    dotnet ef dbcontext scaffold `
        $ConnectionString `
        Microsoft.EntityFrameworkCore.SqlServer `
        --project $persistenceProject `
        --startup-project $startupProject `
        --context NorthStarOpsDbContext `
        --context-dir Database `
        --output-dir Database/Models `
        --namespace NorthStarOps.Persistence.Database.Models `
        --context-namespace NorthStarOps.Persistence.Database `
        --no-onconfiguring `
        --force

    if ($LASTEXITCODE -ne 0) {
        throw "EF Core database scaffold failed."
    }
}
finally {
    Pop-Location
}
