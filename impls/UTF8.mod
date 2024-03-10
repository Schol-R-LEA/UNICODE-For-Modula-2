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

FROM Unicode IMPORT Replacement;

TYPE
   Octet = BITSET;


CONST
   extMask = 0C0H;


PROCEDURE GetEdgeBit(b: BYTE): SHORTCARD;
VAR
   bit: SHORTCARD;

BEGIN
   FOR bit := 7 TO 0 BY -1 DO
      IF bit IN b THEN
          RETURN bit;
      END;
   END;
END GetEdgeBit;


PROCEDURE GetExtChar(b: BYTE): BYTE;
BEGIN
   RETURN b - {7, 6};
END GetExtChar;


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
   edgeBit: SHORTCARD;

BEGIN
   (* clear the output *)
   ch := 0;

   (* Which is the last clear bit in the first byte? *)
   edgeBit := GetEdgeBit(utf8[0]);

   CASE edgeBit OF
      7:
         (* A single-byte ASCII char, just use as-is *)
         ch := utf8[0] |
      5:
         (* use two bytes for the value *)
         ch := ByteShl(BitByteOps.GetBits(utf8[0], 0, 4), 6);
         ch := WordOr(ch, utf8[1], 4) |
      4:
         (* use three bytes for the value *)
         ch := ByteShl(BitByteOps.GetBits(utf8[0], 0, 3), 12);
         ch := WordOr(ch, ByteShl(GetExtChar(utf8[1], 6)));
         ch := WordOr(ch, utf8[2]) |
      3:
         (* use four bytes for the value *)
         ch := ByteShl(BitByteOps.GetBits(utf8[0], 0, 3), 18);
         ch := WordOr(ch, ByteShl(GetExtChar(utf8[1], 12)));
         ch := WordOr(ch, ByteShl(GetExtChar(utf8[2], 6)));
         ch := WordOr(ch, utf8[3])
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

CONST
   MaxCardinal = 0FFFFFFFFH;

BEGIN
   CASE ch OF
      0 .. 07FH:
         utf8[0] := ch; |
      080FH .. 07FFH:
         utf8[0] := ch - {MaxCardinal, 6};
         utf8[1] := ch - {0, 6} |
      0800H .. 00FFFFH:
         utf8[0] := BitByteOps.ByteOr(preambleMask[2], GetBits(ch, 0, 5));
         utf8[1] := BitByteOps.ByteOr(extMask, GetBits(ch, 8, 13));
         utf8[2] := BitByteOps.ByteOr(extMask, GetBits(ch, 14, 21)); |
      010000H .. 010FFFFH:
         utf8[0] := BitByteOps.ByteOr(preambleMask[3], GetBits(ch, 0, 5));
         utf8[1] := BitByteOps.ByteOr(extMask, GetBits(ch, 8, 13));
         utf8[2] := BitByteOps.ByteOr(extMask, GetBits(ch, 12, 21));
         utf8[3] := BitByteOps.ByteOr(extMask, GetBits(ch, 22, 30))
   ELSE
      (* TODO *)
   END;
END UnicharToUtf8;


END UTF8.