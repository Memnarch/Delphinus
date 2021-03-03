unit DN.PackageSource.Settings.Github;

interface

uses
  DN.PackageSource.Settings;

type
  TDNGithubPackageSourceSettings = class(TDNPackageSourceSettings)
  protected
    procedure InitFields; override;
  public
    const OAuthToken = 'OAuthToken';
  end;

implementation

uses
  DN.PackageSource.Settings.Field.Intf;

{ TDNGithubPackageSourceSettings }

procedure TDNGithubPackageSourceSettings.InitFields;
begin
  inherited;
  DeclareField(OAuthToken, ftString);
end;

end.
