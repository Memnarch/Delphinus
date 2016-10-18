unit DN.PackageSource.Github;

interface

uses
  DN.PackageSource,
  DN.PackageProvider.Intf,
  DN.PackageSource.Settings.Intf;

type
  TDNGithubPackageSource = class(TDNPackageSource)
  public
    function GetName: string; override;
    function NewProvider(const ASettings: IDNPackageSourceSettings): IDNPackageProvider; override;
    function NewSettings: IDNPackageSourceSettings; override;
  end;

implementation

uses
  SysUtils,
  DN.PackageSource.Settings.GitHub,
  DN.PackageProvider.Github,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp;

{ TGithubPackageSource }

function TDNGithubPackageSource.GetName: string;
begin
  Result := 'GitHub';
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
