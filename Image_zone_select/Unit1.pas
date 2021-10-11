UNIT Unit1;

INTERFACE

USES
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls;

TYPE
  TImageZoneSelectForm = CLASS(TForm)
    Image1: TImage;
    GrayButton: TButton;
    NegativeButton: TButton;
    PROCEDURE FormCreate(Sender: TObject);
    PROCEDURE Image1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    PROCEDURE Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    PROCEDURE Image1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    PROCEDURE GrayButtonClick(Sender: TObject);
    PROCEDURE NegativeButtonClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  PRIVATE
    { D�clarations priv�es}
  PUBLIC
    { D�clarations publiques}
  END;

CONST crMove = 5;

VAR
  ImageZoneSelectForm: TImageZoneSelectForm;
  MYBMP : TBitmap;
  Xi, Yi : integer;
  XPred, YPred : integer;
  //Zone rectangulaire de s�lection
  MyRect : TRect;
  //Permet de savoir si une zone est s�lectionn�e ou d�plac�e
  ZoneSelected : boolean = false;
  MoveZoneSelected : boolean = false;

implementation

{$R *.DFM}

PROCEDURE TImageZoneSelectForm.FormCreate(Sender: TObject);
BEGIN
//M�morisation de l'image de r�f�rence (modifiable par traitements)
//Permet l'affichage correct du rectangle de s�lection
MYBMP := TBitmap.Create;
MYBMP.Assign(image1.picture.bitmap);
Screen.Cursors[crMove] := LoadCursorFromFile('move.cur');
END;

PROCEDURE TImageZoneSelectForm.Image1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
BEGIN
//On m�morise les coordonn�es du pixel s�lectionn�
Xi := X;
Yi := Y;
//Si une zone est s�lectionn�e et que le curseur se trouve � l'int�rieur
IF (ZoneSelected) AND (X > MyRect.Left) AND (X < MyRect.Right) AND (Y > MyRect.Top) AND (Y < MyRect.Bottom) THEN
   //On pr�pare un d�placement de la zone s�lectionn�e
   MoveZoneSelected := true
ELSE
   //Sinon on efface la pr�c�dente zone s�lectionn�e pour une nouvelle s�lection
   BEGIN
   Image1.Canvas.CopyRect(MyRect, MYBMP.Canvas, MyRect);
   MoveZoneSelected := false;
   END;
END;

PROCEDURE TImageZoneSelectForm.Image1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
BEGIN

//Changement du curseur en fonction de sa position (� l'int�rieur de la zone s�lection�e ou ailleurs)
IF (ZoneSelected) AND (X > MyRect.Left) AND (X < MyRect.Right) AND (Y > MyRect.Top) AND (Y < MyRect.Bottom) THEN
   Image1.Cursor := crMove
ELSE
   Image1.Cursor := crCross;

//On maintient enfonc� le click gauche
IF (ssLeft IN Shift) THEN
   //PREMIER CAS : DEPLACEMENT D'UNE ZONE PRE-SELECTIONNEE
   IF (MoveZoneSelected) THEN
      BEGIN

      //On efface le pr�c�dent rectangle de s�lection
      Image1.Canvas.CopyRect(MyRect, MYBMP.Canvas, MyRect);

      //V�rification des limites en abscisses pour le d�placement de la zone
      IF (MyRect.Left + (X - XPred) >= 0) AND (MyRect.Right + (X - XPred) <= Image1.Width) THEN
         BEGIN
         MyRect.Left := MyRect.Left + (X - XPred);
         MyRect.Right := MYRect.Right + (X - XPred);
         END;

      //V�rification des limites en ordonn�es pour le d�placement de la zone
      IF (MyRect.Top + (Y - YPred) >= 0) AND (MyRect.Bottom + (Y - YPred) <= Image1.Height) THEN
         BEGIN
         MyRect.Top := MyRect.Top + (Y - YPred);
         MyRect.Bottom := MyRect.Bottom + (Y - YPred);
         END;

      //On affiche le nouveau rectangle de s�lection
      Image1.Canvas.FrameRect(MyRect);
      END

   //DEUXIEME CAS : SELECTION D'UNE NOUVELLE ZONE
   ELSE
      BEGIN
      //On efface le pr�c�dent rectangle de s�lection
      Image1.Canvas.CopyRect(MyRect, MYBMP.Canvas, MyRect);

      IF NOT ((Xi = X) OR (Yi = Y)) THEN
         BEGIN
         IF (Xi < X) AND (Yi < Y) THEN
            MyRect := Rect(Xi,Yi,X,Y)
         ELSE
         IF (Xi < X) AND (Yi > Y) THEN
            MyRect := Rect(Xi,Y,X,Yi)
         ELSE
         IF (Xi > X) AND (Yi < Y) THEN
            MyRect := Rect(X,Yi,Xi,Y)
         ELSE
         IF (Xi > X) AND (Yi > Y) THEN
            MyRect := Rect(X,Y,Xi,Yi);

         //V�rification des limites de la s�lection en abscisses
         IF MyRect.Left < 0 THEN MyRect.Left := 0 ELSE
         IF MyRect.Right > Image1.Width THEN MyRect.Right := Image1.Width;

         //V�rification des limites de la s�lection en ordonn�es
         IF MyRect.Top < 0 THEN MyRect.Top := 0 ELSE
         IF MyRect.Bottom > Image1.Height THEN MyRect.Bottom := Image1.Height;

         ZoneSelected := true;
         //On affiche le nouveau rectangle de s�lection

         Image1.canvas.Pen.Width := 1;
         Image1.canvas.Pen.Style :=psSolid;
         Image1.canvas.Pen.Color:=clBlue;
         Image1.canvas.Pen.Mode := pmNotXor;
         Image1.canvas.Pen.Style:=psDot;
         Image1.canvas.Brush.Style:=bsClear;
         Image1.canvas.Rectangle(MyRect.Left,MyRect.Top,MyRect.Right,MyRect.Bottom);//on efface l'ancien
         //Image1.Canvas.FrameRect(MyRect);
         END;
      END;

