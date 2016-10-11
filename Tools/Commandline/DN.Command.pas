unit DN.Command;

interface

uses
  SysUtils,
  Generics.Collections,
  DN.Command.Switch,
  DN.Command.Argument.Intf;

type
  TDNCommand = class(TDNCommandSwitch)
  private
    FSwitches: TList<TDNCommandSwitch>;
    FUsedSwitches: Integer;
    FEnvironment: IInterface;
  protected
    function GetSwitch<T: TDNCommandSwitch>: T;
    function HasSwitch<T: TDNCommandSwitch>: Boolean;
    function SwitchCount: Integer;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure Initialize(const AArgument: IDNCommandArgument); reintroduce;
    procedure Execute; virtual; abstract;
    property Environment: IInterface read FEnvironment write FEnvironment;
    class procedure Validate(const AArgument: IDNCommandArgument); reintroduce; virtual;
    class function SwitchClassCount: Integer; virtual;
    class function SwitchClass(AIndex: Integer): TDNCommandSwitchClass; virtual;
    class function SwitchClassByName(const AName: string): TDNCommandSwitchClass;
  end;

  TDNCommandClass = class of TDNCommand;

implementation

{ TDNCommand }

constructor TDNCommand.Create;
begin
  inherited;
  FSwitches := TList<TDNCommandSwitch>.Create();
end;

destructor TDNCommand.Destroy;
begin
  FSwitches.Free;
  inherited;
end;

function TDNCommand.GetSwitch<T>: T;
var
  LSwitch: TDNCommandSwitch;
begin
  for LSwitch in FSwitches do
    if LSwitch is T then
      Exit(LSwitch as T);

  Result := nil;
end;

function TDNCommand.HasSwitch<T>: Boolean;
var
  LSwitch: TDNCommandSwitch;
begin
  for LSwitch in FSwitches do
    if LSwitch is T then
      Exit(LSwitch.IsUsed);

  Result := False;
end;

function GetSwitchArgument(const AName: string; const AArguments: TArray<IDNCommandSwitchArgument>): IDNCommandSwitchArgument;
var
  LArgument: IDNCommandSwitchArgument;
begin
  for LArgument in AArguments do
    if SameText(AName, LArgument.Name) then
      Exit(LArgument);
  Result := nil;
end;

procedure TDNCommand.Initialize(const AArgument: IDNCommandArgument);
var
  LSwitchArgument: IDNCommandSwitchArgument;
  LSwitch: TDNCommandSwitch;
  i: Integer;
begin
  inherited Initialize(AArgument);

  for i := 0 to SwitchClassCount - 1 do
  begin
    LSwitch := SwitchClass(i).Create();
    try
      LSwitchArgument := GetSwitchArgument(SwitchClass(i).Name, AArgument.Switches);
      if Assigned(LSwitchArgument) then
      begin
        LSwitch.Initialize(LSwitchArgument);
        Inc(FUsedSwitches);
      end;
    finally
      FSwitches.Add(LSwitch);
    end;
  end;
end;

class function TDNCommand.SwitchClass(AIndex: Integer): TDNCommandSwitchClass;
begin
  Result := nil;
end;

class function TDNCommand.SwitchClassByName(
  const AName: string): TDNCommandSwitchClass;
var
  i: Integer;
begin
  for i := 0 to SwitchClassCount - 1 do
    if SameText(AName, SwitchClass(i).Name) then
      Exit(SwitchClass(i));

  raise ENotSupportedException.Create('Unknown switch ' + AName);
end;

class function TDNCommand.SwitchClassCount: Integer;
begin
  Result := 0;
end;

function TDNCommand.SwitchCount: Integer;
begin
  Result := FUsedSwitches;
end;

class procedure TDNCommand.Validate(const AArgument: IDNCommandArgument);
var
  LSwitchArgument: IDNCommandSwitchArgument;
begin
  inherited Validate(AArgument);

  for LSwitchArgument in AArgument.Switches do
    SwitchClassByName(LSwitchArgument.Name).Validate(LSwitchArgument);
end;

end.
