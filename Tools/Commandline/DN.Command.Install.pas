unit DN.Command.Install;

interface

uses
  DN.Command,
  DN.Package.Intf,
  DN.Package.Version.Intf;

type
  TDNCommandInstall = class(TDNCommand)
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
  DN.Version,
  DN.Package.Finder.Intf;

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
  LFinder: IDNPackageFinder;
begin
  inherited;
  LEnvironment := Environment as IDNCommandEnvironment;
  LFinder := LEnvironment.CreatePackageFinder(LEnvironment.OnlinePackages);
  LPackage := LFinder.Find(ReadParameter(CID));
  if ParameterValueCount > 1 then
    LVersion := LEnvironment.VersionFinder.Find(LPackage, ReadParameter(CVersion))
  else if LPackage.Versions.Count > 0 then
    LVersion := LPackage.Versions[0];
  LSetup := LEnvironment.CreateSetup();
  LSetup.Install(LPackage, LVersion);
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
