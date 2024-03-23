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
FROM TextIO IMPORT WriteChar;
FROM WholeIO IMPORT WriteCard, ReadCard;
FROM Unicode IMPORT CodepointToUNICHAR;

TYPE
   Switcher = (Utf8, Card, Char);

   Transfer = RECORD
      CASE tag: Switcher OF
         Utf8:
            utf8: UTF8Buffer |
         Card:
            card: CARDINAL; |
         Char:
            ch: CHAR
     END
   END;


PROCEDURE ReadUtf8Buffer(cid: IOChan.ChanId; VAR utf8: UTF8Buffer);
VAR
   transfer: Transfer;

BEGIN
   transfer.tag := Card;
   ReadCard(cid, transfer.card);
   transfer.tag := Utf8;
   utf8 := transfer.utf8;
END ReadUtf8Buffer;


PROCEDURE WriteUtf8Buffer(cid: IOChan.ChanId; utf8: UTF8Buffer);
VAR
   transfer: Transfer;

BEGIN
   transfer.tag := Utf8;
   transfer.utf8 := utf8;
   transfer.tag := Char;

   WriteChar(cid, transfer.ch);
END WriteUtf8Buffer;

END UniTextIO.