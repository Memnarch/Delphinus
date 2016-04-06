unit DN.VariableResolver.Compiler;

interface

uses
  DN.VariableResolver,
  DN.Compiler.Intf;

type
  TCompilerVariableResolver = class(TVariableResolver)
  public
    constructor Create(APlatform: TDNCompilerPlatform; AConfig: TDNCompilerConfig); reintroduce;
  end;

implementation

uses
  SysUtils;

{ TCompilerVariableResolver }

constructor TCompilerVariableResolver.Create(APlatform: TDNCompilerPlatform;
  AConfig: TDNCompilerConfig);
begin
  inherited Create(['Platform', 'Config', 'BDSCommonDir'],
    [TDNCompilerPlatformName[APlatform], TDNCompilerConfigName[AConfig], GetEnvironmentVariable('BDSCommonDir')]);
end;

end.
