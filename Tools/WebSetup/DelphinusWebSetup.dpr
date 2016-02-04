program DelphinusWebSetup;

{$R *.dres}

uses
  Forms,
  Delphinus.WebSetup.Dialog in 'Delphinus.WebSetup.Dialog.pas' {DNWebSetupDialog},
  Delphinus.DelphiInstallation.View in '..\..\Packages\Delphinus.DelphiInstallation.View.pas' {DelphiInstallationView: TFrame},
  DN.DelphiInstallation.Intf in '..\..\DN.DelphiInstallation.Intf.pas',
  DN.DelphiInstallation in '..\..\DN.DelphiInstallation.pas',
  DN.DelphiInstallation.Provider.Intf in '..\..\DN.DelphiInstallation.Provider.Intf.pas',
  DN.DelphiInstallation.Provider in '..\..\DN.DelphiInstallation.Provider.pas',
  DN.PackageProvider.GitHub in '..\..\DN.PackageProvider.GitHub.pas',
  DN.PackageProvider.Intf in '..\..\DN.PackageProvider.Intf.pas',
  DN.PackageProvider in '..\..\DN.PackageProvider.pas',
  DN.PackageProvider.GitHubRepo in '..\..\DN.PackageProvider.GitHubRepo.pas',
  DN.Installer.Delphinus in '..\..\DN.Installer.Delphinus.pas',
  Delphinus.WebSetup in 'Delphinus.WebSetup.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDNWebSetupDialog, DNWebSetupDialog);
  Application.Run;
end.
