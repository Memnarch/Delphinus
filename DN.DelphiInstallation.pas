unit DN.DelphiInstallation;

interface

uses
  DN.DelphiInstallation.Intf,
  Graphics;

type
  TDNDelphInstallation = class(TInterfacedObject, IDNDelphiInstallation)
  private
    FName: string;
    FRoot: string;
    FDirectory: string;
    FApplication: string;
    FEdition: string;
    FIcon: TIcon;
    procedure Load;
    function GetIcon: TIcon;
    function GetName: string;
    function GetRoot: string;
    function GetDirectory: string;
    function GetApplication: string;
    function GetEdition: string;
  public
    constructor Create(const ARoot: string);
    destructor Destroy; override;
    property Name: string read GetName;
    property Edition: string read GetEdition;
    property Icon: TIcon read GetIcon;
    property Root: string read GetRoot;
    property Directory: string read GetDirectory;
    property Application: string read GetApplication;
  end;

implementation

uses
  Windows,
  Registry,
  IOUtils,
  ShellApi;

{ TDNDelphInstallationInfo }

constructor TDNDelphInstallation.Create(const ARoot: string);
begin
  inherited Create();
  FRoot := ARoot;
  Load();
end;

destructor TDNDelphInstallation.Destroy;
begin
  if Assigned(FIcon) then
    FIcon.Free();
  inherited;
end;

function TDNDelphInstallation.GetApplication: string;
begin
  Result := FApplication;
end;

function TDNDelphInstallation.GetDirectory: string;
begin
  Result := FDirectory;
end;

function TDNDelphInstallation.GetEdition: string;
begin
  Result := FEdition;
end;

function TDNDelphInstallation.GetIcon: TIcon;
begin
  if not Assigned(FIcon) then
  begin
    FIcon := TIcon.Create();
    FIcon.Handle := ExtractIcon(HInstance, PChar(FApplication), 0);
  end;
  Result := FIcon;
end;

function TDNDelphInstallation.GetName: string;
begin
  Result := FName;
end;

function TDNDelphInstallation.GetRoot: string;
begin
  Result := FRoot;
end;

procedure TDNDelphInstallation.Load;
var
  LRegistry: TRegistry;
const
  CDelphiWin32 = 'Delphi.Win32';
begin
  LRegistry := TRegistry.Create();
  try
    LRegistry.Access := LRegistry.Access or KEY_WOW64_64KEY;
    LRegistry.RootKey := HKEY_CURRENT_USER;
    if LRegistry.OpenKey(FRoot, False) then
    begin
      FDirectory := LRegistry.ReadString('RootDir');
      FApplication := LRegistry.ReadString('App');
      FEdition := LRegistry.ReadString('Edition');
      LRegistry.CloseKey();
      if LRegistry.OpenKey(TPath.Combine(FRoot, 'Personalities'), False) then
      begin
        if LRegistry.ValueExists(CDelphiWin32) then
          FName := LRegistry.ReadString(CDelphiWin32)
        else
          FName := LRegistry.ReadString('');
      end;
    end;
  finally
    LRegistry.Free();
  end;
end;

end.
