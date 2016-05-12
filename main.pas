unit main;

interface

uses
  Windows, mmsystem, IniFiles, Messages, SysUtils, Variants, Classes, Graphics,
  Controls,
  Forms,
  Dialogs, ExtCtrls, IdBaseComponent, IdComponent, IdUDPBase, IdUDPClient,
  IdSNMP, StdCtrls, ComCtrls;

type
  TForm1 = class(TForm)
    IdSNMP1: TIdSNMP;
    tmr1: TTimer;
    lbl1: TLabel;
    lblsrv1enrgy: TLabel;
    SoundOn: TCheckBox;
    tmr2: TTimer;
    txt1: TStaticText;
    Phones: TRichEdit;
    btn1: TButton;
    Alerts: TRichEdit;
    procedure tmr1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmr2Timer(Sender: TObject);
    procedure btn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  IniFile: TiniFile;
  IsTruoble: Boolean;
  ETrouble, ETrouble2: array[0..2] of Boolean;
implementation

{$R *.dfm}

procedure THEBEEP();
begin
  if FileExists('.\alert.wav') then
    PlaySound(PChar('.\alert.wav'), 0, SND_SYNC)
  else
  begin
    Windows.Beep(2200, 1000);
    Windows.Beep(1300, 1000);
    Windows.Beep(2200, 1000);
    Windows.Beep(1300, 1000);
    Windows.Beep(2200, 1000);
    Windows.Beep(1300, 1000);
    Windows.Beep(2200, 1000);
    Windows.Beep(1300, 1000);
    Windows.Beep(2200, 1000);
    Windows.Beep(1300, 1000);
    Windows.Beep(2200, 1000);
    Windows.Beep(1300, 1000);
  end;

end;

procedure AddLast(Last: Boolean);
begin
  ETrouble[0] := ETrouble[1];
  ETrouble[1] := ETrouble[2];
  ETrouble[2] := Last;
end;

function IsElectricGood(): Boolean;
begin
  Result := ETrouble[0] or ETrouble[1] or ETrouble[2];
end;

procedure AddLast2(Last: Boolean);
begin
  ETrouble2[0] := ETrouble2[1];
  ETrouble2[1] := ETrouble2[2];
  ETrouble2[2] := Last;
end;

function IsElectricGood2(): Boolean;
begin
  Result := ETrouble2[0] or ETrouble2[1] or ETrouble2[2];
end;

procedure TForm1.tmr1Timer(Sender: TObject);
var
  Tid: Cardinal;
  i: integer;
  //stList : TStringList;
  TempCurrent, TempMin, TempMax, Port1, Port2: integer;
  IP1, IP2, BadEnergy, GoodEnergy, IceCube, NormalTemp, HellBurn, ClearAir,
    Smoke, DryAsDesert, WaterFall, BadMonitoring: string;
