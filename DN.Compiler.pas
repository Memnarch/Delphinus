unit DN.Compiler;

interface

uses
  Classes,
  DN.Compiler.Intf;

type
  TDNCompiler = class(TInterfacedObject, IDNCompiler)
  private
    FDCUOutput: string;
    FDCPOutput: string;
    FEXEOutput: string;
    FBPLOutput: string;
    FTarget: TDNCompilerTarget;
    FConfig: TDNCompilerConfig;
    FLog: TStringList;
    function GetEXEOutput: string;
    function GetDCPOutput: string;
    function GetDCUOutput: string;
    procedure SetEXEOutput(const Value: string);
    procedure SetDCPOutput(const Value: string);
    procedure SetDCUOutput(const Value: string);
    function GetConfig: TDNCompilerConfig;
    function GetTarget: TDNCompilerTarget;
    procedure SetConfig(const Value: TDNCompilerConfig);
    procedure SetTarget(const Value: TDNCompilerTarget);
    function GetBPLOutput: string;
    procedure SetBPLOutput(const Value: string);
    function GetLog: TStrings;
  public
    constructor Create();
    destructor Destroy(); override;
    function Compile(const AProjectFile: string): Boolean; virtual; abstract;
    property DCUOutput: string read GetDCUOutput write SetDCUOutput;
    property DCPOutput: string read GetDCPOutput write SetDCPOutput;
    property EXEOutput: string read GetEXEOutput write SetEXEOutput;
    property BPLOutput: string read GetBPLOutput write SetBPLOutput;
    property Target: TDNCompilerTarget read GetTarget write SetTarget;
    property Config: TDNCompilerConfig read GetConfig write SetConfig;
    property Log: TStrings read GetLog;
  end;

implementation

{ TDNCompiler }

function TDNCompiler.GetEXEOutput: string;
begin
  Result := FEXEOutput;
end;

constructor TDNCompiler.Create;
begin
  inherited;
  FLog := TStringList.Create();
end;

destructor TDNCompiler.Destroy;
begin
  FLog.Free();
  inherited;
end;

function TDNCompiler.GetLog: TStrings;
begin
  Result := FLog;
end;

function TDNCompiler.GetBPLOutput: string;
begin
  Result := FBPLOutput;
end;

function TDNCompiler.GetConfig: TDNCompilerConfig;
begin
  Result := FConfig;
end;

function TDNCompiler.GetDCPOutput: string;
begin
  Result := FDCPOutput;
end;

function TDNCompiler.GetDCUOutput: string;
begin
  Result := FDCUOutput;
end;

function TDNCompiler.GetTarget: TDNCompilerTarget;
begin
  Result := FTarget;
end;

procedure TDNCompiler.SetEXEOutput(const Value: string);
begin
  FEXEOutput := Value;
end;

procedure TDNCompiler.SetBPLOutput(const Value: string);
begin
  FBPLOutput := Value;
end;

procedure TDNCompiler.SetConfig(const Value: TDNCompilerConfig);
begin
  FConfig := Value;
end;

procedure TDNCompiler.SetDCPOutput(const Value: string);
begin
  FDCPOutput := Value;
end;

procedure TDNCompiler.SetDCUOutput(const Value: string);
begin
  FDCUOutput := Value;
end;

procedure TDNCompiler.SetTarget(const Value: TDNCompilerTarget);
begin
  FTarget := Value;
end;

end.
