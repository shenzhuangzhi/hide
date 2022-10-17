unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ShellApi, ExtCtrls, Menus, Registry, IniFiles, commctrl, SHDocVw, MSHTML, ActiveX;
const NOTIFYEVENT = WM_USER + 100;

  //隐藏任务栏图标用
type
  ITaskbarList = interface(IUnknown)
    ['{56FDF344-FD6D-11d0-958A-006097C9A090}']
    procedure HrInit; safecall;
    procedure AddTab(hWindow: HWND); safecall;
    procedure DeleteTab(hWindow: HWND); safecall;
    procedure ActivateTab(hWindow: HWND); safecall;
    procedure SetActiveAlt(hWindow: HWND); safecall;
  end;
  //隐藏任务栏图标用

type
  TForm1 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox7: TGroupBox;
    ComboBoxman: TComboBox;
    Button1: TButton;
    ListBoxhwnd: TListBox;
    GroupBox6: TGroupBox;
    CheckBoxhide: TCheckBox;
    CheckBox800: TCheckBox;
    CheckBox1024: TCheckBox;
    GroupBox10: TGroupBox;
    ListBox2: TListBox;
    Editwu: TEdit;
    ButtonDelWu: TButton;
    ButtonJiaWu: TButton;
    Buttontj: TButton;
    GroupBox9: TGroupBox;
    CheckBoxsave: TCheckBox;
    CheckBoxhideself: TCheckBox;
    CheckBoxclose: TCheckBox;
    CheckBox1: TCheckBox;
    TabSheet2: TTabSheet;
    Memo1: TMemo;
    Edit1: TEdit;
    Image1: TImage;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    CheckBoxautorun: TCheckBox;
    Button2: TButton;
    Timer1: TTimer;
    TabSheet3: TTabSheet;
    Memo2: TMemo;
    hidetaskbar: TButton;
    CheckBox10: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBoxxy: TCheckBox;
    Editx: TEdit;
    Edity: TEdit;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure ComboBoxmanChange(Sender: TObject);
    procedure CheckBoxhideClick(Sender: TObject);
    procedure CheckBoxcloseClick(Sender: TObject);
    procedure CheckBox800Click(Sender: TObject);
    procedure CheckBox1024Click(Sender: TObject);
    procedure ButtonJiaWuClick(Sender: TObject);
    procedure ButtonDelWuClick(Sender: TObject);
    procedure ButtontjClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBoxautorunClick(Sender: TObject);
    procedure CheckBoxsaveClick(Sender: TObject);
    procedure CheckBoxhideselfClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure hidetaskbarClick(Sender: TObject);
    procedure CheckBox10Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBoxxyClick(Sender: TObject);
  private
    { Private declarations }
        //定义热键相关
    hotkeyid: array[1..6] of integer;
    procedure hotkeydown(var msg: Tmessage);
      message wm_hotkey; //响应敏感键按键消息
    procedure RegHot();
    //定义热键相关

    procedure ShellNotify(mode: Byte);
    procedure ShellNotify1(mode: Byte);
    procedure OnNotifyIcon(var message: Tmessage); message NOTIFYEVENT;
    procedure OnSysCommand(var message: Tmessage); message WM_SYSCOMMAND;
    procedure OnMin(Sender: TObject); //任务栏上最小化时,隐藏窗口
    procedure readIni;
    procedure writeIni;
    procedure hideshowall;
    procedure hideshowalla;
    procedure HideTrayIcon;

  public
    HotKeyB: Boolean;
    HotKeyB2: Boolean;
    { Public declarations }
  end;
function EnumWinProc(h: HWND; Param: LParam): Boolean; stdcall;

var
  Form1: TForm1;
  MyHwnd: HWND; //窗口
  //gameformHwnd: HWnd; //窗口
  aproc: dword; //窗口ID
  mHandle, hProcess_N: THandle;
  haveicon, showall: integer;
  manname: widestring;
  filename: string;
  IconId: integer;

implementation

{$R *.dfm}

//读取初始配置
procedure TForm1.readIni;
var
  myinifile: TInifile;
  StrWu, strck, strmc, strmj, a1: string;
  i, j: integer;
