unit DN.Compiler.ValueOverrides;

interface

uses
  DN.Compiler.ValueOverrides.Intf;

type
  TXEDebugValueOverrides = class(TInterfacedObject, ICompilerValueOverrides)
  public
    function DebugInformation: string;
  end;

  TXEReleaseValueOverrides = class(TInterfacedObject, ICompilerValueOverrides)
  public
    function DebugInformation: string;
  end;

  TXE5DebugValueOverrides = class(TInterfacedObject, ICompilerValueOverrides)
  public
    function DebugInformation: string;
  end;

  TXE5ReleaseValueOverrides = class(TInterfacedObject, ICompilerValueOverrides)
  public
    function DebugInformation: string;
  end;

implementation

{ TXEReleaseValueOverrides }

function TXEReleaseValueOverrides.DebugInformation: string;
begin
  Result := 'False';
end;

{ TXEDebugValueOverrides }

function TXEDebugValueOverrides.DebugInformation: string;
begin
  Result := 'True';
end;

{ TXE2ReleaseValueOverrides }

function TXE5ReleaseValueOverrides.DebugInformation: string;
begin
  Result := '0';
end;

{ TXE2DebugValueOverrides }

function TXE5DebugValueOverrides.DebugInformation: string;
begin
  Result := '2;';
end;

end.
