unit uCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, REST.Response.Adapter, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls,
  System.JSON;

type
  TfrmCliente = class(TForm)
    bAPI_ping: TButton;
    ed_idpessoa: TEdit;
    Label1: TLabel;
    ed_flnatureza: TEdit;
    ed_dsdocumento: TEdit;
    ed_nmprimeiro: TEdit;
    ed_nmsegundo: TEdit;
    ed_dtregistro: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label2: TLabel;
    bNovo: TButton;
    bEditar: TButton;
    bExcluir: TButton;
    bGravar: TButton;
    bCancelar: TButton;
    ed_dscep: TEdit;
    StatusBar1: TStatusBar;
    ed_dsuf: TEdit;
    ed_nmcidade: TEdit;
    ed_nmbairro: TEdit;
    ed_nmlogradouro: TEdit;
    ed_dscomplemento: TEdit;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    bProcessamentoEmLote: TButton;
    OpenDialog: TOpenDialog;
    ProgressBar: TProgressBar;

    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure bAPI_pingClick(Sender: TObject);
    procedure ed_idpessoaKeyPress(Sender: TObject; var Key: Char);
    procedure ed_idpessoaChange(Sender: TObject);
    procedure bNovoClick(Sender: TObject);
    procedure bEditarClick(Sender: TObject);
    procedure bExcluirClick(Sender: TObject);
    procedure bGravarClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure ed_dscepChange(Sender: TObject);
    procedure bProcessamentoEmLoteClick(Sender: TObject);

  private
    modo: string;

    procedure LimparCamposPessoa;

    procedure StatusCamposPessoa( OnOff: boolean );

    procedure SetModo( aModo: string );

  public // processamento normal

    procedure ProcessarOnError( Sender: TObject);

    procedure Executar_GET_ping;
    procedure Tratar_GET_ping;

    procedure Executar_GET( idpessoa: integer );
    procedure Tratar_GET;

    procedure Executar_POST;
    procedure Tratar_POST;

    procedure Executar_PUT;
    procedure Tratar_PUT;

    procedure Executar_DELETE( idpessoa: integer );
    procedure Tratar_DELETE;

  public // usado para carregamento em lote

    // para controle por ProcessamentoEmLote()
    CarregamentoComSucesso: array of boolean;

    procedure Executar_POST_ex( INDEXLOTE,flnatureza: integer; dsdocumento,nmprimeiro,nmsegundo,dscep: string );
    procedure Tratar_POST_ex;
    procedure ProcessarOnError_ex( Sender: TObject);

    procedure ProcessamentoEmLote( aFile: string );

    procedure Wait_ms( ms : cardinal );

  end;

var
  frmCliente: TfrmCliente;

implementation

{$R *.dfm}

uses uDM, System.Generics.Collections;

procedure TfrmCliente.bCancelarClick(Sender: TObject);
begin
  if Modo = 'Cancelar' then begin
    exit;
  end;
  SetModo('Cancelar');
end;

procedure TfrmCliente.bEditarClick(Sender: TObject);
begin
  if Modo = 'Editar' then begin
    exit;
  end;
  SetModo('Editar');
end;

procedure TfrmCliente.bExcluirClick(Sender: TObject);
begin
  if Modo = 'Excluir' then begin
    exit;
  end;
  SetModo('Excluir');
end;

procedure TfrmCliente.bGravarClick(Sender: TObject);
begin
  if Modo = 'Gravar' then begin
    exit;
  end;
  SetModo('Gravar');
end;

procedure TfrmCliente.bNovoClick(Sender: TObject);
begin
  if Modo = 'Novo' then begin
    exit;
  end;
  SetModo('Novo');
end;

procedure TfrmCliente.bProcessamentoEmLoteClick(Sender: TObject);
begin
  OpenDialog.InitialDir := GetCurrentDir;
  if OpenDialog.Execute then begin
    ProcessamentoEmLote( OpenDialog.FileName );
  end;
end;

procedure TfrmCliente.bAPI_pingClick(Sender: TObject);
begin
  Executar_GET_ping;
end;

procedure TfrmCliente.ed_dscepChange(Sender: TObject);
begin
  if Modo = 'Editar' then begin
    ed_dsuf.Text := '';
    ed_nmcidade.Text := '';
    ed_nmbairro.Text := '';
    ed_nmlogradouro.Text := '';
    ed_dscomplemento.Text := '';
  end;
end;