begin
  myinifile := TInifile.Create(filename);
  //过滤模块
  StrWu := myinifile.ReadString('guolv', 'guolvwu', '');
  CheckBoxhideself.Checked := myinifile.Readbool('guolv', 'checkhide', False);
  myinifile.Destroy;
  //过滤列表
  j := 1;
  ListBox2.Clear;
  for i := 1 to length(StrWu) do
  begin
    if StrWu[i] = '*' then
    begin
      a1 := Copy(StrWu, j, i - j);
      if a1 > '' then ListBox2.Items.Add(a1);
      j := i + 1;
    end;
  end;
end;

//保存初始配置
procedure TForm1.writeIni;
var
  myinifile: TInifile;
  StrWu, strck, strmc, strmj, a1: string;
  i, j: integer;
begin
  filename := ExtractFilePath(paramstr(0)) + 'config.ini';
  //过滤条件累加
  for i := 0 to (ListBox2.Count - 1) do StrWu := StrWu + ListBox2.Items[i] + '*';
  myinifile := TInifile.Create(filename);
  //过滤模块
  myinifile.writeString('guolv', 'guolvwu', StrWu);
  myinifile.writebool('guolv', 'checkhide', CheckBoxhideself.Checked);
  myinifile.Destroy;
end;

procedure TForm1.ShellNotify(mode: Byte); //小图标生成销毁函数
var
  notifyIcon: TNotifyIconData;
  //manname1:string;
begin
  notifyIcon.cbSize := SizeOf(notifyIcon);
  notifyIcon.Wnd := Handle;
  notifyIcon.uID := 100;
  notifyIcon.uCallbackMessage := NOTIFYEVENT; //按下小图标触发的事件号
  notifyIcon.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  notifyIcon.hIcon := Application.Icon.Handle; //图标句柄
  //manname1:=manname;
  StrPLCopy(notifyIcon.szTip, manname, 63);
  //notifyIcon.szTip :=manname1;
  //'honker的挂'; //提示消息
  if mode = 0 then
    Shell_NotifyIcon(NIM_ADD, @notifyIcon)
  else
    Shell_NotifyIcon(NIM_DELETE, @notifyIcon);
end;

procedure TForm1.ShellNotify1(mode: Byte); //小图标更改函数
var
  notifyIcon: TNotifyIconData;
  manname1: string;
begin
  notifyIcon.cbSize := SizeOf(notifyIcon);
  notifyIcon.Wnd := Handle;
  notifyIcon.uID := 100;
  notifyIcon.uCallbackMessage := NOTIFYEVENT; //按下小图标触发的事件号
  notifyIcon.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;

  if mode = 0 then
  begin
    Form1.Icon := Image1.Picture.Icon;
    notifyIcon.hIcon := Form1.Icon.Handle //图标句柄
  end
  else
  begin
    notifyIcon.hIcon := Application.Icon.Handle; //图标句柄
    Form1.Icon := Application.Icon
  end;
  if manname = '' then manname1 := 'honker小助'
  else
    manname1 := manname;
  StrPLCopy(notifyIcon.szTip, manname1, 63);
  //notifyIcon.szTip := 'honker的挂'; //提示消息
  if mode = 0 then
    Shell_NotifyIcon(NIM_modify, @notifyIcon)
  else
    Shell_NotifyIcon(NIM_modify, @notifyIcon);
end;


procedure TForm1.OnSysCommand(var message: Tmessage); //最小化时隐藏主窗体
begin
  inherited;
  if message.wParam = SC_MINIMIZE then
    Visible := False;
end;
//任务栏上最小化时,隐藏窗口
procedure TForm1.OnMin(Sender: TObject);
begin
  Form1.Visible := False;
end;

