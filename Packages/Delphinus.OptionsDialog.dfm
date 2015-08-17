object DelphinusOptionsDialog: TDelphinusOptionsDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Options'
  ClientHeight = 166
  ClientWidth = 395
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 64
    Height = 13
    Caption = 'OAuth-Token'
  end
  object lbResponse: TLabel
    Left = 8
    Top = 54
    Width = 298
    Height = 13
    AutoSize = False
  end
  object edToken: TEdit
    Left = 8
    Top = 27
    Width = 298
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
  end
  object btnTest: TButton
    Left = 312
    Top = 25
    Width = 75
    Height = 25
    Caption = 'Test'
    TabOrder = 1
    OnClick = btnTestClick
  end
  object btnOK: TButton
    Left = 231
    Top = 133
    Width = 75
    Height = 25
    Caption = 'OK'
    ModalResult = 1
    TabOrder = 2
  end
  object btnCancel: TButton
    Left = 312
    Top = 133
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
end
