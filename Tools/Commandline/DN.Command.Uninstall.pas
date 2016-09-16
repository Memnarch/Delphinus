unit DN.Command.Uninstall;

interface

uses
  DN.Command;

type
  TDNCommandUninstall = class(TDNCommand)
  public
    class function Description: string; override;
    class function Name: string; override;
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
  DN.Package.Intf,
  DN.Package.Finder.Intf;

const
  CID = 'ID';

{ TDNCommandUninstall }

class function TDNCommandUninstall.Description: string;
begin
  Result := 'Uninstalls a given package'
end;

procedure TDNCommandUninstall.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LSetup: IDNSetup;
  LPackage: IDNPackage;
  LFinder: IDNPackageFinder;
begin
  inherited;
  LEnvironment := Environment as IDNCommandEnvironment;
  LFinder := LEnvironment.CreatePackageFinder(LEnvironment.InstalledPackages);
  LPackage := LFinder.Find(ReadParameter(CID));
  LSetup := LEnvironment.CreateSetup();
  if LSetup.Uninstall(LPackage) then
    Exit
  else
    raise Exception.Create('Could not uninstall ' + LPackage.Name);
end;

class function TDNCommandUninstall.Name: string;
begin
  Result := 'Uninstall';
end;

class function TDNCommandUninstall.Parameter(AIndex: Integer): string;
begin
  if AIndex = 0 then
    Result := CID
  else
    Result := inherited;
end;

class function TDNCommandUninstall.ParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandUninstall.ParameterDescription(
  AIndex: Integer): string;
begin
  if AIndex = 0 then
    Result := 'GUID or Name of the package to uninstall'
  else
    Result := inherited;
end;

end.
