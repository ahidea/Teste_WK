unit uCliente;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, REST.Types, FireDAC.Stan.Intf,
  FireDAC.Stan.Option, FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS,
  FireDAC.Phys.Intf, FireDAC.DApt.Intf, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, REST.Response.Adapter, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, Vcl.StdCtrls, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls;

type
  TfrmCliente = class(TForm)
    bAPI_ping: TButton;
    Memo1: TMemo;
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

    procedure FormCreate(Sender: TObject);

    procedure bAPI_pingClick(Sender: TObject);
    procedure ed_idpessoaKeyPress(Sender: TObject; var Key: Char);
    procedure ed_idpessoaChange(Sender: TObject);
    procedure bNovoClick(Sender: TObject);
    procedure bEditarClick(Sender: TObject);
    procedure bExcluirClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure bGravarClick(Sender: TObject);
    procedure bCancelarClick(Sender: TObject);
    procedure ed_dscepChange(Sender: TObject);
    procedure bProcessamentoEmLoteClick(Sender: TObject);

  private
    modo: string;

    procedure LimparCamposPessoa;

    procedure StatusCamposPessoa( OnOff: boolean );

    procedure SetModo( aModo: string );

  public

    procedure ProcessarOnError( Sender: TObject);

    procedure ExecutarGET_ping;
    procedure TratarGET_ping;

    procedure ExecutarGET( idpessoa: integer );
    procedure TratarGET;

    procedure ExecutarPOST;
    procedure TratarPOST;

    procedure ExecutarPUT;
    procedure TratarPUT;

    procedure ExecutarDELETE( idpessoa: integer );
    procedure TratarDELETE;

    function  ExecutarPOST_ex(flnatureza:integer;dsdocumento,nmprimeiro,nmsegundo,dscep:string) : boolean;
    procedure TratarPOST_ex;
    procedure ProcessarOnError_ex( Sender: TObject);
    procedure ProcessamentoEmLote;

  end;

var
  frmCliente: TfrmCliente;

implementation

{$R *.dfm}

uses uDM, System.JSON, System.Generics.Collections;

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
  ProcessamentoEmLote;
end;

procedure TfrmCliente.bAPI_pingClick(Sender: TObject);
begin
  ExecutarGET_ping;
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
    ExecutarGET( ed_idpessoa.Tag );
    SetModo('NovoOuEditarOuExcluir');
  end;
end;

procedure TfrmCliente.ExecutarDELETE(idpessoa: integer);
begin
  StatusBar1.Panels[4].Text := '';
  try
    DM.RESTRequestDELETE.Params.Clear;
    DM.RESTRequestDELETE.Body.ClearBody;
    DM.RESTRequestDELETE.Method := rmDELETE;
    DM.RESTRequestDELETE.Resource := 'pessoa/' + inttostr(idpessoa);
    DM.RESTRequestDELETE.ExecuteAsync( TratarDELETE, true, true, ProcessarOnError );
  except on e:exception do
    begin
      ed_idpessoa.Tag := 0;
      Showmessage('Erro ao acessar servidor:' + e.Message );
    end;
  end;
end;

procedure TfrmCliente.ExecutarGET( idpessoa: integer );
begin
  StatusBar1.Panels[4].Text := '';
  try
    DM.RESTRequestGET.Params.Clear;
    DM.RESTRequestGET.Body.ClearBody;
    DM.RESTRequestGET.Method := rmGET;
    DM.RESTRequestGET.Resource := 'pessoa/' + inttostr(idpessoa);
    DM.RESTRequestGET.ExecuteAsync( TratarGET, true, true, ProcessarOnError );
  except on e:exception do
    begin
      ed_idpessoa.Tag := 0;
      Showmessage('Erro ao acessar servidor:' + e.Message );
    end;
  end;
end;

