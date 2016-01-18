unit DN.Environment;

interface

function GetDelphinusTempFolder: string;

implementation

uses
  SysUtils,
  DN.IOUtils;


function GetDelphinusTempFolder: string;
begin
  Result := TPath.Combine(GetEnvironmentVariable('Temp'), 'Delphinus');
end;

end.