procedure TForm1.OnNotifyIcon(var message: Tmessage); //小图标事件处理函数
var p: Tpoint;
begin
  if message.LParam = WM_LBUTTONDOWN then
  begin
    Visible := True;
    SetForegroundWindow(Handle);

    //下面两句使还原可用
    Form1.Show;
    Application.Restore;

    //ShowWindow(Handle, SC_maximize );
    //ShowWindow(Handle, SC_MINIMIZE);
    //ShowWindow(Handle, sw_restore);
    //ShowWindow(Handle, sw_restore);
    //ShowWindow(Handle, SW_SHOWNORMAL);
    //SHOWWINDOW(FORM1.HANDLE,SW_RESTORE);
    //setwindowlong(form1.handle,GWL_STYLE,getwindowlong(form1.handle,GWL_STYLE) or WS_MINIMIZEBOX);//让最小化按钮可用

    //sendmessage(form1.handle,WM_SYSCOMMAND,SC_RESTORE,0);
   // SendMessage(handle,WM_SYSCOMMAND,SC_RESTORE,0);
//setwindowlong(handle,GWL_STYLE,getwindowlong(handle,GWL_STYLE) or WS_MINIMIZEBOX);//让最小化按钮可用
//SetForegroundWindow(handle);
  end;
  if message.LParam = WM_rBUTTONDOWN then
  begin
    GetCursorPos(p);
    PopupMenu1.Popup(p.x, p.y);
  end;

end;



//热键消息处理
procedure TForm1.hotkeydown(var msg: Tmessage);
begin
  if (msg.LParamHi = $56) and (msg.lparamLo = mod_Alt) then
  begin
    Form1.ComboBoxman.Clear;
    Form1.ListBoxhwnd.Clear;
    hideshowalla;
  end;
  if (msg.LParamHi = $58) and (msg.lparamLo = mod_Alt) then
  begin
    Form1.ComboBoxman.Clear;
    Form1.ListBoxhwnd.Clear;
    hideshowall;
  end;

  if (msg.LParamHi = $5A) and (msg.lparamLo = mod_Alt) then
  begin
    if haveicon = 0 then
    begin
      ShellNotify(1); //小图标处理
      haveicon := 1;
      Visible := False;
    end
    else
    begin
      ShellNotify(0); //小图标处理
      ShellNotify1(0); //小图标处理
      haveicon := 0;
      //Visible := False;
    end;

    //Application.BringToFront;//把窗口显示最前面
  end;
  if (msg.LParamHi = VK_F5) and (msg.lparamLo = MOD_CONTROL or mod_Alt) then
  begin
    Visible := True;
    SetForegroundWindow(Handle);
    //Application.Restore;//显示出窗口
  end;
  if (msg.LParamHi = VK_F6) and (msg.lparamLo = MOD_CONTROL or mod_Alt) then
    //timer1.interval:=600000;//
    //Application.Minimize; //窗口最小化
    Visible := False;
  if (msg.LParamHi = VK_F7) and (msg.lparamLo = MOD_CONTROL or mod_Alt) then
  begin
    ActivateKeyboardLayout(0, KLF_ACTIVATE); //切换输入法
  end;
  if (msg.LParamHi = VK_F8) and (msg.lparamLo = MOD_CONTROL or mod_Alt) then
    Application.Terminate; //退出程序

end;



//注册热键函数
procedure TForm1.RegHot();
var
  i: integer;
begin
  for i := 1 to 6 do
  begin
    hotkeyid[i] := GlobalAddAtom(pchar('MyHotKey' + inttostr(i))) - $C000;
    Registerhotkey(Handle, hotkeyid[1], mod_Alt, $58);
    Registerhotkey(Handle, hotkeyid[2], mod_Alt, $5A);
    Registerhotkey(Handle, hotkeyid[3], mod_Alt, $56);
    Registerhotkey(Handle, hotkeyid[4], MOD_CONTROL or mod_Alt, VK_F5); //如不用辅助键MOD_CONTROL or mod_Alt改为0
    Registerhotkey(Handle, hotkeyid[5], MOD_CONTROL or mod_Alt, VK_F6);
    Registerhotkey(Handle, hotkeyid[6], MOD_CONTROL or mod_Alt, VK_F7);
    // Registerhotkey(Handle, hotkeyid[7], MOD_CONTROL or mod_Alt, VK_F8);
  end;
end;




//列所有进程
function EnumWinProc(h: HWND; Param: LParam): Boolean; stdcall;
var
  Addres: Cardinal;
  s2: array[0..254] of Char;
  s, ss: string;
