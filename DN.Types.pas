{
#########################################################
# Copyright by Alexander Benikowski                     #
# This unit is part of the Delphinus project hosted on  #
# https://github.com/Memnarch/Delphinus                 #
#########################################################
}
unit DN.Types;

interface

type
  TMessageType = (mtNotification, mtWarning, mtError);
  TMessageEvent = procedure(AMessageType: TMessageType; const AMessage: string) of object;
  TPathType = (tpSearchPath, tpBrowsingPath);

const
  CSourceSubDir = 'Source';
  CMacPackageExtension = '.dylib';
  CMacPackagePrefix = 'bpl';

implementation

end.
