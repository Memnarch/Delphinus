unit DN.FileService.Intf;

interface

type
  IDNFileService = interface
    ['{227C4571-F2BA-4956-8359-2AC19EBFC2E0}']
    procedure RegisterFileForDeletion(const AFileName: string);
    procedure RegisterDirectoryForDeletion(const ADirectory: string);
    procedure Cleanup;
  end;

implementation

end.
