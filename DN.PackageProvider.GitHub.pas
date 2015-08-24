{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.PackageProvider.GitHub;

interface

uses
  Classes,
  Types,
  Graphics,
  SysUtils,
  IdHttp,
  IdAuthentication,
  IdHeaderList,
  Generics.Collections,
  DN.Package.Intf,
  DN.PackageProvider,
  DN.JSonFile.CacheInfo;

type
  TDNGitHubPackageProvider = class(TDNPackageProvider)
  private
    FRequest: TIdHTTP;
    FLastContentDisposition: string;
    FCacheDir: string;
    FLastEtag: string;
    FSecurityToken: string;
    function RevalidateCache(): Boolean;
    function ExecuteRequest(const ATarget: TStream; const ARequest: string; const AETag: string = ''): Boolean;
    function LoadCacheInfo(const AInfo: TCacheInfo; const AAuthor, AName, ACache: string): Boolean;
    function DownloadVersionMeta(const AData: TStringStream; ACacheInfo: TCacheInfo; const AAuthor, AName, ADefaultBranch: string): Boolean;
    function LoadPackageFromDirectory(const ADirectory: string;const AAutor: string; out APackage: IDNPackage): Boolean;
    procedure LoadPicture(const APackage: IDNPackage; const APictureFile: string);
    function IsJPegImage(const AFileName: string): Boolean;
  public
    constructor Create(const ASecurityToken: string = '');
    destructor Destroy(); override;
    function Reload(): Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;
  end;

implementation

uses
  IOUtils,
  StrUtils,
  DN.Package,
  DN.Package.Github,
  IdIOHandlerStack,
  IdSSLOpenSSl,
  DN.JSon,
  JPeg,
  DN.Zip,
  DN.JSOnFile.Info,
  DN.Package.Version,
  DN.Package.Version.Intf,
  DN.PackageProvider.GitHub.Authentication;

const
  CGithubRaw = 'https://raw.githubusercontent.com/';
  CGithubRawReferencedFile = CGithubRaw + '%s/%s/%s/%s';//User/Repo/Reference/Filename
  CGitRepoSearch = 'https://api.github.com/search/repositories?q="Delphinus-Support"+in:readme&per_page=100';
  CGithubRepoReleases = 'https://api.github.com/repos/%s/%s/releases';// user/repo/releases
//  CGitRepoSearch = 'https://api.github.com/search/repositories?q=tetris&per_page=30';
  CJpg_Package = 'Jpg_Package';

{$If Declared(hoNoProtocolErrorException)}
  {$Define SupportsErrorCodes}
{$IfEnd}

{ TDCPMPackageProvider }

constructor TDNGitHubPackageProvider.Create;
begin
  inherited Create();
  FSecurityToken := ASecurityToken;
  FCacheDir := TPath.Combine(GetEnvironmentVariable('LocalAppData'), 'Delphinus\Github');
  ForceDirectories(FCacheDir);
  FRequest := TIdHTTP.Create(nil);
  {$IFDEF SupportsErrorCodes}
  FRequest.HTTPOptions := FRequest.HTTPOptions + [hoNoProtocolErrorException];
  {$EndIf}
  FRequest.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(FRequest);
  FRequest.HandleRedirects := True;
end;

destructor TDNGitHubPackageProvider.Destroy;
begin
  FRequest.Free;
  inherited;
end;

function TDNGitHubPackageProvider.Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchive: TFileStream;
  LArchiveFile, LFileName: string;
  LDirs: TStringDynArray;
const
  CNamePrefix = 'filename=';
begin
  LArchiveFile := TPath.Combine(AFolder, 'Package.zip');
  LArchive := TFileStream.Create(LArchiveFile, fmCreate or fmOpenReadWrite);
  try
    Result := ExecuteRequest(LArchive, APackage.DownloadLoaction + IfThen(AVersion <> '', AVersion, (APackage as TDNGitHubPackage).DefaultBranch));
  finally
    LArchive.Free;
  end;
  LFileName := Copy(FLastContentDisposition, Pos(CNamePrefix, FLastContentDisposition) + Length(CNamePrefix), Length(FLastContentDisposition));
//  AContentFolder := TPath.Combine(AFolder, ChangeFileExt(StringReplace(LFileName, AVersion, '', []), ''));
  if Result then
    Result := ShellUnzip(LArchiveFile, AFolder);

  if Result then
  begin
    LDirs := TDirectory.GetDirectories(AFolder);
    Result := Length(LDirs) = 1;
    if Result then
      AContentFolder := LDirs[0];
  end;
  TFile.Delete(LArchiveFile);
end;

function TDNGitHubPackageProvider.DownloadVersionMeta(
  const AData: TStringStream; ACacheInfo: TCacheInfo; const AAuthor, AName, ADefaultBranch: string): Boolean;
var
  LArray: TJSONArray;
  LObject: TJSonObject;
  LValue: TJSonValue;
  i: Integer;
  LFile: TMemoryStream;
  LVersionDir, LFirstVersion: string;
  LVersions: TStringDynArray;
  LInfo: TInfoFile;
begin
  Result := False;
  LFile := TMemoryStream.Create();
  LInfo := TInfoFile.Create();
  try
    //first download HEAD
    LVersionDir := TPath.Combine(FCacheDir, AAuthor + '\' + AName);
    if ExecuteRequest(LFile, CGithubRaw + AAuthor + '/' + AName + '/' + ADefaultBranch + '/info.json') then
    begin
      LFile.SaveToFile(TPath.Combine(LVersionDir, 'info.json'));
      if LInfo.LoadFromFile(TPath.Combine(LVersionDir, 'info.json')) then
      begin
        LFile.Clear();
        LFirstVersion := LInfo.FirstVersion;
        if IsJPegImage(LInfo.Picture) and ExecuteRequest(LFile, CGithubRaw + AAuthor + '/' + AName + '/' + ADefaultBranch + '/' + LInfo.Picture) then
          LFile.SaveToFile(TPath.Combine(LVersionDir, 'Logo.jpg'));
      end;
      LFile.Clear();
      if ExecuteRequest(LFile, CGithubRaw + AAuthor + '/' + AName + '/' + ADefaultBranch + '/install.json') then
      begin
        LFile.SaveToFile(TPath.Combine(LVersionDir,'install.json'));
        Result := True;
      end;
    end;
    LArray := TJSOnObject.ParseJSONValue(AData.DataString) as TJSONArray;
    if Assigned(LArray) then
    begin
      try
        SetLength(LVersions, LArray.Count);
        for i := 0 to LArray.Count - 1 do
        begin
          LObject := LArray.Items[i] as TJSonObject;
          LValue := LObject.GetValue('tag_name');
          if Assigned(LValue) then
          begin
            LVersions[i] := LValue.Value;
            LVersionDir := TPath.Combine(FCacheDir, AAuthor + '\' + AName + '\' + LValue.Value);
            TDirectory.CreateDirectory(LVersionDir);
            LFile.Clear;
            if ExecuteRequest(LFile, Format(CGithubRawReferencedFile, [AAuthor, AName, LValue.Value, 'info.json'])) then
            begin
              LFile.SaveToFile(TPath.Combine(LVersionDir, 'info.json'));
              LFile.Clear();
              if ExecuteRequest(LFile, Format(CGithubRawReferencedFile, [AAuthor, AName, LValue.Value, 'install.json'])) then
              begin
                LFile.SaveToFile(TPath.Combine(LVersionDir, 'install.json'));
                Result := True;
              end;
            end;
            //stop after first supported release, all others are not supported
            if SameText(LValue.Value, LFirstVersion) then
            begin
              SetLength(LVersions, i+1);
              Break;
            end;
          end;
        end;
        ACacheInfo.Versions := LVersions;
      finally
        LArray.Free;
      end;
    end;
  finally
    LInfo.Free;
    LFile.Free;
  end;
end;

function TDNGitHubPackageProvider.ExecuteRequest(const ATarget: TStream; const ARequest: string; const AETag: string): Boolean;
begin
  if AETag <> '' then
  begin
    FRequest.Request.CustomHeaders.Values['If-None-Match'] := AETag;
  end;
  if (not Assigned(FRequest.Request.Authentication)) and (FSecurityToken <> '') then
  begin
    FRequest.Request.Authentication := TGithubAuthentication.Create();
    FRequest.Request.Authentication.Password := FSecurityToken;
  end;
  {$IFDEF SupportsErrorCodes}
  FRequest.Get(ARequest, ATarget);
  {$Else}
  try
    FRequest.Get(ARequest, ATarget);
  except

  end;
  {$EndIf}
  Result := FRequest.ResponseCode = 200;//ok
  FLastContentDisposition := FRequest.Response.ContentDisposition;
  FLastEtag := FRequest.Response.ETag;
end;

function TDNGitHubPackageProvider.IsJPegImage(const AFileName: string): Boolean;
var
  LExtension: string;
begin
  LExtension := ExtractFileExt(AFileName);
  Result := SameText(LExtension, '.jpg') or SameText(LExtension, '.jpeg');
end;

function TDNGitHubPackageProvider.LoadCacheInfo(const AInfo: TCacheInfo;
  const AAuthor, AName, ACache: string): Boolean;
var
  LFile: string;
begin
  LFile := TPath.Combine(FCacheDir, AAuthor + '\' + AName + '\' + ACache);
  Result := TFile.Exists(LFile) and AInfo.LoadFromFile(LFile);
  if not Result then
    AInfo.CacheID := '';
end;

function TDNGitHubPackageProvider.LoadPackageFromDirectory(const ADirectory,
  AAutor: string; out APackage: IDNPackage): Boolean;
var
  LPackage: TDNGitHubPackage;
  LCache: TCacheInfo;
  LInfo: TInfoFile;
  LVersionName, LPicture, LInfoFile: string;
  LVersion: IDNPackageVersion;
begin
  LPackage := TDNGitHubPackage.Create();
  LPackage.Name := ExtractFileName(ExcludeTrailingPathDelimiter(ADirectory));
  LPackage.Author := AAutor;
  LInfo := TInfoFile.Create();
  LCache := TCacheInfo.Create();
  try
    LCache.LoadFromFile(TPath.Combine(ADirectory, 'cache.json'));
    LPackage.Description := LCache.Description;
    LPackage.DownloadLoaction := LCache.DownloadLocation;
    LInfoFile := TPath.Combine(ADirectory, 'info.json');
    if TFile.Exists(LInfoFile) then
    begin
      if LInfo.LoadFromFile(LInfoFile) then
      begin
        LPackage.ID := LInfo.ID;
        LPackage.CompilerMin := LInfo.CompilerMin;
        LPackage.CompilerMax := LInfo.CompilerMax;
      end;
    end;
    for LVersionName in LCache.Versions do
    begin
      LInfoFile := TPath.Combine(TPath.Combine(ADirectory, LVersionName), 'info.json');
      if TFile.Exists(LInfoFile) then
      begin
        LInfo.LoadFromFile(LInfoFile);
        LVersion := TDNPackageVersion.Create();
        LVersion.Name := LVersionName;
        LVersion.CompilerMin := LInfo.CompilerMin;
        LVersion.CompilerMax := LInfo.CompilerMax;
        //the package itself always shows the lowest and highes compiler-version to indicate if there
        //is any version that matches the required one
        if (LPackage.CompilerMin = 0) or (LVersion.CompilerMin < LPackage.CompilerMin) then
          LPackage.CompilerMin := LVersion.CompilerMin;

        if (LPackage.CompilerMax = 0) or (LVersion.CompilerMax > LPackage.CompilerMax) then
          LPackage.CompilerMax := LVersion.CompilerMax;

        LPackage.Versions.Add(LVersion);
      end;
    end;
    LPicture := TPath.Combine(ADirectory, 'logo.jpg');
    LoadPicture(LPackage, LPicture);
    APackage := LPackage;
    Result := True;
  finally
    LCache.Free;
    LInfo.Free;
  end;
end;

procedure TDNGitHubPackageProvider.LoadPicture(const APackage: IDNPackage;
  const APictureFile: string);
var
  LJPG: TJPEGImage;
  LResStream: TResourceStream;
  LIsValid: Boolean;
begin
  LJPG := TJPEGImage.Create();
  try
    LIsValid := False;
    if TFile.Exists(APictureFile) then
    begin
      try
        LJPG.LoadFromFile(APictureFile);
        LIsValid := True;
      except
        on E: EInvalidGraphic do//just catch
      end;
    end;
    if not LIsValid then
    begin
      LResStream := TResourceStream.Create(HInstance, CJpg_Package, RT_RCDATA);
      try
        LJPG.LoadFromStream(LResStream);
      finally
        LResStream.Free;
      end;
    end;
    APackage.Picture.Assign(LJPG);
  finally
    LJPG.Free;
  end;
end;

function TDNGitHubPackageProvider.Reload: Boolean;
var
  LAuthorName: string;
  LAuthorDir, LPackageDir: string;
  LAuthors: TStringDynArray;
  LPackages: TStringDynArray;
  LPackage: IDNPackage;
const
  CArchivePlaceholder = '{archive_format}{/ref}';
begin
  Result := RevalidateCache();
  if Result or (Packages.Count = 0) then
  begin
    Packages.Clear;
    LAuthors := TDirectory.GetDirectories(FCacheDir);
    for LAuthorDir in LAuthors do
    begin
      LPackages := TDirectory.GetDirectories(LAuthorDir);
      LAuthorName := ExtractFileName(ExcludeTrailingPathDelimiter(LAuthorDir));
      for LPackageDir in LPackages do
      begin
        if LoadPackageFromDirectory(LPackageDir, LAuthorName, LPackage) then
          Packages.Add(LPackage);
      end;
    end;
  end;
end;

function TDNGitHubPackageProvider.RevalidateCache: Boolean;
var
  LData, LInfoData, LReleases: TStringStream;
  LRoot: TJSONObject;
  LItems: TJSONArray;
  i: Integer;
  LItem: TJSonObject;
  LCacheInfo: TCacheInfo;
  LName, LAuthor, LDefaultBranch: string;
  LCacheDir, LAuthorDir: string;
const
  CArchivePlaceholder = '{archive_format}{/ref}';
begin
  Result := False;
  LData := TStringStream.Create();
  LCacheInfo := TCacheInfo.Create();
  try
    if ExecuteRequest(LData, CGitRepoSearch) then
    begin
      LRoot := TJSONObject.ParseJSONValue(LData.DataString)as TJSONObject;
      try
        LItems := LRoot.GetValue('items') as TJSONArray;
        for i := 0 to LItems.Count - 1 do
        begin
          LItem := LItems.Items[i] as TJSonObject;
          LInfoData := TStringStream.Create();
          try
            LName := LItem.GetValue('name').Value;
            LAuthor := TJSonObject(LItem.GetValue('owner')).GetValue('login').Value;
            LDefaultBranch := LItem.GetValue('default_branch').Value;
            LoadCacheInfo(LCacheInfo, LAuthor, LName, 'cache.json');
            LReleases := TStringStream.Create();
            try
              if ExecuteRequest(LReleases, Format(CGithubRepoReleases, [LAuthor, LName]), LCacheInfo.CacheID) then
              begin
                Result := True;
                LAuthorDir := TPath.Combine(FCacheDir, LAuthor);
                LCacheDir := TPath.Combine(LAuthorDir, LName);
                if TDirectory.Exists(LCacheDir) then
                begin
                  TDirectory.Delete(LCacheDir, True);
                  TDirectory.CreateDirectory(LCacheDir);
                end;

                ForceDirectories(LCacheDir);
                LCacheInfo.CacheID := FLastEtag;
                if DownloadVersionMeta(LReleases, LCacheInfo, LAuthor, LName, LDefaultBranch) then
                begin
                  LCacheInfo.Description := LItem.GetValue('description').Value;
                  LCacheInfo.DefaultBranch := LDefaultBranch;
                  LCacheInfo.DownloadLocation := LItem.GetValue('archive_url').Value;
                  LCacheInfo.DownloadLocation := StringReplace(LCacheInfo.DownloadLocation, CArchivePlaceholder, 'zipball/', []);
                  LCacheInfo.SaveToFile(TPath.Combine(LCacheDir, 'cache.json'));
                end;
              end;
            finally
              LReleases.Free;
            end;
          finally
            LInfoData.Free;
          end;
        end;
      finally
        LRoot.Free;
      end;
      Result := True;
    end;
  finally
    LCacheInfo.Free;
    LData.Free;
  end;
end;

end.
