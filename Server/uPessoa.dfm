object DMPessoa: TDMPessoa
  Height = 120
  Width = 260
  object qryPessoa: TFDQuery
    Connection = DataModule1.FDConnection1
    SQL.Strings = (
      'SELECT'
      '  a.idpessoa'
      ', a.flnatureza'
      ', a.dsdocumento'
      ', a.nmprimeiro'
      ', a.nmsegundo'
      ', a.dtregistro'
      ', e.idendereco'
      ', e.dscep'
      ', ei.dsuf'
      ', ei.nmcidade'
      ', ei.nmbairro'
      ', ei.nmlogradouro'
      ', ei.dscomplemento'
      'FROM pessoa as a'
      '     LEFT JOIN endereco as e ON e.idpessoa = a.idpessoa'
      
        '     LEFT JOIN endereco_integracao as ei ON ei.idendereco = e.id' +
        'endereco'
      'WHERE a.idpessoa = :idpessoa')
    Left = 40
    Top = 24
    ParamData = <
      item
        Name = 'IDPESSOA'
        DataType = ftInteger
        ParamType = ptInput
        Value = -1
      end>
    object qryPessoaidpessoa: TLargeintField
      FieldName = 'idpessoa'
      Origin = 'idpessoa'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object qryPessoaflnatureza: TSmallintField
      FieldName = 'flnatureza'
      Origin = 'flnatureza'
    end
    object qryPessoadsdocumento: TWideStringField
      FieldName = 'dsdocumento'
      Origin = 'dsdocumento'
    end
    object qryPessoanmprimeiro: TWideStringField
      FieldName = 'nmprimeiro'
      Origin = 'nmprimeiro'
      Size = 100
    end
    object qryPessoanmsegundo: TWideStringField
      FieldName = 'nmsegundo'
      Origin = 'nmsegundo'
      Size = 100
    end
    object qryPessoadtregistro: TDateField
      FieldName = 'dtregistro'
      Origin = 'dtregistro'
    end
    object qryPessoaidendereco: TLargeintField
      AutoGenerateValue = arDefault
      FieldName = 'idendereco'
      Origin = 'idendereco'
    end
    object qryPessoadscep: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'dscep'
      Origin = 'dscep'
      Size = 15
    end
    object qryPessoadsuf: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'dsuf'
      Origin = 'dsuf'
      Size = 50
    end
    object qryPessoanmcidade: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'nmcidade'
      Origin = 'nmcidade'
      Size = 100
    end
    object qryPessoanmbairro: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'nmbairro'
      Origin = 'nmbairro'
      Size = 50
    end
    object qryPessoanmlogradouro: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'nmlogradouro'
      Origin = 'nmlogradouro'
      Size = 100
    end
    object qryPessoadscomplemento: TWideStringField
      AutoGenerateValue = arDefault
      FieldName = 'dscomplemento'
      Origin = 'dscomplemento'
      Size = 100
    end
  end
end
