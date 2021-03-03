unit DN.PackageSource.Gitlab;

interface

uses
  DN.PackageSource,
  DN.PackageProvider.Intf,
  DN.PackageSource.Settings.Intf,
  DN.PackageSource.ConfigPage.Intf;

type
  TDNGitlabPackageSource = class(TDNPackageSource)
  public
    function GetName: string; override;
    function NewProvider(const ASettings: IDNPackageSourceSettings): IDNPackageProvider; override;
    function NewSettings: IDNPackageSourceSettings; override;
    function NewConfigPage: IDNPackageSourceConfigPage; override;
  end;

implementation

uses
  SysUtils,
  DN.PackageSource.Settings.GitLab,
  DN.PackageSource.ConfigPage.Gitlab,
  DN.PackageProvider.Gitlab,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp;

{ TGitlabPackageSource }

function TDNGitlabPackageSource.GetName: string;
begin
  Result := 'GitLab';
end;

function TDNGitlabPackageSource.NewConfigPage: IDNPackageSourceConfigPage;
begin
  Result := TDNGitlabSourceConfigPage.Create(nil);
end;

function TDNGitlabPackageSource.NewProvider(
  const ASettings: IDNPackageSourceSettings): IDNPackageProvider;
var
  LClient: IDNHttpClient;
  LOAuthToken: string;
begin
  LClient := TDNWinHttpClient.Create();
  LOAuthToken := ASettings.Field[TDNGitlabPackageSourceSettings.OAuthToken].Value.ToString;
  if LOAuthToken <> '' then
    LClient.Authentication := Format(CGitlabOAuthAuthentication, [LOAuthToken]);
  Result := TDNGitLabPackageProvider.Create(LClient);
  TDNGitLabPackageProvider(Result).BaseURL := ASettings.Field[TDNGitlabPackageSourceSettings.BaseURL].Value.ToString;
end;

function TDNGitlabPackageSource.NewSettings: IDNPackageSourceSettings;
begin
  Result := TDNGitlabPackageSourceSettings.Create(GetName);
end;

end.
