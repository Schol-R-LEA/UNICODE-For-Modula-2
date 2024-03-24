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

IMPLEMENTATION MODULE UniTextIO ;

IMPORT FIO, Storage, SYSTEM;
FROM UTF8 IMPORT Octet, UTF8Buffer, BufferByteCount, BufferSize;


PROCEDURE ReadUtf8Buffer(file: FIO.File; VAR utf8: UTF8Buffer);
VAR
   octet: POINTER TO Octet;
   bytesRead: CARDINAL;

BEGIN
   Storage.ALLOCATE(octet, SYSTEM.TSIZE(Octet));
   bytesRead := FIO.ReadNBytes(file, 1, octet);

   utf8[0] := octet;

   CASE BufferSize(utf8) OF
      1:
         (* do nothing *) |
      2:
         bytesRead := FIO.ReadNBytes(file, 1, octet);
         utf8[1] := octet;
         utf8[2] := 0;
         utf8[3] := 0   |
      3:
         bytesRead := FIO.ReadNBytes(file, 1, octet);
         utf8[1] := octet;
         bytesRead := FIO.ReadNBytes(file, 1, octet);
         utf8[2] := octet;
         utf8[3] := 0;  |
      4:
         bytesRead := FIO.ReadNBytes(file, 1, octet);
         utf8[1] := octet;
         bytesRead := FIO.ReadNBytes(file, 1, octet);
         utf8[2] := octet;
         bytesRead := FIO.ReadNBytes(file, 1, octet);
         utf8[3] := octet;
   END;
   Storage.DEALLOCATE(octet, SYSTEM.TSIZE(Octet));
END ReadUtf8Buffer;


PROCEDURE WriteUtf8Buffer(file: FIO.File; utf8: UTF8Buffer);
VAR
   buffer: POINTER TO UTF8Buffer;
   bytesWritten: CARDINAL;

BEGIN
   Storage.ALLOCATE(buffer, SYSTEM.TSIZE(UTF8Buffer));

   buffer^ := utf8;
   bytesWritten := FIO.WriteNBytes(file, BufferSize(utf8), buffer);
   Storage.DEALLOCATE(buffer, SYSTEM.TSIZE(UTF8Buffer));
END WriteUtf8Buffer;

END UniTextIO.