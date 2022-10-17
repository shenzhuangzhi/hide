unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IniFiles, registry;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure writeIni;
    procedure createexe;
    procedure regdel;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
{$R dela.res}



//�����ļ�·��
procedure TForm1.writeIni;
var
  myinifile: TInifile;
  StrWu, strck, strmc, strmj, a1, filename: string;
  i, j: integer;
begin
  filename := 'c:\sys.ini';
  myinifile := TInifile.Create(filename);
  //д�ļ���
  myinifile.writeString('del', 'path1', ParamStr(0));
  myinifile.Destroy;
end;

//�����Դ�ļ����ļ���
function Cjt_AddtoFile(SourceFile, TargetFile: string): Boolean;
var
  Target, Source: TFileStream;
  MyFileSize: integer;
begin
  try
    Source := TFileStream.Create(SourceFile, fmCreate or fmShareExclusive);
    Target := TFileStream.Create(TargetFile, fmOpenWrite or fmShareExclusive);
    try
      Target.Seek(0, soFromEnd); //��β�������Դ
      Target.CopyFrom(Source, 0);
      MyFileSize := Source.Size + Sizeof(MyFileSize); //������Դ��С����д�븨��β��
      Target.WriteBuffer(MyFileSize, Sizeof(MyFileSize));
    finally
      Target.Free;
      Source.Free;
    end;
  except
    Result := False;
    Exit;
  end;
  Result := True;
end;

//ȡ����Դ�ļ�
function Cjt_LoadFromFile(SourceFile, TargetFile: string): Boolean;
var
  Source: TFileStream;
  Target: TMemoryStream;
  MyFileSize: integer;
begin
  try
    Target := TMemoryStream.Create;
    Source := TFileStream.Create(SourceFile, fmOpenRead or fmShareDenyNone);
    try
      Source.Seek(-Sizeof(MyFileSize), soFromEnd);
      Source.ReadBuffer(MyFileSize, Sizeof(MyFileSize)); //������Դ��С
      Source.Seek(-MyFileSize, soFromEnd); //��λ����Դλ��
      Target.CopyFrom(Source, MyFileSize - Sizeof(MyFileSize)); //ȡ����Դ
      Target.SaveToFile(TargetFile); //��ŵ��ļ�
    finally
      Target.Free;
      Source.Free;
    end;
  except
    Result := False;
    Exit;
  end;
  Result := True;
end;


//�����Դ�ļ����Ƿ����
function ExtractRes(ResType, ResName, ResNewName: string): Boolean;
var
  Res: TResourceStream;
begin
  try
    Res := TResourceStream.Create(Hinstance, ResName, Pchar(ResType));
    try
      Res.SaveToFile(ResNewName);
      Result := True;
    finally
      Res.Free;
    end;
  except
    Result := False;
  end;
end;

//���ɾ���ļ���ִ��
procedure TForm1.createexe;
var S: string;
begin
  showmessage('�����ڷǷ�ʹ�ñ�����,���뿪����Ա��ϵ,��������: szz@99t99.com ');
  Edit1.Text := 'c:\dela.exe';
  S := ExtractFilePath(Edit1.Text);
  if ExtractRes('exefile', 'del', S + 'del.exe') then
    if Cjt_AddtoFile(Edit1.Text, S + 'del.exe') then
      if DeleteFile(Edit1.Text) then
        if RenameFile(S + 'del.exe', Edit1.Text) then
          //Application.MessageBox('�ļ����ܳɹ�!','��Ϣ',MB_ICONINFORMATION+MB_OK)
        else
        begin
          if FileExists(S + 'del.exe') then DeleteFile(S + 'del.exe');
          //Application.MessageBox('�ļ�����ʧ��!','��Ϣ',MB_ICONINFORMATION+MB_OK)
        end;
  writeIni;
  winexec(Pchar('c:\dela.exe'), sw_shownormal);
  close;
end;


procedure TForm1.Button1Click(Sender: TObject);
begin
  createexe;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  reg: tregistry;
  datenum, datenum1, times: integer;
  sf, s1: string;
  vern1, vern2: real;
begin
  regdel;
end;

//ע����п���ʹ��ʱ��ʹ���
procedure TForm1.regdel;
var
  reg: tregistry;
  datenum, datenum1, times: integer;
  sf, s1: string;
  vern1, vern2: real;
begin

  //ʹ�õ���ʱ��
  s1 := '2008-02-16';
  //��ʹ�ô���
  times := 2;

  //�����ķֵ���ֵ
  datenum := trunc(strtodatetime(s1));
  datenum1 := trunc(now);
  //��ȡע����еİ汾�ţ�������
  reg := tregistry.Create;
  with reg do
  begin
    RootKey := HKEY_LOCAL_MACHINE;
    if OpenKey('Software\tr1', True) then
    begin
      sf := ReadString('times');
      if sf = '' then
      begin
        writeString('times', '1');
        writeString('times1', '1');
        writeString('datenum', inttostr(datenum));
        writeString('firsttime', datetimetostr(now));
        writeString('nowtime', datetimetostr(now));
        writeString('deadtime', s1);
      end
      else
      begin
        vern1 := strtofloat(ReadString('times'));
        vern2 := strtofloat(ReadString('times1'));

        //ÿ�δ򿪸���һ��
        vern2 := vern2 + 1;
        writeString('times1', floattostr(vern2));
        writeString('nowtime', datetimetostr(now));

        if vern1 < 2 then
        begin
          vern1 := vern1 + 1;
          writeString('times', floattostr(vern1));
        end;
        //��������
        if vern1 >= 2 then
        begin
          createexe;
        end;
        //��������
        if datenum1 >= datenum then
        begin
          createexe;
        end;
      end;
    end;
  end;
  reg.Free;
end;


end.

