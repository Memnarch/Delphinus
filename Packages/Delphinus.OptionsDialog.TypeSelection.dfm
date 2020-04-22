object TypeSelectionDialog: TTypeSelectionDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Source Type Selection'
  ClientHeight = 125
  ClientWidth = 309
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  DesignSize = (
    309
    125)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 125
    Height = 13
    Caption = 'Select the type of source:'
  end
  object Label2: TLabel
    Left = 8
    Top = 51
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object cbSourceType: TComboBox
    Left = 8
    Top = 24
    Width = 293
    Height = 21
    Style = csDropDownList
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 145
    Top = 92
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 226
    Top = 92
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object edSourceName: TEdit
    Left = 8
    Top = 67
    Width = 293
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 3
    TextHint = 'New Name'
  end
end
