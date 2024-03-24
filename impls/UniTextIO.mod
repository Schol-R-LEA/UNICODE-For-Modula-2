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

IMPORT IOChan;
IMPORT SYSTEM;
FROM RawIO IMPORT Read, Write;
FROM UTF8 IMPORT UTF8Buffer, BufferByteCount, BufferSize;

VAR
   arr1: ARRAY [0..0] OF SYSTEM.LOC;
   arr2: ARRAY [0..1] OF SYSTEM.LOC;
   arr3: ARRAY [0..2] OF SYSTEM.LOC;
   arr4: ARRAY [0..3] OF SYSTEM.LOC;

PROCEDURE ReadUtf8Buffer(cid: IOChan.ChanId; VAR utf8: UTF8Buffer);
BEGIN
   Read(cid, arr1);

   utf8[0] := SYSTEM.CAST(CARDINAL, arr1[0]);

   CASE BufferSize(utf8) OF
      1:
         (* do nothing *) |
      2:
         Read(cid, arr1);
         utf8[1] := SYSTEM.CAST(CARDINAL, arr1[0]);
         utf8[2] := 0;
         utf8[3] := 0   |
      3:
         Read(cid, arr2);
         utf8[1] := SYSTEM.CAST(CARDINAL, arr2[0]);
         utf8[2] := SYSTEM.CAST(CARDINAL, arr2[1]);
         utf8[3] := 0;  |
      4:
         Read(cid, arr3);
         utf8[1] := SYSTEM.CAST(CARDINAL, arr3[0]);
         utf8[2] := SYSTEM.CAST(CARDINAL, arr3[1]);
         utf8[3] := SYSTEM.CAST(CARDINAL, arr3[2])
   END;

END ReadUtf8Buffer;


PROCEDURE WriteUtf8Buffer(cid: IOChan.ChanId; utf8: UTF8Buffer);
BEGIN
   CASE BufferSize(utf8) OF
      1:
         arr1[0] := SYSTEM.CAST(SYSTEM.LOC, utf8[0]);
         Write(cid, arr1)  |
      2:
         arr2[0] := SYSTEM.CAST(SYSTEM.LOC, utf8[0]);
         arr2[1] := SYSTEM.CAST(SYSTEM.LOC, utf8[1]);
         Write(cid, arr2)  |
      3:
         arr3[0] := SYSTEM.CAST(SYSTEM.LOC, utf8[0]);
         arr3[1] := SYSTEM.CAST(SYSTEM.LOC, utf8[1]);
         arr3[2] := SYSTEM.CAST(SYSTEM.LOC, utf8[2]);
         Write(cid, arr3)  |
      4:
         arr4[0] := SYSTEM.CAST(SYSTEM.LOC, utf8[0]);
         arr4[1] := SYSTEM.CAST(SYSTEM.LOC, utf8[1]);
         arr4[2] := SYSTEM.CAST(SYSTEM.LOC, utf8[2]);
         arr4[3] := SYSTEM.CAST(SYSTEM.LOC, utf8[3]);
         Write(cid, arr4)
   END;
END WriteUtf8Buffer;

END UniTextIO.