procedure TfrmCliente.ed_idpessoaChange(Sender: TObject);
begin
  LimparCamposPessoa;
  StatusCamposPessoa( false );
end;

procedure TfrmCliente.ed_idpessoaKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then begin
    ed_idpessoa.Tag := StrToIntDef( ed_idpessoa.Text,0);
    Executar_GET( ed_idpessoa.Tag );
    SetModo('NovoOuEditarOuExcluir');
  end;
end;

procedure TfrmCliente.Executar_DELETE(idpessoa: integer);
begin
  StatusBar1.Panels[4].Text := '';
  try
    DM.RESTRequest_DELETE.Params.Clear;
    DM.RESTRequest_DELETE.Body.ClearBody;
    DM.RESTRequest_DELETE.Method := rmDELETE;
    DM.RESTRequest_DELETE.Resource := 'Pessoa/' + inttostr(idpessoa);
    DM.RESTRequest_DELETE.ExecuteAsync( Tratar_DELETE, true, true, ProcessarOnError );
  except on e:exception do
    begin
      ed_idpessoa.Tag := 0;
      Showmessage('Erro ao acessar servidor:' + e.Message );
    end;
  end;
end;

procedure TfrmCliente.Executar_GET( idpessoa: integer );
begin
  StatusBar1.Panels[4].Text := '';
  try
    DM.RESTRequest_GET.Params.Clear;
    DM.RESTRequest_GET.Body.ClearBody;
    DM.RESTRequest_GET.Method := rmGET;
    DM.RESTRequest_GET.Resource := 'Pessoa/' + inttostr(idpessoa);
    DM.RESTRequest_GET.ExecuteAsync( Tratar_GET, true, true, ProcessarOnError );
  except on e:exception do
    begin
      ed_idpessoa.Tag := 0;
      Showmessage('Erro ao acessar servidor:' + e.Message );
    end;
  end;
end;

procedure TfrmCliente.Executar_GET_ping;
begin
  StatusBar1.Panels[4].Text := '';
  StatusBar1.Panels[1].Text := '...';
  try
    DM.RESTRequestGET_ping.Params.Clear;
    DM.RESTRequestGET_ping.Body.ClearBody;
    DM.RESTRequestGET_ping.Method := rmGET;
    DM.RESTRequestGET_ping.Resource := 'IsRunning';
    DM.RESTRequestGET_ping.ExecuteAsync( Tratar_GET_ping, true, true, ProcessarOnError );
  except on e:exception do
    begin
      StatusBar1.Panels[1].Text := '?';
      Showmessage('Erro ao acessar servidor:' + e.Message );
    end;
  end;
end;

function JSON_EscapeString(const value: string): string;
var i : integer;
begin // https://www.json.org/
  result := '';
  for i := 1 to Length(value) do begin
    case value[i] of
      '"' : result := result + '\"';
      '\' : result := result + '\\';
      '/' : result := result + '\/';
      #8  : result := result + '\b';
      #9  : result := result + '\t';
      #10 : result := result + '\n';
      #12 : result := result + '\f';
      #13 : result := result + '\r';
    else
    //TODO : Deal with unicode characters properly!
      result := result + value[i];
    end;
  end;
end;

procedure TfrmCliente.Executar_POST;
var JO: TJSONObject;
begin
  StatusBar1.Panels[4].Text := '';
  JO := TJSONObject.Create;
  try
    JO.AddPair('flnatureza', StrToInt(ed_flnatureza.Text) );
    JO.AddPair('dsdocumento', ed_dsdocumento.Text );
    JO.AddPair('nmprimeiro', ed_nmprimeiro.Text );
    JO.AddPair('nmsegundo', ed_nmsegundo.Text );
    JO.AddPair('cep', ed_dscep.Text );
    try
      DM.RESTRequest_POST.Params.Clear;
      DM.RESTRequest_POST.Body.ClearBody;
      DM.RESTRequest_POST.Method := rmPOST;
      DM.RESTRequest_POST.Resource := 'Pessoa';
      DM.RESTRequest_POST.Body.Add( JO.ToString, ContentTypeFromString('application/json') );
      DM.RESTRequest_POST.ExecuteAsync( Tratar_POST, true, true, ProcessarOnError );
    except on e:exception do
      Showmessage('Erro ao registrar dados no servidor:' + e.Message );
    end;
  finally
    if Assigned(JO) then begin
      JO.DisposeOf;
    end;
  end;

end;

