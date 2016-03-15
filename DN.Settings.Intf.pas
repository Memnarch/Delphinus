unit DN.Settings.Intf;

interface

type
  IDNSettings = interface
    ['{AEF92172-BD4F-44BA-B3F2-479533B00285}']
    function GetInstallationDirectory: string;
    function GetOAuthToken: string;
    procedure SetOAuthToken(const Value: string);
    property InstallationDirectory: string read GetInstallationDirectory;
    property OAuthToken: string read GetOAuthToken write SetOAuthToken;
  end;

  IDNElevatedSettings = interface(IDNSettings)
  ['{0FAF4B57-0258-4964-8BA2-310858A48BB3}']
    procedure SetInstallationDirectory(const Value: string);
    procedure Clear();
    property InstallationDirectory: string read GetInstallationDirectory write SetInstallationDirectory;
  end;

implementation

end.
