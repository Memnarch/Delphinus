{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.JSonFile.InstalledInfo;

interface

uses
  DN.Version,
  DN.JSon,
  DN.JSonFile.Info;

type
  TInstalledInfoFile = class(TInfoFile)
  private
    FDescription: string;
    FVersion: TDNVersion;
    FAuthor: string;
    FProjectUrl: string;
    FHomepageUrl: string;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property Author: string read FAuthor write FAuthor;
    property Description: string read FDescription write FDescription;
    property Version: TDNVersion read FVersion write FVersion;
    property ProjectUrl: string read FProjectUrl write FProjectUrl;
    property HomepageUrl: string read FHomepageUrl write FHomepageUrl;
  end;

implementation

{ TInstalledInfoFile }

procedure TInstalledInfoFile.Load(const ARoot: TJSONObject);
begin
  inherited;
  FAuthor := ReadString(ARoot, 'author');
  FDescription := ReadString(ARoot, 'description');
  if not TDNVersion.TryParse(ReadString(ARoot, 'version'), FVersion) then
    FVersion := TDNVersion.Create();
  FProjectUrl := ReadString(ARoot, 'project_url');
  FHomepageUrl := ReadString(ARoot, 'homepage_url');
end;

procedure TInstalledInfoFile.Save(const ARoot: TJSONObject);
begin
  inherited;
  WriteString(ARoot, 'author', FAuthor);
  WriteString(ARoot, 'description', FDescription);
  WriteString(ARoot, 'version', FVersion.ToString);
  WriteString(ARoot, 'project_url', FProjectUrl);
  WriteString(ARoot, 'homepage_url', FHomepageUrl);
end;

end.
