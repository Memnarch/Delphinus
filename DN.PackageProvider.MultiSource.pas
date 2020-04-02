unit DN.PackageProvider.MultiSource;

interface

uses
  DN.Package.Intf,
  DN.PackageProvider,
  DN.PackageProvider.Intf,
  DN.Progress.Intf;

type
  TDNMultiSourceProvider = class(TDNPackageProvider, IDNProgress)
  private
    FSources: TArray<IDNPackageProvider>;
    FProgress: IDNProgress;
    procedure HandleProgress(const Task, Item: string; Progress, Max: Int64);
    function TryGetSourceForPackage(const APackage: IDNPackage; out ASource: IDNPackageProvider): Boolean;
    property Progress: IDNProgress read FProgress implements IDNProgress;
  public
    constructor Create(const ASources: TArray<IDNPackageProvider>);
    function Reload: Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;
  end;

implementation

uses
  SysUtils,
  Generics.Collections,
  DN.Progress;

{ TDNMultiSourceProvider }

constructor TDNMultiSourceProvider.Create(
  const ASources: TArray<IDNPackageProvider>);
var
  LSource: IDNPackageProvider;
  LProgress: IDNProgress;
begin
  inherited Create();
  FSources := ASources;
  FProgress := TDNProgress.Create();
  for LSource in FSources do
    if Supports(LSource, IDNProgress, LProgress) then
      LProgress.OnProgress := HandleProgress;
end;

function TDNMultiSourceProvider.Download(const APackage: IDNPackage;
  const AVersion, AFolder: string; out AContentFolder: string): Boolean;
var
  LSource: IDNPackageProvider;
begin
  Result := TryGetSourceForPackage(APackage, LSource);
  if Result then
    Result := LSource.Download(APackage, AVersion, AFolder, AContentFolder);
end;

procedure TDNMultiSourceProvider.HandleProgress(const Task, Item: string;
  Progress, Max: Int64);
begin
  FProgress.SetTaskProgress(Item, Progress, Max);
end;

function TDNMultiSourceProvider.Reload: Boolean;
var
  LSource: IDNPackageProvider;
  LExisting: TDictionary<string, string>;
  LPackage: IDNPackage;
begin
  Result := False;
  LExisting := TDictionary<string, string>.Create();
  try
    Packages.Clear;
    FProgress.SetTasks(['Reloading']);
    for LSource in FSources do
    begin
      Result := LSource.Reload or Result;
      for LPackage in LSource.Packages do
        if not LExisting.ContainsKey(LPackage.ID.ToString) then
        begin
          LExisting.Add(LPackage.ID.ToString, '');
          Packages.Add(LPackage);
        end;
    end;
    FProgress.Completed;
  finally
    LExisting.Free;
  end;
end;

function TDNMultiSourceProvider.TryGetSourceForPackage(
  const APackage: IDNPackage; out ASource: IDNPackageProvider): Boolean;
var
  LSource: IDNPackageProvider;
begin
  for LSource in FSources do
    if LSource.Packages.IndexOf(APackage) > -1 then
    begin
      ASource := LSource;
      Exit(True);
    end;
  Result := False;
end;

end.
