unit DN.VariableResolver.Compiler;

interface

uses
  DN.VariableResolver,
  DN.Compiler.Intf;

type
  TCompilerVariableResolver = class(TVariableResolver)
  public
    constructor Create(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig; const ABDSCommonDir: string); reintroduce;
  end;

implementation

{ TCompilerVariableResolver }

constructor TCompilerVariableResolver.Create(APlatform: TDNCompilerPlatform;
  AConfig: TDNCompilerConfig; const ABDSCommonDir: string);
begin
  inherited Create(['Platform', 'Config', 'BDSCommonDir'],
    [TDNCompilerPlatformName[APlatform], TDNCompilerConfigName[AConfig], ABDSCommonDir]);
end;

end.
