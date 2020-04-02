unit DN.PackageSource.Github;

interface

uses
  DN.PackageSource,
  DN.PackageProvider.Intf,
  DN.PackageSource.Settings.Intf,
  DN.PackageSource.ConfigPage.Intf;

type
  TDNGithubPackageSource = class(TDNPackageSource)
  public
    function GetName: string; override;
    function NewProvider(const ASettings: IDNPackageSourceSettings): IDNPackageProvider; override;
    function NewSettings: IDNPackageSourceSettings; override;
    function NewConfigPage: IDNPackageSourceConfigPage; override;
  end;

implementation

uses
  SysUtils,
  DN.PackageSource.Settings.GitHub,
  DN.PackageSource.ConfigPage.Github,
  DN.PackageProvider.Github,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp;

{ TGithubPackageSource }

function TDNGithubPackageSource.GetName: string;
begin
  Result := 'GitHub';
end;

function TDNGithubPackageSource.NewConfigPage: IDNPackageSourceConfigPage;
begin
  Result := TDNGithubSourceConfigPage.Create(nil);
end;

function TDNGithubPackageSource.NewProvider(
  const ASettings: IDNPackageSourceSettings): IDNPackageProvider;
var
  LClient: IDNHttpClient;
  LOAuthToken: string;
begin
  LClient := TDNWinHttpClient.Create();
  LOAuthToken := ASettings.Field[TDNGithubPackageSourceSettings.OAuthToken].Value.ToString;
  if LOAuthToken <> '' then
    LClient.Authentication := Format(CGithubOAuthAuthentication, [LOAuthToken]);
  Result := TDNGitHubPackageProvider.Create(LClient);
end;

function TDNGithubPackageSource.NewSettings: IDNPackageSourceSettings;
begin
  Result := TDNGithubPackageSourceSettings.Create(GetName);
end;

end.
