unit Tests.Mocks.Compiler;

interface

uses
  DN.Types,
  DN.Compiler;

type
  TDNCompilerMock = class(TDNCompiler)
  protected
    FVersion: TCompilerVersion;
    function GetVersion: Single; override;
  public
    constructor Create;
    function Compile(const AProjectFile: string): Boolean; override;
    property Version: TCompilerVersion read GetVersion write FVersion;
  end;

const
  CCompilerXE = 22;
  CCompilerXE2 = 23;

implementation

{ TDNCompilerMock }

function TDNCompilerMock.Compile(const AProjectFile: string): Boolean;
begin
  Result := True;
end;

constructor TDNCompilerMock.Create;
begin
  inherited Create(nil);
end;

function TDNCompilerMock.GetVersion: Single;
begin
  Result := FVersion;
end;

end.
