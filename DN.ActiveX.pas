unit DN.ActiveX;

interface

uses
  ActiveX;

type
  IStream = interface(ISequentialStream)
    ['{0000000C-0000-0000-C000-000000000046}']
    function Seek(dlibMove: Largeuint; dwOrigin: Longint;
      out libNewPosition: Largeuint): HResult; stdcall;
    function SetSize(libNewSize: Largeuint): HResult; stdcall;
    function CopyTo(stm: IStream; cb: Largeuint; out cbRead: Largeuint;
      out cbWritten: Largeuint): HResult; stdcall;
    function Commit(grfCommitFlags: Longint): HResult; stdcall;
    function Revert: HResult; stdcall;
    function LockRegion(libOffset: Largeuint; cb: Largeuint;
      dwLockType: Longint): HResult; stdcall;
    function UnlockRegion(libOffset: Largeuint; cb: Largeuint;
      dwLockType: Longint): HResult; stdcall;
    function Stat(out statstg: TStatStg; grfStatFlag: Longint): HResult;
      stdcall;
    function Clone(out stm: IStream): HResult; stdcall;
  end;

  IConnectionPointContainer = ActiveX.IConnectionPointContainer;
  IConnectionPoint = ActiveX.IConnectionPoint;

  PSafeArray = ActiveX.PSafeArray;

implementation

end.