procedure TfrmCliente.ProcessarOnError_ex(Sender: TObject);
begin
  // houve um erro!
end;

procedure TfrmCliente.Tratar_POST_ex;
var json: string;
    JOoriginal, JOresult: TJSONObject;
    JAresult: TJSONArray;
begin
  // ok?
  if (DM.RESTRequest_POST.Response.StatusCode <> 201) and (DM.RESTRequest_POST.Response.StatusCode <> 200) then begin
    exit;
  end;

  // esperado:
  //  {
  //      "result": [
  //          {
  //              "status": 201,
  //              "sucess": true,
  //              "idpessoa": 73,
  //              "idendereco": 42,
  //              "INDEXLOTE": 123    <-- apena quando for processamento me lote
  //          }
  //      ]
  //  }

  // json do retorno
  json := DM.RESTRequest_POST.Response.JSONValue.ToString;

  JOoriginal := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( json ), 0) as TJSONObject;
  try
    JAresult := JOoriginal.FindValue('result') as TJSONArray;
    if Assigned(JAresult) then begin
      // pegar o primeiro item do array
      JOresult := JAresult.Items[0].GetValue<TJSONObject>();
      // sucesso ou fracasso ?
      if JOresult.FindValue('sucess').AsType<boolean> then begin
        try
          CarregamentoComSucesso[ JOresult.FindValue('INDEXLOTE').AsType<integer> ] := true;
        except on e:exception do
          // nada a fazer
        end;
      end;
    end;
  finally
    if Assigned(JOoriginal) then begin
      JOoriginal.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.Executar_POST_ex( INDEXLOTE, flnatureza:integer; dsdocumento,nmprimeiro,nmsegundo,dscep:string);
var JO: TJSONObject;
begin
  JO := TJSONObject.Create;
  try
    JO.AddPair('flnatureza', flnatureza );
    JO.AddPair('dsdocumento', dsdocumento );
    JO.AddPair('nmprimeiro', nmprimeiro );
    JO.AddPair('nmsegundo', nmsegundo );
    JO.AddPair('cep', dscep );
    JO.AddPair('INDEXLOTE', INDEXLOTE ); // vai e volta pela API
    try
      DM.RESTRequest_POST.Params.Clear;
      DM.RESTRequest_POST.Body.ClearBody;
      DM.RESTRequest_POST.Method := rmPOST;
      DM.RESTRequest_POST.Resource := 'Pessoa';
      DM.RESTRequest_POST.Body.Add( JO.ToString, ContentTypeFromString('application/json') );
      //-------------------------------------------------------------------------------------
      DM.RESTRequest_POST.ExecuteAsync( Tratar_POST_ex, true, true, ProcessarOnError_ex );
      //-------------------------------------------------------------------------------------
    except on e:exception do
      // nada a fazer
    end;
  finally
    if Assigned(JO) then begin
      JO.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.Executar_PUT;
var JO: TJSONObject;
begin
  StatusBar1.Panels[4].Text := '';
  JO := TJSONObject.Create;
  try
    JO.AddPair('idpessoa', ed_idpessoa.Tag );
    JO.AddPair('flnatureza', StrToInt(ed_flnatureza.Text) );
    JO.AddPair('dsdocumento', ed_dsdocumento.Text );
    JO.AddPair('nmprimeiro', ed_nmprimeiro.Text );
    JO.AddPair('nmsegundo', ed_nmsegundo.Text );
    JO.AddPair('cep', ed_dscep.Text );
    try
      DM.RESTRequest_PUT.Params.Clear;
      DM.RESTRequest_PUT.Body.ClearBody;
      DM.RESTRequest_PUT.Method := rmPUT;
      DM.RESTRequest_PUT.Resource := 'Pessoa/' + IntToStr( ed_idpessoa.Tag );
      DM.RESTRequest_PUT.Body.Add( JO.ToString, ContentTypeFromString('application/json') );
      DM.RESTRequest_PUT.ExecuteAsync( Tratar_PUT, true, true, ProcessarOnError );
    except on e:exception do
      begin
        Showmessage('ERRO ao registrar dados no servidor:' + e.Message );
      end;
    end;
  finally
    if Assigned(JO) then begin
      JO.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.FormCreate(Sender: TObject);
begin
  Modo := '';
  ProgressBar.Visible := false;
end;

procedure TfrmCliente.FormShow(Sender: TObject);
begin
  SetModo('Default');
  Executar_GET_ping;
