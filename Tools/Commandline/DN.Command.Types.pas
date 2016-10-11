unit DN.Command.Types;

interface

uses
  SysUtils;

type
  ECommandError = class(Exception);
  ECommandValidation = class(ECommandError);
  EInvalidSwitchIndex = class(ECommandError)
  public
    constructor Create(const AIndex: Integer);
  end;

  ECommandFailed = class(ECommandError);

implementation

{ EInvalidSwitchIndex }

constructor EInvalidSwitchIndex.Create(const AIndex: Integer);
begin
  inherited Create('Invalid switch index has been used: ' + IntToStr(AIndex));
end;

end.
