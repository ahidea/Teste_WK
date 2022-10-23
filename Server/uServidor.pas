unit uServidor;

interface

uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, IPPeerServer,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  FireDAC.Stan.Async, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, Vcl.ComCtrls, Horse, Horse.Jhonson;

const c_API_PORT = 9000;

type
  TfrmServer = class(TForm)
    StatusBar: TStatusBar;
    Ativar_API: TButton;
    Parar_API: TButton;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);

    procedure Ativar_APIClick(Sender: TObject);
    procedure Parar_APIClick(Sender: TObject);

  private // Servidor

    procedure ShowStatus;

    procedure Run_API;
    procedure Stop_API;



  private // REST API

    // obtem dados da pessoa idpessoa
    procedure GET_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    // insert pessoa
    procedure POST_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    // update pessoa
    procedure PUT_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);

    // delete pessoa
    procedure DELETE_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);

  public

  end;

var
  frmServer: TfrmServer;

implementation

{$R *.dfm}

uses uDMConexao, uDMServerContainer, System.JSON, uPessoa;

// remove caracteres n�o num�ricos
function OnlyNumbers(str : string) : string;
var x : integer;
begin
  Result := '';
  for x := 0 to Length(str) - 1 do begin
    if (str.Chars[x] In ['0'..'9']) then begin
      Result := Result + str.Chars[x];
    end;
  end;
end;

procedure TfrmServer.Ativar_APIClick(Sender: TObject);
begin
  Run_API;
  ShowStatus;
end;

procedure TfrmServer.DELETE_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var idpessoa: integer;
    dados, ret: TJSONObject;
begin // deletar uma pessoa

  idpessoa := Req.Params['id'].ToInteger;

  if (idpessoa > 0) and DMPessoa.ApagarPessoa( idpessoa ) then begin
    // sucesso
    ret := TJSONObject.Create.AddPair('status',200).AddPair('sucess',true).AddPair('message','registro apagado') ;
    Res.Send<TJSONObject>( ret );
  end
  else begin
    // algo saiu errado
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','not found') ;
    Res.Send<TJSONObject>( ret );
  end;

end;

procedure TfrmServer.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Stop_API;
end;

procedure TfrmServer.FormCreate(Sender: TObject);
begin
  ShowStatus;
end;

procedure TfrmServer.GET_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var idpessoa: integer;
    dados, ret: TJSONObject;
begin // obtem dados da pessoa idpessoa

  idpessoa := Req.Params['id'].ToInteger;

  if idpessoa > 0 then begin
    // devolve dados sobre idpessoa
    if DMPessoa.Pessoa( idpessoa, dados ) then begin
      // sucesso
      ret := TJSONObject.Create.AddPair('status',200).AddPair('data', TJSONArray.Create.Add( dados ) );
      Res.Send<TJSONObject>( ret );
    end
    else begin
      // n�o localizado
      ret := TJSONObject.Create.AddPair('status',204).AddPair('sucess',false).AddPair('message','not found') ;
      Res.Send<TJSONObject>( ret );
    end;
  end
  else begin
    // id invalido
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','invalid ID');
    Res.Send<TJSONObject>( ret );
  end;
end;

procedure TfrmServer.Parar_APIClick(Sender: TObject);
begin
  Stop_API;
  ShowStatus;
end;

procedure TfrmServer.POST_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var jo, ret: TJSONObject;
    flnatureza: integer;
    dsdocumento,nmprimeiro,nmsegundo,cep,dsuf,nmcidade,nmbairro,nmlogradouro,dscomplemento: string;
    idpessoa, idendereco: integer;
begin // registrar uma pessoa
  // espera um json:
