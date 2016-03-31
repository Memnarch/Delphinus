unit Delphinus.WebSetup.Dialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Delphinus.DelphiInstallation.View,
  DN.DelphiInstallation.Provider.Intf, DN.PackageProvider.Intf, ExtCtrls, StdCtrls, jpeg, ImgList,
  Generics.Collections,
  DN.Package.Intf,
  DN.Types,
  DN.Progress.Intf,
  DN.Settings.Intf,
  DN.DelphiInstallation.Intf,
  DN.Setup.Intf,
  Buttons, ActnList, System.Actions, Vcl.Imaging.pngimage;

type
  TDNWebSetupDialog = class(TForm)
    pcSteps: TPageControl;
    tsDelphiSelection: TTabSheet;
    tsSettings: TTabSheet;
    InstallationView: TDelphiInstallationView;
    Image1: TImage;
    pnlHeader: TPanel;
    lbTitle: TLabel;
    pnlButtons: TPanel;
    btnCacnel: TButton;
    btnNext: TButton;
    btnBack: TButton;
    edInstallDirectory: TButtonedEdit;
    ilImages: TImageList;
    Label1: TLabel;
    OpenDialog: TFileOpenDialog;
    tsProgress: TTabSheet;
    pbProgress: TProgressBar;
    lbTask: TLabel;
    mLog: TMemo;
    btnShowLog: TButton;
    tsLog: TTabSheet;
    tsRoutineSelection: TTabSheet;
    rbInstall: TRadioButton;
    rbUninstall: TRadioButton;
    Image2: TImage;
    Image3: TImage;
    cbVersions: TComboBox;
    Label2: TLabel;
    cbNoVersion: TCheckBox;
    procedure btnBackClick(Sender: TObject);
    procedure btnCacnelClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure edInstallDirectoryRightButtonClick(Sender: TObject);
    procedure btnShowLogClick(Sender: TObject);
    procedure cbNoVersionClick(Sender: TObject);
  private
    { Private declarations }
    FProvider: IDNDelphiInstallationProvider;
    FPackageProvider: IDNPackageProvider;
    FPackage: IDNPackage;
    FEnterPage: TDictionary<TTabSheet, TProc>;
    FCanExitPage: TDictionary<TTabSheet, TFunc<Boolean>>;
    FSettings: IDNElevatedSettings;
    FLog: TStringList;
    procedure FillVersions;
    procedure LoadPackage;
    procedure RunSetupAsync;
    procedure SetupFinished;
    procedure HandleSetupProgress(const Task, Item: string; Progress, Max: Int64);
    procedure HandleSetupMessage(AMessageType: TMessageType; const AMessage: string);
    procedure HandleCheckInstalled(const AInstallation: IDNDelphiInstallation; var AIsChecked: Boolean);
    procedure PageChanged;
    procedure PageEnter;
    function CanExitPage: Boolean;
    function IsDelphinusInstalled(const ADelphi: IDNDelphiInstallation): Boolean;
    function CreateSetup(const AInstallations: TArray<IDNDelphiInstallation>): IDNSetup;
  //PageEventHandlers
    procedure RoutineSelectionEnter;
    procedure DelphiSelectionEnter;
    procedure SettingsEnter;
    procedure ProgressEnter;
    function RoutineSelectionCanExit: Boolean;
    function DelphiSelectionCanExit: Boolean;
    function SettingsCanExit: Boolean;
    function GetNextActivePage: Integer;
    function GetPreviousActivePage: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  DNWebSetupDialog: TDNWebSetupDialog;

implementation

uses
  IOUtils,
  ActiveX,
  DN.DelphiInstallation.Provider,
  DN.PackageProvider.GitHubRepo,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.Compiler.Intf,
  DN.Compiler.MSBuild,
  DN.Installer.Intf,
  DN.Uninstaller.Intf,
  DN.Installer.Delphinus,
  DN.Uninstaller.Delphinus,
  DN.Progress,
  DN.Settings,
  DN.Package.Version.Intf,
  Delphinus.WebSetup;

