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

(* This package is derived from an earlier incomplete package by Chris Lilley
   working for the Free Software Foundation in 2010. *)

IMPLEMENTATION MODULE Unicode ;

(*
    Title      : Unicode
    Authors    : Chris Lilley; Alice Osako
    System     : UNIX (GNU Modula-2)
    Date       : 2010-10-03 19:01:11
    Last edit  : $Date: 2024-03-07 15:37:21 $
    Revision   : $Version$
    Description: provides Unicode base types.
*)

(* This module provides a type, Uchar, which is intended as a Unicode Level 1
   compliant replacement for char, for single characters.

   This implementation diverges from the prior Lilley design in that it uses a
   32-bit base representation rather than a 16-bit one.

   The implementation focus of this module is on always returning
   valid Unicode characters. Therefore, the Unicode 'REPLACEMENT CHARACTER'
   is used whenever the conversion would give a result outside the Unicode
   range, or would give nonsense (e.g., combining a low and high surrogate), or
   converting a supposed ASCII character which is outside the ASCII printable
   character range.

   Extension beyond UNICODE Level 1 (e.g., support for bidirectional text,
   combining characters, etc.) is not planned at this time, but may be
   pursued at some future point.
*)

CONST Replacement = FFFDH;      (* Unicode REPLACEMENT CHARACTER *)

VAR
      High : [0D800H .. 0DBFFH];  (* high surrogate range *)
      Low  : [0DC00H .. 0DFFFH];  (* low surrogate range *)

TYPE
    UChar = [0 .. MaxUnicode];     (* a single Unicode character *)
    UTF32_codeunit = CARDINAL;     (* a single UTF-32 code unit  *)

    TFEncodingType = (UTF7, UTF8, UTF16, UTF32);

(*
   Uchar is a CARDINAL subrange and covers all Unicode planes.

   UTF32_codeunit is 32 bits.
*)

PROCEDURE CharToUChar (c: CHAR): UChar;
(* 
   CharToUchar -   converts a single char, c, into a Unicode character.
                   For GM2, a Modula-2 char is a gcc char which is 8 bits.
                   The character represented by a CHAR with an ordinal
                   value greater than 127 depends on the locale.
                   The size and encoding of a Modula-2 char is undefined 
                   in both PIM and ISO Modula-2.
*)
BEGIN
  RETURN ORD(c);
  (* you get whatever char is on the system. good luck. 
     All codepoints in the range 0 to 255 are valid Unicode characters, 
     so the result is always valid, just underdefined and system dependent. 
     Moral: do not use char for real text processing.
   *)
END CharToUChar;

PROCEDURE ASCIIToUChar (a: CHAR): UChar;
(* 
   ASCIIToUChar -  converts a single ASCII printable char, a, into 
                   a Unicode character in the Basic Latin block.
                   For GM2, a Modula-2 char is a gcc char which is 8 bits;
                   printable ASCII values take up the lower half of the 
                   codespace in GM2.
                   If the ordinal value of a is outside the printable 
                   ASCII range, the Unicode character 
                   'REPLACEMENT CHARACTER' is returned.
                   The size and encoding of a Modula-2 char is undefined 
                   in both PIM and ISO Modula-2.
*)
VAR ASCIIRange : [32..127];

   cp: CARDINAL;  (* Unicode codepoint of the passed ASCII character *)

BEGIN
   cp := ORD(a);
   (* if the locale is ASCII, or an ASCII superset like Latin-1, 
      cp will be the code point of the expected character.
      if the locale is  a code-switching set, or EBCIDIC or something,
      then you get what you get, and should not be claiming it covers ASCII.
   *)
   IF (cp IN ASCIIRange) THEN
      RETURN cp;
   ELSE
      RETURN Replacement;
   END;
END ASCIIToUChar;



PROCEDURE CodepointToUChar (cp: CARDINAL): UChar;
(* 
   CodepointToUChar -   converts a numeric codepoint, cp, into a 
                   Unicode character. For example the cardinal 3608, which 
                   has the hexadecimal representation 0E18H, would return 
                   the Unicode character U+0E18, THAI CHARACTER THO THONG.
*)

BEGIN
   IF cp <= MaxUnicode THEN
      RETURN cp;
   ELSE
      RETURN Replacement;
   END;
END CodepointToUChar;

PROCEDURE IsBMP (cu: UTF32_codeunit): BOOLEAN;
(*
   IsBMP -         returns true if the UTF32_codeunit, cu, corresponds to
                   a Basic Multilingual Plane (BMP) Unicode character.
                   Otherwise (cu is a low or high surrogate) returns false.
*)
BEGIN
   IF (cu IN High) OR (cu IN Low) THEN
      RETURN FALSE;
   ELSE
      RETURN TRUE;
   END;
END IsBMP;

PROCEDURE BMPToUChar (b: UTF32_codeunit): UChar;
(*
   BMPToUChar -    converts a single UTF32_codepoint within the BMP, b,
                   into a Unicode character. If b is not in the BMP 
                   but is a low high surrogate, the Unicode character 
                   'REPLACEMENT CHARACTER' is returned.
*)
BEGIN
   IF (b IN High) OR (b IN Low) THEN
      RETURN Replacement;
   ELSE
      RETURN ORD(b);
   END;
END BMPToUChar;

PROCEDURE SurrogatesToUChar (low, high: UTF32_codeunit): UChar;
(*
   SurrogatesToUchar - converts a pair of surrogate characters, low and high,
                   into a Unicode character. If low is outside the range
                   for low surrogates and/or high is outside the range
                   for high surrogates, the Unicode character 
                   'REPLACEMENT CHARACTER' is returned.
*)
BEGIN
   IF (high IN High) AND (low IN Low) THEN
      RETURN (high - 0D800H) * 400H + (low - 0DC00H) + 10000H;  
   ELSE
      RETURN Replacement;
   END;
END SurrogatesToUChar;




END Unicode.