unit uPessoa;

interface

uses
  System.SysUtils, System.Classes, System.Json, DataSnap.DSProviderDataModuleAdapter,
  Datasnap.DSServer, Datasnap.DSAuth, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.Comp.Client,
  Data.DB, FireDAC.Comp.DataSet;

type
  TDMPessoa = class(TDSServerModule)
    qryPessoa: TFDQuery;
    qryPessoaidpessoa: TLargeintField;
    qryPessoaflnatureza: TSmallintField;
    qryPessoadsdocumento: TWideStringField;
    qryPessoanmprimeiro: TWideStringField;
    qryPessoanmsegundo: TWideStringField;
    qryPessoadtregistro: TDateField;
    qryPessoaidendereco: TLargeintField;
    qryPessoadscep: TWideStringField;
    qryPessoadsuf: TWideStringField;
    qryPessoanmcidade: TWideStringField;
    qryPessoanmbairro: TWideStringField;
    qryPessoanmlogradouro: TWideStringField;
    qryPessoadscomplemento: TWideStringField;

  public

    // devolve nil se n�o for localizado
    function Pessoa( aPessoaID: integer; var Dados: TJSONObject ) : boolean;

    // Retorna idpessoa
    // se erro, retorna 0;
    function RegistrarPessoa( flnatureza: integer; dsdocumento, nmprimeiro, nmsegundo: string ) : integer;

    // Retorna idendereco
    function RegistrarEndereco( idpessoa: integer; cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento: string ) : integer;

    // Alterar o cadastro de pessoa
    function AlterarPessoa( idpessoa: integer; flnatureza: integer; dsdocumento, nmprimeiro, nmsegundo: string ) : boolean;

    // Alterar endere�o
    function AlterarEndereco( idendereco: integer; cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento: string ): boolean;

    // Pesquisa idendereco de uma pessoa de retorna:
    // >0: idendereco da pessoa
    //  0: n�o existe endere�o definido
    // -1: endereco invalido
    function Pesquisar_idendereco( idpessoa: integer ) : integer;

    // Apaga endere�o da pessoa
    function ApagarEndereco( idpessoa: integer ) : boolean;

    function ApagarPessoa( idpessoa: integer ) : boolean;

  end;

var
  DMPessoa: TDMPessoa;

implementation

{.%CLASSGROUP 'System.Classes.TPersistent'}

uses uDMConexao;

{$R *.dfm}

{ TWSPessoa }

function TDMPessoa.AlterarEndereco(idendereco: integer; cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento: string): boolean;
var Q : TFDQuery;
begin
  Result := false;
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;

    DataModule1.FDConnection1.StartTransaction;
    try
      Q.ExecSQL( 'UPDATE endereco SET dscep =' + QuotedStr(cep) +' WHERE idendereco = '+IntToStr(idendereco) );
      Q.ExecSQL( 'UPDATE endereco_integracao SET '#13
               + ' dsuf = ' + QuotedStr(dsuf)
               + ',nmcidade = ' + QuotedStr(nmcidade)
               + ',nmbairro = ' + QuotedStr(nmbairro)
               + ',nmlogradouro = ' + QuotedStr(nmlogradouro)
               + ',dscomplemento = ' + QuotedStr(dscomplemento)
               + #13
               + 'WHERE idendereco = '+IntToStr(idendereco) );
      DataModule1.FDConnection1.Commit;
      Result := true;
    except
      DataModule1.FDConnection1.Rollback;
    end;
    Q.Close;

  finally
    FreeAndNil( Q );
  end;
end;

function TDMPessoa.AlterarPessoa(idpessoa, flnatureza: integer; dsdocumento, nmprimeiro, nmsegundo: string): boolean;
var Q : TFDQuery;
begin
  Result := false;
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;

    DataModule1.FDConnection1.StartTransaction;
    try
      Q.ExecSQL( 'UPDATE pessoa SET '#13
               + ' flnatureza =' + IntToStr(flnatureza)
               + ',dsdocumento =' + QuotedStr(dsdocumento)
               + ',nmprimeiro =' + QuotedStr(nmprimeiro)
               + ',nmsegundo =' + QuotedStr(nmsegundo)
               + #13
               + 'WHERE idpessoa = '+IntToStr(idpessoa) );
      DataModule1.FDConnection1.Commit;
      Result := true;
    except
      DataModule1.FDConnection1.Rollback;
    end;
    Q.Close;

  finally
    FreeAndNil( Q );
  end;
