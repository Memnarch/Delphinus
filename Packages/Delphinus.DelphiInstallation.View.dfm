object DelphiInstallationView: TDelphiInstallationView
  Left = 0
  Top = 0
  Width = 320
  Height = 240
  TabOrder = 0
  object sLine: TShape
    Left = 0
    Top = 20
    Width = 320
    Height = 1
    Align = alTop
    Pen.Color = clBtnFace
    ExplicitLeft = -84
    ExplicitTop = 23
    ExplicitWidth = 404
  end
  object View: TCheckListBox
    Left = 0
    Top = 21
    Width = 320
    Height = 219
    OnClickCheck = ViewClickCheck
    Align = alClient
    BorderStyle = bsNone
    Flat = False
    Style = lbOwnerDrawVariable
    TabOrder = 0
    OnDrawItem = ViewDrawItem
  end
  object cbAll: TCheckBox
    AlignWithMargins = True
    Left = 0
    Top = 0
    Width = 320
    Height = 17
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Align = alTop
    AllowGrayed = True
    Caption = 'Install for All'
    TabOrder = 1
    OnClick = cbAllClick
  end
end
