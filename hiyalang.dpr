{
  v0.3 @ 20.05.2021
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
  ProgramTitle: String = 'HiyaCFW language patcher v0.3';
  AppFileArray: Array[0..2] of Array[0..2] of String = (
    ('3', '0', 'Chinese'),
    ('a', '2', 'Japanese'),
    ('b', '0', 'Korean')
  );

var
  ConsoleTitle: Array [0..MAX_PATH] of Char;
  i: Integer;
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

    PatchFile(AppFilePath, Swap64($01xx7F2018607047), $48ba4);
    //ASIA: 014800687047C046, WORLD: 01483E207047C046
    PatchFile(AppFilePath, Swap64($014Bxx2018727047), $48bc8);
    //JPN = 00, USA = 01, EUR = 02, AUS = 03, CHN = ?, KOR = ?
  }

  WriteLn('Looking for Launcher...');

  for i:=0 to Length(AppFileArray)-1 do begin
    AppFilePath:=ExtractFileDrive(ParamStr(0)) +
      '\title\00030017\484e414' +
      AppFileArray[i][0] +
      '\content\0000000' +
      AppFileArray[i][1] +
      '.app';
    BakFilePath:=ChangeFileExt(AppFilePath, '.bak');

    if (FileExists(AppFilePath) = True) then begin
      WriteLn(AppFileArray[i][2] + ' Launcher found!');

      if (FileExists(BakFilePath) = False) then begin
        CopyFile(PChar(AppFilePath), PChar(BakFilePath), True);
        WriteLn('Backup Launcher created');
      end else WriteLn('Backup Launcher exists');

      PatchFile(AppFilePath, Swap64($014B7F2018607047), $48ba4);
      PatchFile(AppFilePath, Swap64($014B022018727047), $48bc8);

      WriteLn('Two patches applied!');
    end else WriteLn(AppFileArray[i][2] + ' Launcher NOT found!');
  end;

  WriteLn('Done, press ENTER to exit...'); ReadLn;
  SetConsoleTitle(ConsoleTitle);
end.

