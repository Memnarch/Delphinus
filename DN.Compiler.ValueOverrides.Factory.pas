unit DN.Compiler.ValueOverrides.Factory;

interface

uses
  DN.Types,
  DN.Compiler.Intf,
  DN.Compiler.ValueOverrides.Intf;

type
  TValueOverridesFactory = class
  public
    class function CreateOverride(const AConfig: TDNCompilerConfig; AVersion: TCompilerVersion): ICompilerValueOverrides;
  end;

implementation

uses
  DN.Compiler.ValueOverrides;

{ TValueOverridesFactory }

class function TValueOverridesFactory.CreateOverride(
  const AConfig: TDNCompilerConfig; AVersion: TCompilerVersion): ICompilerValueOverrides;
begin
  if AVersion >= 26then //XE5 or newer
  begin
    case AConfig of
      ccRelease: Result := TXE5ReleaseValueOverrides.Create();
      ccDebug: Result := TXE5DebugValueOverrides.Create();
    end;
  end
  else
  begin
    case AConfig of
      ccRelease: Result := TXEReleaseValueOverrides.Create();
      ccDebug: Result := TXEDebugValueOverrides.Create();
    end;
  end;
end;

end.
