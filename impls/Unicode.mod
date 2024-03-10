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
    Last edit  : $Date: 2024-03-07 19:20:50 $
    Revision   : $Version$
    Description: provides Unicode base types.
*)

(* This module provides a type, UNICHAR, which is intended as a Unicode Level 1
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

FROM DynamicStrings IMPORT String, InitString, CopyOut, Add, Fin;
FROM StringConvert IMPORT CardinalToString;

CONST
   HighLower = 0D800H;
   HighUpper = 0DBFFH;  (* high surrogate range *)
   LowLower = 0DC00H;
   LowUpper = 0DFFFH;  (* low surrogate range *)



(*
   UNICHAR is a CARDINAL subrange and covers all Unicode planes.

   UCS4_codeunit is 32 bits.
*)

PROCEDURE IsUnicode(uc: UNICHAR): BOOLEAN;

BEGIN
   RETURN uc <= MaxUnicode;
END IsUnicode;

PROCEDURE CharToUNICHAR (c: CHAR): UNICHAR;
(*
   CharToUNICHAR -   converts a single char, c, into a Unicode character.
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
END CharToUNICHAR;

PROCEDURE ASCIIToUNICHAR (a: CHAR): UNICHAR;
(*
   ASCIIToUNICHAR -  converts a single ASCII printable char, a, into
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
VAR
   cp: UCS4_codeunit;  (* Unicode codepoint of the passed ASCII character *)

BEGIN
   cp := ORD(a);
   (* if the locale is ASCII, or an ASCII superset like Latin-1,
      cp will be the code point of the expected character.
      if the locale is a code-switching set, or EBCDIC or something,
      then you get what you get, and should not be claiming it covers ASCII.
   *)
   IF IsPrintableASCII(cp) THEN
      RETURN cp;
   ELSE
      RETURN Replacement;
   END;
END ASCIIToUNICHAR;



PROCEDURE CodepointToUNICHAR (cp: CARDINAL): UNICHAR;
(*
   CodepointToUNICHAR -   converts a numeric codepoint, cp, into a
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
END CodepointToUNICHAR;

PROCEDURE IsPrintableASCII (cu: UCS4_codeunit): BOOLEAN;
(*
   IsPrintableASCII - returns true if the UCS4_codeunit, cu, corresponds to
                   an ASCII character. Otherwise returns false.
*)

BEGIN
   IF (cu >= 32) AND (cu <= 127) THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END;
END IsPrintableASCII;


PROCEDURE IsBMP (cu: UCS4_codeunit): BOOLEAN;
(*
   IsBMP -         returns true if the UCS4_codeunit, cu, corresponds to
                   a Basic Multilingual Plane (BMP) Unicode character.
                   Otherwise (cu is a low or high surrogate) returns false.
*)
BEGIN
   RETURN cu <= 0FFFFH;
END IsBMP;


PROCEDURE IsSurrogate (cu: UCS4_codeunit): BOOLEAN;
(*
   IsSurrogate -   returns true if the UCS4_codeunit, cu, corresponds to
                   a Surrogate Unicode character.
                   Otherwise returns false.
*)
BEGIN
   RETURN ((cu >= HighLower) AND (cu <= HighUpper))
          OR ((cu >= LowLower) AND (cu <= LowUpper));
END IsSurrogate;


PROCEDURE BMPToUNICHAR (b: UCS4_codeunit): UNICHAR;
(*
   BMPToUNICHAR -    converts a single UCS4_codepoint within the BMP, b,
                   into a Unicode character. If b is not in the BMP 
                   but is a low high surrogate, the Unicode character 
                   'REPLACEMENT CHARACTER' is returned.
*)
BEGIN
   IF IsBMP(b) THEN
      RETURN ORD(b);
   ELSE
      RETURN Replacement;
   END;
END BMPToUNICHAR;

PROCEDURE SurrogatesToUNICHAR (low, high: UCS4_codeunit): UNICHAR;
(*
   SurrogatesToUNICHAR - converts a pair of surrogate characters, low and high,
                   into a Unicode character. If low is outside the range
                   for low surrogates and/or high is outside the range
                   for high surrogates, the Unicode character 
                   'REPLACEMENT CHARACTER' is returned.
*)
BEGIN
   IF ((high >= HighLower) AND (high <= HighUpper))
      AND ((low >= LowLower) AND (low <= LowUpper)) THEN
      RETURN (high - 0D800H) * 400H + (low - 0DC00H) + 10000H;
   ELSE
      RETURN Replacement;
   END;
END SurrogatesToUNICHAR;


PROCEDURE CodepointToString(cp: UCS4_codeunit; VAR str: ARRAY OF CHAR);
VAR
   open, value, close, result: String;
BEGIN
   open := InitString("[U+");
   value := CardinalToString(cp, 4, "0", 16, FALSE);
   close := InitString("]");
   result := Add(open, Add(value, close));
   CopyOut(str, result);
   Fin(result);
   Fin(close);
   Fin(value);
   Fin(open);
END CodepointToString;


END Unicode.