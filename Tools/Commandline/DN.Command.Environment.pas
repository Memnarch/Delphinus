unit DN.Command.Environment;

interface

uses
  DN.Command,
  DN.Command.Environment.Intf,
  DN.Package.Intf,
  DN.PackageProvider.Intf,
  DN.DelphiInstallation.Provider.Intf,
  DN.DelphiInstallation.Intf;

type
  TInstalledPackageProviderFactory = reference to function(const AComponentDirectory: string): IDNPackageProvider;

  TDNCommandEnvironment = class(TInterfacedObject, IDNCommandEnvironment)
  private
    FKnownPackages: TArray<TDNCommandClass>;
    FOnlinePackageProvider: IDNPackageProvider;
    FInstalledPackageProvider: IDNPackageProvider;
    FInstalledPackageProviderFactory: TInstalledPackageProviderFactory;
    FInstallationProvider: IDNDelphiInstallationProvider;
    FCurrentDelphi: IDNDelphiInstallation;
    FInteractive: Boolean;
    function GetInstalledPackageProvider: IDNPackageProvider;
    function GetKnownCommands: TArray<TDNCommandClass>;
    function GetOnlinePackages: TArray<IDNPackage>;
    function GetInstalledPackages: TArray<IDNPackage>;
    function GetInteractive: Boolean;
    procedure SetInteractive(const Value: Boolean);
    procedure RequiresCurrentDelphi;
  public
    constructor Create(const AKnownCommands: TArray<TDNCommandClass>;
      const AOnlinePackageProvider: IDNPackageProvider;
      const AInstalledProviderFactory: TInstalledPackageProviderFactory;
      const AInstallationProvider: IDNDelphiInstallationProvider);
  end;

implementation

uses
  SysUtils,
  IOUtils;

{ TDNCommandEnvironment }

constructor TDNCommandEnvironment.Create(
  const AKnownCommands: TArray<TDNCommandClass>; const AOnlinePackageProvider: IDNPackageProvider;
  const AInstalledProviderFactory: TInstalledPackageProviderFactory;
  const AInstallationProvider: IDNDelphiInstallationProvider);
begin
  inherited Create();
  FKnownPackages := AKnownCommands;
  FOnlinePackageProvider := AOnlinePackageProvider;
  FInstalledPackageProviderFactory := AInstalledProviderFactory;
  FInstallationProvider := AInstallationProvider;
end;

function TDNCommandEnvironment.GetInstalledPackageProvider: IDNPackageProvider;
var
  LCompDir: string;
begin
  if not Assigned(FInstalledPackageProvider) then
  begin
    RequiresCurrentDelphi();
    LCompDir := TPath.Combine(FCurrentDelphi.BDSCommonDir, 'comps');
    FInstalledPackageProvider := FInstalledPackageProviderFactory(LCompDir);
  end;
  Result := FInstalledPackageProvider;
end;

function TDNCommandEnvironment.GetInstalledPackages: TArray<IDNPackage>;
begin
  GetInstalledPackageProvider.Reload();
  Result := FInstalledPackageProvider.Packages.ToArray;
end;

function TDNCommandEnvironment.GetInteractive: Boolean;
begin
  Result := FInteractive;
end;

function TDNCommandEnvironment.GetKnownCommands: TArray<TDNCommandClass>;
begin
  Result := FKnownPackages;
end;

function TDNCommandEnvironment.GetOnlinePackages: TArray<IDNPackage>;
begin
  if FOnlinePackageProvider.Packages.Count = 0 then
    FOnlinePackageProvider.Reload;
  Result := FOnlinePackageProvider.Packages.ToArray;
end;

procedure TDNCommandEnvironment.RequiresCurrentDelphi;
begin
  if not Assigned(FCurrentDelphi) then
  begin
    if FInstallationProvider.Installations.Count > 0 then
      FCurrentDelphi := FInstallationProvider.Installations[0]
    else
      raise ENotSupportedException.Create('No Delphi-Installation detected');
  end;
end;

procedure TDNCommandEnvironment.SetInteractive(const Value: Boolean);
begin
  FInteractive := Value;
end;

end.
