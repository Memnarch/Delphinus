unit DN.Command.Info;

interface

uses
  DN.Command,
  DN.Command.Switch,
  DN.Package.Intf;

type
  TDNCommandInfo = class(TDNCommand)
  private
    procedure PrintDescription(const APackage: IDNPackage);
    procedure PrintVersions(const APackage: IDNPackage);
    procedure PrintLicense(const APackage: IDNPackage);
  public
    class function Name: string; override;
    class function Description: string; override;
    class function ParameterCount: Integer; override;
    class function Parameter(AIndex: Integer): string; override;
    class function ParameterDescription(AIndex: Integer): string; override;
    class function SwitchClass(AIndex: Integer): TDNCommandSwitchClass; override;
    class function SwitchClassCount: Integer; override;
    procedure Execute; override;
  end;

implementation

uses
  SysUtils,
  DN.Utils,
  DN.Command.Environment.Intf,
  DN.Command.Switch.Versions,
  DN.Command.Switch.License,
  DN.Package.Version.Intf;

const
  CID = 'ID';
  CName           = 'Name:          ';
  CIDCaption      = 'ID:            ';
  CAuthor         = 'Author:        ';
  CDescription    = 'Description:   ';
  CVersion        = 'Version:       ';
  CSupports       = 'Supports:      ';
  CPlatforms      = 'Platforms:     ';
  CHomePage       = 'HomePage:      ';
  CProjectPage    = 'ProjectPage:   ';
  CBugTracker     = 'BugTracker:    ';
  CLicense        = 'License:       ';
  CNone = '<none>';

{ TDNCommandInfo }

class function TDNCommandInfo.Description: string;
begin
  Result := 'Displays information of the given package';
end;

procedure TDNCommandInfo.Execute;
var
  LPackage: IDNPackage;
  LEnvironment: IDNCommandEnvironment;
begin
  inherited;
  if SwitchCount > 1 then
    raise Exception.Create('you can only display one detail at a time');

  LEnvironment := Environment as IDNCommandEnvironment;
  LPackage := LEnvironment.CreatePackageFinder(LEnvironment.OnlinePackages).Find(ReadParameter(CID));

  if HasSwitch<TDNCommandSwitchVersions>() then
    PrintVersions(LPackage);

  if HasSwitch<TDNCommandSwitchLicense>() then
    PrintLicense(LPackage);

  if SwitchCount = 0 then
    PrintDescription(LPackage);
end;

class function TDNCommandInfo.Name: string;
begin
  Result := 'Info';
end;

class function TDNCommandInfo.Parameter(AIndex: Integer): string;
begin
  if AIndex = 0 then
    Result := CID
  else
    Result := inherited;
end;

class function TDNCommandInfo.ParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandInfo.ParameterDescription(AIndex: Integer): string;
begin
  if AIndex = 0 then
    Result := 'Name or ID of package'
  else
    Result := inherited;
end;

procedure TDNCommandInfo.PrintDescription(const APackage: IDNPackage);
begin
  Writeln(CName, APackage.Name);
  Writeln(CIDCaption, APackage.ID.ToString);
  Writeln(CAuthor, APackage.Author);
  Writeln(CSupports, GenerateSupportsString(APackage.CompilerMin, APackage.CompilerMax));
  Writeln(CPlatforms, GeneratePlatformString(APackage.Platforms));
  Writeln(CLicense, APackage.LicenseType);
  if APackage.Versions.Count > 0 then
    Writeln(CVersion, APackage.Versions[0].Value.ToString)
  else
    Writeln(CVersion, CNone);

  Writeln(CHomePage, APackage.HomepageUrl);
  Writeln(CProjectPage, APackage.ProjectUrl);
  Writeln(CBugTracker, APackage.ReportUrl);
  Writeln(CDescription, APackage.Description);
end;

procedure TDNCommandInfo.PrintLicense(const APackage: IDNPackage);
begin
  Writeln('');
  Writeln(APackage.LicenseText);
  Writeln('');
end;

procedure TDNCommandInfo.PrintVersions(const APackage: IDNPackage);
var
  LVersion: IDNPackageVersion;
  LVersionStr: string;
const
  CMaxVersionLength = 15;
begin
  Writeln('');
  Writeln('Version        Supports');
  for LVersion in APackage.Versions do
  begin
    LVersionStr := LVersion.Value.ToString;
    Writeln(LVersionStr + StringOfChar(' ', CMaxVersionLength - Length(LVersionStr)) + GenerateSupportsString(LVersion.CompilerMin, LVersion.CompilerMax));
  end;
  if APackage.Versions.Count = 0 then
    Writeln('No versions available');
  Writeln('');
end;

class function TDNCommandInfo.SwitchClass(
  AIndex: Integer): TDNCommandSwitchClass;
begin
  if AIndex = 0 then
    Result := TDNCommandSwitchVersions
  else if AIndex = 1 then
    Result := TDNCommandSwitchLicense
  else
    Result := inherited;
end;

class function TDNCommandInfo.SwitchClassCount: Integer;
begin
  Result := 2;
end;

end.
