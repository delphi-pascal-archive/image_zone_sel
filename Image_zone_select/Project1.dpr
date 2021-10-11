program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {ImageZoneSelectForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TImageZoneSelectForm, ImageZoneSelectForm);
  Application.Run;
end.