end;

function TDMPessoa.ApagarEndereco(idpessoa: integer): boolean;
var Q : TFDQuery;
begin
  Result := false;
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;
    Q.ExecSQL('DELETE FROM endereco_integracao '
             +'WHERE idendereco = coalesce((SELECT idendereco FROM endereco WHERE idpessoa = '+IntToStr(idpessoa)+'),0);');
    Q.ExecSQL('DELETE FROM endereco WHERE WHERE idpessoa = '+IntToStr(idpessoa));
    Result := true;
  finally
    FreeAndNil( Q );
  end;
end;

function TDMPessoa.ApagarPessoa(idpessoa: integer): boolean;
var Q : TFDQuery;
begin // apagar pessoa e endereco (cascade)
  Result := false;
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;
    Q.ExecSQL('DELETE FROM pessoa WHERE idpessoa = ' + IntToStr(idpessoa));
    Result := true;
  finally
    FreeAndNil( Q );
  end;
end;

// Pesquisa idendereco de uma pessoa de retorna:
// >0: idendereco da pessoa
//  0: n�o existe endere�o definido
// -1: endereco invalido
function TDMPessoa.Pesquisar_idendereco(idpessoa: integer): integer;
var Q : TFDQuery;
begin
  Result := 0;
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;

    Q.Open( 'SELECT '
          + '  a.idpessoa '
          + ', coalesce(e.idendereco,0) as idendereco_em_endereco '
          + ', coalesce(ei.idendereco,0) as idendereco_em_endereco_integracao '
          + ', coalesce(e.idendereco,-1) = coalesce(ei.idendereco,-2) idendereco_valido '
          + 'FROM pessoa as a '
          + '     LEFT JOIN endereco as e ON e.idpessoa = a.idpessoa '
          + '     LEFT JOIN endereco_integracao as ei ON ei.idendereco = e.idendereco '
          + 'WHERE a.idpessoa = ' + IntToStr(idpessoa) );
    if Q.Eof then begin
      // n�o existe endere�o definido
      Result := 0;
    end
    else begin
      if Q.FieldByName('idendereco_valido').AsBoolean then begin
        // idendereco da pessoa
        Result := Q.FieldByName('idendereco_em_endereco').AsInteger;
      end
      else begin
        // endereco invalido
        Result := -1;
      end;

    end;
    Q.Close;

  finally
    FreeAndNil( Q );
  end;



(*
SELECT
  a.idpessoa
, coalesce(e.idendereco,0) as idendereco_em_endereco
, coalesce(ei.idendereco,0) as idendereco_em_endereco_integracao
, coalesce(e.idendereco,-1) = coalesce(ei.idendereco,-2) idendereco_valido
FROM pessoa as a
     LEFT JOIN endereco as e ON e.idpessoa = a.idpessoa
     LEFT JOIN endereco_integracao as ei ON ei.idendereco = e.idendereco
WHERE a.idpessoa = @@@
*)
end;

function TDMPessoa.Pessoa(aPessoaID: integer; var Dados: TJSONObject ) : boolean;
var sql : string;
    cep : string;
    idendereco: integer;
