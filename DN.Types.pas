unit DN.Types;

interface

type
  TMessageType = (mtNotification, mtWarning, mtError);
  TMessageEvent = reference to procedure(AMessageType: TMessageType; const AMessage: string);
  TPathType = (tpSearchPath, tpBrowsingPath);

const
  CSourceSubDir = 'Source';
  CMacPackageExtension = '.dylib';
  CMacPackagePrefix = 'bpl';

implementation

end.
