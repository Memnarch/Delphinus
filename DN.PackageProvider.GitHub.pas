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
  DN.Package.Github,
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
    function IsValidImage(const AFileName: string): Boolean;
  protected
    function GetLicense(const APackage: TDNGitHubPackage): string;
  public
    constructor Create(const ASecurityToken: string = '');
    destructor Destroy(); override;
    function Reload(): Boolean; override;
    function Download(const APackage: IDNPackage; const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean; override;
  end;

implementation

uses
  IOUtils,
  DN.IOUtils,
  StrUtils,
  jpeg,
  pngimage,
  IdIOHandlerStack,
  IdSSLOpenSSl,
  DN.Types,
  DN.Package,
  DN.JSon,
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
  FCacheDir := TPath.Combine(TPath.GetCachePath(), 'Delphinus\Github');
  ForceDirectories(FCacheDir);
  FRequest := TIdHTTP.Create(nil);
  FRequest.ReadTimeout := 30000;
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

function TDNGitHubPackageProvider.Download(const APackage: IDNPackage;
  const AVersion: string; const AFolder: string; out AContentFolder: string): Boolean;
var
  LArchive: TFileStream;
  LArchiveFile, LFileName, LFolder: string;
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
  if Result then
  begin
    LFolder := TPath.Combine(AFolder, TGuid.NewGuid.ToString);
    Result := ForceDirectories(LFolder);
    if Result then
      Result := ShellUnzip(LArchiveFile, LFolder);
  end;

  if Result then
  begin
    LDirs := TDirectory.GetDirectories(LFolder);
    Result := Length(LDirs) = 1;
    if Result then
      AContentFolder := LDirs[0];
  end;
  TFile.Delete(LArchiveFile);
end;

function TDNGitHubPackageProvider.DownloadVersionMeta(
  const AData: TStringStream; ACacheInfo: TCacheInfo; const AAuthor, AName,
  ADefaultBranch: string): Boolean;
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
    if ExecuteRequest(LFile, CGithubRaw + AAuthor + '/' + AName + '/' + ADefaultBranch + '/' + CInfoFile) then
    begin
      ForceDirectories(LVersionDir);
      LFile.SaveToFile(TPath.Combine(LVersionDir, CInfoFile));
      if LInfo.LoadFromFile(TPath.Combine(LVersionDir, CInfoFile)) then
      begin
        LFile.Clear();
        LFirstVersion := LInfo.FirstVersion;
        if IsValidImage(LInfo.Picture) and ExecuteRequest(LFile, CGithubRaw + AAuthor + '/' + AName + '/' + ADefaultBranch + '/' + LInfo.Picture) then
          LFile.SaveToFile(TPath.Combine(LVersionDir, ExtractFileName(LInfo.Picture)));
        Result := True;
      end;
    end
    else
    begin
      Exit(False);
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
            if ExecuteRequest(LFile, Format(CGithubRawReferencedFile, [AAuthor, AName, LValue.Value, CInfoFile])) then
            begin
              LFile.SaveToFile(TPath.Combine(LVersionDir, CInfoFile));
              Result := True;
            end;
            //stop after first supported release, all others are not supported
            if SameText(LValue.Value, LFirstVersion) then
            begin
              SetLength(LVersions, i + 1);
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

function TDNGitHubPackageProvider.ExecuteRequest(const ATarget: TStream;
  const ARequest: string; const AETag: string): Boolean;
var
  LIndex: Integer;
begin
  if AETag <> '' then
  begin
    FRequest.Request.CustomHeaders.Values['If-None-Match'] := AETag;
  end
  else
  begin
    LIndex := FRequest.Request.CustomHeaders.IndexOfName('If-None-Match');
    if LIndex > -1 then
      FRequest.Request.CustomHeaders.Delete(LIndex);
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

function TDNGitHubPackageProvider.GetLicense(
  const APackage: TDNGitHubPackage): string;
var
  LLicense: TStringStream;
begin
  Result := '';
  if (APackage.LicenseType <> '') then
  begin
    LLicense := TStringStream.Create();
    try
      if ExecuteRequest(LLicense, Format(CGithubRawReferencedFile, [APackage.Author, APackage.RepositoryName, APackage.DefaultBranch, APackage.LicenseFile])) then
      begin
        Result := LLicense.DataString;
        //if we do not detect a single Windows-Linebreak, we assume Posix-LineBreaks and convert
        if not ContainsStr(Result, sLineBreak) then
          Result := StringReplace(Result, #10, sLineBreak, [rfReplaceAll]);
      end
      else
      begin
        Result := 'An error occured while doanloading the license information';
      end;
    finally
      LLicense.Free;
    end;
  end;
end;

function TDNGitHubPackageProvider.IsValidImage(const AFileName: string): Boolean;
var
  LExtension: string;
begin
  LExtension := LowerCase(ExtractFileExt(AFileName));
  Result := (LExtension = '.jpg') or (LExtension = '.jpeg') or
    (LExtension = '.png');
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
  LVersionName, LPicture, LInfoFile, LCacheFile: string;
  LVersion: IDNPackageVersion;
begin
  LPackage := TDNGitHubPackage.Create();
  LPackage.OnGetLicense := GetLicense;
  LPackage.Name := ExtractFileName(ExcludeTrailingPathDelimiter(ADirectory));
  LPackage.Author := AAutor;
  LInfo := TInfoFile.Create();
  LCache := TCacheInfo.Create();
  try
    LCacheFile := TPath.Combine(ADirectory, CCacheFile);
    if TFile.Exists(LCacheFile) then
    begin
      LCache.LoadFromFile(LCacheFile);
      LPackage.Description := LCache.Description;
      LPackage.DownloadLoaction := LCache.DownloadLocation;
      LPackage.RepositoryName := LCache.RepositoryName;
      LPackage.DefaultBranch := LCache.DefaultBranch;
      LInfoFile := TPath.Combine(ADirectory, CInfoFile);
      if TFile.Exists(LInfoFile) then
      begin
        if LInfo.LoadFromFile(LInfoFile) then
        begin
          if LInfo.Name <> '' then
            LPackage.Name := LInfo.Name;
          LPackage.ID := LInfo.ID;
          LPackage.CompilerMin := LInfo.CompilerMin;
          LPackage.CompilerMax := LInfo.CompilerMax;
          LPackage.LicenseType := LInfo.LicenseType;
          LPackage.LicenseFile := LInfo.LicenseFile;
        end;
      end;
      for LVersionName in LCache.Versions do
      begin
        LInfoFile := TPath.Combine(TPath.Combine(ADirectory, LVersionName), CInfoFile);
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
      LPicture := TPath.Combine(ADirectory, ExtractFileName(LInfo.Picture));
      LoadPicture(LPackage, LPicture);

      APackage := LPackage;
      Result := True;
    end
    else
    begin
      Result := False;
    end;
  finally
    LCache.Free;
    LInfo.Free;
  end;
end;

procedure TDNGitHubPackageProvider.LoadPicture(const APackage: IDNPackage;
  const APictureFile: string);
var
  LGraphic: TGraphic;
  LResStream: TResourceStream;
  LIsValid: Boolean;
begin
  LIsValid := False;
  LGraphic := nil;
  if TFile.Exists(APictureFile) then
  begin
    if LowerCase(ExtractFileExt(APictureFile)) = '.png' then
    begin
      LGraphic := TPNGImage.Create;
      try
        LGraphic.LoadFromFile(APictureFile);
        LIsValid := True;
      except
        on E: EInvalidGraphic do//just catch
      end;
    end
    else
    begin
      LGraphic := TJPEGImage.Create();
      try
        LGraphic.LoadFromFile(APictureFile);
        LIsValid := True;
      except
        on E: EInvalidGraphic do//just catch
      end;
    end;
  end;

  if not LIsValid then
  begin
    LResStream := TResourceStream.Create(HInstance, CJpg_Package, RT_RCDATA);
    try
      LGraphic := TJPEGImage.Create();
      LGraphic.LoadFromStream(LResStream);
    finally
      LResStream.Free;
    end;
  end;

  APackage.Picture.Assign(LGraphic);

  if Assigned(LGraphic) then
    LGraphic.Free;
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
            LoadCacheInfo(LCacheInfo, LAuthor, LName, CCacheFile);
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
                end;

                LCacheInfo.CacheID := FLastEtag;
                if DownloadVersionMeta(LReleases, LCacheInfo, LAuthor, LName, LDefaultBranch) then
                begin
                  ForceDirectories(LCacheDir);
                  LCacheInfo.Description := LItem.GetValue('description').Value;
                  LCacheInfo.DefaultBranch := LDefaultBranch;
                  LCacheInfo.RepositoryName := LName;
                  LCacheInfo.DownloadLocation := LItem.GetValue('archive_url').Value;
                  LCacheInfo.DownloadLocation := StringReplace(LCacheInfo.DownloadLocation, CArchivePlaceholder, 'zipball/', []);
                  LCacheInfo.SaveToFile(TPath.Combine(LCacheDir, CCacheFile));
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