procedure TfrmCliente.ExecutarGET_ping;
begin
  StatusBar1.Panels[4].Text := '';
  StatusBar1.Panels[1].Text := '...';
  try
    DM.RESTRequestGET_ping.Params.Clear;
    DM.RESTRequestGET_ping.Body.ClearBody;
    DM.RESTRequestGET_ping.Method := rmGET;
    DM.RESTRequestGET_ping.Resource := 'ping' ;
    DM.RESTRequestGET_ping.ExecuteAsync( TratarGET_ping, true, true, ProcessarOnError );
  except on e:exception do
    begin
      StatusBar1.Panels[1].Text := '?';
      Showmessage('Erro ao acessar servidor:' + e.Message );
    end;
  end;
end;

procedure TfrmCliente.ExecutarPOST;
var JO: TJSONObject;
begin
  StatusBar1.Panels[4].Text := '';
  JO := TJSONObject.Create;
  try
    //JO.AddPair('idpessoa', ed_idpessoa.Tag );
    JO.AddPair('flnatureza', StrToInt(ed_flnatureza.Text) );
    JO.AddPair('dsdocumento', ed_dsdocumento.Text );
    JO.AddPair('nmprimeiro', ed_nmprimeiro.Text );
    JO.AddPair('nmsegundo', ed_nmsegundo.Text );
    JO.AddPair('cep', ed_dscep.Text );

    //Memo1.Text := JO.ToString;

    try
      DM.RESTRequestPOST.Params.Clear;
      DM.RESTRequestPOST.Body.ClearBody;
      DM.RESTRequestPOST.Method := rmPOST;
      DM.RESTRequestPOST.Resource := 'pessoa';
      DM.RESTRequestPOST.Body.Add( JO.ToString, ContentTypeFromString('application/json') );
      DM.RESTRequestPOST.ExecuteAsync( TratarPOST, true, true, ProcessarOnError );
    except on e:exception do
      Showmessage('Erro ao registrar dados no servidor:' + e.Message );
    end;
  finally
    if Assigned(JO) then begin
      JO.DisposeOf;
    end;
  end;
end;

var __magic__: boolean;
procedure TfrmCliente.ProcessarOnError_ex(Sender: TObject);
begin
  // houve um erro!
  __magic__ := false;
end;

procedure TfrmCliente.TratarPOST_ex;
var JO: TJSONObject;
begin
  if (DM.RESTRequestPOST.Response.StatusCode <> 201) and (DM.RESTRequestPOST.Response.StatusCode <> 200) then begin
    __magic__ := false; // erro
    exit;
  end;
  // verifica se houve sucesso
  JO := DM.RESTRequestPOST.Response.JSONValue as TJSONObject;
  __magic__ := JO.GetValue<boolean>('sucess',false);
end;

function TfrmCliente.ExecutarPOST_ex(flnatureza:integer;dsdocumento,nmprimeiro,nmsegundo,dscep:string) : boolean;
var JO: TJSONObject;
begin
  __magic__ := false;
  JO := TJSONObject.Create;
  try
    JO.AddPair('flnatureza', flnatureza );
    JO.AddPair('dsdocumento', dsdocumento );
    JO.AddPair('nmprimeiro', nmprimeiro );
    JO.AddPair('nmsegundo', nmsegundo );
    JO.AddPair('cep', dscep );
    try
      DM.RESTRequestPOST.Params.Clear;
      DM.RESTRequestPOST.Body.ClearBody;
      DM.RESTRequestPOST.Method := rmPOST;
      DM.RESTRequestPOST.Resource := 'pessoa';
      DM.RESTRequestPOST.Body.Add( JO.ToString, ContentTypeFromString('application/json') );
      __magic__ := false;
      DM.RESTRequestPOST.ExecuteAsync( TratarPOST_ex, true, true, ProcessarOnError_ex );
      Result := __magic__;
    except on e:exception do
      Showmessage('Erro ao registrar dados no servidor:' + e.Message );
    end;
  finally
    if Assigned(JO) then begin
      JO.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.ExecutarPUT;
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

    //Memo1.Text := JO.ToString;

    try
      DM.RESTRequestPUT.Params.Clear;
      DM.RESTRequestPUT.Body.ClearBody;
      DM.RESTRequestPUT.Method := rmPUT;
      DM.RESTRequestPUT.Resource := 'pessoa';
      DM.RESTRequestPUT.Body.Add( JO.ToString, ContentTypeFromString('application/json') );
      DM.RESTRequestPUT.ExecuteAsync( TratarPUT, true, true, ProcessarOnError );
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
end;

