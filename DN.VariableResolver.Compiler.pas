unit DN.VariableResolver.Compiler;

interface

uses
  DN.VariableResolver,
  DN.Types;

type
  TCompilerVariableResolver = class(TVariableResolver)
  public
    constructor Create(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig; const ABDSCommonDir: string); reintroduce;
  end;

implementation

uses
  DN.Utils;

{ TCompilerVariableResolver }

constructor TCompilerVariableResolver.Create(APlatform: TDNCompilerPlatform;
  AConfig: TDNCompilerConfig; const ABDSCommonDir: string);
begin
  inherited Create(['Platform', 'Config', 'BDSCommonDir'],
    [TDNCompilerPlatformName[APlatform], TDNCompilerConfigName[AConfig], ABDSCommonDir]);
end;

end.
