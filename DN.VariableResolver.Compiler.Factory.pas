unit DN.VariableResolver.Compiler.Factory;

interface

uses
  DN.VariableResolver.Intf,
  DN.Types;

type
  TDNCompilerVariableResolverFacory = reference to function(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig): IVariableResolver;

implementation

end.