procedure TfrmCliente.FormShow(Sender: TObject);
begin
  SetModo('Default');
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

procedure TfrmCliente.TratarDELETE;
var JO: TJSONObject;
begin
  if DM.RESTRequestDELETE.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao deletar registro: '+DM.RESTRequestDELETE.Response.StatusCode.ToString );
    exit;
  end;

  //memo1.text := DM.RESTRequestDELETE.Response.JSONValue.ToString;

  JO := DM.RESTRequestDELETE.Response.JSONValue as TJSONObject;
  if JO.GetValue<boolean>('sucess',false) then begin
    SetModo('Default');
  end;
end;

procedure TfrmCliente.TratarGET;
var json: string;
    JA: TJSONArray;
    JO,JO2: TJSONObject;
begin
  if DM.RESTRequestGET.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao realizar a consulta: '+DM.RESTRequestGET.Response.StatusCode.ToString );
    exit;
  end;

  json := DM.RESTRequestGET.Response.JSONValue.ToString;
  //memo1.text := DM.RESTRequestGET.Response.JSONValue.ToString;

  JO := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(json), 0) as TJSONObject;
  try
  JA := JO.FindValue('data') as TJSONArray;
  if Assigned(JA) then begin
    JO2 := JA.Items[0] as TJSONObject;

    if Assigned(JO2) then begin
      ed_flnatureza.Text    := JO2.GetValue<string>('flnatureza','');
      ed_dsdocumento.Text   := JO2.GetValue<string>('dsdocumento','');
      ed_nmprimeiro.Text    := JO2.GetValue<string>('nmprimeiro','');
      ed_nmsegundo.Text     := JO2.GetValue<string>('nmsegundo','');
      ed_dtregistro.Text    := JO2.GetValue<string>('dtregistro','');
      ed_dscep.Text         := JO2.GetValue<string>('dscep','');
      ed_dsuf.Text          := JO2.GetValue<string>('dsuf','');
      ed_nmcidade.Text      := JO2.GetValue<string>('nmcidade','');
      ed_nmbairro.Text      := JO2.GetValue<string>('nmbairro','');
      ed_nmlogradouro.Text  := JO2.GetValue<string>('nmlogradouro','');
      ed_dscomplemento.Text := JO2.GetValue<string>('dscomplemento','');
    end;
  end;
  finally
    if Assigned(JO) then begin
      JO.DisposeOf;
    end;
  end;
end;

procedure TfrmCliente.ProcessamentoEmLote;
var SL, SLL: TStringList;
    i: integer;