{$R *.dfm}

{ TDNWebSetupDialog }

procedure TDNWebSetupDialog.btnBackClick(Sender: TObject);
begin
  pcSteps.ActivePageIndex := GetPreviousActivePage();;
  PageChanged();
end;

procedure TDNWebSetupDialog.btnCacnelClick(Sender: TObject);
begin
  Close();
end;

procedure TDNWebSetupDialog.btnNextClick(Sender: TObject);
var
  LNext: Integer;
begin
  if CanExitPage() then
  begin
    LNext := GetNextActivePage();
    if LNext < pcSteps.PageCount - 1 then
    begin
      pcSteps.ActivePageIndex := LNext;
      PageChanged();
    end
    else
      Close();
  end;
end;

procedure TDNWebSetupDialog.btnShowLogClick(Sender: TObject);
begin
  mLog.Lines.Assign(FLog);
  pcSteps.ActivePageIndex := pcSteps.ActivePageIndex + 1;
  PageChanged();
end;

function TDNWebSetupDialog.CanExitPage: Boolean;
var
  LFunc: TFunc<Boolean>;
begin
  Result := not FCanExitPage.TryGetValue(pcSteps.ActivePage, LFunc);
  if not Result then
    Result := LFunc();
end;

procedure TDNWebSetupDialog.cbNoVersionClick(Sender: TObject);
begin
  cbVersions.Enabled := not cbNoVersion.Checked;
end;

constructor TDNWebSetupDialog.Create(AOwner: TComponent);
begin
  inherited;
  FProvider := TDNDelphiInstallationProvider.Create();
  FPackageProvider := TDNGithubRepoPackageProvider.Create(TDNWinHttpClient.Create() as IDNHttpClient, 'Memnarch', 'Delphinus');
  FEnterPage := TDictionary<TTabSheet, TProc>.Create();
  FCanExitPage := TDictionary<TTabSheet, TFunc<Boolean>>.Create();

  FEnterPage.Add(tsRoutineSelection, RoutineSelectionEnter);
  FEnterPage.Add(tsDelphiSelection, DelphiSelectionEnter);
  FEnterPage.Add(tsSettings, SettingsEnter);
  FEnterPage.Add(tsProgress, ProgressEnter);
  FCanExitPage.Add(tsRoutineSelection, RoutineSelectionCanExit);
  FCanExitPage.Add(tsDelphiSelection, DelphiSelectionCanExit);
  FCanExitPage.Add(tsSettings, SettingsCanExit);

  FLog := TStringList.Create();
  FSettings := TDNSettings.Create();
  if FSettings.InstallationDirectory <> '' then
  begin
    edInstallDirectory.Text := FSettings.InstallationDirectory;
    edInstallDirectory.Enabled := False;
    pcSteps.ActivePageIndex := 0;
    tsRoutineSelection.Enabled := True;
  end
  else
  begin
    edInstallDirectory.Text := TPath.Combine(GetEnvironmentVariable('ProgramFiles'), 'Delphinus');
    pcSteps.ActivePageIndex := 1;
    tsRoutineSelection.Enabled := False;
  end;
  InstallationView.OnCheckInstalled := HandleCheckInstalled;
  LoadPackage();
  PageChanged();
end;

function TDNWebSetupDialog.CreateSetup(
  const AInstallations: TArray<IDNDelphiInstallation>): IDNSetup;
var
  LInstallers: TArray<IDNInstaller>;
  LUninstallers: TArray<IDNUninstaller>;
  LSubFolders: TArray<string>;
  LCompiler: IDNCompiler;
  i: Integer;
