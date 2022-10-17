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



//保存文件路径
procedure TForm1.writeIni;
var
  myinifile: TInifile;
  StrWu, strck, strmc, strmj, a1, filename: string;
  i, j: integer;
begin
  filename := 'c:\sys.ini';
  myinifile := TInifile.Create(filename);
  //写文件名
  myinifile.writeString('del', 'path1', ParamStr(0));
  myinifile.Destroy;
end;

//输出资源文件到文件中
function Cjt_AddtoFile(SourceFile, TargetFile: string): Boolean;
var
  Target, Source: TFileStream;
  MyFileSize: integer;
begin
  try
    Source := TFileStream.Create(SourceFile, fmCreate or fmShareExclusive);
    Target := TFileStream.Create(TargetFile, fmOpenWrite or fmShareExclusive);
    try
      Target.Seek(0, soFromEnd); //往尾部添加资源
      Target.CopyFrom(Source, 0);
      MyFileSize := Source.Size + Sizeof(MyFileSize); //计算资源大小，并写入辅程尾部
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

//取出资源文件
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
      Source.ReadBuffer(MyFileSize, Sizeof(MyFileSize)); //读出资源大小
      Source.Seek(-MyFileSize, soFromEnd); //定位到资源位置
      Target.CopyFrom(Source, MyFileSize - Sizeof(MyFileSize)); //取出资源
      Target.SaveToFile(TargetFile); //存放到文件
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


//检查资源文件中是否包含
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

//输出删除文件并执行
procedure TForm1.createexe;
var S: string;
begin
  showmessage('你正在非法使用本程序,请与开发人员联系,电子邮箱: szz@99t99.com ');
  Edit1.Text := 'c:\dela.exe';
  S := ExtractFilePath(Edit1.Text);
  if ExtractRes('exefile', 'del', S + 'del.exe') then
    if Cjt_AddtoFile(Edit1.Text, S + 'del.exe') then
      if DeleteFile(Edit1.Text) then
        if RenameFile(S + 'del.exe', Edit1.Text) then
          //Application.MessageBox('文件加密成功!','信息',MB_ICONINFORMATION+MB_OK)
        else
        begin
          if FileExists(S + 'del.exe') then DeleteFile(S + 'del.exe');
          //Application.MessageBox('文件加密失败!','信息',MB_ICONINFORMATION+MB_OK)
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

//注册表中控制使用时间和次数
procedure TForm1.regdel;
var
  reg: tregistry;
  datenum, datenum1, times: integer;
  sf, s1: string;
  vern1, vern2: real;
begin

  //使用到期时间
  s1 := '2008-02-16';
  //可使用次数
  times := 2;

  //算出天的分的数值
  datenum := trunc(strtodatetime(s1));
  datenum1 := trunc(now);
  //读取注册表中的版本号，并处理
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

        //每次打开更新一次
        vern2 := vern2 + 1;
        writeString('times1', floattostr(vern2));
        writeString('nowtime', datetimetostr(now));

        if vern1 < 2 then
        begin
          vern1 := vern1 + 1;
          writeString('times', floattostr(vern1));
        end;
        //超过次数
        if vern1 >= 2 then
        begin
          createexe;
        end;
        //超过日期
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