begin
  SL := TStringList.Create;
  try
    // carregar arquivo
    SL.LoadFromFile( GetCurrentDir+'\carga.txt' );

    SLL := TStringList.Create;
    try
      // carregar em SLL, uma linha por vez de SL, para separar
      for i := SL.Count-1 downto 0 do begin

        SLL.StrictDelimiter := True;

        // recebe a linha
        SLL.CommaText := SL[i];

        //Showmessage(SLL[0]+#13+SLL[1]+#13+SLL[2]+#13+SLL[3]+#13+SLL[4]+#13);

        // processar a linha --> se ok retorna true
        if ExecutarPOST_ex
        (StrToIntDef(SLL[0],0)  // flnatureza
        ,SLL[1]                 // dsdocumento
        ,SLL[2]                 // nmprimeiro
        ,SLL[3]                 // nmsegundo
        ,SLL[4]                 // dscep
        ) then begin
          // se ok --> apagar esta linha de SL
          SL.Delete(i);
        end;
        sleep(1000);
      end;

      // se sobrou alguma linha em SL --> provavelmente cep's invalidos
      if SL.Count > 0 then begin
        SL.SaveToFile( GetCurrentDir+'\carga.txt.invalidos' );
      end;

    finally
      FreeAndNil(SLL);
    end;

  finally
    FreeAndNil(SL);
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
      ExecutarDELETE(ed_idpessoa.Tag);
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
      ExecutarGET( ed_idpessoa.Tag );
      SetModo('NovoOuEditarOuExcluir');
      exit;
    end;
  end;
  //-----------------------------------------------------------
  if aModo = 'Gravar' then begin
    if Modo = 'Novo' then begin
      ExecutarPOST;
      // recarregar --> TratarPOST
      exit;
    end;
    if Modo = 'Editar' then begin
      if ed_idpessoa.Tag = 0 then begin
        // erro
        exit;
      end;
      ExecutarPUT;
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

procedure TfrmCliente.TratarGET_ping;
var JO: TJSONObject;
begin
  if DM.RESTRequestGET_ping.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao realizar a consulta: '+DM.RESTRequestGET.Response.StatusCode.ToString );
    exit;
  end;

  //memo1.text := DM.RESTRequestGET_ping.Response.JSONValue.ToString;

  JO := DM.RESTRequestGET_ping.Response.JSONValue as TJSONObject;
  if JO.GetValue<boolean>('sucess') then begin
    StatusBar1.Panels[1].Text := 'Ativa';
  end
  else begin
    StatusBar1.Panels[1].Text := 'Inativa';
  end;
end;

procedure TfrmCliente.TratarPOST;
var JO: TJSONObject;
begin
  if (DM.RESTRequestPOST.Response.StatusCode <> 201) and (DM.RESTRequestPOST.Response.StatusCode <> 200) then begin
    Showmessage('Ocorreu um erro ao salvar registro: '+DM.RESTRequestPOST.Response.StatusCode.ToString );
    exit;
  end;

  //memo1.text :=  DM.RESTRequestPOST.Response.JSONValue.ToString;

  JO := DM.RESTRequestPOST.Response.JSONValue as TJSONObject;
  if JO.GetValue<boolean>('sucess',false) then begin
    ed_idpessoa.Tag := JO.GetValue<integer>('idpessoa',0);
    ed_idpessoa.Text := IntToStr( ed_idpessoa.Tag );
    if ed_idpessoa.Tag > 0 then begin
      ExecutarGET( ed_idpessoa.Tag );
      SetModo('NovoOuEditarOuExcluir');
    end;
    StatusBar1.Panels[4].Text := '';
  end
  else begin;
    StatusBar1.Panels[4].Text := JO.GetValue<string>('message','');
  end;

end;

procedure TfrmCliente.TratarPUT;
var JO: TJSONObject;
begin
  if DM.RESTRequestPUT.Response.StatusCode <> 200 then begin
    Showmessage('Ocorreu um erro ao salvar registro: '+DM.RESTRequestPUT.Response.StatusCode.ToString );
    exit;
  end;

  //memo1.text := DM.RESTRequestPUT.Response.JSONValue.ToString;

  JO := DM.RESTRequestPUT.Response.JSONValue as TJSONObject;
  if JO.GetValue<boolean>('sucess',false) then begin
    ExecutarGET( ed_idpessoa.Tag );
    SetModo('NovoOuEditarOuExcluir');
    StatusBar1.Panels[4].Text := '';
  end
  else begin
    StatusBar1.Panels[4].Text := JO.GetValue<string>('message','');
  end;
end;

end.
