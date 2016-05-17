unit DN.BPLService.ToolsApi;

interface

uses
  DN.BPLService.Intf;

type
  TDNToolsApiBPLService = class(TInterfacedObject, IDNBPLService)
  public
    function Install(const ABPLFile: string): Boolean;
    function Uninstall(const ABPLFile: string): Boolean;
  end;

implementation

uses
  Classes,
  SysUtils,
  ToolsApi;

{ TDNToolsApiBPLService }

function TDNToolsApiBPLService.Install(const ABPLFile: string): Boolean;
var
  LResult: Boolean;
begin
  LResult := False;
  TThread.Synchronize(nil,
  procedure
  begin
    LResult := (BorlandIDEServices as IOTAPackageServices).InstallPackage(ABPLFile);
  end);
  Result := LResult;
end;

function TDNToolsApiBPLService.Uninstall(const ABPLFile: string): Boolean;
var
  LResult: Boolean;
  LPackage: string;
  LService: IOTAPackageServices;
begin
  LResult := False;
  TThread.Synchronize(nil,
  procedure
  var
    i: Integer;
  begin
    LService := (BorlandIDEServices as IOTAPackageServices);
    LResult := LService.UninstallPackage(ABPLFile);
    if not LResult then
    begin
      //if uninstallation failed but package is not present, it is a doubled uninstallation
      //we return success since this state might be archieved by a previous broken uninstallation
      //or user manipulation
      LResult := True;
      LPackage := ExtractFileName(ABPLFile);
      for i := 0 to LService.PackageCount - 1 do
      begin
        if SameText(LService.Package[i].Name, LPackage) then
        begin
          LResult := False;
          Exit;
        end;
      end;
    end;
  end);
  Result := LResult;
end;

end.