end;

procedure TfrmCliente.LimparCamposPessoa;
begin
  ed_flnatureza.Text := '';
  ed_dsdocumento.Text := '';
  ed_nmprimeiro.Text := '';
  ed_nmsegundo.Text := '';
  ed_dtregistro.Text := '';
  ed_dscep.Text := '';
  ed_dsuf.Text := '';
  ed_nmcidade.Text := '';
  ed_nmbairro.Text := '';
  ed_nmlogradouro.Text := '';
  ed_dscomplemento.Text := '';
end;


procedure TfrmCliente.Tratar_DELETE;
var json: string;
    JAresult: TJSONArray;
    JOoriginal, JOresult: TJSONObject;
begin
  if DM.RESTRequest_DELETE.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao deletar registro: '+DM.RESTRequest_DELETE.Response.StatusCode.ToString );
    exit;
  end;

  // esperado:
  //  {
  //      "result": [
  //          {
  //              "status": 200,
  //              "sucess": true,
  //              "message": "registro apagado"
  //          }
  //      ]
  //  }

  // json do retorno
  json := DM.RESTRequest_DELETE.Response.JSONValue.ToString;

  JOoriginal := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( json ), 0) as TJSONObject;
  try
    JAresult := JOoriginal.FindValue('result') as TJSONArray;
    if Assigned(JAresult) then begin

      // objeto com as informa��es
      JOresult := JAresult.Items[0].GetValue<TJSONObject>();

      if JOresult.FindValue('sucess').AsType<boolean> then begin
        Showmessage( JOresult.GetValue<string>('message','') );
      end;

      SetModo('Default');

    end;
  finally
    if Assigned(JOoriginal) then begin
      JOoriginal.DisposeOf;
    end;
  end;

end;


procedure TfrmCliente.Tratar_GET;
var json: string;
    JAresult,JAdata: TJSONArray;
    JOoriginal,JOresult,JOdata: TJSONObject;
begin
  if DM.RESTRequest_GET.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao realizar a consulta: '+DM.RESTRequest_GET.Response.StatusCode.ToString );
    exit;
  end;

  // esperado:
  //  {
  //      "result": [
  //          {
  //              "status": 200,
  //              "data": [
  //                  {
  //                      "idpessoa": 68,
  //                      "flnatureza": "135",
  //                      "dsdocumento": "87582475824",
  //                      "nmprimeiro": "ZE",
  //                      "nmsegundo": "CARIOCA",
  //                      "dtregistro": "2022-10-28",
  //                      "idendereco": 0,
  //                      "dscep": "",
  //                      "dsuf": "",
  //                      "nmcidade": "",
  //                      "nmbairro": "",
  //                      "nmlogradouro": "",
  //                      "dscomplemento": ""
  //                  }
  //              ],
  //              "sucess": true
  //          }
  //      ]
  //  }
  //
  //  ou
  //
  //  {
  //      "result": [
  //          {
  //              "status": 404,
  //              "sucess": false,
  //              "message": "not found"
  //          }
  //      ]
  //  }


  // json do retorno
  json := DM.RESTRequest_GET.Response.JSONValue.ToString;

  JOoriginal := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( json ), 0) as TJSONObject;
  try
    // procurar result
    JAresult := JOoriginal.FindValue('result') as TJSONArray;

    if Assigned(JAresult) then begin

      JOresult := JAresult.Items[0].GetValue<TJSONObject>();

      if not JOresult.FindValue('sucess').AsType<boolean> then begin
        Showmessage( JOresult.GetValue<string>('message','') );
        SetModo('Default');
        exit;
      end;

      if Assigned(JOresult) then begin

        // procurar data
        JAdata := JOresult.FindValue('data') as TJSONArray;

        if Assigned(JAdata) then begin

          JOdata := JAdata.Items[0].GetValue<TJSONObject>();

          // finalmente
          ed_idpessoa.Tag       := JOdata.FindValue('idpessoa').AsType<integer>;
          ed_flnatureza.Text    := JOdata.FindValue('flnatureza').AsType<string>;
          ed_dsdocumento.Text   := JOdata.FindValue('dsdocumento').AsType<string>;
          ed_nmprimeiro.Text    := JOdata.FindValue('nmprimeiro').AsType<string>;
          ed_nmsegundo.Text     := JOdata.FindValue('nmsegundo').AsType<string>;
          ed_dtregistro.Text    := JOdata.FindValue('dtregistro').AsType<string>;
          ed_dscep.Text         := JOdata.FindValue('dscep').AsType<string>;
          ed_dsuf.Text          := JOdata.FindValue('dsuf').AsType<string>;
          ed_nmcidade.Text      := JOdata.FindValue('nmcidade').AsType<string>;
          ed_nmbairro.Text      := JOdata.FindValue('nmbairro').AsType<string>;
          ed_nmlogradouro.Text  := JOdata.FindValue('nmlogradouro').AsType<string>;
          ed_dscomplemento.Text := JOdata.FindValue('dscomplemento').AsType<string>;

        end;
      end;
    end;
  finally
    if Assigned(JOoriginal) then begin
      JOoriginal.DisposeOf;
    end;
    SetModo('NovoOuEditarOuExcluir');
  end;
