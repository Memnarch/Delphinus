unit Delphinus.Dialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DN.PackageOverview, System.Actions, Vcl.ActnList, Vcl.ImgList, Vcl.ToolWin,
  Vcl.ComCtrls,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  Generics.Collections,
  Delphinus.PackageDetailView;

type
  TDelphinusDialog = class(TForm)
    ToolBar1: TToolBar;
    imgMenu: TImageList;
    DialogActions: TActionList;
    ToolButton1: TToolButton;
    actRefresh: TAction;
    procedure actRefreshExecute(Sender: TObject);
  private
    { Private declarations }
    FOverView: TPackageOverView;
    FDetailView: TPackageDetailView;
    FPackageProvider: IDNPackageProvider;
    FPackages: TList<IDNPackage>;
    procedure HandleSelectedPackageChanged(Sender: TObject);
    procedure HandleInstallPackage(Sender: TObject);
    procedure HandleUninstallPackage(Sender: TObject);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy(); override;
  end;

var
  DelphinusDialog: TDelphinusDialog;

implementation

uses
  IOUtils,
  DN.PackageProvider,
  Delphinus.SetupDialog,
  DN.Compiler.Intf,
  DN.Compiler.MSBuild,
  DN.Installer.Intf,
  DN.Installer;

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
  end;
end;

constructor TDelphinusDialog.Create(AOwner: TComponent);
begin
  inherited;
  FOverView := TPackageOverView.Create(Self);
  FOverView.Align := alClient;
  FOverView.Parent := Self;
  FOverView.OnSelectedPackageChanged := HandleSelectedPackageChanged;
  FOverView.BorderStyle := bsSingle;
  FDetailView := TPackageDetailView.Create(Self);
  FDetailView.Align := alRight;
  FDetailView.AlignWithMargins := True;
  FDetailView.btnInstall.OnClick := HandleInstallPackage;
  FDetailView.btnUninstall.OnClick := HandleUninstallPackage;
  FDetailView.Parent := Self;
  FPackages := TList<IDNPackage>.Create();
  FPackageProvider := TDNPackageProvider.Create();
end;

destructor TDelphinusDialog.Destroy;
begin
  FPackages.Free;
  FPackageProvider := nil;
  inherited;
end;

procedure TDelphinusDialog.HandleInstallPackage(Sender: TObject);
var
  LDialog: TSetupDialog;
  LCompiler: IDNCompiler;
  LInstaller: IDNInstaller;
begin
  if Assigned(FOverView.SelectedPackage) then
  begin
    LDialog := TSetupDialog.Create(nil);
    try
      LCompiler := TDNMSBuildCompiler.Create(GetEnvironmentVariable('BDSBIN'));
      LCompiler.BPLOutput := TPath.Combine(GetEnvironmentVariable('BDSCOMMONDIR'), 'Bpl');
      LCompiler.DCPOutput := TPath.Combine(GetEnvironmentVariable('BDSCOMMONDIR'), 'Dcp');
      LInstaller := TDNInstaller.Create(LCompiler, Trunc(CompilerVersion));
      LDialog.ExecuteInstallation(FOverView.SelectedPackage, FPackageProvider, LInstaller,
        TPath.Combine(GetEnvironmentVariable('BDSCOMMONDIR'), 'Comps'));
    finally
      LDialog.Free;
    end;
  end;
end;

procedure TDelphinusDialog.HandleSelectedPackageChanged(Sender: TObject);
begin
  FDetailView.Package := FOverView.SelectedPackage;
end;

procedure TDelphinusDialog.HandleUninstallPackage(Sender: TObject);
begin

end;

end.
