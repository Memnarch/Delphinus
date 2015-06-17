unit DN.Installer.Intf;

interface

type
  IDNInstaller = interface
    ['{BE1681DA-4DC1-4393-9E7A-050CD63468D2}']
    function Install(const ASourceDirectory, ATargetDirectory: string): Boolean;
  end;

implementation

end.