end;

procedure TfrmCliente.ProcessamentoEmLote( aFile: string );
var SL, SLL: TStringList;
    i: integer;
    Total,Realizados: integer;
    flnatureza: integer;
    dsdocumento,nmprimeiro,nmsegundo,dscep: string;
begin
  SL := TStringList.Create;
  try
    // carregar arquivo
    SL.LoadFromFile( aFile );

    if SL.Count = 0 then begin
      exit;
    end;

    SetLength( CarregamentoComSucesso, SL.Count );

    Total := SL.Count;
    Realizados := 0;
    ProgressBar.Position := 0;
    ProgressBar.Min := 0;
    ProgressBar.Max := 100;
    ProgressBar.Visible := true;

    // para carregar uma linha por vez
    SLL := TStringList.Create;
    try
      // uma linha (== um registro) por vez de SL
      // separar
      // exclui de SL se ok
      // o que sobrar fica no arquivo .invalidos
      for i := 0 to SL.Count-1 do begin

        SLL.StrictDelimiter := True;

        // recebe a linha
        SLL.CommaText := SL[i];

        // campos
        flnatureza  := StrToIntDef( SLL[0], 0 );
        dsdocumento := SLL[1];
        nmprimeiro  := SLL[2];
        nmsegundo   := SLL[3];
        dscep       := SLL[4];

        // a confirma��o volta pela API no campo "INDEXLOTE"
        // isso ser� trado em Tratar_POST_ex()
        CarregamentoComSucesso[i] := false;

        // processar a linha
        Executar_POST_ex( i, flnatureza, dsdocumento, nmprimeiro, nmsegundo, dscep );

        inc( Realizados );
        ProgressBar.Position := Round( 100*realizados/Total );

        Wait_ms(250);

      end; // for

      // comparar SL com CarregamentoComSucesso[]

      for i := SL.Count-1 downto 0 do begin
        // remover os itens cadastrados com sucesso
        if CarregamentoComSucesso[i] then begin
          SL.Delete(i);
        end;
      end;
      // se sobrou alguma linha em SL --> gerar arquivos com invalidos
      if SL.Count > 0 then begin
        SL.SaveToFile( aFile + '.invalidos' );
        Showmessage('*** Carga realizada com sucesso parcial.'#13#13
                   +'Os casos que n�o foram registrados, est�o salvos no arquivo:'#13#13
                   +'      '+System.SysUtils.ExtractFileName(aFile + '.invalidos')+#13#13
                   +'na mesma pasta do original');
      end
      else begin
        Showmessage('*** Carga realizada com sucesso ***');
      end;

    finally
      FreeAndNil(SLL);
    end;

  finally
    FreeAndNil(SL);
    ProgressBar.Visible := false;
  end;
end;

procedure TfrmCliente.ProcessarOnError(Sender: TObject);
begin
  if Assigned(Sender) and (Sender is Exception) then begin
    Showmessage( Exception(Sender).Message );
  end;

end;

procedure TfrmCliente.SetModo(aModo: string);
var excluir: boolean;
begin
  if aModo = 'Default' then begin
    Modo := 'Default';
    LimparCamposPessoa;
    ed_idpessoa.Text := '';
    ed_idpessoa.Enabled := true;
    StatusCamposPessoa(false);
    ed_idpessoa.SetFocus;
    //
    bNovo.Enabled := true;
    bEditar.Enabled := false;
    bExcluir.Enabled := false;
    bGravar.Enabled := false;
    bCancelar.Enabled := false;
    exit;
  end;
  if aModo = 'Novo' then begin
    Modo := 'Novo';
    LimparCamposPessoa;
    ed_idpessoa.Text := '';
    ed_idpessoa.Enabled := false;
    StatusCamposPessoa(true);
    ed_flnatureza.SetFocus;
    //
    bNovo.Enabled := true;
    bEditar.Enabled := false;
    bExcluir.Enabled := false;
    bGravar.Enabled := true;
    bCancelar.Enabled := true;
    exit;
  end;
  if aModo = 'Editar' then begin
    if ed_idpessoa.Tag = 0 then begin
      exit;
    end;
    Modo := 'Editar';
