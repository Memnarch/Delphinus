unit DN.JSonFile.InstalledInfo;

interface

uses
  DN.JSon,
  DN.JSonFile.Info;

type
  TInstalledInfoFile = class(TInfoFile)
  private
    FDescription: string;
    FVersion: string;
    FAuthor: string;
  protected
    procedure Load(const ARoot: TJSONObject); override;
    procedure Save(const ARoot: TJSONObject); override;
  public
    property Author: string read FAuthor write FAuthor;
    property Description: string read FDescription write FDescription;
    property Version: string read FVersion write FVersion;
  end;

implementation

{ TInstalledInfoFile }

procedure TInstalledInfoFile.Load(const ARoot: TJSONObject);
begin
  inherited;
  FAuthor := ReadString(ARoot, 'author');
  FDescription := ReadString(ARoot, 'description');
  FVersion := ReadString(ARoot, 'version');
end;

procedure TInstalledInfoFile.Save(const ARoot: TJSONObject);
begin
  inherited;
  WriteString(ARoot, 'author', FAuthor);
  WriteString(ARoot, 'description', FDescription);
  WriteString(ARoot, 'version', FVersion);
end;

end.
