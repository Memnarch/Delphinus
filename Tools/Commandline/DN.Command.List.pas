unit DN.Command.List;

interface

uses
  DN.Command,
  DN.Package.Intf;

type
  TDNCommandList = class(TDNCommand)
  private
    procedure PrintPackageInfo(const APackages: TArray<IDNPackage>);
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
  DN.Command.Environment.Intf,
  DN.TextTable,
  DN.TextTable.Intf;

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
    2: LPackages := LEnvironment.UpdatePackages;
  else
    raise ENotSupportedException.Create('Unknown section ' + LSection);
  end;

  PrintPackageInfo(LPackages);
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

procedure TDNCommandList.PrintPackageInfo(const APackages: TArray<IDNPackage>);
var
  LTable: IDNTextTable;
  LVersion: string;
  LPackage: IDNPackage;
begin
  LTable := TDNTextTable.Create();
  LTable.AddColumn('Name', 50);
  LTable.AddColumn('Author', 20);
  LTable.AddColumn('Version', 10);
  for LPackage in APackages do
  begin
    if LPackage.Versions.Count > 0 then
      LVersion := LPackage.Versions.First.Value.ToString
    else
      LVersion := '';
    LTable.AddRecord([LPackage.Name, LPackage.Author, LVersion]);
  end;
  Writeln('');
  Writeln(LTable.Text);
end;

end.
