unit DN.VariableResolver.Compiler.Factory;

interface

uses
  DN.VariableResolver.Intf,
  DN.Compiler.Intf;

type
  TDNCompilerVariableResolverFacory = reference to function(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig): IVariableResolver;

implementation

end.
