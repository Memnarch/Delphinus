unit DN.Command.List;

interface

uses
  DN.Command,
  DN.Package.Intf;

type
  TDNCommandList = class(TDNCommand)
  private
    procedure PrintPackageInfo(const APackage: IDNPackage);
  public
    class function Name: string; override;
    class function Parameter(AIndex: Integer): string; override;
    class function ParameterCount: Integer; override;
    class function OptionalParameterCount: Integer; override;
    class function Description: string; override;
    class function ParameterDescription(AIndex: Integer): string; override;
    procedure Execute; override;
  end;

implementation

uses
  SysUtils,
  StrUtils,
  DN.Command.Environment.Intf;

const
  CSection = 'Section';
  COnline = 'Online';
  CInstalled = 'Installed';
  CUpdates = 'Updates';

{ TDNCommandList }

class function TDNCommandList.Description: string;
begin
  Result := 'Lists packages from section';
end;

procedure TDNCommandList.Execute;
var
  LEnvironment: IDNCommandEnvironment;
  LPackages: TArray<IDNPackage>;
  LPackage: IDNPackage;
  LSection: string;
begin
  LEnvironment := Environment as IDNCommandEnvironment;
  if ParameterValueCount = 1 then
    LSection := ReadParameter(CSection)
  else
    LSection := COnline;

  case AnsiIndexText(LSection, [COnline, CInstalled, CUpdates]) of
    0: LPackages := LEnvironment.OnlinePackages;
    1: LPackages := LEnvironment.InstalledPackages;
  else
    raise ENotSupportedException.Create('Unknown section ' + LSection);
  end;

  for LPackage in LPackages do
  begin
    Writeln('');
    PrintPackageInfo(LPackage);
  end;
end;

class function TDNCommandList.Name: string;
begin
  Result := 'List';
end;

class function TDNCommandList.OptionalParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandList.Parameter(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := CSection;
  end;
end;

class function TDNCommandList.ParameterCount: Integer;
begin
  Result := 1;
end;

class function TDNCommandList.ParameterDescription(AIndex: Integer): string;
begin
  case AIndex of
    0: Result := 'One fo the following sections: Online, Installed, Updates (Online if not specified)';
  end;
end;

procedure TDNCommandList.PrintPackageInfo(const APackage: IDNPackage);
begin
  Writeln('Name: ' + APackage.Name);
  Writeln('Author: ' + APackage.Author);
  Writeln('ID: ' + APackage.ID.ToString);
  if APackage.Versions.Count > 0 then
    Writeln('Version: ' + APackage.Versions[0].Value.ToString)
  else
    Writeln('Version: <none>');
end;

end.
