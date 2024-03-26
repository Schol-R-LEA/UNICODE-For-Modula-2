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


MODULE TestUTF8Console;

FROM Unicode IMPORT UNICHAR, UCS4_codeunit, IsUnicode,
                    CharToUNICHAR,
                    Is7BitPrintable, ASCIIToUNICHAR,
                    CodepointToUNICHAR, CodepointToString,
                    IsBMP, BMPToUNICHAR, SurrogatesToUNICHAR;

FROM STextIO IMPORT WriteChar, WriteString, WriteLn;
FROM SWholeIO IMPORT WriteCard;
FROM DynamicStrings IMPORT CopyOut;
FROM UTF8 IMPORT UTF8Buffer, UnicharStatus, UnicharToUtf8, Utf8ToUnichar;
FROM SUniTextIO IMPORT WriteUtf8Buffer;

VAR
  a: ARRAY [0..12] OF UNICHAR;
  i: CARDINAL;
  passes, fails: CARDINAL;

PROCEDURE TestIsASCII(uc: UNICHAR);
BEGIN
  IF Is7BitPrintable(uc) THEN
    WriteString(" is ");
  ELSE
    WriteString(" is not ");
  END;
  WriteString("a printable ASCII character;");
END TestIsASCII;


PROCEDURE TestIsBMP(uc: UNICHAR);
BEGIN
  IF IsBMP(uc) THEN
    WriteString(" is ");
  ELSE
    WriteString(" is not ");
  END;
 WriteString("in the BMP.");
END TestIsBMP;


PROCEDURE TestUnichar(uc: UNICHAR);
VAR
  buffer: ARRAY [0..31] OF CHAR;
  ubuffer: UTF8Buffer;
  convert: UNICHAR;
  status: UnicharStatus;

BEGIN
  status := UnicharToUtf8(uc, ubuffer);
  IF status = Valid THEN
    INC(passes);
  ELSE
    INC(fails);
    RETURN;
  END;

  WriteChar("'");
  WriteUtf8Buffer(ubuffer);
  WriteString("' ");

  CodepointToString(uc, buffer);
  WriteString(buffer);

  IF IsUnicode(uc) THEN
    WriteString(" is ");
  ELSE
    WriteString(" is not ");
  END;
  WriteString("a valid codepoint;");

  TestIsASCII(uc);
  TestIsBMP(uc);

  WriteString(" -> ");
  status := Utf8ToUnichar(ubuffer, convert);
  IF status = Valid THEN
    INC(passes);
  ELSE
    INC(fails);
    RETURN;
  END;
  WriteCard(convert, 1);
  WriteString(" -> ");
  WriteChar("'");
  status := UnicharToUtf8(convert, ubuffer);
  IF status = Valid THEN
    INC(passes);
  ELSE
    INC(fails);
    RETURN;
  END;
  WriteUtf8Buffer(ubuffer);
  WriteString("' ");
END TestUnichar;



BEGIN
  a[0] := CharToUNICHAR('a');         (* a CHAR which is a BMP codepoint *)
  a[1] := ASCIIToUNICHAR('a');        (* an ASCII char which is a BMP codepoint *)
  a[2] := CodepointToUNICHAR(ORD('a'));
  a[3] := CodepointToUNICHAR(120H);  (* a non-ASCII char which is a BMP codepoint *)
  a[4] := BMPToUNICHAR(0C1H);           (* a non-ASCII char which is a BMP codepoint *)
  a[5] := CodepointToUNICHAR(0C1H);  (* a non-ASCII char which is a BMP codepoint *)
  a[6] := BMPToUNICHAR(0141H);           (* a non-ASCII char which is a BMP codepoint *)
  a[7] := BMPToUNICHAR(10401H);  (* a non-ASCII char which is not a BMP codepoint *)
  a[8] := CodepointToUNICHAR(10401H);  (* a non-ASCII char which is not a BMP codepoint *)
  a[9] := SurrogatesToUNICHAR(0DC01H, 0D801H);  (* a non-ASCII char which is not a BMP codepoint *)
  a[10] := CodepointToUNICHAR(0FFFFFFFFH);  (* an invalid codepoint, should return REPLACEMENT CHAR *)
  a[11] := CodepointToUNICHAR(21H);  (* an invalid codepoint, should return REPLACEMENT CHAR *)
  a[12] := CodepointToUNICHAR(0E18H);  (* a valid non-ASCII char which is a BMP codepoint *)

  FOR i := 0 TO 12 DO
    WriteCard(i, 2);
    WriteString(": ");
    TestUnichar(a[i]);
    WriteLn;
  END;

  WriteString("Passes: ");
  WriteCard(passes, 2);
  WriteLn;
  WriteString("Fails: ");
  WriteCard(fails, 2);
  WriteLn;
END TestUTF8Console.