begin
  if not IsTruoble then
  begin
    Phones.Lines.Clear();
    //  stList:=TStringList.Create();
    //  stList.Clear();   //??????? ????? ?? ???????? ?????? ?????? - ???? ??????
    IniFile.ReadSectionValues('Phones', Phones.Lines);
    for i := 0 to Phones.Lines.Count - 1 do
      Phones.Lines.Strings[i] := (StringReplace(Phones.Lines.Strings[i], '=',
        ' ', [rfReplaceAll, rfIgnoreCase]));
    //  for i:=0 to stList.Count-1 do
      //  Phones.Lines.Add(StringReplace(stList.Strings[i],'=',' ',[rfReplaceAll, rfIgnoreCase])) ;
        //stList.Destroy;
  end;
  TempMin := IniFile.ReadInteger('Options', 'TempMin', 10) * 10;
  TempMax := IniFile.ReadInteger('Options', 'TempMax', 27) * 10;
  IP1 := IniFile.ReadString('Options', 'IP1', '192.168.0.1');
  Port1 := IniFile.ReadInteger('Options', 'Port1', 161);
  IP2 := IniFile.ReadString('Options', 'IP2', '192.168.0.2');
  Port2 := IniFile.ReadInteger('Options', 'Port2', 161);
  BadEnergy := IniFile.ReadString('Options', 'BadEnergy',
    'Â ñåðâåðíîé @N íåò ýëåêòðè÷åñòâà, âîçìîæíî åãî ñïèçäèëè');
  GoodEnergy := IniFile.ReadString('Options', 'GoodEnergy',
    'Â ñåðâåðíîé @N åñòü ýëåêòðè÷åñòâî, íî ðàññëàáëÿòüñÿ íå ñòîèò');
  IceCube := IniFile.ReadString('Options', 'IceCube',
    'Â ñåðâåðíîé @N î÷åíü õîëîäíî - @T, âîçìîæíî çèìà è ñïèçäèëè ñòåíó');
  NormalTemp := IniFile.ReadString('Options', 'NormalTemp',
    'Â ñåðâåðíîé @N íîðìàëüíàÿ òåìïåðàòóðà - @T, âîçìîæíî ñïèçäèëè ñåðâåð è íå÷åìó íàãðåâàòüñÿ');
  HellBurn := IniFile.ReadString('Options', 'HellBurn',
    'Â ñåðâåðíîé @N î÷åíü æàðêî - @T, âîçìîæíî ñïèçäèëè êîíäèöèîíåð èëè äàæå 2');
  ClearAir := IniFile.ReadString('Options', 'ClearAir',
    'Â ñåðâåðíîé @N íè÷åãî íå äûìèò, âîçìîæíî äûìèòü óæå íå÷åìó');
  Smoke := IniFile.ReadString('Options', 'Smoke',
    'Â ñåðâåðíîé @N ÷àä êóòåæà è óãàðà,ñåðâåðà ñåé÷àñ óãîðÿò');
  DryAsDesert := IniFile.ReadString('Options', 'DryAsDesert',
    'Â ñåðâåðíîé @N ñóõîâ, âîçìîæíî ñïèçäèëè âîäîïðîâîä');
  WaterFall := IniFile.ReadString('Options', 'WaterFall',
    'Â ñåðâåðíîé @N ðàéñêèå âîäîïàäû, ñåðâåðà ñêîðî áóäóò â ðàþ');
  BadMonitoring := IniFile.ReadString('Options', 'BadMonitoring',
    'Óñòðîéñòâî ìîíèòîðèíãà â ñåðâåðíîé @N íå îòâå÷àåò, íó òû ïîíÿë ... äà ?');
  //
  IsTruoble := False;
  IdSNMP1.active := true;
  //Ñåðâåðíàÿ ¹ 1
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP1;
  IdSNMP1.Query.Port := Port1;
  //Íà÷àëî çàïðîñà ¹ 1
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.26.0', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;

  with Alerts.Font do // Ïîäáèðàåì øðèôò
  begin
    Color := clGreen;
    Size := 24;
    Name := 'Times New Roman';
    Style := [fsBold];
  end;

  lblsrv1enrgy.Caption :='Ïðîâåðêà ýëåêòðîïèòàíèÿ';
  Application.ProcessMessages;

  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin

      AddLast(IdSNMP1.Reply.Value[i] = '1');
      Alerts.Lines.Clear;
      if IsElectricGood() then
      begin
        Alerts.Lines.Add(StringReplace(GoodEnergy, '@N', '1',
          [rfReplaceAll, rfIgnoreCase]));
      end;
      if IdSNMP1.Reply.Value[i] = '0' then
      begin
        Alerts.Lines.Add(StringReplace(BadEnergy, '@N', '1',
          [rfReplaceAll, rfIgnoreCase]));
        IsTruoble := True;
      end;
    end
  else
  begin
    Alerts.Lines.Clear;
    Alerts.Lines.Add(StringReplace(BadMonitoring, '@N', '1', [rfReplaceAll,
      rfIgnoreCase]));
    with Alerts.Font do // Ïîäáèðàåì øðèôò
    begin
      Color := clRed;
      Size := 24;
      Name := 'Times New Roman';
      Style := [fsBold];
    end;

  end;

  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 1

  //Íà÷àëî çàïðîñà ¹ 2           1.3.6.1.4.1.35160.1.16.1.13.1
  IdSNMP1.active := true;
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP1;
  IdSNMP1.Query.Port := Port1;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.16.1.13.1', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;

  lblsrv1enrgy.Caption :='Ïðîâåðêà òåìïåðàòóðû';
  Application.ProcessMessages;

 if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      try
        TempCurrent := StrToInt(IdSNMP1.Reply.Value[i]);
        if TempCurrent < TempMin then
        begin
          with Alerts.Font do // Ïîäáèðàåì øðèôò
          begin
            Color := clBlue;
            Size := 24;
            Name := 'Times New Roman';
            Style := [fsBold];
          end;
          Alerts.Lines.Add(StringReplace(StringReplace(IceCube, '@N', '1', [rfReplaceAll, rfIgnoreCase]), '@T',
            FloatToStr(TempCurrent / 10), [rfReplaceAll,
            rfIgnoreCase]));
          IsTruoble := True;
        end;
        if (TempCurrent >= TempMin) and (TempCurrent <= TempMax) then
        begin
          Alerts.Lines.Add(StringReplace(StringReplace(NormalTemp, '@N',
            '1',
            [rfReplaceAll, rfIgnoreCase]), '@T',
            FloatToStr(TempCurrent / 10), [rfReplaceAll,
            rfIgnoreCase]));
        end;
        if TempCurrent > TempMax then
        begin
          with Alerts.Font do // Ïîäáèðàåì øðèôò
          begin
            Color := clRed;
            Size := 24;
            Name := 'Times New Roman';
            Style := [fsBold];
          end;
          Alerts.Lines.Add(StringReplace(StringReplace(HellBurn, '@N',
            '1',
            [rfReplaceAll, rfIgnoreCase]), '@T',
            FloatToStr(TempCurrent / 10), [rfReplaceAll,
            rfIgnoreCase]));
          IsTruoble := True;
        end;
      except
        //      TempCurrent:= Round((TempMin + TempMax)/2);
      end;
    end
  else
    begin
    Alerts.Lines.Clear;
    Alerts.Lines.Add(StringReplace(BadMonitoring, '@N', '1', [rfReplaceAll,
      rfIgnoreCase]));
    with Alerts.Font do // Ïîäáèðàåì øðèôò
    begin
      Color := clRed;
      Size := 24;
      Name := 'Times New Roman';
      Style := [fsBold];
    end;

  end;

  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 2
  //Íà÷àëî çàïðîñà ¹ 3
  IdSNMP1.active := true;
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP1;
  IdSNMP1.Query.Port := Port1;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.15.1.7.2', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;

  lblsrv1enrgy.Caption :='Ïðîâåðêà äàò÷èêà äûìà';
  Application.ProcessMessages;

  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      if IdSNMP1.Reply.Value[i] = '1' then
      begin
        Alerts.Lines.Add( StringReplace(ClearAir, '@N', '1',
          [rfReplaceAll, rfIgnoreCase]));
      end;
      if IdSNMP1.Reply.Value[i] = '0' then
      begin
        with Alerts.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clRed;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
         Alerts.Lines.Add( StringReplace(Smoke, '@N', '1', [rfReplaceAll,
          rfIgnoreCase]));
        IsTruoble := True;
      end;
    end
  else
   begin
    Alerts.Lines.Clear;
    Alerts.Lines.Add(StringReplace(BadMonitoring, '@N', '1', [rfReplaceAll,
      rfIgnoreCase]));
    with Alerts.Font do // Ïîäáèðàåì øðèôò
    begin
      Color := clRed;
      Size := 24;
      Name := 'Times New Roman';
      Style := [fsBold];
    end;

  end;
  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 3

   //Íà÷àëî çàïðîñà ¹ 4
  IdSNMP1.active := true;
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP1;
  IdSNMP1.Query.Port := Port1;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.15.1.7.1', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;

  lblsrv1enrgy.Caption :='Ïðîâåðêà äàò÷èêà âîäû';
  Application.ProcessMessages;

  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      if IdSNMP1.Reply.Value[i] = '1' then
      begin
       Alerts.Lines.Add( StringReplace(DryAsDesert, '@N', '1',
          [rfReplaceAll, rfIgnoreCase]));
      end;
      if IdSNMP1.Reply.Value[i] = '0' then
      begin
        with Alerts.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clRed;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        Alerts.Lines.Add( StringReplace(WaterFall, '@N', '1',
          [rfReplaceAll, rfIgnoreCase]));
        IsTruoble := True;
      end;
    end
  else
   begin
    Alerts.Lines.Clear;
    Alerts.Lines.Add(StringReplace(BadMonitoring, '@N', '1', [rfReplaceAll,
      rfIgnoreCase]));
    with Alerts.Font do // Ïîäáèðàåì øðèôò
    begin
      Color := clRed;
      Size := 24;
      Name := 'Times New Roman';
      Style := [fsBold];
    end;

  end;
  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 4


  lblsrv1enrgy.Caption := 'Îæèäàíèå îáíîâëåíèÿ';

 {  //Ñåðâåðíàÿ ¹ 2

  begin
    with lblsrv2enrgy.Font do // Ïîäáèðàåì øðèôò
    begin
      Color := clRed;
      Size := 24;
      Name := 'Times New Roman';
      Style := [fsBold];
    end;
    lblsrv1enrgy.Caption := StringReplace(GoodEnergy, '@N', '1',
      [rfReplaceAll, rfIgnoreCase]);
  end;

  //Íà÷àëî çàïðîñà ¹ 1
  IdSNMP1.active := true;
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP2;
  IdSNMP1.Query.Port := Port2;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.26.0', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;
  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      AddLast2(IdSNMP1.Reply.Value[i] = '1');
      if IsElectricGood2() then
      begin
        with lblsrv2enrgy.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clGreen;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        lblsrv2enrgy.Caption := StringReplace(GoodEnergy, '@N', '2',
          [rfReplaceAll, rfIgnoreCase]);
      end;
      if IdSNMP1.Reply.Value[i] = '0' then
      begin
        with lblsrv2enrgy.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clRed;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        lblsrv2enrgy.Caption := StringReplace(BadEnergy, '@N', '2',
          [rfReplaceAll, rfIgnoreCase]);
        IsTruoble := True;
      end;
    end
  else
    lblsrv2enrgy.Caption := StringReplace(BadMonitoring, '@N', '2',
      [rfReplaceAll, rfIgnoreCase]);
  //Êîíåö îïðîñà ¹ 1
  IdSNMP1.Active := false;
  IdSNMP1.active := true;
  //Íà÷àëî çàïðîñà ¹ 2           1.3.6.1.4.1.35160.1.16.1.13.1
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP2;
  IdSNMP1.Query.Port := Port2;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.16.1.13.1', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;
  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      try
        TempCurrent := StrToInt(IdSNMP1.Reply.Value[i]);
        if TempCurrent < TempMin then
        begin
          with lblsrv2temp.Font do // Ïîäáèðàåì øðèôò
          begin
            Color := clBlue;
            Size := 24;
            Name := 'Times New Roman';
            Style := [fsBold];
          end;
          lblsrv2temp.Caption := StringReplace(StringReplace(IceCube, '@N', '2',
            [rfReplaceAll, rfIgnoreCase]), '@T',
            FloatToStr(TempCurrent / 10), [rfReplaceAll,
            rfIgnoreCase]);
          IsTruoble := True;
        end;
        if (TempCurrent >= TempMin) and (TempCurrent <= TempMax) then
        begin
          with lblsrv2temp.Font do // Ïîäáèðàåì øðèôò
          begin
            Color := clGreen;
            Size := 24;
            Name := 'Times New Roman';
            Style := [fsBold];
          end;
          lblsrv2temp.Caption := StringReplace(StringReplace(NormalTemp, '@N',
            '2',
            [rfReplaceAll, rfIgnoreCase]), '@T',
            FloatToStr(TempCurrent / 10), [rfReplaceAll,
            rfIgnoreCase]);
        end;
        if TempCurrent > TempMax then
        begin
          with lblsrv2temp.Font do // Ïîäáèðàåì øðèôò
          begin
            Color := clRed;
            Size := 24;
            Name := 'Times New Roman';
            Style := [fsBold];
          end;
          lblsrv2temp.Caption := StringReplace(StringReplace(HellBurn, '@N',
            '2',
            [rfReplaceAll, rfIgnoreCase]), '@T',
            FloatToStr(TempCurrent / 10), [rfReplaceAll,
            rfIgnoreCase]);
          IsTruoble := True;
        end;
      except
        // TempCurrent:= Round((TempMin + TempMax)/2);
      end;
    end
  else
    lblsrv2enrgy.Caption := StringReplace(BadMonitoring, '@N', '2',
      [rfReplaceAll, rfIgnoreCase]);

  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 2
 //Íà÷àëî çàïðîñà ¹ 3
  IdSNMP1.active := true;
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP2;
  IdSNMP1.Query.Port := Port2;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.15.1.7.2', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;
  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      if IdSNMP1.Reply.Value[i] = '1' then
      begin
        with lblsrv2smoke.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clGreen;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        lblsrv2smoke.Caption := StringReplace(ClearAir, '@N', '2',
          [rfReplaceAll, rfIgnoreCase]);
      end;
      if IdSNMP1.Reply.Value[i] = '0' then
      begin
        with lblsrv2smoke.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clRed;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        lblsrv2smoke.Caption := StringReplace(Smoke, '@N', '2', [rfReplaceAll,
          rfIgnoreCase]);
        IsTruoble := True;
      end;
    end;
  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 3
   //Íà÷àëî çàïðîñà ¹ 4
  IdSNMP1.active := true;
  IdSNMP1.Query.Clear;
  IdSNMP1.Query.Host := IP2;
  IdSNMP1.Query.Port := Port2;
  IdSNMP1.Query.MIBAdd(Format('1.3.6.1.4.1.35160.1.15.1.7.1', [i]), '');
  IdSNMP1.Query.PDUType := PDUGetRequest;
  if IdSNMP1.SendQuery then
    for i := 0 to IdSNMP1.Reply.ValueCount - 1 do
    begin
      if IdSNMP1.Reply.Value[i] = '1' then
      begin
        with lblsrv2water.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clGreen;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        lblsrv2water.Caption := StringReplace(DryAsDesert, '@N', '2',
          [rfReplaceAll, rfIgnoreCase]);
      end;
      if IdSNMP1.Reply.Value[i] = '0' then
      begin
        with lblsrv2water.Font do // Ïîäáèðàåì øðèôò
        begin
          Color := clRed;
          Size := 24;
          Name := 'Times New Roman';
          Style := [fsBold];
        end;
        lblsrv2water.Caption := StringReplace(WaterFall, '@N', '2',
          [rfReplaceAll, rfIgnoreCase]);
        IsTruoble := True;
      end;
    end
  else
    lblsrv2enrgy.Caption := StringReplace(BadMonitoring, '@N', '2',
      [rfReplaceAll, rfIgnoreCase]);

  IdSNMP1.Active := false;
  //Êîíåö îïðîñà ¹ 4     }

  PlaySound(nil, 0, SND_PURGE);
  if IsTruoble then
  begin
   { lblsrv1enrgy.Width := 745;
    lblsrv1temp.Width := 745;
    lblsrv1water.Width := 745;
    lblsrv1smoke.Width := 745;
    lblsrv2enrgy.Width := 745;
    lblsrv2temp.Width := 745;
    lblsrv2water.Width := 745;
    lblsrv2smoke.Width := 745;  }
    Phones.Visible := True;
    if SoundOn.Checked then
      CreateThread(nil, 0, @THEBEEP, nil, 0, Tid);
  end
  else
  begin
   { lblsrv1enrgy.Width := 1045;
    lblsrv1temp.Width := 1045;
    lblsrv1water.Width := 1045;
    lblsrv1smoke.Width := 1045;
    lblsrv2enrgy.Width := 1045;
    lblsrv2temp.Width := 1045;
    lblsrv2water.Width := 1045;
    lblsrv2smoke.Width := 1045; }
    Phones.Visible := False;
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  AddLast(True);
  AddLast(True);
  AddLast2(True);
  AddLast2(True);
  IniFile := TIniFile.Create('.\config.ini');
  if not FileExists('.\config.ini') then
  begin
    IniFile.WriteBool('Options', 'SoundOn', True);
    { Ñåêöèÿ Options: Sound:=true }
    IniFile.WriteInteger('Options', 'TempMin', 10);
    IniFile.WriteInteger('Options', 'TempMax', 27);
    IniFile.WriteString('Options', 'IP1', '192.168.50.164');
    IniFile.WriteInteger('Options', 'Port1', 161);
    IniFile.WriteInteger('Options', 'Interval', 17);
    IniFile.WriteString('Options', 'IP2', '192.168.50.163');
    IniFile.WriteInteger('Options', 'Port2', 161);
    IniFile.WriteString('Options', 'BadEnergy',
      'Â ñåðâåðíîé @N íåò ýëåêòðè÷åñòâà');
    IniFile.WriteString('Options', 'GoodEnergy',
      'Â ñåðâåðíîé @N åñòü ýëåêòðè÷åñòâî');
    IniFile.WriteString('Options', 'IceCube',
      'Â ñåðâåðíîé @N î÷åíü õîëîäíî - @T');
    IniFile.WriteString('Options', 'NormalTemp',
      'Â ñåðâåðíîé @N íîðìàëüíàÿ òåìïåðàòóðà - @T');
    IniFile.WriteString('Options', 'HellBurn',
      'Â ñåðâåðíîé @N î÷åíü æàðêî - @T');
    IniFile.WriteString('Options', 'ClearAir', 'Â ñåðâåðíîé @N âñå ÎÊ');
    IniFile.WriteString('Options', 'Smoke', 'Â ñåðâåðíîé @N çàäûìëåíèå!!!!');
    IniFile.WriteString('Options', 'DryAsDesert', 'Â ñåðâåðíîé @N âñå ÎÊ');
    IniFile.WriteString('Options', 'WaterFall', 'Â ñåðâåðíîé @N çàòîïëåíèå!!!');
    IniFile.WriteString('Phones', 'Ýëåêòðèê', '8 911 946 81 84');
  end;
  tmr1.Interval := IniFile.ReadInteger('Options', 'Interval', 161) * 1000;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  IniFile.Free; { Çàêðûëè ôàéë, óíè÷òîæèëè îáúåêò è îñâîáîäèëè ïàìÿòü }
end;

procedure TForm1.tmr2Timer(Sender: TObject);
begin
  SoundOn.Checked := True;
end;

procedure TForm1.btn1Click(Sender: TObject);
begin
  Windows.Beep(2200, 1000);
  Windows.Beep(1300, 1000);
  Windows.Beep(2200, 1000);
  Windows.Beep(1300, 1000);
  Windows.Beep(2200, 1000);
  Windows.Beep(1300, 1000);
end;

end.

