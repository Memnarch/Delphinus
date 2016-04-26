unit DN.FileService;

interface

uses
  DN.FileService.Intf;

type
  TDNFileService = class(TInterfacedObject, IDNFileService)
  private
    FRootKey: string;
  public
    constructor Create(const ARootKey: string);
    procedure RegisterDirectoryForDeletion(const ADirectory: string);
    procedure RegisterFileForDeletion(const AFileName: string);
    procedure Cleanup;
  end;

implementation

uses
  Classes,
  IOUtils,
  Registry;

const
  CRootDir = 'Delphinus.FileCleanupService';
  CDirectories = 'Directories';
  CFiles = 'Files';

{ TDNFileService }

constructor TDNFileService.Create(const ARootKey: string);
begin
  inherited Create();
  FRootKey := ARootKey;
end;

procedure TDNFileService.Cleanup;
var
  LRegistry: TRegistry;
  LEntries: TStringList;
  LEntry: string;
begin
  LRegistry := TRegistry.Create();
  LEntries := TStringList.Create();
  try
    if LRegistry.OpenKey(FRootKey, False) then
    begin
      if LRegistry.OpenKey(CRootDir, False) then
      begin
        if LRegistry.OpenKey(CFiles, False) then
        begin
          try
            LRegistry.GetValueNames(LEntries);
            for LEntry in LEntries do
              if TFile.Exists(LEntry) then
                TFile.Delete(LEntry);
          finally
            LRegistry.CloseKey();
          end;
          LRegistry.DeleteKey(TPath.Combine(TPath.Combine(FRootKey, CRootDir), CFiles));
        end;

        if LRegistry.OpenKey(CDirectories, False) then
        begin
          try
            LRegistry.GetValueNames(LEntries);
            for LEntry in LEntries do
              if TDirectory.Exists(LEntry) then
                TDirectory.Delete(LEntry, True);
          finally
            LRegistry.CloseKey();
          end;
          LRegistry.DeleteKey(TPath.Combine(TPath.Combine(FRootKey, CRootDir), CDirectories));
        end;
        LRegistry.CloseKey();
        LRegistry.DeleteKey(TPath.Combine(FRootKey, CRootDir));
      end;
    end;
  finally
    LEntries.Free;
    LRegistry.Free;
  end;
end;

procedure TDNFileService.RegisterDirectoryForDeletion(const ADirectory: string);
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    if LRegistry.OpenKey(FRootKey, False) then
    begin
      if LRegistry.OpenKey(CRootDir, True) then
      begin
        if LRegistry.OpenKey(CDirectories, True) then
        begin
          LRegistry.WriteString(ADirectory, '');
        end;
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

procedure TDNFileService.RegisterFileForDeletion(const AFileName: string);
var
  LRegistry: TRegistry;
begin
  LRegistry := TRegistry.Create();
  try
    if LRegistry.OpenKey(FRootKey, False) then
    begin
      if LRegistry.OpenKey(CRootDir, True) then
      begin
        if LRegistry.OpenKey(CFiles, True) then
        begin
          LRegistry.WriteString(AFileName, '');
        end;
      end;
    end;
  finally
    LRegistry.Free;
  end;
end;

end.
