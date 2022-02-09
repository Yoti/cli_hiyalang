{
  v0.5 @ 06.02.2022
  This patcher utility is written by Yoti
  American region support added by Simonsator
  Mostly based on Mighty Max's work - thx
}
{
  '\title\00030017\484e4143\content\00000000.app'; // CHN
  '\title\00030017\484e4145\content\00000002.app'; // USA
  '\title\00030017\484e414a\content\00000002.app'; // JPN
  '\title\00030017\484e414b\content\00000000.app'; // KOR
  '\title\00030017\484e4150\content\00000002.app'; // EUR
  '\title\00030017\484e4155\content\00000002.app'; // AUS

  @48ba4:
    ASIA: 014800687047C046
    WORLD: 01483E207047C046
  @48bc8:
    JPN = 00
    USA = 01
    EUR = 02
    AUS = 03
    CHN = ??
    KOR = ??
}
program hiyalang;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  System.Hash,
  WinApi.Windows;

const
  ProgramTitle: String = 'HiyaCFW language patcher v0.4' + #13#10 +
                         '-- https://github.com/Yoti --';
  LocalFileArr: Array[0..1] of String = (
    '00000000.app', '00000002.app'
  );
  AppFileArray: Array[0..3] of Array[0..2] of String = (
    ('3', '0', 'Chinese'),
    ('5', '2', 'USA'),
    ('a', '2', 'Japanese'),
    ('b', '0', 'Korean')
  );
  PatchesArray: Array[0..1] of Array[0..1] of Int64 = (
    ($014B7F2018607047, $48ba4),
    ($014B022018727047, $48bc8)
  );

var
  ConsoleTitle: Array [0..MAX_PATH] of Char;
  i: Integer;
  AppFilePath: String;

function Swap64(Value: Int64): Int64;
asm
  mov   edx, Value.Int64Rec.Lo
  bswap edx
  mov   eax, Value.Int64Rec.Hi
  bswap eax
end;

procedure PatchFile(const inFileName: String; const PatchData, PatchOffset: Int64);
var
  FileStream: TFileStream;
begin
  FileStream:=TFileStream.Create(inFileName, fmOpenReadWrite or fmShareDenyWrite);
  FileStream.Position:=PatchOffset;
  FileStream.Write(PatchData, SizeOf(PatchData));
  FileStream.Free;
end;

procedure CreateBackup(const inFileName: String);
var
  outFileName: String;
begin
  outFileName:=ChangeFileExt(inFileName, '.bak');

  if (FileExists(outFileName) = False) then begin
    CopyFile(PChar(inFileName), PChar(outFileName), False);
    WriteLn('Backup Launcher created');
  end else WriteLn('Backup Launcher exists');
end;

begin
  GetConsoleTitle(PChar(@ConsoleTitle), MAX_PATH);
  SetConsoleTitle(PChar(ChangeFileExt(ExtractFileName(ParamStr(0)), '')));
  WriteLn(ProgramTitle);

  WriteLn('Looking for Launcher...');

  for i:=0 to Length(LocalFileArr)-1 do begin
    AppFilePath:=ExtractFilePath(ParamStr(0)) + LocalFileArr[i];

    if (FileExists(AppFilePath) = True) then begin
      WriteLn(ChangeFileExt(LocalFileArr[i], '') + ' Launcher IS found!');

      CreateBackup(AppFilePath);
      PatchFile(AppFilePath, Swap64(PatchesArray[0][0]), PatchesArray[0][1]);
      PatchFile(AppFilePath, Swap64(PatchesArray[1][0]), PatchesArray[1][1]);

      WriteLn(IntToStr(Length(PatchesArray)) + ' patches applied!');
    end else WriteLn(ChangeFileExt(LocalFileArr[i], '') + ' Launcher NOT found!');
  end;

  for i:=0 to Length(AppFileArray)-1 do begin
    AppFilePath:=ExtractFileDrive(ParamStr(0)) +
      '\title\00030017\484e414' +
      AppFileArray[i][0] +
      '\content\0000000' +
      AppFileArray[i][1] +
      '.app';

    if (FileExists(AppFilePath) = True) then begin
      WriteLn(AppFileArray[i][2] + ' Launcher IS found!');

      CreateBackup(AppFilePath);
      PatchFile(AppFilePath, Swap64(PatchesArray[0][0]), PatchesArray[0][1]);
      PatchFile(AppFilePath, Swap64(PatchesArray[1][0]), PatchesArray[1][1]);

      WriteLn(IntToStr(Length(PatchesArray)) + ' patches applied!');
    end else WriteLn(AppFileArray[i][2] + ' Launcher NOT found!');
  end;

  WriteLn('Done, press ENTER to exit...'); ReadLn;
  SetConsoleTitle(ConsoleTitle);
end.

