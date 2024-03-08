MODULE TestUCS4Repr;

FROM Unicode IMPORT UNICHAR, UCS4_codeunit,
                    CharToUNICHAR,
                    IsPrintableASCII, ASCIIToUNICHAR,
                    CodepointToUNICHAR,
                    IsBMP, BMPToUNICHAR, SurrogatesToUNICHAR;

FROM STextIO IMPORT WriteChar, WriteString, WriteLn;
FROM DynamicStrings IMPORT CopyOut;
FROM StringConvert IMPORT CardinalToString;


VAR
   a: ARRAY [0..9] OF UNICHAR;
   i: CARDINAL;

   PROCEDURE TestIsASCII(uc: UNICHAR);
   BEGIN
      IF IsPrintableASCII(uc) THEN
         WriteString(" is ");
      ELSE
         WriteString(" is not ");
      END;
      WriteString("a printable ASCII character;");
   END TestIsASCII;


PROCEDURE TestIsBMP(uc: UNICHAR);
BEGIN
   IF IsBMP(uc) THEN
      WriteString(" is ");
   ELSE
      WriteString(" is not ");
   END;
   WriteString("in the BMP.");
END TestIsBMP;


PROCEDURE TestUnichar(uc: UNICHAR);
VAR
   buffer: ARRAY [0..31] OF CHAR;

BEGIN
   WriteChar("'");
   WriteChar(CHR(uc));
   WriteString("' [U+");
   CopyOut(buffer, CardinalToString(uc, 4, "0", 16, FALSE));
   WriteString(buffer);
   WriteString("] ");
   TestIsASCII(uc);
   TestIsBMP(uc);
END TestUnichar;

BEGIN
   a[0] := CharToUNICHAR('a');         (* a CHAR which is a BMP codepoint *)
   a[1] := ASCIIToUNICHAR('a');        (* an ASCII char which is a BMP codepoint *)
   a[2] := CodepointToUNICHAR(ORD('a'));
   a[3] := CodepointToUNICHAR(0E18H);  (* a non-ASCII char which is a BMP codepoint *)
   a[4] := BMPToUNICHAR(0E18H);           (* a non-ASCII char which is a BMP codepoint *)
   a[5] := SurrogatesToUNICHAR(0DC01H, 0D801H);  (* a non-ASCII char which is not a BMP codepoint *)

   FOR i := 0 TO 9 DO
      TestUnichar(a[i]);
      WriteLn;
   END;

END TestUCS4Repr.