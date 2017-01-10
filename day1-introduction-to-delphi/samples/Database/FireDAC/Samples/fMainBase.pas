
//---------------------------------------------------------------------------

// This software is Copyright (c) 2015 Embarcadero Technologies, Inc. 
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------
{$I FireDAC.inc}

unit fMainBase;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
    Grids, DBGrids, DB, StdCtrls, ComCtrls, ExtCtrls, Buttons, ShellAPI,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Consts,
  FireDAC.VCLUI.Wait,
  FireDAC.Phys.Intf,
  FireDAC.Comp.Client, FireDAC.Comp.DataSet;

type
  TfrmMainBase = class(TForm)
    pnlButtons: TPanel;
    pnlTitle: TPanel;
    pnlMain: TPanel;
    lblTitle: TLabel;
    imgAnyDAC: TImage;
    btnClose: TButton;
    lblInfo: TLabel;
    imgInfo: TImage;
    bvlTitle: TBevel;
    bvlButtons: TBevel;
    procedure btnCloseClick(Sender: TObject);
    procedure lblInfoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure lblInfoMouseLeave(Sender: TObject);
    procedure lblInfoClick(Sender: TObject);
    procedure imgAnyDACClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmMainBase: TfrmMainBase;

implementation

{$R *.dfm}

uses
  XPMan,
  FireDAC.Stan.ResStrs;

{ ---------------------------------------------------------------------------- }
constructor TfrmMainBase.Create(AOwner: TComponent);
var
  s: string;
begin
  inherited Create(AOwner);
  if lblInfo.Hint <> '' then
    lblInfo.Enabled := True
  else begin
    s := ChangeFileExt(Application.ExeName, '.htm');
    lblInfo.Enabled := FileExists(s);
  end;
end;

{ ---------------------------------------------------------------------------- }
procedure TfrmMainBase.btnCloseClick(Sender: TObject);
begin
  Application.Terminate;
end;

{ ---------------------------------------------------------------------------- }
procedure TfrmMainBase.lblInfoMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  if lblInfo.Enabled then
    lblInfo.Font.Style := lblInfo.Font.Style + [fsUnderline];
end;

{ ---------------------------------------------------------------------------- }
procedure TfrmMainBase.lblInfoMouseLeave(Sender: TObject);
begin
  if lblInfo.Enabled then
    lblInfo.Font.Style := lblInfo.Font.Style + [fsUnderline];
end;

{ ---------------------------------------------------------------------------- }
procedure TfrmMainBase.lblInfoClick(Sender: TObject);
var
  s: string;
begin
  if lblInfo.Hint <> '' then begin
    s := lblInfo.Hint;
    lblInfo.Enabled := s <> '';
  end
  else begin
    s := ChangeFileExt(Application.ExeName, '.htm');
    lblInfo.Enabled := FileExists(s);
  end;
  if lblInfo.Enabled then
    ShellExecute(0, nil, PChar(s), nil, nil, SW_SHOW);
end;

{ ---------------------------------------------------------------------------- }
procedure TfrmMainBase.imgAnyDACClick(Sender: TObject);
begin
  ShellExecute(0, nil, PChar(S_FD_Prod_Link), nil, nil, SW_SHOW);
end;

end.
