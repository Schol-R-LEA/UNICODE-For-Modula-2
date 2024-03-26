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


IMPLEMENTATION MODULE UTF8;

FROM Unicode IMPORT MaxUnicode, Replacement, CodepointToUNICHAR;
FROM CardBitOps IMPORT bit, SetBit, ClearBit,
                       shl, shr, bwAnd, bwNot, bwOr,
                       ClearLSBtoN, ClearMSBtoN;

CONST
  extMask = 0C0H;


VAR
  firstByteMasks: ARRAY [1 .. 3] OF Octet;


PROCEDURE GetEdgeBit(b: Octet): BitPosition;
VAR
  index: BitPosition;

BEGIN
  FOR index := 7 TO 3 BY -1 DO
    IF (index # 6) AND (NOT bit(b, index)) THEN
      RETURN index;
    END;
  END;
END GetEdgeBit;


PROCEDURE GetSubChar(b: Octet): Octet;
VAR
  temp: Octet;

BEGIN
  temp := b;
  ClearMSBtoN(temp, 5);
  RETURN temp;
END GetSubChar;


PROCEDURE BufferSize(utf8: UTF8Buffer): BufferByteCount;
(*
   BufferSize - get the effective size of the UTF-8 character in bytes.
*)
VAR
  edgeBit: BitPosition;

BEGIN
  (* Which is the last clear bit in the first byte? *)
  edgeBit := GetEdgeBit(utf8[0]);

  CASE edgeBit OF
    7:
      RETURN 1 |
    5:
      RETURN 2 |
    4:
      RETURN 3 |
    3:
      RETURN 4 |
  END;
END BufferSize;


PROCEDURE Utf8ToUnichar(utf8: UTF8Buffer; VAR ch: UNICHAR);
(*
  Utf8ToUnichar - Convert a buffer of UTF-8 characters
               to the internal UCS-4 format.

   Following RFC 3629 (https://www.rfc-editor.org/rfc/rfc3629#section-3),
   the mappings between UTF-8 and UCS-4 are as follows:

   Char. number range  |        UTF-8 octet sequence
      (hexadecimal)    |              (binary)
   --------------------+---------------------------------------------
   0000 0000-0000 007F | 0xxxxxxx
   0000 0080-0000 07FF | 110xxxxx 10xxxxxx
   0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
   0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx

   Any candidate character which does not match these cases should be
   replaced with the REPLACEMENT CHAR.
*)

VAR
  edgeBit: CARDINAL;
  subChar: UTF8Buffer;    (* holds the sub-components of the character *)
  index, component : CARDINAL;


BEGIN
  (* clear the output *)
  ch := 0;

  subChar[0] := 0;
  FOR index := 1 TO 3 DO
    subChar[index] := GetSubChar(utf8[index]);
  END;


  (* Which is the last clear bit in the first byte? *)
  edgeBit := GetEdgeBit(utf8[0]);
  ch := utf8[0];

  CASE edgeBit OF
    7:
      (* A single-byte ASCII char, just use as-is *) |
    5:
      (* use two bytes for the value *)
      ClearMSBtoN(ch, 6);
      ch := bwOr(ch, 080H);
      ch := bwOr(ch, shl(subChar[1], 8)) |
    4:
      (* use three bytes for the value *)
      ClearMSBtoN(ch, 5);
      ch := bwOr(ch, 080H);
      ch := bwOr(ch, shl(subChar[1], 8));
      ch := bwOr(ch, shl(subChar[2], 16)) |
    3:
      (* use four bytes for the value *)
      ClearMSBtoN(ch, 4);
      ch := bwOr(ch, shl(subChar[1], 4));
      ch := bwOr(ch, shl(subChar[2], 12));
      ch := bwOr(ch, shl(subChar[3], 20)) |
  ELSE
    (* should never happen, return the REPLACEMENT CHAR *)
    ch := Replacement;
  END;
END Utf8ToUnichar;


PROCEDURE UnicharToUtf8(ch: UNICHAR; VAR utf8: UTF8Buffer);
(*
   UnicharToUtf8 - Convert the internal UCS-4 characters to
                   a buffer of UTF-8 characters.
*)
VAR
  index : CARDINAL;
  component: CARDINAL;


BEGIN
  FOR index := 0 TO 3 DO
    utf8[index] := 0
  END;

  component := ch;  (* initialize the first byte *)
  ClearMSBtoN(component, 8);
  utf8[0] := component;

  CASE ch OF
    0 .. 07FH:
      (* no change *) |
    080H .. 07FFH:
      ClearMSBtoN(utf8[0], 6);
      component := shr(ch, 8);
      ClearMSBtoN(component, 8);
      utf8[0] := bwOr(utf8[0], firstByteMasks[1]);
      utf8[1] := bwOr(component, extMask) |
    0800H .. 00FFFFH:
      ClearMSBtoN(utf8[0], 5);
      component := shr(ch, 8);
      ClearMSBtoN(component, 8);
      utf8[0] := bwOr(utf8[0], firstByteMasks[2]);
      utf8[1] := bwOr(component, extMask);
      component := shr(ch, 16);
      ClearMSBtoN(component, 8);
      utf8[2] := bwOr(component, extMask) |
    010000H .. 010FFFFH:
      ClearMSBtoN(utf8[0], 3);
      component := shr(ch, 3);
      ClearMSBtoN(component, 8);
      utf8[0] := bwOr(utf8[0], firstByteMasks[3]);
      utf8[1] := bwOr(component, extMask);
      component := shr(ch, 13);
      ClearMSBtoN(component, 8);
      utf8[2] := bwOr(component, extMask);
      ClearMSBtoN(component, 12);
      utf8[2] := bwOr(component, extMask) |
 ELSE
   (* TODO *)
 END;
END UnicharToUtf8;

BEGIN
  firstByteMasks[1] := 0C0H;
  firstByteMasks[2] := 0E0H;
  firstByteMasks[3] := 0F0H;

END UTF8.