//  {
//      "flnatureza": 1,
//      "dsdocumento": "000.000.0001-23",
//      "nmprimeiro": "Jos�",
//      "nmsegundo": "Silva",
//      "cep": "07092-070"
//  }

  // json recebido
  jo := Req.Body<TJSONObject>;

  // validar dados recebidos
  flnatureza := jo.GetValue<integer>('flnatureza',999999999 );
  if flnatureza = 999999999 then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''flnatureza'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  dsdocumento := trim( jo.GetValue<string>('dsdocumento',''));
  if dsdocumento = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''dsdocumento'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  nmprimeiro := trim( jo.GetValue<string>('nmprimeiro',''));
  if nmprimeiro = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''nmprimeiro'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  nmsegundo := trim( jo.GetValue<string>('nmsegundo',''));
  if nmsegundo = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''nmsegundo'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  cep := OnlyNumbers( jo.GetValue<string>('cep','') );
  if cep = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''cep'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end
  else if Length(cep) <> 8 then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''cep'' inv�lido');
    Res.Send<TJSONObject>( ret );
    exit;
  end
  else begin
    // pesquisa cep, e obtem campos necess�rios
    if not DataModule1.Consultar_WS_ViaCEP(cep,dsuf,nmcidade,nmbairro,nmlogradouro,dscomplemento) then  begin
      // erro
      ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','cep n�o existe');
      Res.Send<TJSONObject>( ret );
      exit;
    end;
  end;

  // registrar //

  idpessoa := DMPessoa.RegistrarPessoa( flnatureza, dsdocumento, nmprimeiro, nmsegundo );

  if idpessoa <= 0 then begin
    // erro
    ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao cadastrar pessoa');
    Res.Send<TJSONObject>( ret );
  end
  else begin
    // pessoa: OK --> cadastrar endere�o

    idendereco := DMPessoa.RegistrarEndereco( idpessoa, cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento );

    if idendereco <= 0 then begin
      // erro
      ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao cadastrar endere�o');
      Res.Send<TJSONObject>( ret );
      exit;
    end;
    // endere�o OK
    ret := TJSONObject.Create.AddPair('status',201).AddPair('sucess',true).AddPair('idpessoa',idpessoa).AddPair('idendereco',idendereco);
    Res.Send<TJSONObject>( ret );
  end;

end;

