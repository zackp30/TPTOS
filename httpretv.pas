program httpretv;
uses
  SysUtils,WinInet;
var
 str:string;
function DownloadFile(const Url,Filename: string): string;
var
  NetHandle: HINTERNET;
  UrlHandle: HINTERNET;
  Buffer: array[0..1024] of Char;
  BytesRead: Cardinal;
  f:file;
begin
  NetHandle := InternetOpen('Delphi 5.x', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);

  if Assigned(NetHandle) then
  begin
    UrlHandle := InternetOpenUrl(NetHandle, PChar(Url), nil, 0, INTERNET_FLAG_RELOAD, 0);

    if Assigned(UrlHandle) then
      { UrlHandle valid? Proceed with download }
    begin
      Assign(f,Filename);
      Rewrite(f,1);
      repeat
        FillChar(Buffer, SizeOf(Buffer), 0);
        InternetReadFile(UrlHandle, @Buffer, SizeOf(Buffer), BytesRead);
        blockwrite(f,Buffer,BytesRead);
      until BytesRead = 0;
      InternetCloseHandle(UrlHandle);
      Close(f);
    end
    else
      { UrlHandle is not valid. Raise an exception. }
    raise Exception.CreateFmt('Cannot open URL %s', [Url]);

    InternetCloseHandle(NetHandle);
  end
  else
    { NetHandle is not valid. Raise an exception }
    raise Exception.Create('Unable to initialize Wininet');
end;
begin
  { TODO -oUser -cConsole Main : Insert code here }
   if ParamCount=2 then
    str:=DownloadFile(ParamStr(1),ParamStr(2));
end.
