(* Copyright (C) 2024 Alice Osako,
   based on code Copyright (C) 2010 The Free Software Foundation, Inc. *)
(*
UNICODE for Modula-2 is free software; you can redistribute it and/or
modify it under the terms of the GNU Limited General Public License as published
by the Free Software Foundation; either version 2.1, or (at your option)
any later version.

UNICODE for Modula-2 is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU Limited General Public License along
with this package; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. *)

IMPLEMENTATION MODULE UniTextIO ;

IMPORT FIO, Storage, SYSTEM;
FROM UTF8 IMPORT Octet, UTF8Buffer, BufferByteCount, BufferSize;


PROCEDURE ReadUtf8Buffer(file: FIO.File; VAR utf8: UTF8Buffer);
VAR
  octet: CHAR;
  bytesRead: CARDINAL;

BEGIN
  utf8[0] := ORD(FIO.ReadChar(file));

  CASE BufferSize(utf8) OF
    1:
      (* do nothing *) |
    2:
      utf8[1] := ORD(FIO.ReadChar(file));
      utf8[2] := 0;
      utf8[3] := 0  |
    3:
      utf8[1] := ORD(FIO.ReadChar(file));
      utf8[2] := ORD(FIO.ReadChar(file));
      utf8[3] := 0  |
    4:
    utf8[1] := ORD(FIO.ReadChar(file));
    utf8[2] := ORD(FIO.ReadChar(file));
    utf8[3] := ORD(FIO.ReadChar(file))
   END;
END ReadUtf8Buffer;


PROCEDURE WriteUtf8Buffer(file: FIO.File; utf8: UTF8Buffer);
VAR
  octet: CHAR;
  size: BufferByteCount;
  i: CARDINAL;

BEGIN
  size := BufferSize(utf8);

  FOR i := 0 TO size-1 DO
    FIO.WriteChar(file, CHR(utf8[i]));
  END;
END WriteUtf8Buffer;

END UniTextIO.