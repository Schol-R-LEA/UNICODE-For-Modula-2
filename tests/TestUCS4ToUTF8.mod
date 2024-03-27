(* Copyright (C) 2024 Alice Osako,
   based on code Copyright (C) 2010 The Free Software Foundation, Inc. *)
(*
UNICODE for Modula-2 is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 3, or (at your option)
any later version.

UNICODE for Modula-2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU Lesser General Public License along
with this package; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. *)


MODULE TestUCS4ToUTF8;

FROM Unicode IMPORT UNICHAR, UCS4_codeunit, IsUnicode, MaxUnicode,
                    CodepointToUNICHAR, CodepointToString;

FROM STextIO IMPORT WriteChar, WriteString, WriteLn;
FROM SWholeIO IMPORT WriteCard;
FROM UTF8 IMPORT UnicharStatus, BufferSize, BufferByteCount,
                 UTF8Buffer, Octet,
                 UnicharToUtf8, Utf8ToUnichar, BitPosition,
                 GetEdgeBit, GetSubChar;


VAR
  passes, fails, index: CARDINAL;
  bytes, bytesComputed: BufferByteCount;
  ucs4, recurse: UNICHAR;
  utf8: UTF8Buffer;
  buffer: ARRAY [0..31] OF CHAR;
  octet: Octet;
  inStatus, outStatus: UnicharStatus;


PROCEDURE WriteUtf8Bytes(utf8: UTF8Buffer);
BEGIN
  WriteCard(utf8[3], 3); WriteChar(' ');
  WriteCard(utf8[2], 3); WriteChar(' ');
  WriteCard(utf8[1], 3); WriteChar(' ');
  WriteCard(utf8[0], 3);
END WriteUtf8Bytes;


BEGIN
  passes := 0;
  fails := 0;

  FOR index := 0 TO MaxUnicode DO
    ucs4 := CodepointToUNICHAR(index);
    inStatus := UnicharToUtf8(ucs4, utf8);
    CASE inStatus OF
      Valid:
        INC(passes); |
      Invalid:
        WriteCard(index, 7);
        WriteString(": Codepoint ");
        CodepointToString(ucs4, buffer);
        WriteString(buffer);
        WriteString(" is not a valid UCS4 character.");
        WriteLn;
        INC(fails);
    END;

    bytesComputed := BufferSize(utf8);
    IF bytesComputed > 4 THEN
      WriteCard(index, 7);
      WriteString(": Codepoint ");
      CodepointToString(ucs4, buffer);
      WriteString(buffer);
      WriteString(" transforms to more than 4 bytes.");
      WriteLn;
      INC(fails);
    END;
    outStatus := Utf8ToUnichar(utf8, recurse);
    CASE inStatus OF
      Valid:
        INC(passes); |
      OutOfOrder:
        WriteCard(index, 7);
        WriteString(": Codepoint ");
        CodepointToString(ucs4, buffer);
        WriteString(buffer);
        WriteString(" is not a valid UCS4 character.");
        WriteLn;
        INC(fails) |
      Invalid:
        WriteCard(index, 7);
        WriteString(" is not a valid UTF-8 character.");
        WriteLn;
        INC(fails)
    END;

    CASE index OF
      0 .. 07FH:
        bytes := 1 |
      080H .. 07FFH:
        bytes := 2 |
      0800H .. 00FFFFH:
        bytes := 3 |
      010000H .. MaxUnicode:
        bytes := 4
    END;

    IF bytes = bytesComputed THEN
      INC(passes)
    ELSE
      WriteCard(index, 7);
      WriteString(": Codepoint ");
      CodepointToString(ucs4, buffer);
      WriteString(buffer);
      WriteString(" converts to ");
      WriteCard(bytesComputed, 1);
      WriteString(" bytes, should be ");
      WriteCard(bytes, 1);
      WriteString(". Edge bit = ");
      WriteCard(GetEdgeBit(utf8[0]), 1);
      WriteString(". Elements are: ");
      WriteUtf8Bytes(utf8);
      WriteLn;
      INC(fails)
    END;

    IF ucs4 = recurse THEN
      INC(passes);
    ELSE
      WriteCard(index, 7);
      WriteString(": Codepoint ");
      CodepointToString(ucs4, buffer);
      WriteString(buffer);
      WriteString(" # ");
      CodepointToString(recurse, buffer);
      WriteString(buffer);
      WriteString(". Elements are: ");
      WriteUtf8Bytes(utf8);
      WriteLn;
      INC(fails);
    END;
  END;


  WriteString("Passes: ");
  WriteCard(passes, 2);
  WriteLn;
  WriteString("Fails: ");
  WriteCard(fails, 2);
  WriteLn;
END TestUCS4ToUTF8.