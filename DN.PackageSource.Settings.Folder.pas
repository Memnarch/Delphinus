unit DN.PackageSource.Settings.Folder;

interface

uses
  DN.PackageSource.Settings;

type
  TDNFolderSourceSettings = class(TDNPackageSourceSettings)
  protected
    procedure InitFields; override;
  public
    const Path = 'Path';
  end;

implementation

uses
  DN.PackageSource.Settings.Field.Intf;

{ TDNFolderSourceSettings }

procedure TDNFolderSourceSettings.InitFields;
begin
  inherited;
  DeclareField(Path, ftString);
end;

end.