//    LimparCamposPessoa;
//    ed_idpessoa.Text := '';
    ed_idpessoa.Enabled := false;
    StatusCamposPessoa(true);
    ed_flnatureza.SetFocus;
    //
    bNovo.Enabled := false;
    bEditar.Enabled := true;
    bExcluir.Enabled := false;
    bGravar.Enabled := true;
    bCancelar.Enabled := true;
    exit;
  end;
  //-----------------------------------------------------------
  if aModo = 'Excluir' then begin
    if ed_idpessoa.Tag = 0 then begin
      exit;
    end;
    Modo := 'Excluir';
//    LimparCamposPessoa;
//    ed_idpessoa.Text := '';
    ed_idpessoa.Enabled := false;
    StatusCamposPessoa(false);
//    ed_flnatureza.SetFocus;
    //
    bNovo.Enabled := false;
    bEditar.Enabled := false;
    bExcluir.Enabled := true;
    bGravar.Enabled := false;
    bCancelar.Enabled := false;
    //
    excluir := MessageBox( Handle
                         , 'Deseja realmente excluir esta pessoa?'
                         , 'ATEN��O', MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON1 + MB_APPLMODAL ) = IDYES;
    if excluir then begin
      Executar_DELETE(ed_idpessoa.Tag);
      exit;
    end
    else begin
      SetModo('NovoOuEditarOuExcluir');
      exit;
    end;
    exit;
  end;
  //-----------------------------------------------------------
  if aModo = 'NovoOuEditarOuExcluir' then begin
    Modo := 'NovoOuEditarOuExcluir';
    ed_idpessoa.Enabled := true;
    StatusCamposPessoa(false);
    ed_idpessoa.SetFocus;
    //
    bNovo.Enabled := true;
    bEditar.Enabled := true;
    bExcluir.Enabled := true;
    bGravar.Enabled := false;
    bCancelar.Enabled := false;
    exit;
  end;
  //-----------------------------------------------------------
  if aModo = 'Cancelar' then begin
    if Modo = 'Novo' then begin
      SetModo('Default');
      exit;
    end;
    if Modo = 'Editar' then begin
      if ed_idpessoa.Tag = 0 then begin
        // erro
        SetModo('Default');
        exit;
      end;
      // atualizar os edit's
      Executar_GET( ed_idpessoa.Tag );
      SetModo('NovoOuEditarOuExcluir');
      exit;
    end;
  end;
  //-----------------------------------------------------------
  if aModo = 'Gravar' then begin
    if Modo = 'Novo' then begin
      Executar_POST;
      // recarregar --> TratarPOST
      exit;
    end;
    if Modo = 'Editar' then begin
      if ed_idpessoa.Tag = 0 then begin
        // erro
        exit;
      end;
      Executar_PUT;
      // atualizar os edit's --> TratarPUT
      exit;
    end;
  end;
end;

procedure TfrmCliente.StatusCamposPessoa(OnOff: boolean);
begin
  ed_flnatureza.Enabled := OnOff;
  ed_dsdocumento.Enabled := OnOff;
  ed_nmprimeiro.Enabled := OnOff;
  ed_nmsegundo.Enabled := OnOff;
  ed_dtregistro.Enabled := false;
  ed_dscep.Enabled := OnOff;
  ed_dsuf.Enabled := false;
  ed_nmcidade.Enabled := false;
  ed_nmbairro.Enabled := false;
  ed_nmlogradouro.Enabled := false;
  ed_dscomplemento.Enabled := false;
end;

procedure TfrmCliente.Tratar_GET_ping;
var JOoriginal: TJSONObject;
    JAresult: TJSONArray;
    json, info: string;
