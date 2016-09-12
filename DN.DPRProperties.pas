unit DN.DPRProperties;

interface

uses
  Classes,
  SysUtils,
  DN.DPRProperties.Intf;

type
  TDPRProperties = class(TInterfacedObject, IDPRProperties)
  private
    FFileName: string;
    FBackup: string;
    FContent: TStringList;
    procedure Open;
    procedure Close;
    procedure SetDefine(const AName, AValue: string);
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    procedure BeginTemporaryOverride;
    procedure EndTemporaryOverride;
    procedure SetLibVersion(const AVersion: string);
    procedure SetPrefix(const APrefix: string);
    procedure SetSuffix(const ASuffix: string);
  end;

implementation

uses
  IOUtils,
  StrUtils;

{ TDPKProperties }

procedure TDPRProperties.BeginTemporaryOverride;
begin
  if FBackup <> '' then
    raise Exception.Create('can not recursively enter temporary override');

  FBackup := FFileName + '.bak';
  TFile.Copy(FFileName, FBackup);
end;

procedure TDPRProperties.Close;
begin
  try
    FContent.SaveToFile(FFileName);
  finally
    FContent.Free;
  end;
end;

constructor TDPRProperties.Create(const AFileName: string);
begin
  inherited Create();
  FFileName := AFileName;
end;

destructor TDPRProperties.Destroy;
begin
  if FBackup <> '' then
    EndTemporaryOverride();
  inherited;
end;

procedure TDPRProperties.EndTemporaryOverride;
begin
  if FBackup = '' then
    raise Exception.Create('Tried to exit nonexisting temporary overridesession');

  TFile.Copy(FBackup, FFileName, True);
  TFile.Delete(FBackup);
  FBackup := '';
end;

procedure TDPRProperties.Open;
begin
  FContent := TStringList.Create();
  FContent.LoadFromFile(FFileName);
end;

procedure TDPRProperties.SetDefine(const AName, AValue: string);
var
  i: Integer;
const
  CDefine = '{$%s %s}';
begin
  Open();
  try
    for i := FContent.Count - 1 downto 0 do
    begin
      if StartsText('end.', Trim(FContent[i])) and (i > 0) then
      begin
        FContent.Insert(i, Format(CDefine, [AName, AValue]));
        Exit;
      end;
    end;
    raise Exception.Create('failed to set Define ' + AName + ' in ' + FFileName);
  finally
    Close();
  end;
end;

procedure TDPRProperties.SetLibVersion(const AVersion: string);
begin
  SetDefine('LibVersion', QuotedStr(AVersion));
end;

procedure TDPRProperties.SetPrefix(const APrefix: string);
begin
  SetDefine('LibPrefix', QuotedStr(APrefix));
end;

procedure TDPRProperties.SetSuffix(const ASuffix: string);
begin
  SetDefine('LibSuffix', QuotedStr(ASuffix));
end;

end.
