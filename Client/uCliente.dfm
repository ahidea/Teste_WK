object frmCliente: TfrmCliente
  Left = 0
  Top = 0
  Caption = 'Cliente'
  ClientHeight = 400
  ClientWidth = 706
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object Label1: TLabel
    Left = 16
    Top = 8
    Width = 46
    Height = 15
    Caption = 'idpessoa'
  end
  object Label3: TLabel
    Left = 120
    Top = 8
    Width = 52
    Height = 15
    Caption = 'flnatureza'
  end
  object Label4: TLabel
    Left = 265
    Top = 8
    Width = 74
    Height = 15
    Caption = 'dsdocumento'
  end
  object Label5: TLabel
    Left = 120
    Top = 52
    Width = 63
    Height = 15
    Caption = 'nmprimeiro'
  end
  object Label6: TLabel
    Left = 120
    Top = 96
    Width = 64
    Height = 15
    Caption = 'nmsegundo'
  end
  object Label7: TLabel
    Left = 406
    Top = 8
    Width = 51
    Height = 15
    Caption = 'dtregistro'
  end
  object Label2: TLabel
    Left = 120
    Top = 141
    Width = 31
    Height = 15
    Caption = 'dscep'
  end
  object Label8: TLabel
    Left = 192
    Top = 185
    Width = 53
    Height = 15
    Caption = 'nmcidade'
  end
  object Label9: TLabel
    Left = 120
    Top = 185
    Width = 23
    Height = 15
    Caption = 'dsuf'
  end
  object Label10: TLabel
    Left = 120
    Top = 229
    Width = 49
    Height = 15
    Caption = 'nmbairro'
  end
  object Label11: TLabel
    Left = 120
    Top = 273
    Width = 77
    Height = 15
    Caption = 'nmlogradouro'
  end
  object Label12: TLabel
    Left = 120
    Top = 317
    Width = 87
    Height = 15
    Caption = 'dscomplemento'
  end
  object bAPI_ping: TButton
    Left = 600
    Top = 287
    Width = 75
    Height = 25
    Caption = 'API Ping'
    TabOrder = 11
    OnClick = bAPI_pingClick
  end
  object ed_idpessoa: TEdit
    Left = 16
    Top = 24
    Width = 73
    Height = 23
    NumbersOnly = True
    TabOrder = 0
    OnChange = ed_idpessoaChange
    OnKeyPress = ed_idpessoaKeyPress
  end
  object ed_flnatureza: TEdit
    Left = 120
    Top = 24
    Width = 121
    Height = 23
    MaxLength = 6
    NumbersOnly = True
    TabOrder = 1
  end
  object ed_dsdocumento: TEdit
    Left = 265
    Top = 24
    Width = 121
    Height = 23
    MaxLength = 20
    TabOrder = 2
  end
  object ed_nmprimeiro: TEdit
    Left = 120
    Top = 67
    Width = 407
    Height = 23
    MaxLength = 100
    TabOrder = 3
  end
  object ed_nmsegundo: TEdit
    Left = 120
    Top = 112
    Width = 407
    Height = 23
    MaxLength = 100
    TabOrder = 4
  end
  object ed_dtregistro: TEdit
    Left = 406
    Top = 24
    Width = 121
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 18
  end
  object bNovo: TButton
    Left = 600
    Top = 23
    Width = 75
    Height = 25
    Caption = 'Novo'
    TabOrder = 6
    OnClick = bNovoClick
  end
  object bEditar: TButton
    Left = 600
    Top = 54
    Width = 75
    Height = 25
    Caption = 'Editar'
    TabOrder = 7
    OnClick = bEditarClick
  end
  object bExcluir: TButton
    Left = 600
    Top = 85
    Width = 75
    Height = 25
    Caption = 'Excluir'
    TabOrder = 8
    OnClick = bExcluirClick
  end
  object bGravar: TButton
    Left = 600
    Top = 137
    Width = 75
    Height = 25
    Caption = 'Gravar'
    TabOrder = 9
    OnClick = bGravarClick
  end
  object bCancelar: TButton
    Left = 600
    Top = 168
    Width = 75
    Height = 25
    Caption = 'Cancelar'
    TabOrder = 10
    OnClick = bCancelarClick
  end
  object ed_dscep: TEdit
    Left = 120
    Top = 156
    Width = 121
    Height = 23
    TabOrder = 5
    OnChange = ed_dscepChange
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 381
    Width = 706
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'API'
        Width = 50
      end
      item
        Alignment = taCenter
        Text = 'on/off'
        Width = 80
      end
      item
        Width = 50
      end
      item
        Alignment = taRightJustify
        Text = '> '
        Width = 20
      end
      item
        Width = 10
      end>
    ExplicitTop = 380
    ExplicitWidth = 702
  end
  object ed_dsuf: TEdit
    Left = 120
    Top = 200
    Width = 52
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 13
  end
  object ed_nmcidade: TEdit
    Left = 192
    Top = 200
    Width = 335
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 14
  end
  object ed_nmbairro: TEdit
    Left = 120
    Top = 244
    Width = 407
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 15
  end
  object ed_nmlogradouro: TEdit
    Left = 120
    Top = 288
    Width = 407
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 16
  end
  object ed_dscomplemento: TEdit
    Left = 120
    Top = 332
    Width = 407
    Height = 23
    TabStop = False
    ReadOnly = True
    TabOrder = 17
  end
  object bProcessamentoEmLote: TButton
    Left = 600
    Top = 328
    Width = 75
    Height = 25
    Caption = 'Em Lote'
    TabOrder = 12
    OnClick = bProcessamentoEmLoteClick
  end
  object ProgressBar: TProgressBar
    Left = 0
    Top = 373
    Width = 706
    Height = 8
    Align = alBottom
    TabOrder = 20
    ExplicitTop = 372
    ExplicitWidth = 702
  end
  object OpenDialog: TOpenDialog
    DefaultExt = 'txt'
    InitialDir = '.'
    Left = 624
    Top = 224
  end
end