begin
  if DM.RESTRequestGET_ping.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao realizar a consulta: '+DM.RESTRequest_GET.Response.StatusCode.ToString );
    exit;
  end;

  // esperado:
  //  {
  //      "result": [
  //          "Running"
  //      ]
  //  }

  json := DM.RESTRequestGET_ping.Response.JSONValue.ToString;
  info := '';

  JOoriginal := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( json ), 0) as TJSONObject;
  try

    JAresult := JOoriginal.FindValue('result') as TJSONArray;

    if Assigned(JAresult) then begin
      // json com as informa��es
      info := JAresult.Items[0].GetValue<string>();
    end;

  finally
    if Assigned(JOoriginal) then begin
      JOoriginal.DisposeOf;
    end;
  end;

  if SameText( info, 'Running' ) then begin
    StatusBar1.Panels[1].Text := 'Ativa';
  end
  else begin
    StatusBar1.Panels[1].Text := 'Inativa';
  end;
end;

procedure TfrmCliente.Tratar_POST;
var json: string;
    JOoriginal, JOresult: TJSONObject;
    JAresult: TJSONArray;
begin

  if (DM.RESTRequest_POST.Response.StatusCode <> 201) and (DM.RESTRequest_POST.Response.StatusCode <> 200) then begin
    Showmessage('Ocorreu um erro ao salvar registro: '+DM.RESTRequest_POST.Response.StatusCode.ToString );
    exit;
  end;

  // esperado:
  //  {
  //      "result": [
  //          {
  //              "status": 201,
  //              "sucess": true,
  //              "idpessoa": 73,
  //              "idendereco": 42
  //          }
  //      ]
  //  }

  // json do retorno
  json := DM.RESTRequest_POST.Response.JSONValue.ToString;

  JOoriginal := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( json ), 0) as TJSONObject;
  try

    JAresult := JOoriginal.FindValue('result') as TJSONArray;

    if Assigned(JAresult) then begin
      // objeto com as informa��es
      JOresult := JAresult.Items[0].GetValue<TJSONObject>();

      if JOresult.FindValue('sucess').AsType<boolean> then begin

        ed_idpessoa.Tag := JOresult.FindValue('idpessoa').AsType<integer>;
        ed_idpessoa.Text := IntToStr( ed_idpessoa.Tag );
        if ed_idpessoa.Tag > 0 then begin
          Executar_GET( ed_idpessoa.Tag );
          SetModo('NovoOuEditarOuExcluir');
        end;
        StatusBar1.Panels[4].Text := '';

      end
      else begin
        Showmessage( JOresult.GetValue<string>('message','') );
        StatusBar1.Panels[4].Text := JOresult.GetValue<string>('message','');
      end;

    end;
  finally
    if Assigned(JOoriginal) then begin
      JOoriginal.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.Tratar_PUT;
var json: string;
    JOoriginal, JOresult: TJSONObject;
    JAresult: TJSONArray;
begin
  if DM.RESTRequest_PUT.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao salvar registro: '+DM.RESTRequest_PUT.Response.StatusCode.ToString );
    exit;
  end;

  // esperado:
  //  {
  //      "result": [
  //          {
  //              "status": 200,
  //              "sucess": true
  //          }
  //      ]
  //  }
  //
  // ou
  //
  //  {
  //    "result":[
  //      {
  //        "status":400,
  //        "sucess":false,
  //        "message":"cep n�o existe"
  //      }
  //    ]
  //  }

  // json do retorno
  json := DM.RESTRequest_PUT.Response.JSONValue.ToString;

  JOoriginal := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes( json ), 0) as TJSONObject;
  try

    JAresult := JOoriginal.FindValue('result') as TJSONArray;

    if Assigned(JAresult) then begin

      // objeto com as informa��es
      JOresult := JAresult.Items[0].GetValue<TJSONObject>();

      if JOresult.FindValue('sucess').AsType<boolean> then begin

        if ed_idpessoa.Tag > 0 then begin
          Executar_GET( ed_idpessoa.Tag );
          SetModo('NovoOuEditarOuExcluir');
        end;
        StatusBar1.Panels[4].Text := '';

      end
      else begin
        Showmessage( JOresult.GetValue<string>('message','') );
        StatusBar1.Panels[4].Text := JOresult.GetValue<string>('message','');
      end;

    end;
  finally
    if Assigned(JOoriginal) then begin
      JOoriginal.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.Wait_ms(ms: cardinal);
var tk : cardinal;
begin
  tk := GetTickCount() + ms;
  repeat
    Application.ProcessMessages;
    sleep(1);
  until GetTickCount()>tk;
end;

end.
