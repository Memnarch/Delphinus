unit DN.DPM;

interface

uses
  Generics.Collections,
  DN.Command,
  DN.Command.Dispatcher.Intf,
  DN.Command.Environment.Intf,
  DN.PackageProvider.Intf,
  DN.Settings.Intf,
  DN.DelphiInstallation.Provider.Intf,
  DN.PackageSource.Settings.Intf,
  DN.PackageSource.Registry.Intf;

type
  TDPM = class
  private
    FEnvironment: IDNCommandEnvironment;
    FSettings: IDNSettings;
    FOnlinePackageProvider: IDNPackageProvider;
    FDelphiProvider: IDNDelphiInstallationProvider;
    FDispatcher: IDNCommandDispatcher;
    FSourceRegistry: IDNPackageSourceRegistry;
    function SourceSettingsFactory(const ASourceName: string;
                  out ASettings: IDNPackageSourceSettings): Boolean;
    function GetCommandLine: string;
    function GetKnownCommands: TArray<TDNCommandClass>;
  public
    constructor Create;
    function Run: Cardinal;
  end;

implementation

uses
  SysUtils,
  DN.Command.Argument.Parser,
  DN.Command.Argument.Parser.Intf,
  DN.Command.Argument,
  DN.Command.Argument.Intf,
  DN.Command.Dispatcher,
  DN.Command.Environment,
  DN.Command.Help,
  DN.Command.Install,
  DN.Command.Uninstall,
  DN.Command.Update,
  DN.Command.Default,
  DN.Command.Exit,
  DN.Command.List,
  DN.Command.Info,
  DN.Command.About,
  DN.Command.Delphis,
  DN.PackageProvider.Github,
  DN.PackageProvider.Installed,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.Settings,
  DN.DelphiInstallation.Editions,
  DN.DelphiInstallation.Provider,
  DN.PackageSource.Intf,
  DN.PackageSource.Registry,
  DN.PackageSource.Github,
  DN.PackageSource.Gitlab,
  DN.PackageSource.Folder;

{ TDPM }

function TDPM.SourceSettingsFactory(const ASourceName: string;
  out ASettings: IDNPackageSourceSettings): Boolean;
var
  LSource: IDNPackageSource;
begin
  Result := FSourceRegistry.TryGetSource(ASourceName, LSource);
  if Result then
    ASettings := LSource.NewSettings;
end;

constructor TDPM.Create;
var
  LHTTP: IDNHttpClient;
  LFactory: TInstalledPackageProviderFactory;
begin
  inherited;
  FSourceRegistry := TDNPackageSourceRegistry.Create();
  FSourceRegistry.RegisterSource(TDNGithubPackageSource.Create() as IDNPackageSource);
  FSourceRegistry.RegisterSource(TDNGitlabPackageSource.Create() as IDNPackageSource);
  FSourceRegistry.RegisterSource(TDNFolderPackageSource.Create() as IDNPackageSource);
  FSettings := TDNSettings.Create(SourceSettingsFactory);
  LHTTP := TDNWinHttpClient.Create();
  if FSettings.OAuthToken <> '' then
    LHTTP.Authentication := Format(CGithubOAuthAuthentication, [FSettings.OAuthToken]);
  FOnlinePackageProvider := TDNGitHubPackageProvider.Create(LHTTP, False);
  FDelphiProvider := TDNDelphiInstallationProvider.Create([CDelphiEditionStarter]);
  LFactory :=
    function (const AComponentDirectory: string): IDNPackageProvider
    begin
      Result := TDNInstalledPackageProvider.Create(AComponentDirectory);
    end;
  FEnvironment := TDNCommandEnvironment.Create(GetKnownCommands(), FOnlinePackageProvider, LFactory,
    FDelphiProvider);
  FDispatcher := TDNCommandDispatcher.Create(FEnvironment);
end;

function TDPM.GetCommandLine: string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to ParamCount do
    Result := Result + ' "' + ParamStr(i) + '"';
end;

function TDPM.GetKnownCommands: TArray<TDNCommandClass>;
var
  LCommands: TList<TDNCommandClass>;
begin
  LCommands := TList<TDNCommandClass>.Create();
  LCommands.Add(TDNCommandDefault);
  LCommands.Add(TDNCommandHelp);
  LCommands.Add(TDNCommandInstall);
  LCommands.Add(TDNCommandUninstall);
  LCommands.Add(TDNCommandUpdate);
  LCommands.Add(TDNCommandList);
  LCommands.Add(TDNCommandInfo);
  LCommands.Add(TDNCommandExit);
  LCommands.Add(TDNCommandAbout);
  LCommands.Add(TDNCommandDelphis);
  Result := LCommands.ToArray;
end;

function TDPM.Run: Cardinal;
var
  LParser: IDNCommandArgumentParser;
  LCommand: IDNCommandArgument;
  LLine: string;
begin
  Result := 0;
  LParser := TDNCommandArgumentParser.Create();
  LCommand := LParser.FromText(GetCommandLine());
  FDispatcher.Execute(LCommand);
  while FEnvironment.Interactive do
  begin
    try
      Write('DPM>');
      ReadLn(LLine);
      FDispatcher.Execute(LParser.FromText(LLine));
    except
      on E:Exception do
      begin
        if FEnvironment.PanicOnError then
          raise
        else
        begin
          Writeln(E.Message);
          Inc(Result);
        end;
      end;
    end;
  end;
end;

end.
