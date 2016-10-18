unit DN.Settings.Intf;

interface

uses
  DN.PackageSource.Settings.Intf;

type
  IDNSettings = interface
    ['{AEF92172-BD4F-44BA-B3F2-479533B00285}']
    function GetInstallationDirectory: string;
    function GetOAuthToken: string;
    function GetVersion: string;
    function GetInstallDate: TDateTime;
    function GetSourceSettings: TArray<IDNPackageSourceSettings>;
    procedure SetOAuthToken(const Value: string);
    property InstallationDirectory: string read GetInstallationDirectory;
    property OAuthToken: string read GetOAuthToken write SetOAuthToken;
    property Version: string read GetVersion;
    property InstallDate: TDateTime read GetInstallDate;
    property SourceSettings: TArray<IDNPackageSourceSettings> read GetSourceSettings;
  end;

  IDNElevatedSettings = interface(IDNSettings)
  ['{0FAF4B57-0258-4964-8BA2-310858A48BB3}']
    procedure SetInstallationDirectory(const Value: string);
    procedure SetVersion(const AVersion: string);
    procedure SetInstallDate(const Value: TDateTime);
    procedure Clear();
    property InstallationDirectory: string read GetInstallationDirectory write SetInstallationDirectory;
    property Version: string read GetVersion write SetVersion;
    property InstallDate: TDateTime read GetInstallDate write SetInstallDate;
  end;

implementation

end.
