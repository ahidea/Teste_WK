object frmServer: TfrmServer
  Left = 0
  Top = 0
  Caption = 'Servidor'
  ClientHeight = 77
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCreate = FormCreate
  TextHeight = 15
  object StatusBar: TStatusBar
    Left = 0
    Top = 58
    Width = 323
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'Status API'
        Width = 80
      end
      item
        Alignment = taCenter
        Text = 'INATIVA'
        Width = 80
      end
      item
        Alignment = taCenter
        Text = 'Porta'
        Width = 50
      end
      item
        Alignment = taCenter
        Text = '1234'
        Width = 50
      end
      item
        Width = 50
      end>
    ExplicitTop = 57
    ExplicitWidth = 319
  end
  object Ativar_API: TButton
    Left = 8
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Ativar_API'
    TabOrder = 1
    OnClick = Ativar_APIClick
  end
  object Parar_API: TButton
    Left = 89
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Parar_API'
    TabOrder = 2
    OnClick = Parar_APIClick
  end
end