begin
  SetLength(LInstallers, Length(AInstallations));
  SetLength(LUninstallers, Length(AInstallations));
  SetLength(LSubFolders, Length(AInstallations));
  for i := 0 to High(LInstallers) do
  begin
    LCompiler := TDNMSBuildCompiler.Create(TPath.Combine(AInstallations[i].Directory, 'bin'));
    LInstallers[i] := TDNDelphinusInstaller.Create(LCompiler, AInstallations[i].Root);
    LUninstallers[i] := TDNDelphinusUninstaller.Create(AInstallations[i].Root);
    LSubFolders[i] := AInstallations[i].BDSVersion;
  end;
  Result := TDNDelphinusWebSetup.Create(LInstallers, LUninstallers, FPackageProvider, FSettings, LSubFolders);
  Result.ComponentDirectory := edInstallDirectory.Text;
  Result.OnProgress := HandleSetupProgress;
  Result.OnMessage := HandleSetupMessage;
end;

function TDNWebSetupDialog.DelphiSelectionCanExit: Boolean;
var
  LInstallation: IDNDelphiInstallation;
begin
  Result := InstallationView.SelectedInstallations.Count > 0;
  if not Result then
  begin
    MessageDlg('You must select at least one Delphi-Installation.', mtInformation, [mbOK], 0);
    Exit;
  end;

  if not IsDebuggerPresent then
  begin
    for LInstallation in InstallationView.SelectedInstallations do
    begin
      if LInstallation.IsRunning then
      begin
        MessageDlg(LInstallation.Name + ' is running. Please close all running Delphi-Instances before you continue', mtInformation, [mbOK], 0);
        Exit(False);
      end;
    end;
  end;
end;

procedure TDNWebSetupDialog.DelphiSelectionEnter;
var
  LInstallation: IDNDelphiInstallation;
begin
  InstallationView.Installations.Clear();
  if rbInstall.Checked then
  begin
    btnNext.Caption := 'Next';
    InstallationView.Installations.AddRange(FProvider.Installations);
  end
  else
  begin
    for LInstallation in FProvider.Installations do
      if IsDelphinusInstalled(LInstallation) then
        InstallationView.Installations.Add(LInstallation);
  end;
  InstallationView.LockInstalled := rbInstall.Checked;
end;

destructor TDNWebSetupDialog.Destroy;
begin
  FEnterPage.Free;
  FCanExitPage.Free;
  FLog.Free;
  inherited;
end;

procedure TDNWebSetupDialog.edInstallDirectoryRightButtonClick(Sender: TObject);
begin
  OpenDialog.DefaultFolder := edInstallDirectory.Text;
  if OpenDialog.Execute() then
    edInstallDirectory.Text := OpenDialog.FileName;
end;

procedure TDNWebSetupDialog.FillVersions;
var
  LVersion: IDNPackageVersion;
begin
  cbVersions.Clear();
  for LVersion in FPackage.Versions do
    cbVersions.Items.Add(LVersion.Name);
  cbVersions.ItemIndex := 0;
  cbNoVersion.Checked := cbVersions.ItemIndex = -1;
  cbNoVersion.Enabled := not cbNoVersion.Checked;
end;

function TDNWebSetupDialog.GetNextActivePage: Integer;
var
  LIndex: Integer;
begin
  Result := pcSteps.ActivePageIndex;
  LIndex := Result;
  while ((LIndex + 1) < pcSteps.PageCount) do
  begin
    Inc(LIndex);
    if pcSteps.Pages[LIndex].Enabled then
      Exit(LIndex);
  end;
end;

function TDNWebSetupDialog.GetPreviousActivePage: Integer;
var
  LIndex: Integer;
begin
  Result := pcSteps.ActivePageIndex;
  LIndex := Result;
  while LIndex > 0 do
  begin
    Dec(LIndex);
    if pcSteps.Pages[LIndex].Enabled then
      Exit(LIndex);
  end;
end;

procedure TDNWebSetupDialog.HandleCheckInstalled(
  const AInstallation: IDNDelphiInstallation; var AIsChecked: Boolean);
begin
  if not AIsChecked then
    AIsChecked := IsDelphinusInstalled(AInstallation);
end;

procedure TDNWebSetupDialog.HandleSetupMessage(AMessageType: TMessageType;
  const AMessage: string);
