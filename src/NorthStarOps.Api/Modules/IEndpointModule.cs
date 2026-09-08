namespace NorthStarOps.Api.Modules;

public interface IEndpointModule
{
    void MapEndpoints(IEndpointRouteBuilder endpoints);
}