begin
  MyHwnd := h;
  GetWindowText(h, s2, 255);
  s := s2;
  //if (length(s) > 0) and (UpperCase(s) = '金山单词通 2002') then begin
  //if (length(s) > 0) and (UpperCase(s) = '页面') then begin
  if (length(s) > 0) and (pos(Form1.Edit1.text, s) > 0) then
  begin
    GetWindowThreadProcessId(h, aproc);
    Form1.ComboBoxman.AddItem(s, Form1.ComboBoxman);
    Form1.ListBoxhwnd.AddItem(inttostr(integer(MyHwnd)), Form1.ListBoxhwnd);
  end;
  Result := True;
end;


procedure TForm1.Button1Click(Sender: TObject);
var
  ss: string;
  Addres: Cardinal;
begin
  Form1.ComboBoxman.Clear;
  Form1.ListBoxhwnd.Clear;
  EnumWindows(@EnumWinProc, 0);

end;

procedure TForm1.ComboBoxmanChange(Sender: TObject);
begin
  ListBoxhwnd.ItemIndex := ComboBoxman.ItemIndex;
  //listboxhwnd.Selected[comboboxman.ItemIndex];
  MyHwnd := StrToInt64(trim(ListBoxhwnd.Items.Strings[ComboBoxman.ItemIndex]));
  //labeltest.Caption:=inttostr(integer(myhwnd));
  GetWindowThreadProcessId(MyHwnd, aproc);
end;

procedure TForm1.CheckBoxhideClick(Sender: TObject);
begin
  if CheckBoxhide.Checked = True then
  begin
    Windows.ShowWindow(MyHwnd, SW_HIDE);
    //隐藏任务栏图标
    //hidetaskbar.Click;
  end
  else
  begin
    Windows.ShowWindow(MyHwnd, SW_SHOW);
  end;
end;

procedure TForm1.CheckBoxcloseClick(Sender: TObject);
begin
  if CheckBoxclose.Checked = True then
  begin

    hProcess_N := OpenProcess(PROCESS_ALL_ACCESS, False, aproc); //打开被注入的进程
    TerminateProcess(hProcess_N, 0);
    CloseHandle(hProcess_N); //关闭打开的句柄
  end;
end;

procedure TForm1.CheckBox800Click(Sender: TObject);
begin
  if CheckBox800.Checked = True then
  begin
    //SetWindowPos(MyHwnd, HWND_TopMost, 0, 0, 800, 600, SWP_ShowWindow);
    SetWindowPos(MyHwnd, 0, 0, 0, 800, 600, SWP_NOACTIVATE);
  end;
end;

procedure TForm1.CheckBox1024Click(Sender: TObject);
begin
  if CheckBox1024.Checked = True then
  begin
    SetWindowPos(MyHwnd, 0, 0, 0, 1024, 768, SWP_NOACTIVATE);
  end;
end;

procedure TForm1.ButtonJiaWuClick(Sender: TObject);
var a1: string;
begin
  if ListBox2.Count < 30 then
  begin
    a1 := trim(Editwu.text);
    Editwu.text := '';
    if a1 > '' then ListBox2.Items.Add(a1);
  end;

end;

procedure TForm1.ButtonDelWuClick(Sender: TObject);
begin
  ListBox2.DeleteSelected;
end;

procedure TForm1.ButtontjClick(Sender: TObject);

begin

  ListBox2.Clear;
  ListBox2.Items.Add('QQ');
  ListBox2.Items.Add('msn');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  //设置时间为短时间格式
  dateseparator := '-';   // 日期分隔符
  shortdateformat := 'yyyy-mm-dd'; // 短日期格式
  longdateformat := 'yyyy-mm-dd'; // 长日期格式
  timeSeparator := ':'; // 时间 分隔符
  shortTimeFormat := 'hh:mm:ss'; // 短时间格式
  longtimeformat := 'hh:mm:ss'; //长时间格式


  ShellNotify(0); //小图标处理
  ShellNotify1(0); //小图标处理
  Application.OnMinimize := OnMin; //任务栏上最小化时,隐藏窗口
  RegHot;

  //从配置文件中读配置
  filename := ExtractFilePath(paramstr(0)) + 'config.ini';
  if fileexists(filename) then readIni; //Labeldienum.Caption := '存在此文件';
  if CheckBoxhideself.Checked = True then
  begin
    //下三行不显示窗口
    Application.CreateHandle;
    ShowWindow(Application.Handle, SW_HIDE);
    Application.ShowMainForm := False;
  end;

