unit DN.TextTable.Intf;

interface

type
  IDNTextTable = interface
  ['{D5333616-22A7-4716-9D3C-20C3E5391BC1}']
    function GetText: string;
    procedure AddColumn(const ACaption: string; ACharWidth: Integer = -1);
    procedure AddRecord(const AValues: array of string);
    property Text: string read GetText;
  end;

implementation

end.
