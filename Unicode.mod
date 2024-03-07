(* Copyright (C) 2010
                 Free Software Foundation, Inc. *)
(* This file is planned to be part of GNU Modula-2.

GNU Modula-2 is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GNU Modula-2 is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

You should have received a copy of the GNU General Public License along
with gm2; see the file COPYING.  If not, write to the Free Software
Foundation, 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. *)

IMPLEMENTATION MODULE Unicode ;

(*
    Title      : Unicode
    Author     : Chris Lilley
    System     : UNIX (GNU Modula-2)
    Date       : 
    Last edit  : $Date: 2010/10/03 19:01:11 $ 
    Revision   : $Version$ 
    Description: provides Unicode base types.
*)

(* This module provides a type, Uchar, which is intended as a Unicode-compliant 
   replacement for char, for single characters. Using 32 bits per character is
   wasteful for strings, so this module also provides support functions
   for UTF-16 strings, as used by many modern programming languages for 
   Unicode string support. The benefits of direct adressability are retained
   while using only 16 bits for all common (Basic Multilingual Plane)
   characters, and a pair of 16-bit surrogates to represent uncommon 
   characters in 32 bits.

   The implementation focus of this module is on always returning 
   valid Unicode characters. Therefore, the Unicode 'REPLACEMENT CHARACTER'
   is used whenever the conversion would give a result outside the Unicode 
   range, or would give nonsense (combining a low and high surrogate), or
   converting a supposed ASCII character which is outside the ASCII printable
   character range.
*)

CONST Replacement = FFFDH;      (* Unicode REPLACEMENT CHARACTER *)

VAR
      High : [D800H .. DBFFH];  (* high surrogate range *)
      Low  : [DC00H .. DFFFH];  (* low surrogate range *)

TYPE
    UChar = [0 .. MaxUnicode];     (* a single Unicode character *)
    UTF16_codeunit = SHORTCARD;     (* a single UTF-16 code unit  *)

(* 
   Uchar is a CARDINAL subrange and covers all Unicode planes.

   UTF16_codeunit is 16bits. This could be done with a SHORTCARD (probably 
   16 bits) or one of the ISO SYSTEM types, like CARDIBAL16. The latter 
   would definitely be 16 bits, but may not be supported on some architectures.
   Is Shortcard ever 8bits on any architecture?

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

PROCEDURE IsBMP (cu: UTF16_codeunit): BOOLEAN;
(*
   IsBMP -         returns true if the UTF16_codeunit, cu, corresponds to
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

PROCEDURE BMPToUChar (b: UTF16_codeunit): UChar;
(*
   BMPToUChar -    converts a single UTF16_codepoint within the BMP, b,
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

PROCEDURE SurrogatesToUChar (low, high: UTF16_codeunit): UChar;
(*
   SurrogatesToUchar - converts a pair of surrogate characters, low and high,
                   into a Unicode character. If low is outside the range 
                   for low surrogates and/or high is outside the range 
                   for high surrogates, the Unicode character 
                   'REPLACEMENT CHARACTER' is returned.
*)
BEGIN
   IF (high IN High) AND (low IN Low) THEN
      RETURN (high - D800H) * 400H + (low - DC00H) + 10000H;  
   ELSE
      RETURN Replacement;
   END;
END SurrogatesToUChar;  
  
(*
  Maybe add UTF8 utility functions to this module also
*)

END Unicode.