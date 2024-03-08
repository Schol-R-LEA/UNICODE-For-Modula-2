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


MODULE TestUCS4Repr;

FROM Unicode IMPORT UNICHAR, UCS4_codeunit, IsUnicode,
                    CharToUNICHAR,
                    IsPrintableASCII, ASCIIToUNICHAR,
                    CodepointToUNICHAR, CodepointToString,
                    IsBMP, BMPToUNICHAR, SurrogatesToUNICHAR;

FROM STextIO IMPORT WriteChar, WriteString, WriteLn;
FROM DynamicStrings IMPORT CopyOut;


VAR
   a: ARRAY [0..9] OF UNICHAR;
   i: CARDINAL;

   PROCEDURE TestIsASCII(uc: UNICHAR);
   BEGIN
      IF IsPrintableASCII(uc) THEN
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

BEGIN
   WriteChar("'");
   WriteChar(CHR(uc));
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
END TestUnichar;

BEGIN
   a[0] := CharToUNICHAR('a');         (* a CHAR which is a BMP codepoint *)
   a[1] := ASCIIToUNICHAR('a');        (* an ASCII char which is a BMP codepoint *)
   a[2] := CodepointToUNICHAR(ORD('a'));
   a[3] := CodepointToUNICHAR(0E18H);  (* a non-ASCII char which is a BMP codepoint *)
   a[4] := BMPToUNICHAR(0E18H);           (* a non-ASCII char which is a BMP codepoint *)
   a[5] := SurrogatesToUNICHAR(0DC01H, 0D801H);  (* a non-ASCII char which is not a BMP codepoint *)
   a[6] := CodepointToUNICHAR(0FFFFFFFFH);  (* an invalid codepoint, should return REPLACEMENT CHAR *)

   FOR i := 0 TO 9 DO
      TestUnichar(a[i]);
      WriteLn;
   END;

END TestUCS4Repr.