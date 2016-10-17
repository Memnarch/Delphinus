unit Tests.Mocks.VariableResolver;

interface

uses
  DN.Types,
  DN.VariableResolver.Intf;

function MockedVariableResolverFactory(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig): IVariableResolver;

implementation

uses
  DN.VariableResolver;

function MockedVariableResolverFactory(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig): IVariableResolver;
begin
  Result := TVariableResolver.Create([], []);
end;

end.
