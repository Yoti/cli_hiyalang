{
  v0.2 @ 13.05.2021
  This patcher utility is written by Yoti
  Mostly based on Mighty Max's work - thx
}
program hiyalang;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  System.Hash,
  WinApi.Windows;

const
  ProgramTitle: String = 'HiyaCFW language patcher v0.2';

var
  ConsoleTitle: Array [0..MAX_PATH] of Char;
  AppFilePath: String;
  BakFilePath: String;

function Swap64(Value: Int64): Int64;
asm
  mov   edx, Value.Int64Rec.Lo
  bswap edx
  mov   eax, Value.Int64Rec.Hi
  bswap eax
end;

procedure PatchFile(FileName: String; PatchData: Int64; PatchOffset: Int64);
var
  FileStream: TFileStream;
begin
  FileStream:=TFileStream.Create(FileName, fmOpenReadWrite or fmShareDenyWrite);
  FileStream.Position:=PatchOffset;
  FileStream.Write(PatchData, SizeOf(PatchData));
  FileStream.Free;
end;

begin
  GetConsoleTitle(PChar(@ConsoleTitle), MAX_PATH);
  SetConsoleTitle(PChar(ChangeFileExt(ExtractFileName(ParamStr(0)), '')));
  if (ProgramTitle <> '') then WriteLn(ProgramTitle);

  {
    '\title\00030017\484e4143\content\00000000.app'; // CHN
    '\title\00030017\484e4145\content\00000002.app'; // USA
    '\title\00030017\484e414a\content\00000002.app'; // JAP
    '\title\00030017\484e414b\content\00000000.app'; // KOR
    '\title\00030017\484e4150\content\00000002.app'; // EUR
    '\title\00030017\484e4155\content\00000002.app'; // AUS
  }

  WriteLn('Looking for Launcher...');

  AppFilePath:=ExtractFileDrive(ParamStr(0)) +
    '\title\00030017\484e4143\content\00000000.app'; // CHN
  BakFilePath:=ChangeFileExt(AppFilePath, '.bak');

  if (FileExists(AppFilePath) = True) then begin
    WriteLn('Chinese Launcher found!');

    if (FileExists(BakFilePath) = False) then begin
      CopyFile(PChar(AppFilePath), PChar(BakFilePath), True);
      WriteLn('Backup Launcher created');
    end else WriteLn('Backup Launcher exists');

    PatchFile(AppFilePath, Swap64($014B7F2018607047), $48ba4);
    PatchFile(AppFilePath, Swap64($014B022018727047), $48bc8);

    WriteLn('Two patches applied!');
  end;

  AppFilePath:=ExtractFileDrive(ParamStr(0)) +
    '\title\00030017\484e414a\content\00000002.app'; // JAP
  BakFilePath:=ChangeFileExt(AppFilePath, '.bak');

  if (FileExists(AppFilePath) = True) then begin
    WriteLn('Japanese Launcher found!');

    if (FileExists(BakFilePath) = False) then begin
      CopyFile(PChar(AppFilePath), PChar(BakFilePath), True);
      WriteLn('Backup Launcher created');
    end else WriteLn('Backup Launcher exists');

    PatchFile(AppFilePath, Swap64($014B7F2018607047), $48ba4);
    PatchFile(AppFilePath, Swap64($014B022018727047), $48bc8);

    WriteLn('Two patches applied!');
  end;

  AppFilePath:=ExtractFileDrive(ParamStr(0)) +
    '\title\00030017\484e414b\content\00000000.app'; // KOR
  BakFilePath:=ChangeFileExt(AppFilePath, '.bak');

  if (FileExists(AppFilePath) = True) then begin
    WriteLn('Korean Launcher found!');

    if (FileExists(BakFilePath) = False) then begin
      CopyFile(PChar(AppFilePath), PChar(BakFilePath), True);
      WriteLn('Backup Launcher created');
    end else WriteLn('Backup Launcher exists');

    PatchFile(AppFilePath, Swap64($014B7F2018607047), $48ba4);
    PatchFile(AppFilePath, Swap64($014B022018727047), $48bc8);

    WriteLn('Two patches applied!');
  end;

  WriteLn('Done, press ENTER to exit...'); ReadLn;
  SetConsoleTitle(ConsoleTitle);
end.

