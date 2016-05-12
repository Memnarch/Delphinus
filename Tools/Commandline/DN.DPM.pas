unit DN.DPM;

interface

uses
  Generics.Collections,
  DN.Command,
  DN.Command.Dispatcher.Intf,
  DN.Command.Environment.Intf,
  DN.PackageProvider.Intf,
  DN.Settings.Intf,
  DN.DelphiInstallation.Provider.Intf;

type
  TDPM = class
  private
    FEnvironment: IDNCommandEnvironment;
    FSettings: IDNSettings;
    FOnlinePackageProvider: IDNPackageProvider;
    FDelphiProvider: IDNDelphiInstallationProvider;
    FDispatcher: IDNCommandDispatcher;
    function GetCommandLine: string;
    function GetKnownCommands: TArray<TDNCommandClass>;
  public
    constructor Create;
    procedure Run;
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
  DN.Command.Default,
  DN.Command.Exit,
  DN.Command.List,
  DN.PackageProvider.Github,
  DN.PackageProvider.Installed,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.Settings,
  DN.DelphiInstallation.Provider;

{ TDPM }

constructor TDPM.Create;
var
  LHTTP: IDNHttpClient;
  LFactory: TInstalledPackageProviderFactory;
begin
  inherited;
  FSettings := TDNSettings.Create();
  LHTTP := TDNWinHttpClient.Create();
  if FSettings.OAuthToken <> '' then
    LHTTP.Authentication := Format(CGithubOAuthAuthentication, [FSettings.OAuthToken]);
  FOnlinePackageProvider := TDNGitHubPackageProvider.Create(LHTTP, False);
  FDelphiProvider := TDNDelphiInstallationProvider.Create();
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
  LCommands.Add(TDNCommandList);
  LCommands.Add(TDNCommandExit);
  Result := LCommands.ToArray;
end;

procedure TDPM.Run;
var
  LParser: IDNCommandArgumentParser;
  LCommand: IDNCommandArgument;
  LLine: string;
begin
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
        Writeln(E.Message);
      end;
    end;
  end;
end;

end.
