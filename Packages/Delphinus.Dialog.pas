unit Delphinus.Dialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DN.PackageOverview, System.Actions, Vcl.ActnList, Vcl.ImgList, Vcl.ToolWin,
  Vcl.ComCtrls,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  ContNrs,
  Generics.Collections,
  DN.PackageDetailView;

type
  TDelphinusDialog = class(TForm)
    ToolBar1: TToolBar;
    imgMenu: TImageList;
    DialogActions: TActionList;
    ToolButton1: TToolButton;
    actRefresh: TAction;
    ToolButton2: TToolButton;
    btnInstallFolder: TToolButton;
    dlgSelectInstallFile: TOpenDialog;
    btnUninstall: TToolButton;
    dlgSelectUninstallFile: TOpenDialog;
    PageControl: TPageControl;
    tsAvailable: TTabSheet;
    tsInstalled: TTabSheet;
    procedure actRefreshExecute(Sender: TObject);
    procedure btnInstallFolderClick(Sender: TObject);
    procedure btnUninstallClick(Sender: TObject);
  private
    { Private declarations }
    FOverView: TPackageOverView;
    FInstalledOverview: TPackageOverView;
    FPackageProvider: IDNPackageProvider;
    FInstalledPackageProvider: IDNPackageProvider;
    FPackages: TList<IDNPackage>;
    FInstalledPackages: TList<IDNPackage>;
    FDetailView: TPackageDetailView;
    procedure InstallPackage(const APackage: IDNPackage);
    procedure UnInstallPackage(const APackage: IDNPackage);
    function GetComponentDirectory: string;
    function GetBPLDirectory: string;
    function GetDCPDirectory: string;
    procedure RefreshInstalledPackages;
    function IsPackageInstalled(const APackage: IDNPackage): Boolean;
    function GetInstalledPackage(const APackage: IDNPackage): IDNPackage;
    function GetInstalledVersion(const APackage: IDNPackage): string;
    function GetActiveOverView: TPackageOverView;
    procedure ShowDetail(const APackage: IDNPackage);
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
  DN.PackageProvider.GitHub,
  DN.PackageProvider.Installed,
  Delphinus.SetupDialog,
  DN.Compiler.Intf,
  DN.Compiler.MSBuild,
  DN.Installer.Intf,
  DN.Installer.IDE,
  DN.Uninstaller.Intf,
  DN.Uninstaller.IDE;

{$R *.dfm}

{ TDelphinusDialog }

procedure TDelphinusDialog.actRefreshExecute(Sender: TObject);
begin
  FPackages.Clear;
  if FPackageProvider.Reload() then
  begin
    FPackages.AddRange(FPackageProvider.Packages);
    FOverView.Clear;
    FOverView.Packages.AddRange(FPackages);
    tsAvailable.Caption := 'Available (' + IntToStr(FPackages.Count) + ')';
  end;
  RefreshInstalledPackages();
end;

procedure TDelphinusDialog.btnInstallFolderClick(Sender: TObject);
var
  LDialog: TSetupDialog;
  LCompiler: IDNCompiler;
  LInstaller: IDNInstaller;
begin
  if dlgSelectInstallFile.Execute() then
  begin
    LDialog := TSetupDialog.Create(nil);
    try
      LCompiler := TDNMSBuildCompiler.Create(GetEnvironmentVariable('BDSBIN'));
      LCompiler.BPLOutput := GetBPLDirectory();
      LCompiler.DCPOutput := GetDCPDirectory();
      LInstaller := TDNIDEInstaller.Create(LCompiler, Trunc(CompilerVersion));
      LDialog.ExecuteInstallationFromDirectory(ExtractFilePath(dlgSelectInstallFile.FileName), LInstaller,
        GetComponentDirectory());
    finally
      LDialog.Free;
    end;
    RefreshInstalledPackages();
  end;
end;

procedure TDelphinusDialog.btnUninstallClick(Sender: TObject);
var
  LDialog: TSetupDialog;
  LUninstaller: IDNUninstaller;
begin
  if dlgSelectUninstallFile.Execute() then
  begin
    LDialog := TSetupDialog.Create(nil);
    try
      LUninstaller := TDNIDEUninstaller.Create();
      LDialog.ExecuteUninstallation(ExtractFilePath(dlgSelectUninstallFile.FileName), LUninstaller);
    finally
      LDialog.Free;
    end;
    RefreshInstalledPackages();
  end;
end;