begin
  sql:='SELECT '#13
      +'  a.idpessoa '#13
      +', a.flnatureza '#13
      +', a.dsdocumento '#13
      +', a.nmprimeiro '#13
      +', a.nmsegundo '#13
      +', a.dtregistro '#13
      +', e.idendereco '#13
      +', e.dscep '#13
      +', ei.dsuf '#13
      +', ei.nmcidade '#13
      +', ei.nmbairro '#13
      +', ei.nmlogradouro '#13
      +', ei.dscomplemento '#13
      +'FROM pessoa as a '#13
      +'     LEFT JOIN endereco as e ON e.idpessoa = a.idpessoa '#13
      +'     LEFT JOIN endereco_integracao as ei ON ei.idendereco = e.idendereco '#13
      +'WHERE a.idpessoa = ' + IntToStr( aPessoaID );

  qryPessoa.Close;
  qryPessoa.Open( sql );
  if qryPessoa.eof then begin
    Dados := nil;
    Result := false;
    exit;
  end;

  Dados := TJSONObject.Create;
  Dados.AddPair('idpessoa', qryPessoaidpessoa.AsInteger );
  Dados.AddPair('flnatureza', qryPessoaflnatureza.AsInteger );
  Dados.AddPair('dsdocumento', qryPessoadsdocumento.AsString );
  Dados.AddPair('nmprimeiro', qryPessoanmprimeiro.AsString );
  Dados.AddPair('nmsegundo', qryPessoanmsegundo.AsString );
  Dados.AddPair('dtregistro', FormatDateTime('YYYY-MM-DD', qryPessoadtregistro.AsDateTime ) );
  Dados.AddPair('dscep', qryPessoadscep.AsString );
  Dados.AddPair('idendereco', qryPessoaidendereco.AsInteger );
  Dados.AddPair('dsuf', qryPessoadsuf.AsString );
  Dados.AddPair('nmcidade', qryPessoanmcidade.AsString );
  Dados.AddPair('nmbairro', qryPessoanmbairro.AsString );
  Dados.AddPair('nmlogradouro', qryPessoanmlogradouro.AsString );
  Dados.AddPair('dscomplemento', qryPessoadscomplemento.AsString );

  Result := true;

  qryPessoa.Close;
end;

function TDMPessoa.RegistrarEndereco(idpessoa: integer; cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento: string): integer;
var Q : TFDQuery;
begin
  Result := 0; // 0 == erro
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;

    DataModule1.FDConnection1.StartTransaction;
    try
      Q.ExecSQL('INSERT INTO endereco(idpessoa,dscep) VALUES '#13
               + '(' + IntToStr(idpessoa)
               + ',' + QuotedStr(cep)
               + ');');
      Q.ExecSQL('INSERT INTO endereco_integracao(idendereco,dsuf,nmcidade,nmbairro,nmlogradouro,dscomplemento) VALUES '#13
               + '(' + '(SELECT max(idendereco) FROM endereco)'
               + ',' + QuotedStr(dsuf)
               + ',' + QuotedStr(nmcidade)
               + ',' + QuotedStr(nmbairro)
               + ',' + QuotedStr(nmlogradouro)
               + ',' + QuotedStr(dscomplemento)
               + ');');
      Q.Open('SELECT max(idendereco) as idendereco FROM endereco;');
      if not Q.Eof then begin
        Result := Q.FieldByName('idendereco').AsInteger;
      end;
      DataModule1.FDConnection1.Commit;

    except
      DataModule1.FDConnection1.Rollback;
    end;
    Q.Close;

  finally
    FreeAndNil( Q );
  end;
end;

function TDMPessoa.RegistrarPessoa(flnatureza: integer; dsdocumento, nmprimeiro, nmsegundo: string ): integer;
var Q : TFDQuery;
begin
  Result := 0; // 0 == erro
  Q := TFDQuery.Create( nil );
  try
    Q.Connection := DataModule1.FDConnection1;

    DataModule1.FDConnection1.StartTransaction;
    try
      Q.ExecSQL('INSERT INTO pessoa(flnatureza,dsdocumento,nmprimeiro,nmsegundo) VALUES '#13
               + '(' + IntToStr(flnatureza)
               + ',' + QuotedStr(dsdocumento)
               + ',' + QuotedStr(nmprimeiro)
               + ',' + QuotedStr(nmsegundo)
               + ');');
      Q.Open('SELECT max(idpessoa) as idpessoa FROM pessoa;');
      if not Q.Eof then begin
        Result := Q.FieldByName('idpessoa').AsInteger;
      end;
      DataModule1.FDConnection1.Commit;

    except
      DataModule1.FDConnection1.Rollback;
    end;
    Q.Close;

  finally
    FreeAndNil( Q );
  end;
end;

end.