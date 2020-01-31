{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit Delphinus.SetupDialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Package.Version.Intf,
  DN.Package.DirectoryLoader.Intf,
  DN.Setup.Dependency.Resolver.Intf,
  DN.Setup.Dependency.Intf,
  DN.Setup.Dependency.Processor.Intf,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  StdCtrls,
  DN.Types,
  DN.Setup.Intf,
  Delphinus.Forms,
  ComCtrls,
  ExtCtrls,
  DN.ComCtrls.Helper,
  ImgList
{$IFDEF CONDITIONALEXPRESSIONS}
{$IF CompilerVersion >= 29.0}
   , System.ImageList
{$IFEND}
{$ENDIF};

const
  CStart = WM_USER + 1;

type
  TSetupDialogMode = (sdmInstall, sdmInstallDirectory, sdmUninstall, sdmUninstallDirectory, sdmUpdate);

  TSetupDialog = class(TForm)
    mLog: TMemo;
    pcSteps: TPageControl;
    tsMainPage: TTabSheet;
    tsLog: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    Image1: TImage;
    lbNameInstallUpdate: TLabel;
    cbVersion: TComboBox;
    Label1: TLabel;
    lbLicenseAnotation: TLabel;
    Label3: TLabel;
    lbLicenseType: TLabel;
    btnLicense: TButton;
    tsProgress: TTabSheet;
    pbProgress: TProgressBar;
    btnCloseProgress: TButton;
    lbAction: TLabel;
    btnShowLog: TButton;
    ilButtons: TImageList;
    btnDependencies: TButton;
    cbIgnoreDependencies: TCheckBox;
    procedure HandleOK(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnLicenseClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnShowLogClick(Sender: TObject);
    procedure cbVersionChange(Sender: TObject);
    procedure btnDependenciesClick(Sender: TObject);
  private
    { Private declarations }
    FMode: TSetupDialogMode;
    FPackage: IDNPackage;
    FInstalledComponentDirectory: string;
    FDirectoryToInstall: string;
    FSetup: IDNSetup;
    FSetupIsRunning: Boolean;
    FLoader: IDNPackageDirectoryLoader;
    FDependencyResolver: IDNSetupDependencyResolver;
    FDependencies: TArray<IDNSetupDependency>;
    FDependencyCount: Integer;
    FDependencyProcessor: IDNSetupDependencyProcessor;
    procedure Log(const AMessage: string);
    procedure HandleLogMessage(AType: TMessageType; const AMessage: string);
    procedure HandleProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    procedure HandleDependencyProgress(const ATask, AItem: string; AProgress, AMax: Int64);
    procedure InitMainPage();
    procedure InitVersionSelection();
    procedure Execute();
    procedure SetupFinished;
    function GetSelectedVersion: IDNPackageVersion;
    function LoadPackage(const ADirectory: string): IDNPackage;
    procedure ResolvelDependencies;
  public
    { Public declarations }
    constructor Create(const ASetup: IDNSetup;
      const ADependencyResolver: IDNSetupDependencyResolver;
      const ADependencyProcessor: IDNSetupDependencyProcessor); reintroduce;
    function ExecuteInstallation(const APackage: IDNPackage): Boolean;
    function ExecuteInstallationFromDirectory(const ADirectory: string): Boolean;
    function ExecuteUninstallation(const APackage: IDNPackage): Boolean;
    function ExecuteUninstallationFromDirectory(const ADirectory: string): Boolean;
    function ExecuteUpdate(const APackage: IDNPackage): Boolean;
  end;

var
  SetupDialog: TSetupDialog;

implementation

uses
  IOUtils,
  StrUtils,
  DN.JSonFile.InstalledInfo,
  Delphinus.LicenseDialog,
  Delphinus.Resources.Names,
  Delphinus.Resources,
  DN.Package.DirectoryLoader,
  DN.Package,
  Delphinus.DependencyDialog;

{$R *.dfm}

{ TSetupDialog }

procedure TSetupDialog.btnDependenciesClick(Sender: TObject);
var
  LDialog: TDependencyDialog;
begin
  LDialog := TDependencyDialog.Create(nil);
  try
    LDialog.Dependencies := FDependencies;
    LDialog.ShowModal();
  finally
    LDialog.Free();
  end;
end;

procedure TSetupDialog.btnLicenseClick(Sender: TObject);
var
  LDialog: TLicenseDialog;
begin
  LDialog := TLicenseDialog.Create(nil);
  try
    LDialog.Package := FPackage;
    LDialog.ShowModal();
  finally
    LDialog.Free;
  end;
end;

procedure TSetupDialog.btnShowLogClick(Sender: TObject);
begin
  pcSteps.ActivePage := tsLog;
end;

procedure TSetupDialog.cbVersionChange(Sender: TObject);
begin
  if cbVersion.ItemIndex > -1 then
  begin
    ResolvelDependencies();
  end
  else
  begin
    btnDependencies.Enabled := False;
  end;
end;

constructor TSetupDialog.Create(const ASetup: IDNSetup;
  const ADependencyResolver: IDNSetupDependencyResolver;
  const ADependencyProcessor: IDNSetupDependencyProcessor);
begin
  inherited Create(nil);
  FDependencyResolver := ADependencyResolver;
  FDependencyProcessor := ADependencyProcessor;
  FDependencyProcessor.OnMessage := HandleLogMessage;
  FDependencyProcessor.OnProgress := HandleDependencyProgress;
  FSetup := ASetup;
  FSetup.OnMessage := HandleLogMessage;
  FSetup.OnProgress := HandleProgress;
  btnLicense.ImageIndex := AddIconToImageList(ilButtons, Ico_Agreement);
  btnLicense.DisabledImageIndex := AddIconToImageList(ilButtons, Ico_Agreement_Disabled);
  btnDependencies.ImageIndex := AddIconToImageList(ilButtons, Ico_Dependencies);
  btnDependencies.DisabledImageIndex := AddIconToImageList(ilButtons, Ico_Dependencies_Disabled);
end;

procedure TSetupDialog.Execute;
var
  LThread: TThread;
  LError: string;
begin
  FSetupIsRunning := True;
  mLog.Clear;
  pbProgress.Position := 0;
  pbProgress.State := pbsNormal;
  pcSteps.ActivePage := tsProgress;
  LThread := TThread.CreateAnonymousThread(
    procedure
    begin
      try
        if cbIgnoreDependencies.Checked or FDependencyProcessor.Execute(FDependencies) then
        begin
          case FMode of
            sdmInstall: FSetup.Install(FPackage, GetSelectedVersion());
            sdmInstallDirectory: FSetup.InstallDirectory(FDirectoryToInstall);
            sdmUninstall: FSetup.Uninstall(FPackage);
            sdmUninstallDirectory: FSetup.UninstallDirectory(FInstalledComponentDirectory);
            sdmUpdate: FSetup.Update(FPackage, GetSelectedVersion());
          end;
        end;
      except
        on E: Exception do
          LError := E.ToString;
      end;
      if LError <> '' then
        TThread.Synchronize(nil, procedure begin HandleLogMessage(mtError, LError) end);
      TThread.Synchronize(nil, SetupFinished);
    end);
  LThread.Start;
end;

function TSetupDialog.ExecuteInstallation(const APackage: IDNPackage): Boolean;
begin
  FPackage := APackage;
  FMode := sdmInstall;
  Result := ShowModal() <> mrCancel;
end;

function TSetupDialog.ExecuteInstallationFromDirectory(
  const ADirectory: string): Boolean;
begin
  FDirectoryToInstall := ADirectory;
  FMode := sdmInstallDirectory;
  FPackage := LoadPackage(ADirectory);
  Result := ShowModal() <> mrCancel;
end;

function TSetupDialog.ExecuteUninstallation(const APackage: IDNPackage): Boolean;
begin
  FPackage := APackage;
  FMode := sdmUninstall;
  Result := ShowModal() <> mrCancel;;
end;

function TSetupDialog.ExecuteUninstallationFromDirectory(
  const ADirectory: string): Boolean;
begin
  FInstalledComponentDirectory := ADirectory;
  FMode := sdmUninstallDirectory;
  FPackage := LoadPackage(ADirectory);
  Result := ShowModal() <> mrCancel;
end;

function TSetupDialog.ExecuteUpdate(const APackage: IDNPackage): Boolean;
begin
  FPackage := APackage;
  FMode := sdmUpdate;
  Result := ShowModal() <> mrCancel;
end;

procedure TSetupDialog.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not FSetupIsRunning;
  if not CanClose then
    MessageDlg('You can not close the dialog while the setup is running, please wait', mtInformation, [mbOK], 0)
  else if (ModalResult = mrCancel) and (pcSteps.ActivePageIndex > 0) then
    ModalResult := mrOk;
end;

procedure TSetupDialog.FormShow(Sender: TObject);
begin
  InitMainPage();
end;

function TSetupDialog.GetSelectedVersion: IDNPackageVersion;
begin
  if Assigned(FPackage) and (cbVersion.ItemIndex > -1) then
    Result := FPackage.Versions[cbVersion.ItemIndex]
  else
    Result := nil;
end;

procedure TSetupDialog.HandleDependencyProgress(const ATask, AItem: string;
  AProgress, AMax: Int64);
begin
  TThread.Queue(nil,
  procedure
  begin
    lbAction.Caption := ATask + ' ' + AItem;
    pbProgress.Position := Round(AProgress / AMax * pbProgress.Max / (FDependencyCount + 1) * FDependencyCount);
  end
  );
end;

procedure TSetupDialog.HandleLogMessage(AType: TMessageType;
  const AMessage: string);
begin
  TThread.Synchronize(nil,
    procedure
    begin
      case AType of
        mtNotification: Log(AMessage);
        mtWarning: Log('Warning: ' + AMessage);
        mtError:
        begin
          Log('Error: ' + AMessage);
          pbProgress.State := pbsError;
        end;
      end;
    end
  );
end;

procedure TSetupDialog.HandleOK(Sender: TObject);
begin
  Execute();
end;

procedure TSetupDialog.HandleProgress(const ATask, AItem: string; AProgress, AMax: Int64);
begin
  TThread.Queue(nil,
  procedure
  var
    LBase: Single;
    LScale: Single;
    LElements: Integer;
  begin
    lbAction.Caption := IfThen(AItem <> '', AItem, ATask);
    LElements := FDependencyCount + 1;
    if LElements > 1 then
    begin
      LBase := pbProgress.Max / LElements * FDependencyCount;
    end
    else
    begin
      LBase := 0;
    end;
    LScale := 1 / LElements;
    pbProgress.Position := Round(LBase + (AProgress / AMax * pbProgress.Max * LScale));
  end
  );
end;

procedure TSetupDialog.InitMainPage;
begin
  pcSteps.ActivePage := tsMainPage;
  if not Assigned(FPackage) then
    Exit;
  case FMode of
    sdmInstall, sdmInstallDirectory:
    begin
      btnOK.Caption := 'Install';
      lbNameInstallUpdate.Caption := FPackage.Name;
      lbLicenseType.Caption := FPackage.LicenseTypes;
      btnLicense.Enabled := lbLicenseType.Caption <> '';
      if Assigned(FPackage.Picture) then
        Image1.Picture.Assign(FPackage.Picture);
      InitVersionSelection();
    end;

    sdmUninstall, sdmUninstallDirectory:
    begin
      btnOK.Caption := 'Uninstall';
      lbNameInstallUpdate.Caption := FPackage.Name;
      lbLicenseType.Caption := FPackage.LicenseTypes;
      if Assigned(FPackage.Picture) then
        Image1.Picture.Assign(FPackage.Picture);
      cbVersion.Enabled := False;
      btnLicense.Enabled := False;
      lbLicenseAnotation.Visible := False;
      ResolvelDependencies();
    end;

    sdmUpdate:
    begin
      btnOK.Caption := 'Update';
      lbNameInstallUpdate.Caption := FPackage.Name;
      if Assigned(FPackage.Picture) then
        Image1.Picture.Assign(FPackage.Picture);
      InitVersionSelection();
    end;
  end;
end;

procedure TSetupDialog.InitVersionSelection;
var
  i: Integer;
begin
  cbVersion.Enabled := (FPackage.Versions.Count > 0) and (not FPackage.Versions.First.Value.IsEmpty);
  for i := 0 to FPackage.Versions.Count - 1 do
  begin
    cbVersion.Items.Add(FPackage.Versions[i].Name);
  end;
  cbVersion.ItemIndex := 0;
  cbVersionChange(cbVersion);
end;

function TSetupDialog.LoadPackage(const ADirectory: string): IDNPackage;
begin
  if not Assigned(FLoader) then
    FLoader := TDNPackageDirectoryLoader.Create();
  Result := TDNPackage.Create();
  FLoader.Load(ADirectory, Result);
end;

procedure TSetupDialog.Log(const AMessage: string);
begin
  mLog.Lines.Add(AMessage);
end;

procedure TSetupDialog.ResolvelDependencies;
var
  LDependency: IDNSetupDependency;
begin
  FDependencyCount := 0;
  if cbVersion.ItemIndex > -1 then
    FDependencies := FDependencyResolver.Resolve(FPackage, FPackage.Versions[cbVersion.ItemIndex])
  else
    FDependencies := FDependencyResolver.Resolve(FPackage, FPackage.Versions.First);
  for LDependency in FDependencies do
      if LDependency.Action <> daNone then
        Inc(FDependencyCount);
  btnDependencies.Enabled := Length(FDependencies) > 0;
  cbIgnoreDependencies.Enabled := btnDependencies.Enabled;
end;

procedure TSetupDialog.SetupFinished;
begin
  btnCloseProgress.Enabled := True;
  btnShowLog.Enabled := True;
  FSetupIsRunning := False;
  if FSetup.HasPendingChanges then
    MessageDlg('Some changes require an IDE restart to take effect', mtInformation, [mbOK], 0);
end;

end.
