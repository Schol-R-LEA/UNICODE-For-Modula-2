(* Copyright (C) 2024 Alice Osako,
   based on code Copyright (C) 2010 The Free Software Foundation, Inc. *)
(*
UNICODE for Modula-2 is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public License as published
by the Free Software Foundation; either version 2.1, or (at your option)
any later version.

UNICODE for Modula-2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU Lesser General Public License along
with this package; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. *)


IMPLEMENTATION MODULE UTF8;

FROM Unicode IMPORT MaxUnicode, Replacement, CodepointToUNICHAR;
FROM CardBitOps IMPORT bit, SetBit, ClearBit,
                       shl, shr, bwAnd, bwNot, bwOr,
                       ClearLSBtoN, ClearMSBtoN;

CONST
  extMask = 080H;
  subCharOffset = 6;

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
  ClearMSBtoN(temp, 6);
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


PROCEDURE Utf8ToUnichar(utf8: UTF8Buffer; VAR ch: UNICHAR): UnicharStatus;
(*
  Utf8ToUnichar - Convert a buffer of UTF-8 characters
               to the internal UCS-4 format.

   Following RFC 3629 (https://www.rfc-editor.org/rfc/rfc3629#section-3),
   the mappings between UTF-8 and UCS-4 are as follows:

   Char. number range  |        UTF-8 octet sequence
      (hexadecimal)    |              (binary)
   --------------------+-----------------------------------------------------
   0000 0000-0000 007F | 0xxxxxxx
   0000 0080-0000 07FF | 110xxxxx 10xxxxxx
   0000 0800-0000 FFFF | 1110xxxx 10xxxxxx 10xxxxxx
   0001 0000-0010 FFFF | 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
   0020 0000-03FF FFFF | 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
   0400 0000-7FFF FFFF | 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx

   Any candidate character which does not match these cases should be
   replaced with the REPLACEMENT CHAR.
*)

VAR
  edgeBit: BitPosition;
  subChar: UTF8Buffer;    (* holds the sub-components of the character *)
  index, component : CARDINAL;


BEGIN
  (* clear the output *)
  ch := 0;

  (* get the character part of each of the higher bytes *)
  subChar[0] := 0;
  FOR index := 1 TO 3 DO
    subChar[index] := GetSubChar(utf8[index]);
  END;


  (* Which is the last clear bit in the first byte? *)
  edgeBit := GetEdgeBit(utf8[0]);

  CASE edgeBit OF
    7:
      (* A single-byte ASCII char, just use as-is *)
      ch := utf8[0] |

    6:
      (* A byte value which is out of order,
         set ch to REPLACEMENT CHAR and return an error *)
        ch := Replacement;
        RETURN OutOfOrder |

    5:
      (* use two bytes for the value *)
      (* start by getting the character part of the first byte
         by getting the 1-byte inverse of the byte mask and
         masking it off the character part, which is then
         shifted it by 6.
         *)
      component := bwNot(firstByteMasks[1]);
      ClearMSBtoN(component, 8);
      ch := shl(bwAnd(utf8[0], component), subCharOffset);

      (* mask in the character part of the remaining bytes *)
      ch := bwOr(ch, subChar[1]) |

    4:
      (* use three bytes for the value *)
      (* start by getting the character part of the first byte
         by getting the 1-byte inverse of the byte mask and
         masking it off the character part, which is then
         shifted it by an offset.
         *)
      component := bwNot(firstByteMasks[2]);
      ClearMSBtoN(component, 8);
      ch := shl(bwAnd(utf8[0], component), subCharOffset * 2);

      (* mask in the character part of the remaining bytes *)
      ch := bwOr(ch, shl(subChar[1], subCharOffset));
      ch := bwOr(ch, subChar[2]) |
    3:
      (* use four bytes for the value *)
      (* start by getting the character part of the first byte
      by getting the 1-byte inverse of the byte mask and
      masking it off the character part, which is then
      shifted it by an offset.
      *)
      component := bwNot(firstByteMasks[3]);
      ClearMSBtoN(component, 8);
      ch := shl(bwAnd(utf8[0], component), subCharOffset * 3);

      (* mask in the character part of the remaining bytes *)
      ch := bwOr(ch, shl(subChar[1], subCharOffset * 2));
      ch := bwOr(ch, shl(subChar[2], subCharOffset));
      ch := bwOr(ch, subChar[3])
 |
  ELSE
    (* byte stream was corrupted, return the REPLACEMENT CHAR *)
    ch := Replacement;
    RETURN Invalid;
  END;
  RETURN Valid;
END Utf8ToUnichar;


PROCEDURE UnicharToUtf8(ch: UNICHAR; VAR utf8: UTF8Buffer): UnicharStatus;
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


  CASE ch OF
    0 .. 07FH:
      (* initialize the first character *)
      utf8[0] := ch |

    080H .. 07FFH:
      utf8[0] := bwOr(bwAnd(shr(ch, subCharOffset), 03FH), firstByteMasks[1]);
      utf8[1] := bwOr(bwAnd(ch, 03FH), extMask) |

    0800H .. 00FFFFH:
      utf8[0] := bwOr(bwAnd(shr(ch, subCharOffset * 2), 03FH), firstByteMasks[2]);
      utf8[1] := bwOr(bwAnd(shr(ch, subCharOffset), 03FH), extMask);
      utf8[2] := bwOr(bwAnd(ch, 03FH), extMask) |

    010000H .. 010FFFFH:
      utf8[0] := bwOr(bwAnd(shr(ch, subCharOffset*3), 03FH), firstByteMasks[3]);
      utf8[1] := bwOr(bwAnd(shr(ch, subCharOffset * 2), 03FH), extMask);
      utf8[2] := bwOr(bwAnd(shr(ch, subCharOffset), 03FH), extMask);
      utf8[3] := bwOr(bwAnd(ch, 03FH), extMask) |
 ELSE
   RETURN Invalid;
 END;
 RETURN Valid;
END UnicharToUtf8;

BEGIN
  firstByteMasks[1] := 0C0H;
  firstByteMasks[2] := 0E0H;
  firstByteMasks[3] := 0F0H;

END UTF8.