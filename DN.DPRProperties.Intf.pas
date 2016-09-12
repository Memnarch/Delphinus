unit DN.DPRProperties.Intf;

interface

type
  IDPRProperties = interface
    ['{5451E096-4E56-4FA9-A4EB-1890735545DB}']
    procedure BeginTemporaryOverride;
    procedure EndTemporaryOverride;
    procedure SetLibVersion(const AVersion: string);
    procedure SetSuffix(const ASuffix: string);
    procedure SetPrefix(const APrefix: string);
  end;

implementation

end.
