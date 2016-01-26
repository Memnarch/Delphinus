object DelphiInstallationView: TDelphiInstallationView
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object View: TCheckListBox
    Left = 0
    Top = 0
    Width = 320
    Height = 240
    Align = alClient
    BorderStyle = bsNone
    Flat = False
    Style = lbOwnerDrawVariable
    TabOrder = 0
    OnDrawItem = ViewDrawItem
  end
end
