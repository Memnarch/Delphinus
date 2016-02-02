{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.Dialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,
  DN.PackageOverview, ActnList, ImgList, ToolWin,
  ComCtrls,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  ContNrs,
  Generics.Collections,
  DN.PackageDetailView,
  Delphinus.Forms,
  Delphinus.Settings,
  DN.Setup.Intf,
  Delphinus.CategoryFilterView,
  Delphinus.ProgressDialog,
  DN.PackageFilter,
  ExtCtrls,
  StdCtrls,
  Registry;

type
  TDelphinusDialog = class(TForm)
    ToolBar1: TToolBar;
    ilMenu: TImageList;
    DialogActions: TActionList;
    ToolButton1: TToolButton;
    actRefresh: TAction;
    ToolButton2: TToolButton;
    btnInstallFolder: TToolButton;
    dlgSelectInstallFile: TOpenDialog;
    btnUninstall: TToolButton;
    dlgSelectUninstallFile: TOpenDialog;
    actOptions: TAction;
    pnlPackages: TPanel;
    edSearch: TButtonedEdit;
    ilSmall: TImageList;
    pnlToolBar: TPanel;
    procedure actRefreshExecute(Sender: TObject);
    procedure btnInstallFolderClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
    procedure actOptionsExecute(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure edSearchKeyPress(Sender: TObject; var Key: Char);
    procedure edSearchRightButtonClick(Sender: TObject);
    procedure edSearchLeftButtonClick(Sender: TObject);
  private
    { Private declarations }
    FOverView: TPackageOverView;
    FPackageProvider: IDNPackageProvider;
    FInstalledPackageProvider: IDNPackageProvider;
    FPackages: TList<IDNPackage>;
    FInstalledPackages: TList<IDNPackage>;
    FUpdatePackages: TList<IDNPackage>;
    FDetailView: TPackageDetailView;
    FSettings: TDelphinusSettings;
    FCategoryFilteView: TCategoryFilterView;
    FCategory: TPackageCategory;
    FProgressDialog: TProgressDialog;
    FFilter: string;
    procedure InstallPackage(const APackage: IDNPackage);
    procedure UnInstallPackage(const APackage: IDNPackage);
    procedure UpdatePackage(const APackage: IDNPackage);
    function GetComponentDirectory: string;
    function GetBPLDirectory: string;
    function GetDCPDirectory: string;
    procedure RefreshInstalledPackages;
    function IsPackageInstalled(const APackage: IDNPackage): Boolean;
    function GetInstalledPackage(const APackage: IDNPackage): IDNPackage;
    function GetOnlinePackage(const APackage: IDNPackage): IDNPackage;
    function GetInstalledVersion(const APackage: IDNPackage): string;
    function GetUpdateVersion(const APackage: IDNPackage): string;
    function GetActiveOverView: TPackageOverView;
    procedure ShowDetail(const APackage: IDNPackage);
    procedure LoadSettings(out ASettings: TDelphinusSettings);
    procedure SaveSettings(const ASettings: TDelphinusSettings);
    procedure RecreatePackageProvider();
    function CreateSetup: IDNSetup;
    procedure HandleCategoryChanged(Sender: TObject; ANewCategory: TPackageCategory);
    procedure HandleSelectedPackageChanged(Sender: TObject);
    procedure HandleAsyncProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    function GetActivePackageSource: TList<IDNPackage>;
    procedure RefreshOverview();
    procedure DoFilter(const AFilter: string);
    procedure FilterPackage(const APackage: IDNPackage; var AAccepted: Boolean);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  DelphinusDialog: TDelphinusDialog;

implementation

uses
  ToolsApi,
  IOUtils,
  RTTI,
  Types,
  DN.Types,
  DN.PackageProvider.GitHub,
  DN.PackageProvider.Installed,
  Delphinus.SetupDialog,
  DN.Compiler.Intf,
  DN.Compiler.MSBuild,
  DN.Installer.Intf,
  DN.Installer.IDE,
  DN.Uninstaller.Intf,
  DN.Uninstaller.IDE,
  DN.Setup,
  Delphinus.OptionsDialog,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.Progress.Intf,
  StrUtils;

{$R *.dfm}

const
  CDelphinusSubKey = 'Delphinus';
  CFiltersSubKey = 'Filters';
  COAuthTokenKey = 'OAuthToken';

{ TDelphinusDialog }

procedure TDelphinusDialog.actOptionsExecute(Sender: TObject);
var
  LDialog: TDelphinusOptionsDialog;
begin
  LDialog := TDelphinusOptionsDialog.Create(nil);
  try
    LDialog.Settings := FSettings;
    if LDialog.ShowModal = mrOk then
    begin
      FSettings := LDialog.Settings;
      SaveSettings(FSettings);
      RecreatePackageProvider();
    end;
  finally
    LDialog.Free;
  end;
end;

procedure TDelphinusDialog.actRefreshExecute(Sender: TObject);
begin
  TThread.CreateAnonymousThread(
    procedure
    var
      LProgress: IDNProgress;
    begin
      try
        if Supports(FPackageProvider, IDNProgress, LProgress) then
          LProgress.OnProgress := HandleAsyncProgress;
        if FPackageProvider.Reload() then
        begin
          FPackages.Clear;
          FPackages.AddRange(FPackageProvider.Packages);
        end;
      finally
        if Assigned(LProgress) then
          LProgress.OnProgress := nil;
        TThread.Queue(nil,
          procedure
          begin
            FCategoryFilteView.OnlineCount := FPackages.Count;
            RefreshInstalledPackages();
            FProgressDialog.ModalResult := mrOk;
          end);
      end;
    end).Start;
  FProgressDialog.Caption := 'Delphinus';
  FProgressDialog.Task := 'Refreshing';
  FProgressDialog.Progress := -1;
  FProgressDialog.ShowModal();
end;

procedure TDelphinusDialog.btnInstallFolderClick(Sender: TObject);
var
  LDialog: TSetupDialog;
begin
  if dlgSelectInstallFile.Execute() then
  begin
    LDialog := TSetupDialog.Create(CreateSetup());
    try
      if LDialog.ExecuteInstallationFromDirectory(ExtractFilePath(dlgSelectInstallFile.FileName)) then
        RefreshInstalledPackages();
    finally
      LDialog.Free;
    end;
  end;
end;

procedure TDelphinusDialog.btnUninstallClick(Sender: TObject);
var
  LDialog: TSetupDialog;
begin
  if dlgSelectUninstallFile.Execute() then
  begin
    LDialog := TSetupDialog.Create(CreateSetup());
    try
      if LDialog.ExecuteUninstallationFromDirectory(ExtractFilePath(dlgSelectUninstallFile.FileName)) then
        RefreshInstalledPackages();
    finally
      LDialog.Free;
    end;
  end;
end;

constructor TDelphinusDialog.Create(AOwner: TComponent);
begin
  inherited;
  FSettings := TDelphinusSettings.Create();
  FPackages := TList<IDNPackage>.Create();
  FInstalledPackages := TList<IDNPackage>.Create();
  FUpdatePackages := TList<IDNPackage>.Create();

  FProgressDialog := TProgressDialog.Create(Self);
  FDetailView := TPackageDetailView.Create(Self);
  FDetailView.OnGetOnlineVersion := GetUpdateVersion;
  FDetailView.OnGetInstalledVersion := GetInstalledVersion;
  FDetailView.Align := alRight;
  FDetailView.Parent := Self;

  FOverView := TPackageOverView.Create(Self);
  FOverView.Align := alClient;
  FOverView.Parent := pnlPackages;
  FOverView.OnCheckIsPackageInstalled := GetInstalledVersion;
  FOverView.OnCheckHasPackageUpdate := GetUpdateVersion;
  FOverView.OnSelectedPackageChanged := HandleSelectedPackageChanged;
  FOverView.OnInstallPackage :=  InstallPackage;
  FOverView.OnUninstallPackage := UninstallPackage;
  FOverView.OnUpdatePackage := UpdatePackage;
  FOverView.DoubleBuffered := True;
  FOverView.OnFilter := FilterPackage;
  FCategoryFilteView := TCategoryFilterView.Create(Self);
  FCategoryFilteView.Width := 200;
  FCategoryFilteView.Align := alLeft;
  FCategoryFilteView.OnCategoryChanged := HandleCategoryChanged;
  FCategoryFilteView.Parent := Self;

  LoadSettings(FSettings);
  RecreatePackageProvider();
  FInstalledPackageProvider := TDNInstalledPackageProvider.Create(GetComponentDirectory());
  RefreshInstalledPackages();
  dlgSelectInstallFile.Filter := CInstallFileFilter;
  dlgSelectUninstallFile.Filter := CUninstallFileFilter;

  //adjust serachbar to be over the Packagelist
  edSearch.Width := pnlPackages.Width;
  edSearch.Left := pnlPackages.Left;
end;

function TDelphinusDialog.CreateSetup: IDNSetup;
var
  LCompiler: IDNCompiler;
  LInstaller: IDNInstaller;
  LUninstaller: IDNUninstaller;
begin
  LCompiler := TDNMSBuildCompiler.Create(GetEnvironmentVariable('BDSBIN'));
  LCompiler.BPLOutput := GetBPLDirectory();
  LCompiler.DCPOutput := GetDCPDirectory();
  LInstaller := TDNIDEInstaller.Create(LCompiler);
  LUninstaller := TDNIDEUninstaller.Create();
  Result := TDNSetup.Create(LInstaller, LUninstaller, FPackageProvider);
  Result.ComponentDirectory := GetComponentDirectory();
end;

destructor TDelphinusDialog.Destroy;
begin
  SaveSettings(FSettings);
  FOverView.OnSelectedPackageChanged := nil;
  FPackages.Free;
  FInstalledPackages.Free;
  FUpdatePackages.Free;
  FPackageProvider := nil;
  FInstalledPackageProvider := nil;
  FSettings.Free;
  inherited;
end;

procedure TDelphinusDialog.DoFilter(const AFilter: string);
begin
  FFilter := Trim(AFilter);
  FOverView.ApplyFilter();
end;

procedure TDelphinusDialog.edSearchKeyPress(Sender: TObject; var Key: Char);
begin
  if Ord(Key) = VK_RETURN then
  begin
    DoFilter(edSearch.Text);
    Key := #0;
  end;

  if Ord(Key) = VK_ESCAPE then
  begin
    edSearch.Text := '';
    DoFilter('');
    Key := #0;
  end;
end;

procedure TDelphinusDialog.edSearchLeftButtonClick(Sender: TObject);
begin
  DoFilter(edSearch.Text);
end;

procedure TDelphinusDialog.edSearchRightButtonClick(Sender: TObject);
begin
  edSearch.Text := '';
  DoFilter('');
end;

procedure TDelphinusDialog.FilterPackage(const APackage: IDNPackage;
  var AAccepted: Boolean);
begin
  AAccepted := ((FFilter = '') or ContainsText(APackage.Name, FFilter));
end;

procedure TDelphinusDialog.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
var
  LPos: TPoint;
  LOverView: TPackageOverView;
begin
  LOverView := GetActiveOverView();
  LPos := LOverView.ScreenToClient(MousePos);
  if PtInRect(Rect(0, 0, LOverView.Width, LOverView.Height), LPos) then
  begin
    LOverView.VertScrollBar.Position := LOverView.VertScrollBar.Position - WheelDelta;
    Handled := True;
  end;
end;

function TDelphinusDialog.GetActiveOverView: TPackageOverView;
begin
  Result := FOverView;
end;

function TDelphinusDialog.GetActivePackageSource: TList<IDNPackage>;
begin
  case FCategory of
    pcOnline: Result := FPackages;
    pcInstalled: Result := FInstalledPackages;
    pcUpdates: Result := FUpdatePackages;
  else
    Result := FPackages;
  end;
end;

function TDelphinusDialog.GetBPLDirectory: string;
begin
  Result := TPath.Combine(GetEnvironmentVariable('BDSCOMMONDIR'), 'Bpl');
end;

function TDelphinusDialog.GetComponentDirectory: string;
begin
  Result := TPath.Combine(GetEnvironmentVariable('BDSCOMMONDIR'), 'Comps');
end;

function TDelphinusDialog.GetDCPDirectory: string;
begin
  Result := TPath.Combine(GetEnvironmentVariable('BDSCOMMONDIR'), 'Dcp');
end;

function TDelphinusDialog.GetInstalledPackage(
  const APackage: IDNPackage): IDNPackage;
var
  LPackage: IDNPackage;
begin
  Result := nil;
  if Assigned(APackage) then
  begin
    for LPackage in FInstalledPackages do
    begin
      if LPackage.ID = APackage.ID then
        Exit(LPackage);
    end;
  end
end;

function TDelphinusDialog.GetInstalledVersion(
  const APackage: IDNPackage): string;
var
  LPackage: IDNPackage;
begin
  Result := '';
  LPackage := GetInstalledPackage(APackage);
  if Assigned(LPackage) then
  begin
    if LPackage.Versions.Count > 0 then
      Result := LPackage.Versions[0].Name
    else
      Result := 'none';
  end;
end;

function TDelphinusDialog.GetOnlinePackage(
  const APackage: IDNPackage): IDNPackage;
var
  LPackage: IDNPackage;
begin
  Result := nil;
  if Assigned(APackage) then
  begin
    for LPackage in FPackages do
    begin
      if LPackage.ID = APackage.ID then
        Exit(LPackage);
    end;
  end
end;

function TDelphinusDialog.GetUpdateVersion(const APackage: IDNPackage): string;
var
  LVersion: string;
  LPackage: IDNPackage;
begin
  Result := '';
  LVersion := GetInstalledVersion(APackage);
  LPackage := GetOnlinePackage(APackage);
  if Assigned(LPackage) and (LVersion <> '') then
  begin
    if (LPackage.Versions.Count > 0) and (LPackage.Versions[0].Name <> LVersion) then
      Result := LPackage.Versions[0].Name;
  end;
end;

procedure TDelphinusDialog.HandleAsyncProgress(const ATask, AItem: string;
  AProgress, AMax: Int64);
begin
  TThread.Queue(nil,
    procedure
    begin
      FProgressDialog.Task := AItem;
      FProgressDialog.Progress := AProgress;
    end
  );
end;

procedure TDelphinusDialog.HandleCategoryChanged(Sender: TObject;
  ANewCategory: TPackageCategory);
begin
  FCategory := ANewCategory;
  RefreshOverview();
end;

procedure TDelphinusDialog.HandleSelectedPackageChanged(Sender: TObject);
begin
  ShowDetail(GetActiveOverView().SelectedPackage);
end;

procedure TDelphinusDialog.InstallPackage(const APackage: IDNPackage);
var
  LDialog: TSetupDialog;
begin
  if Assigned(APackage) then
  begin
    LDialog := TSetupDialog.Create(CreateSetup());
    try
      if LDialog.ExecuteInstallation(APackage) then
        RefreshInstalledPackages();
    finally
      LDialog.Free;
    end;
  end;
end;

function TDelphinusDialog.IsPackageInstalled(
  const APackage: IDNPackage): Boolean;
begin
  Result := Assigned(GetInstalledPackage(APackage));
end;

procedure TDelphinusDialog.LoadSettings(out ASettings: TDelphinusSettings);
var
  LRegistry: TRegistry;
  LBase: string;
begin
  LRegistry := TRegistry.Create();
  try
    LBase := (BorlandIDEServices as IOTAServices).GetBaseRegistryKey();
    LRegistry.RootKey := HKEY_CURRENT_USER;
    if LRegistry.OpenKey(TPath.Combine(LBase, CDelphinusSubKey), False) then
      FSettings.OAuthToken := LRegistry.ReadString(COAuthTokenKey);
  finally
    LRegistry.Free;
  end;
end;

procedure TDelphinusDialog.RecreatePackageProvider;
var
  LClient: IDNHttpClient;
begin
  LClient := TDNWinHttpClient.Create();
  if FSettings.OAuthToken <> '' then
    LClient.Authentication := Format(CGithubOAuthAuthentication, [FSettings.OAuthToken]);
  FPackageProvider := TDNGitHubPackageProvider.Create(LClient);
end;

procedure TDelphinusDialog.RefreshInstalledPackages;
var
  LInstalledPackage: IDNPackage;
begin
  if FInstalledPackageProvider.Reload() then
  begin
    FInstalledPackages.Clear;
    FInstalledPackages.AddRange(FInstalledPackageProvider.Packages);
    FCategoryFilteView.InstalledCount := FInstalledPackages.Count;
    FUpdatePackages.Clear();
    for LInstalledPackage in FInstalledPackages do
    begin
      if GetUpdateVersion(LInstalledPackage) <> '' then
        FUpdatePackages.Add(LInstalledPackage);
    end;
    FCategoryFilteView.UpdatesCount := FUpdatePackages.Count;
  end;
  RefreshOverview();
end;

procedure TDelphinusDialog.RefreshOverview;
begin
  GetActiveOverView().Clear;
  GetActiveOverView().Packages.AddRange(GetActivePackageSource());
end;

procedure TDelphinusDialog.SaveSettings(const ASettings: TDelphinusSettings);
var
  LRegistry: TRegistry;
  LBase: string;
begin
  LRegistry := TRegistry.Create();
  try
    LBase := (BorlandIDEServices as IOTAServices).GetBaseRegistryKey();
    LRegistry.RootKey := HKEY_CURRENT_USER;
    if LRegistry.OpenKey(TPath.Combine(LBase, CDelphinusSubKey), True) then
      LRegistry.WriteString(COAuthTokenKey, FSettings.OAuthToken);
  finally
    LRegistry.Free;
  end;
end;

procedure TDelphinusDialog.ShowDetail(const APackage: IDNPackage);
begin
  FDetailView.Package := APackage;
  FDetailView.BringToFront();
end;

procedure TDelphinusDialog.UnInstallPackage(const APackage: IDNPackage);
var
  LDialog: TSetupDialog;
begin
  if Assigned(APackage) then
  begin
    LDialog := TSetupDialog.Create(CreateSetup());
    try
      if LDialog.ExecuteUninstallation(APackage) then
        RefreshInstalledPackages();
    finally
      LDialog.Free;
    end;
  end;
end;

procedure TDelphinusDialog.UpdatePackage(const APackage: IDNPackage);
var
  LDialog: TSetupDialog;
begin
  if Assigned(APackage) then
  begin
    LDialog := TSetupDialog.Create(CreateSetup());
    try
      if LDialog.ExecuteUpdate(GetOnlinePackage(APackage))then
        RefreshInstalledPackages();
    finally
      LDialog.Free;
    end;
  end;
end;

end.