end;

procedure TForm1.N3Click(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  Visible := True;
  SetForegroundWindow(Handle);
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  Visible := False;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var i: integer;
begin
  //释放热键。
  for i := 1 to 6 do
    unregisterhotkey(Handle, hotkeyid[i]);
  ShellNotify(1); //小图标处理
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
  //  RegHot;
  Form1.ComboBoxman.Clear;
  Form1.ListBoxhwnd.Clear;
  hideshowall;
end;

procedure TForm1.CheckBoxautorunClick(Sender: TObject);
var
  s1: string;
  registerTemp: TRegistry; //注册表启动
begin
  if CheckBoxautorun.Checked = True then
  begin
    s1 := ExtractFilePath(Application.ExeName) + extractfilename(Application.ExeName);
    Edit1.text := s1;
    //注册表启动项中增加此程序,以便下次每次启动时启动程序
    registerTemp := TRegistry.Create;
    with registerTemp do
    begin
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKey('Software\Microsoft\Windows\CurrentVersion\run', True) then
      begin
        writeString(extractfilename(s1), s1);
        //ShowMessage('操作成功');
      end
      else
        ShowMessage('操作失败');
      CloseKey;
    end;

  end;



end;

procedure TForm1.CheckBoxsaveClick(Sender: TObject);
begin
  if CheckBoxsave.Checked = True then
  begin
    writeIni;
  end;
end;

procedure TForm1.hideshowall;
var
  i: integer;
begin
  //列出满足条件的窗口
  for i := 0 to (ListBox2.Count - 1) do
  begin
    ListBoxhwnd.ItemIndex := i;
    Edit1.text := ListBox2.Items.Strings[i];
    EnumWindows(@EnumWinProc, 0);
    HideTrayIcon;
  end;
  //对满足条件的窗口隐藏和显示
  if showall = 0 then
  begin
    for i := 0 to (ListBoxhwnd.Count - 1) do
    begin
      MyHwnd := StrToInt64(trim(ListBoxhwnd.Items.Strings[i]));
      //GetWindowThreadProcessId(MyHwnd, aproc);
      Windows.ShowWindow(MyHwnd, SW_HIDE);
      //隐藏任务栏图标
     // hidetaskbar.Click;
    end;
    showall := 1;
  end
  else
  begin
    for i := 0 to (ListBoxhwnd.Count - 1) do
    begin
      MyHwnd := StrToInt64(trim(ListBoxhwnd.Items.Strings[i]));
      //GetWindowThreadProcessId(MyHwnd, aproc);
      Windows.ShowWindow(MyHwnd, SW_SHOW);
    end;
    showall := 0;
  end;
end;

procedure TForm1.hideshowalla;
var
  i: integer;
begin
  //列出满足条件的窗口
  for i := 0 to (ListBox2.Count - 1) do
  begin
    ListBoxhwnd.ItemIndex := i;
    Edit1.text := ListBox2.Items.Strings[i];
    EnumWindows(@EnumWinProc, 0);
    HideTrayIcon;
  end;
  //对满足条件的窗口隐藏和显示
  if showall = 0 then
  begin
    for i := 0 to (ListBoxhwnd.Count - 1) do
    begin
      MyHwnd := StrToInt64(trim(ListBoxhwnd.Items.Strings[i]));
      //GetWindowThreadProcessId(MyHwnd, aproc);
      //Windows.ShowWindow(MyHwnd, SW_HIDE);
      //隐藏任务栏图标
      hidetaskbar.Click;
      SetWindowPos(MyHwnd, 0, 0, 0, 1, 1, SWP_NOACTIVATE);
    end;
    showall := 1;
  end
  else
  begin
    for i := 0 to (ListBoxhwnd.Count - 1) do
    begin
      MyHwnd := StrToInt64(trim(ListBoxhwnd.Items.Strings[i]));
      //GetWindowThreadProcessId(MyHwnd, aproc);
      SetWindowPos(MyHwnd, 0, 0, 0, 800, 600, SWP_NOACTIVATE);
      Windows.ShowWindow(MyHwnd, SW_SHOW);
    end;
    showall := 0;
  end;
end;

procedure TForm1.CheckBoxhideselfClick(Sender: TObject);
{var
  aWnd : Thandle;
begin
  aWnd:=FindWindowEx( FindWindow('Shell_TrayWnd',nil),0,'TrayNotifyWnd',nil);
  aWnd:=GetWindow(aWnd,GW_CHILD) ;
  aWnd:=GetNextWindow(aWnd,GW_HWNDNEXT);
  //showwindow(aWnd,SW_HIDE); 隐藏所有图标
  showmessage(inttostr(SendMessage(aWnd, TB_BUTTONCOUNT, 0, 0))); //得到图标总数（包括分隔条）
  //sendmessage(aWnd,TB_HIDEBUTTON,2,1);  //隐藏某个图标 }
var
  TrayWnd, TrayNWnd, ClockWnd: HWND;

  notifyIcon: TNotifyIconData;
  //manname1:string;
begin


  {  TrayWnd  := FindWindow('Shell_TrayWnd', nil);
   showmessage(inttostr(TrayWnd));
   //showwindow(TrayWnd,SW_HIDE);
   Windows.ShowWindow(TrayWnd, SW_SHOW);
   TrayNWnd := FindWindowEx(TrayWnd, 0, 'TrayNotifyWnd', nil);
   showmessage(inttostr(TrayNWnd));
   ClockWnd := FindWindowEx(TrayNWnd, 0, 0, 'honker小助');
   showwindow(ClockWnd,SW_HIDE);
     //ClockWnd := FindWindowEx(TrayNWnd, 0, 'TrayClockWClass', nil);
     ClockWnd := FindWindowEx(TrayNWnd, 0, 'form1', nil);
       showwindow(ClockWnd,SW_HIDE);
      // showwindow(ClockWnd,SW_normal);

      GetWindowThreadProcessId(ClockWnd, aproc);
       hProcess_N := OpenProcess(PROCESS_ALL_ACCESS, False, aproc); //打开被注入的进程
     TerminateProcess(hProcess_N, 0);
     CloseHandle(hProcess_N); //关闭打开的句柄
      }
   //sendmessage(aWnd,TB_HIDEBUTTON,2,1);
   //showmessage(inttostr(TrayWnd));
     //showmessage(inttostr(ClockWnd));
    { notifyIcon.cbSize := SizeOf(notifyIcon);
   notifyIcon.Wnd := ClockWnd;
   notifyIcon.uID := 100;
   notifyIcon.uCallbackMessage := NOTIFYEVENT; //按下小图标触发的事件号
   notifyIcon.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
   notifyIcon.hIcon := Application.Icon.Handle; //图标句柄   }
   //manname1:=manname;
   //StrPLCopy(notifyIcon.szTip, manname, 63);
   //notifyIcon.szTip :=manname1;
   //'honker的挂'; //提示消息
     //Shell_NotifyIcon(NIM_add, @notifyIcon);
   //Result := IsWindow(ClockWnd);
   //if Result then
   //begin
     //ShowWindow(ClockWnd, Ord(bValue));
     //PostMessage(ClockWnd, WM_PAINT, 0, 0);
   //end;
end;


function GetToolBarButtonRect(HWND: HWND; Title: string): TRect;
{
  返回指定工具栏对应的按钮指定文本的矩形区域
  hWnd:工具栏句柄，Title：需要返回矩形区域的按钮文字
  返回值：指定按钮的边界矩形，屏幕坐标
}
var
  C, i: integer;
  Info: _TBBUTTON;
  Item: tagTCITEM;
  Buff: pchar;
  s: array[0..1024] of Char;
  PID: THandle;
  PRC: THandle;
  R: Cardinal;
begin
  FillChar(Result, SizeOf(Result), 0);
  if HWND = 0 then Exit;
  GetWindowThreadProcessId(HWND, @PID);
  PRC := OpenProcess(PROCESS_VM_OPERATION or PROCESS_VM_READ or PROCESS_VM_WRITE, False, PID);
  Buff := VirtualAllocEx(PRC, nil, 4096, MEM_RESERVE or MEM_COMMIT, PAGE_READWRITE);

  if Format('%d.%d', [Win32MajorVersion, Win32MinorVersion]) >= '5.1' then {// Is Windows XP or Higher}
  begin
    C := SendMessage(HWND, TB_BUTTONCOUNT, 0, 0);
    for i := 0 to C - 1 do
    begin
      FillChar(Info, SizeOf(Info), 0);
      WriteProcessMemory(PRC, Buff, @Info, SizeOf(Info), R);

      SendMessage(HWND, TB_GETBUTTON, i, integer(Buff));
      ReadProcessMemory(PRC, Buff, @Info, SizeOf(Info), R);

      SendMessage(HWND, TB_GETBUTTONTEXT, Info.idCommand, integer(integer(@Buff[0]) + SizeOf(Info)));
      ReadProcessMemory(PRC, Pointer(integer(@Buff[0]) + SizeOf(Info)), @s[0], SizeOf(s), R);
      //if SameText(StrPas(S), Title) and not Boolean(SendMessage(hWnd, TB_ISBUTTONHIDDEN, Info.idCommand, 0)) then
      if (pos(Title, StrPas(s)) > 0) and not Boolean(SendMessage(HWND, TB_ISBUTTONHIDDEN, Info.idCommand, 0)) then
      begin
        //IconId:=(C-1)-i;
        IconId := (C - 1) - i;
        SendMessage(HWND, TB_GETRECT, Info.idCommand, integer(integer(@Buff[0]) + SizeOf(Info)));
        ReadProcessMemory(PRC, Pointer(integer(@Buff[0]) + SizeOf(Info)), @Result, SizeOf(Result), R);

        Windows.ClientToScreen(HWND, Result.TopLeft);
        Windows.ClientToScreen(HWND, Result.BottomRight);
        mHandle := HWND;

        Break;
      end;
    end;
  end
  else
  begin
    C := SendMessage(HWND, TCM_GETITEMCOUNT, 0, 0);
    for i := 0 to C - 1 do
    begin
      with Item do
      begin
        mask := TCIF_TEXT;
        dwState := 0;
        dwStateMask := 0;
        cchTextMax := 2048;
        pszText := pchar(integer(Buff) + SizeOf(Item) * 4);
        iImage := 0;
        LParam := 0;
      end;
      WriteProcessMemory(PRC, Buff, @Item, SizeOf(Item), R);
      SendMessage(HWND, TCM_GETITEM, i, integer(Buff));

      ReadProcessMemory(PRC, Buff, @Item, SizeOf(Item), R);
      ReadProcessMemory(PRC, pchar(integer(Buff) + SizeOf(Item) * 4), @s[0], SizeOf(s), R);
      //if SameText(S, Title) then
      if (pos(Title, StrPas(s)) > 0) then
      begin
        SendMessage(HWND, TCM_GETITEMRECT, i, integer(Buff));
        ReadProcessMemory(PRC, Buff, @Result, SizeOf(Result), R);

        Windows.ClientToScreen(HWND, Result.TopLeft);
        Windows.ClientToScreen(HWND, Result.BottomRight);
        Break;
      end;
    end;
  end;

  VirtualFreeEx(PRC, Buff, 0, MEM_RELEASE);
  CloseHandle(PRC);
end;


function GetSysTrayWnd: HWND;
{
  返回系统托盘的句柄，适合于WinXP以上版本
}
begin
  Result := FindWindow('Shell_TrayWnd', nil);
  Result := FindWindowEx(Result, 0, 'TrayNotifyWnd', nil);
  Result := FindWindowEx(Result, 0, 'SysPager', nil);
  Result := FindWindowEx(Result, 0, 'ToolbarWindow32', nil);
end;



function GetSysTrayIconRect(text: string): TRect;
{
  返回系统托盘中指定文字的图标的矩形区域。
  例如返回音量控制图标的矩形区域：
  GetSysTrayIconRect('音量');
}
begin
  Result := GetToolBarButtonRect(GetSysTrayWnd, text);
end;





procedure TForm1.HideTrayIcon;
var
  trayIcon: string;
  isHide: Boolean;
  myRect: TRect;
begin
  trayIcon := Edit1.text;
  isHide := True;
  myRect := GetSysTrayIconRect(trayIcon);

  if isHide then
    SendMessage(GetSysTrayWnd, TB_HIDEBUTTON, IconId, 1)
  else
    SendMessage(GetSysTrayWnd, TB_HIDEBUTTON, IconId, 0);

end;




procedure TForm1.Button2Click(Sender: TObject);
var
  aClassName, ComponetName: array[0..255] of Char;
  nt: TNotifyIconData;
begin
  { //Result:=True;
   GetClassName(GetSysTrayWnd, aClassName, 255);     //依次得到子窗体所有控件类名
   GetWindowText(GetSysTrayWnd, ComponetName, 255);
 showmessage(inttostr(GetSysTrayWnd));
 showmessage(aClassName);
 showmessage(ComponetName);             }
  GetSysTrayIconRect('安全删除硬件');
  MyHwnd := 2360462;
  with nt do
  begin
    cbSize := SizeOf(nt); //#32770
    Wnd := MyHwnd; //   FindWindow(nil,'金山词霸 2006'   );
    uID := 0;
    uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
    uCallbackMessage := WM_USER + 17;
    hIcon := 0;
    szTip := '';
  end;
  Shell_NotifyIcon(NIM_DELETE, @nt);
  ShowMessage(inttostr(MyHwnd));
  HideTrayIcon;
  //hideStartbutton(false);
  //Windows.ShowWindow(MyHwnd, SW_HIDE);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  str1: string;
  datestr: tdatetime;
  i: integer;
begin
  Timer1.Enabled := False;
    //设置时间为短时间格式
  dateseparator := '-';   // 日期分隔符
  shortdateformat := 'yyyy-mm-dd'; // 短日期格式
  longdateformat := 'yyyy-mm-dd'; // 长日期格式
  timeSeparator := ':'; // 时间 分隔符
  shortTimeFormat := 'hh:mm:ss'; // 短时间格式
  longtimeformat := 'hh:mm:ss'; //长时间格式

  str1 := '2050-12-30 9:25:10';
  datestr := strtodatetime(str1);
  str1 := datetimetostr(now);
  if now > datestr then
  begin
    Editwu.text := str1;
    //释放热键。
    for i := 1 to 6 do
      unregisterhotkey(Handle, hotkeyid[i]);
    ShellNotify(1); //小图标处理
    ShowMessage('你所用的版本已过期,要想继续用,请联系开发人员,索取免费版!!');
    Application.Terminate();
  end;
  //showmessage(str1);
  Timer1.Enabled := True;

end;

procedure TForm1.hidetaskbarClick(Sender: TObject);
var
  TaskbarList: ITaskbarList;
const
  CLSID_TaskbarList: TGUID = '{56FDF344-FD6D-11d0-958A-006097C9A090}';
  IID_ITaskbarList: TGUID = '{602D4995-B13A-429b-A66E-1935E44F4317}';
begin
  CoCreateInstance(CLSID_TaskbarList, nil, CLSCTX_INPROC_SERVER, IID_ITaskbarList, TaskbarList);
  TaskbarList.HrInit();
  TaskbarList.DeleteTab(MyHwnd);
end;

procedure TForm1.CheckBox10Click(Sender: TObject);
begin
  if CheckBox10.Checked = True then
  begin
    //SetWindowPos(MyHwnd, HWND_TopMost, 0, 0, 800, 600, SWP_ShowWindow);
    SetWindowPos(MyHwnd, 0, 0, 0, 1, 1, SWP_NOACTIVATE);
  end;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  Form1.ComboBoxman.Clear;
  Form1.ListBoxhwnd.Clear;
  hideshowalla;
end;

procedure TForm1.CheckBoxxyClick(Sender: TObject);
var
x,y:integer;
begin
  if CheckBoxxy.Checked = True then
  begin
    //SetWindowPos(MyHwnd, HWND_TopMost, 0, 0, 800, 600, SWP_ShowWindow);
    x:=strtoint(editx.Text );  
    y:=strtoint(edity.Text );
    SetWindowPos(MyHwnd, 0, 0, 0, x, y, SWP_NOACTIVATE);
  end;
end;

end.

