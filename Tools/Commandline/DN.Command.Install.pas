unit DN.Command.Install;

interface

uses
  DN.Command,
  DN.Package.Intf,
  DN.Package.Version.Intf;

type
  TDNCommandInstall = class(TDNCommand)
  private
    function FindPackage(const AID: string; const APackages: TArray<IDNPackage>): IDNPackage;
    function FindVersion(const APackage: IDNPackage; const AVersion: string): IDNPackageVersion;
  public
    class function Description: string; override;
    class function Name: string; override;
    class function OptionalParameterCount: Integer; override;
    class function Parameter(AIndex: Integer): string; override;
    class function ParameterCount: Integer; override;
    class function ParameterDescription(AIndex: Integer): string; override;

    procedure Execute; override;
  end;

implementation

uses
  SysUtils,
  DN.Command.Environment.Intf,
  DN.Setup.Intf,
  DN.Version;

const
  CID = 'ID';
  CVersion = 'Version';

{ TDNCommandInstall }

class function TDNCommandInstall.Description: string;
begin
  Result := 'Installs or updates a package';
end;

procedure TDNCommandInstall.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LSetup: IDNSetup;
  LPackage: IDNPackage;
  LVersion: IDNPackageVersion;
begin
  inherited;
  LEnvironment := Environment as IDNCommandEnvironment;
  LSetup := LEnvironment.CreateSetup();
  LPackage := FindPackage(Trim(ReadParameter(CID)), LEnvironment.OnlinePackages);
  if Assigned(LPackage) then
  begin
    if ParameterValueCount > 1 then
    begin
      LVersion := FindVersion(LPackage, Trim(ReadParameter(CVersion)));
    end
    else
    begin
      if LPackage.Versions.Count > 0 then
        LVersion := LPackage.Versions[0];
    end;
    LSetup.Install(LPackage, LVersion);
  end
  else
  begin
    raise Exception.Create('Could not resolve package: ' + Trim(ReadParameter(CID)));
  end;
end;

function TDNCommandInstall.FindPackage(const AID: string;
  const APackages: TArray<IDNPackage>): IDNPackage;
var
  LPackage: IDNPackage;
begin
  for LPackage in APackages do
    if SameText(LPackage.Name, AID) or SameText(LPackage.ID.ToString, AID) then
      Exit(LPackage);
  Result := nil;
end;

function TDNCommandInstall.FindVersion(const APackage: IDNPackage;
  const AVersion: string): IDNPackageVersion;
var
  LVersion: TDNVersion;
  LPackageVersion: IDNPackageVersion;
begin
  Result := nil;
  if AVersion = '' then
    Exit;
  LVersion := TDNVersion.Parse(AVersion);
  for LPackageVersion in APackage.Versions do
    if LPackageVersion.Value = LVersion then
      Exit(LPackageVersion);

  if not Assigned(Result) then
    raise Exception.Create('Version not found: ' + LVersion.ToString);
end;

class function TDNCommandInstall.Name: string;
begin
  Result := 'Install';
end;

class function TDNCommandInstall.OptionalParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandInstall.Parameter(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := CID;
    1: Result := CVersion;
  end;
end;

class function TDNCommandInstall.ParameterCount: Integer;
begin
  Result := 2;
end;

class function TDNCommandInstall.ParameterDescription(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'GUID or Name of a package';
    1: Result := 'Version to install. Most recent is used when not specified'
  end;
end;


end.
