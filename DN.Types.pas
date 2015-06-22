unit DN.Types;

interface

type
  TMessageType = (mtNotification, mtWarning, mtError);
  TMessageEvent = reference to procedure(AMessageType: TMessageType; const AMessage: string);

const
  CSourceSubDir = 'Source';

implementation

end.