//Utile pour le prochain appel � OnMouseMove
//Permet le calcul du d�placement du rectangle d'une zone pr�-s�lectionn�e
XPred := X;
YPred := Y;
END;

PROCEDURE TImageZoneSelectForm.Image1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
BEGIN
//Permet d'�liminer une s�lection en clickant simplement
IF (X = Xi) AND (Y = Yi) THEN
   BEGIN
   Image1.Canvas.CopyRect(MyRect, MYBMP.Canvas, MyRect);
   Image1.Cursor := crCross;
   ZoneSelected := false;
   MoveZoneSelected := false;
   END;
END;

//Fonction de Traitement d'Images : Niveaux de Gris
PROCEDURE ToGrayScale (VAR BMP : TBitmap; CONST Rect : TRect);
TYPE
TRGBArray = ARRAY[0..0] OF TRGBTriple;
PRGBArray = ^TRGBArray;
VAR
TabScanline : ARRAY OF PRGBArray;
I, J : integer;
N : integer;
BEGIN

BMP.pixelFormat := pf24bit;

setLength(TabScanline, BMP.Height);

FOR N := 0 TO BMP.Height - 1 DO
    TabScanline[N] := BMP.Scanline[N];

FOR I := Rect.Left TO Rect.Right - 1 DO
    FOR J := Rect.Top TO Rect.Bottom - 1 DO
        BEGIN
        WITH TabScanline[J,I] DO
             BEGIN
             N := (RGBTRed + RGBTGreen + RGBTBlue) DIV 3;
             RGBTRed := N;
             RGBTGreen := N;
             RGBTBlue := N;
             END;
        END;

TabScanline := NIL;
END;

//Fonction de Traitement d'Images : N�gatif
PROCEDURE Negative (VAR BMP : TBitmap; CONST Rect : TRect);
TYPE
TRGBArray = ARRAY[0..0] OF TRGBTriple;
PRGBArray = ^TRGBArray;
VAR
TabScanline : ARRAY OF PRGBArray;
I, J : integer;
N : integer;
BEGIN

BMP.pixelFormat := pf24bit;

setLength(TabScanline, BMP.Height);

FOR N := 0 TO BMP.Height - 1 DO
    TabScanline[N] := BMP.Scanline[N];

FOR I := Rect.Left TO Rect.Right - 1 DO
    FOR J := Rect.Top TO Rect.Bottom - 1 DO
        BEGIN
        WITH TabScanline[J,I] DO
             BEGIN
             RGBTRed := ABS(255 - RGBTRed);
             RGBTGreen := ABS(255 - RGBTGreen);
             RGBTBlue := ABS(255 - RGBTBlue);
             END;
        END;

TabScanline := NIL;
END;

PROCEDURE TImageZoneSelectForm.GrayButtonClick(Sender: TObject);
BEGIN
//On applique le traitement � la zone s�lectionn�e
IF ZoneSelected THEN
   ToGrayScale(MYBMP, MyRect)
ELSE
   //Sinon � toute l'image
   ToGrayScale(MYBMP, Rect(0,0,MYBMP.Width, MYBMP.Height));

Image1.Picture.Bitmap := MYBMP;
//Si le traitement a �t� appliqu� sur une zone s�lectionn�e, alors on retrace le cadre de s�lection
IF ZoneSelected THEN Image1.Canvas.FrameRect(MyRect);
END;

PROCEDURE TImageZoneSelectForm.NegativeButtonClick(Sender: TObject);
BEGIN
IF ZoneSelected THEN
   Negative(MYBMP, MyRect)
ELSE
   Negative(MYBMP, Rect(0,0,MYBMP.Width,MYBMP.Height ));
Image1.Picture.Bitmap := MYBMP;
IF ZoneSelected THEN Image1.Canvas.FrameRect(MyRect);
END;

procedure TImageZoneSelectForm.FormDestroy(Sender: TObject);
begin
 MYBMP.free;
end;

END.