constructor TDelphinusDialog.Create(AOwner: TComponent);
begin
  inherited;
  FDetailView := TPackageDetailView.Create(Self);
  FDetailView.Align := alClient;
  FDetailView.Visible := False;
  FDetailView.Parent := Self;

  FOverView := TPackageOverView.Create(Self);
  FOverView.Align := alClient;
  FOverView.Parent := tsAvailable;
  FOverView.OnCheckIsPackageInstalled := GetInstalledVersion;
  FOverView.OnInstallPackage :=  InstallPackage;
  FOverView.OnUninstallPackage := UninstallPackage;
  FOverView.OnInfoPackage := ShowDetail;
  FInstalledOverview := TPackageOverView.Create(Self);
  FInstalledOverview.Align := alClient;
  FInstalledOverview.Parent := tsInstalled;
  FInstalledOverview.OnCheckIsPackageInstalled := GetInstalledVersion;
  FInstalledOverview.OnUninstallPackage := UnInstallPackage;
  FInstalledOverview.OnInfoPackage := ShowDetail;
  FPackages := TList<IDNPackage>.Create();
  FInstalledPackages := TList<IDNPackage>.Create();
  FPackageProvider := TDNGitHubPackageProvider.Create();
  FInstalledPackageProvider := TDNInstalledPackageProvider.Create(GetComponentDirectory());
  RefreshInstalledPackages();
end;

destructor TDelphinusDialog.Destroy;
begin
  FOverView.OnSelectedPackageChanged := nil;
  FInstalledOverview.OnSelectedPackageChanged := nil;
  FPackages.Free;
  FInstalledPackages.Free;
  FPackageProvider := nil;
  FInstalledPackageProvider := nil;
  inherited;
end;

function TDelphinusDialog.GetActiveOverView: TPackageOverView;
begin
  if PageControl.ActivePageIndex = 1 then
    Result := FInstalledOverview
  else
    Result := FOverView;
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
      if LPackage.Name = APackage.Name then
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
    if Length(LPackage.Versions) > 0 then
      Result := LPackage.Versions[0]
    else
      Result := 'none';
  end;
end;

procedure TDelphinusDialog.InstallPackage(const APackage: IDNPackage);
var
  LDialog: TSetupDialog;
  LCompiler: IDNCompiler;
  LInstaller: IDNInstaller;
begin
  if Assigned(APackage) then
  begin
    LDialog := TSetupDialog.Create(nil);
    try
      LCompiler := TDNMSBuildCompiler.Create(GetEnvironmentVariable('BDSBIN'));
      LCompiler.BPLOutput := GetBPLDirectory();
      LCompiler.DCPOutput := GetDCPDirectory();
      LInstaller := TDNIDEInstaller.Create(LCompiler, Trunc(CompilerVersion));
      LDialog.ExecuteInstallation(APackage, FPackageProvider, LInstaller,
        GetComponentDirectory());
    finally
      LDialog.Free;
    end;
    RefreshInstalledPackages();
  end;
end;

function TDelphinusDialog.IsPackageInstalled(
  const APackage: IDNPackage): Boolean;
begin
  Result := Assigned(GetInstalledPackage(APackage));
end;

procedure TDelphinusDialog.RefreshInstalledPackages;
begin
  if FInstalledPackageProvider.Reload() then
  begin
    FInstalledPackages.Clear;
    FInstalledPackages.AddRange(FInstalledPackageProvider.Packages);
    FInstalledOverview.Clear;
    FInstalledOverview.Packages.AddRange(FInstalledPackages);
    tsInstalled.Caption := 'Installed (' + IntToStr(FInstalledPackages.Count) + ')';
    FOverView.Refresh();
  end;
  FDetailView.Visible := False;
end;

procedure TDelphinusDialog.ShowDetail(const APackage: IDNPackage);
begin
  FDetailView.Package := APackage;
//  PageControl.Visible := False;
  FDetailView.BringToFront();
  FDetailView.Visible := True;
end;

procedure TDelphinusDialog.UnInstallPackage(const APackage: IDNPackage);
var
  LDialog: TSetupDialog;
  LUninstaller: IDNUninstaller;
begin
  if Assigned(APackage) then
  begin
    LDialog := TSetupDialog.Create(nil);
    try
      LUninstaller := TDNIDEUninstaller.Create();
      LDialog.ExecuteUninstallation(TPath.Combine(GetComponentDirectory(), APackage.Name), LUninstaller);
    finally
      LDialog.Free;
    end;
    RefreshInstalledPackages();
  end;
end;

end.