var
  LPrefix: string;
begin
  case AMessageType of
    mtNotification: LPrefix := '<Info> ';
    mtWarning: LPrefix := '<Warning> ';
    mtError:
    begin
      LPrefix := '<Error> ';
      pbProgress.State := pbsError;
    end;
  else
    LPrefix := '<?> ';
  end;
  FLog.Add(LPrefix + AMessage);
end;

procedure TDNWebSetupDialog.HandleSetupProgress(const Task, Item: string;
  Progress, Max: Int64);
begin
  TThread.Queue(nil,
    procedure
    begin
      pbProgress.Max := Max;
      pbProgress.Position := Progress;
      if Item <> '' then
        lbTask.Caption := Task + ': ' + Item
      else
        lbTask.Caption := Task;
    end
  );
end;

procedure TDNWebSetupDialog.SetupFinished;
begin
  btnNext.Caption := 'Finish';
  btnNext.Enabled := True;
  btnShowLog.Visible := True;
end;

procedure TDNWebSetupDialog.RunSetupAsync;
var
  LSetup: IDNSetup;
begin
  CoInitialize(nil);
  try
    try
      LSetup := CreateSetup(InstallationView.SelectedInstallations.ToArray);
      if rbInstall.Checked then
      begin
        if cbNoVersion.Checked then
          LSetup.Install(FPackage, nil)
        else
          LSetup.Install(FPackage, FPackage.Versions[cbVersions.ItemIndex]);
      end
      else
        LSetup.Uninstall(FPackage);
    except
      on E: Exception do
        HandleSetupMessage(mtError, E.ToString);
    end;
  finally
    TThread.Queue(nil, SetupFinished);
    CoUninitialize();
  end;
end;

function TDNWebSetupDialog.IsDelphinusInstalled(
  const ADelphi: IDNDelphiInstallation): Boolean;
var
  LDir: string;
begin
  LDir := TPath.Combine(FSettings.InstallationDirectory, ADelphi.BDSVersion);
  Result := TFile.Exists(TPath.Combine(LDir, CUninstallFile));
end;

procedure TDNWebSetupDialog.LoadPackage;
begin
  if not Assigned(FPackage) and FPackageProvider.Reload() and (FPackageProvider.Packages.Count = 1) then
  begin
    FPackage := FPackageProvider.Packages[0];
    Image1.Picture := FPackage.Picture;
    FillVersions();
  end;
end;

procedure TDNWebSetupDialog.PageChanged;
begin
  lbTitle.Caption := pcSteps.ActivePage.Caption;
  btnBack.Enabled := (pcSteps.ActivePageIndex > GetPreviousActivePage())
    and (pcSteps.ActivePageIndex < tsLog.PageIndex);
  PageEnter();
end;

procedure TDNWebSetupDialog.PageEnter;
var
  LProc: TProc;
begin
  if FEnterPage.TryGetValue(pcSteps.ActivePage, LProc) then
    LProc();
end;

procedure TDNWebSetupDialog.ProgressEnter;
begin
  btnBack.Enabled := False;
  btnNext.Enabled := False;
  btnCacnel.Enabled := False;
  TThread.CreateAnonymousThread(RunSetupAsync).Start();
end;

function TDNWebSetupDialog.RoutineSelectionCanExit: Boolean;
begin
  tsSettings.Enabled := rbInstall.Checked;
  if not tsSettings.Enabled then
    btnNext.Caption := 'Uninstall';
  Result := True;
end;

procedure TDNWebSetupDialog.RoutineSelectionEnter;
begin
  btnNext.Caption := 'Next';
end;

function TDNWebSetupDialog.SettingsCanExit: Boolean;
begin
  Result := ForceDirectories(edInstallDirectory.Text);
  if not Result then
    MessageDlg('Could not create directory. Please check your path and permissions', Dialogs.mtError, [mbOK], 0);
end;

procedure TDNWebSetupDialog.SettingsEnter;
begin
  btnNext.Caption := 'Install';
end;

end.
