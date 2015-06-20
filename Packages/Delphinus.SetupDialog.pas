unit Delphinus.SetupDialog;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  DN.PackageProvider.Intf,
  DN.Package.Intf,
  DN.Installer.Intf, Vcl.StdCtrls,
  DN.Types;

const
  CStart = WM_USER + 1;

type
  TSetupDialogMode = (sdmInstall, sdmUninstall);

  TSetupDialog = class(TForm)
    mLog: TMemo;
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    FMode: TSetupDialogMode;
    FPackage: IDNPackage;
    FProvider: IDNPackageProvider;
    FInstaller: IDNInstaller;
    FComponentDirectory: string;
    procedure HandleCustomMessage(var AMSG: TMessage); message CStart;
    procedure Install;
    procedure Uninstall;
    procedure Log(const AMessage: string);
    procedure HandleLogMessage(AType: TMessageType; const AMessage: string);
  public
    { Public declarations }
    procedure ExecuteInstallation(const APackage: IDNPackage; AProvider: IDNPackageProvider; AInstaller: IDNInstaller; const AComponentDirectory: string);
  end;

var
  SetupDialog: TSetupDialog;

implementation

uses
  IOUtils;

{$R *.dfm}

{ TSetupDialog }

procedure TSetupDialog.ExecuteInstallation(const APackage: IDNPackage;
  AProvider: IDNPackageProvider; AInstaller: IDNInstaller; const AComponentDirectory: string);
begin
  FPackage := APackage;
  FProvider := AProvider;
  FInstaller := AInstaller;
  FComponentDirectory := AComponentDirectory;
  FMode := sdmInstall;
  ShowModal();
end;

procedure TSetupDialog.FormShow(Sender: TObject);
begin
  PostMessage(Handle, CStart, 0, 0);
end;

procedure TSetupDialog.HandleCustomMessage(var AMSG: TMessage);
begin
  case FMode of
    sdmInstall: Install;
    sdmUninstall: Uninstall;
  end;
end;

procedure TSetupDialog.HandleLogMessage(AType: TMessageType;
  const AMessage: string);
begin
  case AType of
    mtNotification: Log(AMessage);
    mtWarning: Log('Warning: ' + AMessage);
    mtError: Log('Error: ' + AMessage);
  end;
end;

procedure TSetupDialog.Install;
var
  LTempDir, LContentDir: string;
  LError: Boolean;
begin
  mLog.Clear;
  LError := False;
  Log('Downloading ' + FPackage.Name);
  LTempDir := TPath.Combine(GetEnvironmentVariable('Temp'), 'Delphinus');
  ForceDirectories(LTempDir);
  if FProvider.Download(FPackage, LTempDir, LContentDir) then
  begin
    Log('installing...');
    FInstaller.OnMessage := HandleLogMessage;
    if not FInstaller.Install(LContentDir, TPath.Combine(FComponentDirectory, FPackage.Name)) then
    begin
      Log('installation failed');
      LError := True;
    end;
  end
  else
  begin
    Log('failed to download');
    LError := True;
  end;
  Log('cleaning tempfiles');
  TDirectory.Delete(LTempDir, True);
//  if not LError then
//  begin
//    ModalResult := mrOk;
//  end;
end;

procedure TSetupDialog.Log(const AMessage: string);
begin
  mLog.Lines.Add(AMessage);
end;

procedure TSetupDialog.Uninstall;
begin

end;

end.
