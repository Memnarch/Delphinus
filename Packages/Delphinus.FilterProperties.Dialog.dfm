object FilterPropertiesDialog: TFilterPropertiesDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FilterPropertiesDialog'
  ClientHeight = 229
  ClientWidth = 412
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  DesignSize = (
    412
    229)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 31
    Height = 13
    Caption = 'Name:'
  end
  object Label2: TLabel
    Left = 8
    Top = 54
    Width = 49
    Height = 13
    Caption = 'Platforms:'
  end
  object edName: TEdit
    Left = 8
    Top = 27
    Width = 121
    Height = 21
    TabOrder = 0
  end
  object clbPlatforms: TCheckListBox
    Left = 8
    Top = 73
    Width = 121
    Height = 97
    ItemHeight = 13
    TabOrder = 1
  end
  object btnCacnel: TButton
    Left = 329
    Top = 196
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnOk: TButton
    Left = 248
    Top = 196
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Ok'
    ModalResult = 1
    TabOrder = 3
  end
end
