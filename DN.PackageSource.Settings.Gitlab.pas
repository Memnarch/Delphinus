{
#########################################################
# Author: Matthias Heunecke, Navimatix                  #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageSource.Settings.Gitlab;

interface

uses
  DN.PackageSource.Settings;

type
  TDNGitlabPackageSourceSettings = class(TDNPackageSourceSettings)
  protected
    procedure InitFields; override;
  public
    const OAuthToken = 'OAuthToken';
    const BaseURL = 'BaseURL';
  end;

implementation

uses
  DN.PackageSource.Settings.Field.Intf;

{ TDNGitlabPackageSourceSettings }

procedure TDNGitlabPackageSourceSettings.InitFields;
begin
  inherited;
  DeclareField(OAuthToken, ftString);
  DeclareField(BaseURL, ftString);
end;

end.
