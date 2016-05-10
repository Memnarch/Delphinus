unit DN.Command.Environment;

interface

uses
  DN.Command,
  DN.Command.Environment.Intf,
  DN.Package.Intf,
  DN.PackageProvider.Intf;

type
  TDNCommandEnvironment = class(TInterfacedObject, IDNCommandEnvironment)
  private
    FKnownPackages: TArray<TDNCommandClass>;
    FOnlinePackageProvider: IDNPackageProvider;
    FInstalledPackageProvider: IDNPackageProvider;
    FInteractive: Boolean;
    function GetKnownCommands: TArray<TDNCommandClass>;
    function GetOnlinePackages: TArray<IDNPackage>;
    function GetInstalledPackages: TArray<IDNPackage>;
    function GetInteractive: Boolean;
    procedure SetInteractive(const Value: Boolean);
  public
    constructor Create(const AKnownCommands: TArray<TDNCommandClass>;
      const AOnlinePackageProvider, AInstalledPackageProvider: IDNPackageProvider);
  end;

implementation

{ TDNCommandEnvironment }

constructor TDNCommandEnvironment.Create(
  const AKnownCommands: TArray<TDNCommandClass>; const AOnlinePackageProvider,
  AInstalledPackageProvider: IDNPackageProvider);
begin
  inherited Create();
  FKnownPackages := AKnownCommands;
  FOnlinePackageProvider := AOnlinePackageProvider;
  FInstalledPackageProvider := AInstalledPackageProvider;
end;

function TDNCommandEnvironment.GetInstalledPackages: TArray<IDNPackage>;
begin
  FInstalledPackageProvider.Reload();
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

procedure TDNCommandEnvironment.SetInteractive(const Value: Boolean);
begin
  FInteractive := Value;
end;

end.
