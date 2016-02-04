unit Delphinus.WebSetup.Dialog;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Delphinus.DelphiInstallation.View,
  DN.DelphiInstallation.Provider.Intf, DN.PackageProvider.Intf, ExtCtrls, StdCtrls, jpeg, ImgList,
  Generics.Collections,
  DN.Package.Intf,
  DN.Types,
  DN.Progress.Intf;

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
    procedure btnBackClick(Sender: TObject);
    procedure btnCacnelClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure edInstallDirectoryRightButtonClick(Sender: TObject);
    procedure btnShowLogClick(Sender: TObject);
  private
    { Private declarations }
    FProvider: IDNDelphiInstallationProvider;
    FPackageProvider: IDNPackageProvider;
    FPackage: IDNPackage;
    FEnterPage: TDictionary<TTabSheet, TProc>;
    FCanExitPage: TDictionary<TTabSheet, TFunc<Boolean>>;
    FProgress: IDNProgress;
    FLog: TStringList;
    procedure InstallDelphinusAsync;
    procedure InstallationFinished;
    procedure HandleSetupProgress(const Task, Item: string; Progress, Max: Int64);
    procedure HandleTotalProgress(const Task, Item: string; Progress, Max: Int64);
    procedure HandleSetupMessage(AMessageType: TMessageType; const AMessage: string);
    procedure PageChanged;
    procedure PageEnter;
    function CanExitPage: Boolean;
  //PageEventHandlers
    procedure DelphiSelectionEnter;
    procedure SettingsEnter;
    procedure ProgressEnter;
    function DelphiSelectionCanExit: Boolean;
    function SettingsCanExit: Boolean;
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
  DN.DelphiInstallation.Intf,
  DN.DelphiInstallation.Provider,
  DN.PackageProvider.GitHubRepo,
  DN.HttpClient.Intf,
  DN.HttpClient.WinHttp,
  DN.Setup.Intf,
  DN.Compiler.Intf,
  DN.Compiler.MSBuild,
  DN.Installer.Intf,
  DN.Installer.Delphinus,
  DN.Progress,
  Delphinus.WebSetup;

{$R *.dfm}

{ TDNWebSetupDialog }

procedure TDNWebSetupDialog.btnBackClick(Sender: TObject);
begin
  pcSteps.ActivePageIndex := pcSteps.ActivePageIndex - 1;
  PageChanged();
end;

procedure TDNWebSetupDialog.btnCacnelClick(Sender: TObject);
begin
  Close();
end;

procedure TDNWebSetupDialog.btnNextClick(Sender: TObject);
begin
  if CanExitPage() then
  begin
    if pcSteps.ActivePageIndex < pcSteps.PageCount - 2 then
    begin
      pcSteps.ActivePageIndex := pcSteps.ActivePageIndex + 1;
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

constructor TDNWebSetupDialog.Create(AOwner: TComponent);
begin
  inherited;
  FProvider := TDNDelphiInstallationProvider.Create();
  FPackageProvider := TDNGithubRepoPackageProvider.Create(TDNWinHttpClient.Create() as IDNHttpClient, 'Memnarch', 'Delphinus');
  FEnterPage := TDictionary<TTabSheet, TProc>.Create();
  FCanExitPage := TDictionary<TTabSheet, TFunc<Boolean>>.Create();
  InstallationView.Installations.AddRange(FProvider.Installations);
  edInstallDirectory.Text := TPath.Combine(GetEnvironmentVariable('ProgramFiles'), 'Delphinus');
  FEnterPage.Add(tsDelphiSelection, DelphiSelectionEnter);
  FEnterPage.Add(tsSettings, SettingsEnter);
  FEnterPage.Add(tsProgress, ProgressEnter);
  FCanExitPage.Add(tsDelphiSelection, DelphiSelectionCanExit);
  FCanExitPage.Add(tsSettings, SettingsCanExit);
  pcSteps.ActivePageIndex := 0;
  FProgress := TDNProgress.Create();
  FProgress.OnProgress := HandleTotalProgress;
  FLog := TStringList.Create();
  PageChanged();
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
begin
  btnNext.Caption := 'Next';
  if not Assigned(FPackage) and FPackageProvider.Reload() and (FPackageProvider.Packages.Count = 1) then
  begin
    FPackage := FPackageProvider.Packages[0];
    Image1.Picture := FPackage.Picture;
  end;
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

procedure TDNWebSetupDialog.HandleSetupMessage(AMessageType: TMessageType;
  const AMessage: string);
var
  LPrefix: string;
begin
  case AMessageType of
    mtNotification: LPrefix := '<Info> ';
    mtWarning: LPrefix := '<Warning> ';
    mtError: LPrefix := '<Error> ';
  else
    LPrefix := '<?> ';
  end;
  FLog.Add(LPrefix + AMessage);
end;

procedure TDNWebSetupDialog.HandleSetupProgress(const Task, Item: string;
  Progress, Max: Int64);
begin
  if Item <> '' then
    FProgress.SetTaskProgress(Item, Progress, Max)
  else
    FProgress.SetTaskProgress(Task, Progress, Max);
end;

procedure TDNWebSetupDialog.HandleTotalProgress(const Task, Item: string;
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

procedure TDNWebSetupDialog.InstallationFinished;
begin
  btnNext.Caption := 'Finish';
  btnNext.Enabled := True;
  btnShowLog.Visible := True;
end;

procedure TDNWebSetupDialog.InstallDelphinusAsync;
var
  LInstallation: IDNDelphiInstallation;
  LSetup: IDNSetup;
  LInstaller: IDNInstaller;
  LCompiler: IDNCompiler;
begin
  CoInitialize(nil);
  try
    FProgress.SetTasks([]);
    for LInstallation in InstallationView.SelectedInstallations do
      FProgress.AddTask(LInstallation.Name);

    for LInstallation in InstallationView.SelectedInstallations do
    begin
      FLog.Add('<Setup> ' + LInstallation.Name);
      LCompiler := TDNMSBuildCompiler.Create(TPath.Combine(LInstallation.Directory, 'bin'));
      LInstaller := TDNDelphinusInstaller.Create(LCompiler, LInstallation.Root);
      LSetup := TDNDelphinusWebSetup.Create(LInstaller, nil, FPackageProvider, LInstallation.Root);
      LSetup.ComponentDirectory := edInstallDirectory.Text;
      LSetup.OnProgress := HandleSetupProgress;
      LSetup.OnMessage := HandleSetupMessage;
      LSetup.Install(FPackage, nil);
      FProgress.NextTask();
    end;
    FProgress.Completed();
  finally
    TThread.Queue(nil, InstallationFinished);
    CoUninitialize();
  end;
end;

procedure TDNWebSetupDialog.PageChanged;
begin
  lbTitle.Caption := pcSteps.ActivePage.Caption;
  btnBack.Enabled := (pcSteps.ActivePageIndex > 0) and (pcSteps.ActivePageIndex < tsLog.PageIndex);
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
  TThread.CreateAnonymousThread(InstallDelphinusAsync).Start();
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