procedure TfrmServer.PUT_pessoa(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var jo, ret: TJSONObject;
    idpessoa,idendereco,flnatureza: integer;
    dsdocumento,nmprimeiro,nmsegundo,cep,dsuf,nmcidade,nmbairro,nmlogradouro,dscomplemento: string;
begin // Alterar cadastro de uma pessoa
  // espera um json:
//    {
//        "idpessoa": 123
//        "flnatureza": 1,
//        "dsdocumento": "000.000.0001-23",
//        "nmprimeiro": "Jos�",
//        "nmsegundo": "Silva",
//        "cep": "07092-080"
//    }

  // json recebido
  jo := Req.Body<TJSONObject>;

  // validar idpessoa
  idpessoa := jo.GetValue<integer>('idpessoa', 0 );
  if idpessoa <= 0 then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''idpessoa'' inv�lido');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  // validar dados recebidos
  flnatureza := jo.GetValue<integer>('flnatureza',999999999 );
  if flnatureza = 999999999 then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''flnatureza'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  dsdocumento := trim( jo.GetValue<string>('dsdocumento',''));
  if dsdocumento = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''dsdocumento'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  nmprimeiro := trim( jo.GetValue<string>('nmprimeiro',''));
  if nmprimeiro = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''nmprimeiro'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  nmsegundo := trim( jo.GetValue<string>('nmsegundo',''));
  if nmsegundo = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''nmsegundo'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

  cep := OnlyNumbers( jo.GetValue<string>('cep','') );
  if cep = '' then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''cep'' � obrigat�rio');
    Res.Send<TJSONObject>( ret );
    exit;
  end
  else if Length(cep) <> 8 then begin
    ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','campo ''cep'' inv�lido');
    Res.Send<TJSONObject>( ret );
    exit;
  end
  else begin
    // pesquisa cep, e obtem campos necess�rios
    if not DataModule1.Consultar_WS_ViaCEP(cep,dsuf,nmcidade,nmbairro,nmlogradouro,dscomplemento) then  begin
      // erro
      ret := TJSONObject.Create.AddPair('status',400).AddPair('sucess',false).AddPair('message','cep n�o existe');
      Res.Send<TJSONObject>( ret );
      exit;
    end;
  end;

  // Registrar altera��es

  if DMPessoa.AlterarPessoa( idpessoa, flnatureza, dsdocumento, nmprimeiro, nmsegundo ) then begin
    // cadastro da pessoa OK --> atualizar endereco

    idendereco := DMPessoa.Pesquisar_idendereco( idpessoa );

    if idendereco > 0 then begin
      // atualizar
      if DMPessoa.AlterarEndereco( idendereco, cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento ) then begin
        ret := TJSONObject.Create.AddPair('status',200).AddPair('sucess',true);
        Res.Send<TJSONObject>( ret );
        exit;
      end
      else begin
        ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao gravar dados da pessoa/endere�o');
        Res.Send<TJSONObject>( ret );
        exit;
      end;
    end;

    if idendereco = 0 then begin
      // n�o h� endere�o --> cadastrar
      idendereco := DMPessoa.RegistrarEndereco( idpessoa, cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento );
      if idendereco <= 0 then begin
        // erro
        ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao cadastrar endere�o');
        Res.Send<TJSONObject>( ret );
        exit;
      end;
      // endere�o OK
      ret := TJSONObject.Create.AddPair('status',201).AddPair('sucess',true).AddPair('idpessoa',idpessoa).AddPair('idendereco',idendereco);
      Res.Send<TJSONObject>( ret );
      exit;
    end
    else begin
      // idendereco = -1 --> endereco invalido --> recadastrar endere�o

      // apagar endere�o invalido
      if DMPessoa.ApagarEndereco( idpessoa ) then begin
        // registrar novo endereco
        idendereco := DMPessoa.RegistrarEndereco( idpessoa, cep, dsuf, nmcidade, nmbairro, nmlogradouro, dscomplemento );
        if idendereco <= 0 then begin
          // erro
          ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao cadastrar endere�o');
          Res.Send<TJSONObject>( ret );
          exit;
        end;
        // endere�o OK
        ret := TJSONObject.Create.AddPair('status',201).AddPair('sucess',true).AddPair('idpessoa',idpessoa).AddPair('idendereco',idendereco);
        Res.Send<TJSONObject>( ret );
        exit;
      end
      else begin
        ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao atualizar endere�o');
        Res.Send<TJSONObject>( ret );
        exit;
      end;

    end;

  end
  else begin
    // erro
    ret := TJSONObject.Create.AddPair('status',500).AddPair('sucess',false).AddPair('message','erro ao gravar dados endere�o');
    Res.Send<TJSONObject>( ret );
    exit;
  end;

end;

procedure TfrmServer.Run_API;
begin
  // registra
  THorse.Use( Jhonson );

  //----------------------------------------------------------------------------

  THorse.Get('ping',
  procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
  var LBody: TJSONObject;
  begin
    LBody := Req.Body<TJSONObject>;
    // devolver
    if uDMConexao.DataModule1.FDConnection1.Connected then begin
      Res.Send<TJSONObject>( TJSONObject.Create.AddPair('status',200).AddPair('sucess',true).AddPair('message','runnig') );
    end
    else begin
      Res.Send<TJSONObject>( TJSONObject.Create.AddPair('status',200).AddPair('sucess',true).AddPair('message','pong') );
    end;
  end );

  //----------------------------------------------------------------------------

  // obtem dados da pessoa idpessoa
  THorse.GET('pessoa/:id', GET_pessoa );

  //----------------------------------------------------------------------------

  // registrar pessoa e cep
  THorse.POST('pessoa', POST_pessoa );

  //----------------------------------------------------------------------------

  THorse.DELETE('pessoa/:id', DELETE_pessoa );

  //----------------------------------------------------------------------------

  THorse.Put('pessoa', PUT_pessoa );

  //----------------------------------------------------------------------------


  THorse.Listen( c_API_PORT );
end;

procedure TfrmServer.ShowStatus;
begin
  Ativar_API.Enabled := not THorse.IsRunning;
  Parar_API.Enabled := THorse.IsRunning;

  StatusBar.Panels[3].Text := IntToStr( c_API_PORT );

  if THorse.IsRunning then begin
    StatusBar.Panels[1].Text := 'ATIVA';
  end
  else begin
    StatusBar.Panels[1].Text := 'INATIVA'
  end;
end;


procedure TfrmServer.Stop_API;
begin
  if THorse.IsRunning then THorse.StopListen;
end;

end.

