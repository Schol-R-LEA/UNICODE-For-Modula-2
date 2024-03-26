(* Copyright (C) 2024 Alice Osako,
   based on code Copyright (C) 2010 The Free Software Foundation, Inc. *)
(*
UNICODE for Modula-2 is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as published
by the Free Software Foundation; either version 3, or (at your option)
any later version.

UNICODE for Modula-2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with this package; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. *)


MODULE TestUTF8FileIO;

FROM Unicode IMPORT UNICHAR, UCS4_codeunit, IsUnicode,
                    CharToUNICHAR,
                    Is7BitPrintable, ASCIIToUNICHAR,
                    CodepointToUNICHAR, CodepointToString,
                    IsBMP, BMPToUNICHAR, SurrogatesToUNICHAR;


FROM FIO IMPORT File, OpenToRead, OpenToWrite, Close;
FROM STextIO IMPORT WriteString, WriteLn;
FROM SWholeIO IMPORT WriteCard;
FROM UTF8 IMPORT UTF8Buffer, UnicharToUtf8, Utf8ToUnichar, UnicharStatus;
FROM UniTextIO IMPORT ReadUtf8Buffer, WriteUtf8Buffer;


VAR
  passes, fails, index: CARDINAL;
  a: ARRAY [0..12] OF UNICHAR;

PROCEDURE TestUnichar(uc: UNICHAR);
VAR
  f: File;
  buffer: ARRAY [0..31] OF CHAR;
  obuffer, ibuffer: UTF8Buffer;
  readUCS: UNICHAR;
  status: UnicharStatus;

BEGIN
  status := UnicharToUtf8(uc, obuffer);

  f := OpenToWrite("read_write_test.txt");
  WriteUtf8Buffer(f, obuffer);
  Close(f);

  f := OpenToRead("read_write_test.txt");
  ReadUtf8Buffer(f, ibuffer);
  Close(f);

  status := Utf8ToUnichar(ibuffer, readUCS);

  IF status = Valid THEN
    INC(passes);
  ELSE
    WriteCard(index, 7);
    WriteString(": Read value is not a valid USC-4 codepoint.");
    WriteLn;
    INC(fails);
  END;

  IF uc = readUCS THEN
    INC(passes);
  ELSE
    WriteCard(index, 7);
    WriteString(": Codepoint ");
    CodepointToString(uc, buffer);
    WriteString(buffer);
    WriteString(" # ");
    CodepointToString(readUCS, buffer);
    WriteString(buffer);
    WriteLn;
    INC(fails);
  END;

END TestUnichar;



BEGIN
   passes := 0;
   fails := 0;

   a[0] := CharToUNICHAR('a');         (* a CHAR which is a BMP codepoint *)
   a[1] := ASCIIToUNICHAR('a');        (* an ASCII char which is a BMP codepoint *)
   a[2] := CodepointToUNICHAR(ORD('a'));
   a[3] := CodepointToUNICHAR(120H);  (* a non-ASCII char which is a BMP codepoint *)
   a[4] := BMPToUNICHAR(0C1H);           (* a non-ASCII char which is a BMP codepoint *)
   a[5] := CodepointToUNICHAR(0C1H);  (* a non-ASCII char which is a BMP codepoint *)
   a[6] := BMPToUNICHAR(0141H);   (* a non-ASCII char which is a BMP codepoint *)
   a[7] := BMPToUNICHAR(10401H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[8] := CodepointToUNICHAR(10401H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[9] := SurrogatesToUNICHAR(0DC01H, 0D801H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[10] := CodepointToUNICHAR(0FFFFFFFFH);  (* an invalid codepoint, should return REPLACEMENT CHAR *)
   a[11] := CodepointToUNICHAR(21H);  (* an invalid codepoint, should return REPLACEMENT CHAR *)
   a[12] := CodepointToUNICHAR(0E18H);  (* a non-ASCII char which is a BMP codepoint *)


   FOR index := 0 TO 12 DO
      TestUnichar(a[index]);
   END;


   WriteString("Passes: ");
   WriteCard(passes, 2);
   WriteLn;
   WriteString("Fails: ");
   WriteCard(fails, 2);
   WriteLn;
END TestUTF8FileIO.