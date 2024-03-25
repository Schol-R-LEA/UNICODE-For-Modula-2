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


FROM FIO IMPORT File, Open, Close;
FROM STextIO IMPORT WriteChar, WriteString, WriteLn;
FROM SWholeIO IMPORT WriteCard;
FROM UTF8 IMPORT UTF8Buffer, UnicharToUtf8, Utf8ToUnichar;
FROM UniTextIO IMPORT ReadUtf8Buffer, WriteUtf8Buffer;


TYPE
  TestFrame = RECORD
    uc: UNICHAR;
    valid, ascii, bmp: BOOLEAN;
  END;

VAR
  a: ARRAY [0..15] OF TestFrame;
  passes, fails, i: CARDINAL;
  output: File;

PROCEDURE TestUnichar(tf: TestFrame);
VAR
  buffer: ARRAY [0..31] OF CHAR;
  ubuffer: UTF8Buffer;
  convert: UNICHAR;

BEGIN
  UnicharToUtf8(uc, ubuffer);

  WriteUtf8Buffer(output, ubuffer);

  CodepointToString(uc, buffer);



   TestIsASCII(uc);
   TestIsBMP(uc);

   WriteString(" -> ");
   Utf8ToUnichar(ubuffer, convert);
   WriteCard(convert, 1);
   WriteString(" -> ");
   WriteChar("'");
   UnicharToUtf8(convert, ubuffer);
   WriteUtf8Buffer(ubuffer);
   WriteString("' ");

END TestUnichar;



BEGIN
   passes := 0;
   fails := 0;
   Open(output);

   a[0].uc := CharToUNICHAR('a');         (* a CHAR which is a BMP codepoint *)
   a[0].valid := TRUE;
   a[0].bmp := TRUE;
   a[0].ascii := TRUE;

   a[1].uc := ASCIIToUNICHAR('a');        (* an ASCII char which is a BMP codepoint *)
   a[1].valid := TRUE;
   a[1].bmp := TRUE;
   a[1].ascii := TRUE;

   a[2].uc := CodepointToUNICHAR(ORD('a'));
   a[2].valid := TRUE;
   a[2].bmp := TRUE;
   a[2].ascii := TRUE;

   a[3].uc := CodepointToUNICHAR(120H);  (* a non-ASCII char which is a BMP codepoint *)
   a[3].valid := TRUE;
   a[3].bmp := TRUE;
   a[3].ascii := FALSE;

   a[4].uc := BMPToUNICHAR(0C1H);           (* a non-ASCII char which is a BMP codepoint *)
   a[4].valid := TRUE;
   a[4].bmp := TRUE;
   a[4].ascii := FALSE;

   a[5].uc := CodepointToUNICHAR(0C1H);  (* a non-ASCII char which is a BMP codepoint *)
   a[5].valid := TRUE;
   a[5].bmp := TRUE;
   a[5].ascii := FALSE;

   a[6].uc := BMPToUNICHAR(0141H);           (* a non-ASCII char which is a BMP codepoint *)
   a[6].valid := TRUE;
   a[6].bmp := TRUE;
   a[6].ascii := FALSE;

   a[7].uc := BMPToUNICHAR(10401H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[7].valid := TRUE;
   a[7].bmp := FALSE;
   a[7].ascii := FALSE;

   a[8].uc := CodepointToUNICHAR(10401H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[8].valid := TRUE;
   a[8].bmp := FALSE;
   a[8].ascii := FALSE;

   a[9].uc := SurrogatesToUNICHAR(0DC01H, 0D801H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[9].valid := TRUE;
   a[9].bmp := FALSE;
   a[9].ascii := FALSE;

   a[10].uc := CodepointToUNICHAR(0FFFFFFFFH);  (* an invalid codepoint, should return REPLACEMENT CHAR *)
   a[10].valid := FALSE;
   a[10].bmp := FALSE;
   a[10].ascii := FALSE;

   a[11].uc := CodepointToUNICHAR(21H);  (* an invalid codepoint, should return REPLACEMENT CHAR *)
   a[11].valid := FALSE;
   a[11].bmp := FALSE;
   a[11].ascii := FALSE;

   FOR i := 0 TO 15 DO
      TestUnichar(a[i]);
   END;

   WriteString("Passes: ");
   WriteCard(passes, 2);
   WriteLn;
   WriteString("Fails: ");
   WriteCard(fails, 2);
   WriteLn;
END TestUTF8FileIO.