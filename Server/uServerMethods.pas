unit uServerMethods;

interface

uses System.SysUtils, System.Classes, System.Json, System.Rtti,
    DataSnap.DSProviderDataModuleAdapter,
    Datasnap.DSServer, Datasnap.DSAuth;

type
  {$METHODINFO ON}
  TServerMethods1 = class(TDSServerModule)
  private
    { Private declarations }
  public
    { Public declarations }
    function IsRunning: string;
  end;
  {$METHODINFO off}

implementation


{$R *.dfm}


uses System.StrUtils;

function TServerMethods1.IsRunning;
begin
  Result := 'Running';
end;

end.

