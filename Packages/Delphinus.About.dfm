object AboutDialog: TAboutDialog
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'About'
  ClientHeight = 218
  ClientWidth = 288
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object imgDelphinus: TImage
    Left = 8
    Top = 8
    Width = 32
    Height = 32
  end
  object Label1: TLabel
    Left = 46
    Top = 8
    Width = 83
    Height = 23
    Caption = 'Delphinus'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 8
    Top = 46
    Width = 252
    Height = 13
    Caption = 'Packagemanager for Delphi by Alexander Benikowski'
  end
  object Label3: TLabel
    Left = 8
    Top = 65
    Width = 24
    Height = 13
    Caption = 'Blog:'
  end
  object Label4: TLabel
    Left = 8
    Top = 84
    Width = 35
    Height = 13
    Caption = 'Github:'
  end
  object imgIcons8: TImage
    Left = 8
    Top = 120
    Width = 32
    Height = 32
  end
  object Label5: TLabel
    Left = 46
    Top = 120
    Width = 55
    Height = 23
    Caption = 'Icons8'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -19
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label6: TLabel
    Left = 8
    Top = 158
    Width = 158
    Height = 13
    Caption = 'Delphinus uses icons from Icons8'
  end
  object Label7: TLabel
    Left = 8
    Top = 177
    Width = 55
    Height = 13
    Caption = 'Homepage:'
  end
  object LinkLabel1: TLinkLabel
    Left = 49
    Top = 84
    Width = 197
    Height = 17
    Caption = 
      '<a href="https://github.com/Memnarch/Delphinus">https://github.c' +
      'om/Memnarch/Delphinus</a>'
    TabOrder = 0
    OnLinkClick = OpenLinkInBrowser
  end
  object LinkLabel2: TLinkLabel
    Left = 49
    Top = 65
    Width = 146
    Height = 17
    Caption = 
      '<a href="http://memnarch.bplaced.net">http://memnarch.bplaced.ne' +
      't</a>'
    TabOrder = 1
    OnLinkClick = OpenLinkInBrowser
  end
  object LinkLabel3: TLinkLabel
    Left = 69
    Top = 177
    Width = 94
    Height = 17
    Caption = '<a href="https://icons8.com">https://icons8.com</a>'
    TabOrder = 2
    OnLinkClick = OpenLinkInBrowser
  end
end
