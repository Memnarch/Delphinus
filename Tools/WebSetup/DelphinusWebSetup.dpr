program DelphinusWebSetup;

uses
  Forms,
  Delphinus.WebSetup.Dialog in 'Delphinus.WebSetup.Dialog.pas' {DNWebSetupDialog},
  Delphinus.DelphiInstallation.View in '..\..\Packages\Delphinus.DelphiInstallation.View.pas' {DelphiInstallationView: TFrame},
  DN.DelphiInstallation.Intf in '..\..\DN.DelphiInstallation.Intf.pas',
  DN.DelphiInstallation in '..\..\DN.DelphiInstallation.pas',
  DN.DelphiInstallation.Provider.Intf in '..\..\DN.DelphiInstallation.Provider.Intf.pas',
  DN.DelphiInstallation.Provider in '..\..\DN.DelphiInstallation.Provider.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDNWebSetupDialog, DNWebSetupDialog);
  Application.Run;
end.
