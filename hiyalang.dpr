{
  v0.1 @ 13.05.2021
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
  ProgramTitle: String = 'HiyaCFW language patcher v0.1';

var
  ConsoleTitle: Array [0..MAX_PATH] of Char;
  AppFilePath: String;
  BakFilePath: String;
  AppFileData: TFileStream;
  BakFileData: TFileStream;
  TmpPatchData: Cardinal;

function Swap16(Value: SmallInt): SmallInt;
asm
  rol ax, 8
end;

function Swap32(Value: Integer): Integer;
asm
  bswap eax
end;

begin
  GetConsoleTitle(PChar(@ConsoleTitle), MAX_PATH);
  SetConsoleTitle(PChar(ChangeFileExt(ExtractFileName(ParamStr(0)), '')));
  if (ProgramTitle <> '') then WriteLn(ProgramTitle);

  AppFilePath:=ExtractFileDrive(ParamStr(0)) +
  //'\title\00030017\484e4143\content\00000000.app'; // CHN
  //'\title\00030017\484e4145\content\00000002.app'; // USA
    '\title\00030017\484e414a\content\00000002.app'; // JAP
  //'\title\00030017\484e414b\content\00000000.app'; // KOR
  //'\title\00030017\484e4150\content\00000002.app'; // EUR
  //'\title\00030017\484e4155\content\00000002.app'; // AUS
  BakFilePath:=ChangeFileExt(AppFilePath, '.bak');

  if (FileExists(AppFilePath) = True) then begin
    WriteLn('Launcher APP found!');
    if (THashSHA2.GetHashStringFromFile(AppFilePath) = '257c474851715e4ec2b0aa0c45ae9284252908aa8267cb281214d6b8f799731d') then begin
      AppFileData:=TFileStream.Create(AppFilePath, fmOpenReadWrite or fmShareDenyWrite);

      BakFileData:=TFileStream.Create(BakFilePath, fmCreate or fmOpenWrite or fmShareDenyWrite);
      BakFileData.CopyFrom(AppFileData, AppFileData.Size);
      BakFileData.Free;
      WriteLn('Backup copy done!');

      AppFileData.Position:=$48ba4; // JAPv512
      TmpPatchData:=Swap32($014B7F20); // patchLangMaskPatch 1 of 3 - EUR
      AppFileData.Write(TmpPatchData, SizeOf(TmpPatchData));
      TmpPatchData:=Swap32($18607047); // patchLangMaskPatch 2 of 3
      AppFileData.Write(TmpPatchData, SizeOf(TmpPatchData));
      TmpPatchData:=Swap32($68FDFF02); // patchLangMaskPatch 3 of 3
      AppFileData.Write(TmpPatchData, SizeOf(TmpPatchData));

      AppFileData.Position:=$48bc8; // JAPv512
      TmpPatchData:=Swap32($014B0220); // patchRegionPatch 1 of 3 - EUR
      AppFileData.Write(TmpPatchData, SizeOf(TmpPatchData));
      TmpPatchData:=Swap32($18727047); // patchRegionPatch 2 of 3
      AppFileData.Write(TmpPatchData, SizeOf(TmpPatchData));
      TmpPatchData:=Swap32($68FDFF02); // patchRegionPatch 3 of 3
      AppFileData.Write(TmpPatchData, SizeOf(TmpPatchData));

      AppFileData.Free;
      WriteLn('APP patching done!');
    end else if (THashSHA2.GetHashStringFromFile(AppFilePath) = 'd10e75e3da274e954fc6e374a1debe67da2c79dbed2d08feb9e5c4db3c000167') then begin
      WriteLn('Launcher APP already patched!');
    end else begin
      WriteLn('Launcher APP is broken :(');
    end;
  end else WriteLn('Launcher APP not found :(');

  {$IFDEF DEBUG}ReadLn;{$ENDIF}
  SetConsoleTitle(ConsoleTitle);
end.
