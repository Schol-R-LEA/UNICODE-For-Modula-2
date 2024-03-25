# This is a list of all non-source files that are part of the distribution.
AUX      = Makefile README.md LICENSE .gitignore


CC_PATH  = $(HOME)/opt/bin
COMPILER = $(CC_PATH)/gm2
FLAGS    = -g -fiso
INC      = defs
SRC      = impls
OBJ      = objs
BIN      = bin
TESTS    = tests
BITWISE  = CardBitOps

testutf8console: unicode utf8 sunitextio $(TESTS)/TestUTF8Console.mod
	$(COMPILER) $(FLAGS) -I$(INC)/ $(TESTS)/TestUTF8Console.mod \
	$(OBJ)/Unicode.o $(OBJ)/UTF8.o $(OBJ)/UniTextIO.o $(OBJ)/SUniTextIO.o \
	$(BITWISE)/$(OBJ)/gnu/x86/CardBitOps.o \
	-o $(BIN)/TestUTF8Console

testutf8fileio: unicode utf8 unitextio $(TESTS)/TestUTF8FileIO.mod
	$(COMPILER) $(FLAGS) -I$(INC)/ $(TESTS)/TestUTF8FileIO.mod \
	$(OBJ)/Unicode.o $(OBJ)/UTF8.o $(OBJ)/UniTextIO.o $(OBJ)/SUniTextIO.o \
	$(BITWISE)/$(OBJ)/gnu/x86/CardBitOps.o \
	-o $(BIN)/TestUTF8FileIO


testucs4validity: unicode $(TESTS)/TestUTF8FileIO.mod
	$(COMPILER) $(FLAGS) -I$(INC)/ $(TESTS)/TestUCS4Validity.mod \
	$(OBJ)/Unicode.o $(OBJ)/UTF8.o $(OBJ)/UniTextIO.o $(OBJ)/SUniTextIO.o \
	$(BITWISE)/$(OBJ)/gnu/x86/CardBitOps.o \
	-o $(BIN)/TestUCS4Validity


sunitextio: unicode utf8 unitextio $(SRC)/SUniTextIO.mod $(INC)/SUniTextIO.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/SUniTextIO.mod \
	-o $(OBJ)/SUniTextIO.o

unitextio: unicode utf8 $(SRC)/UniTextIO.mod $(INC)/UniTextIO.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/UniTextIO.mod \
	-o $(OBJ)/UniTextIO.o


utf8: unicode $(SRC)/UTF8.mod $(INC)/UTF8.def $(BITWISE)/$(INC)/CardBitOps.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -I$(BITWISE)/$(INC)/ \
	-c $(SRC)/UTF8.mod \
	-o $(OBJ)/UTF8.o


unicode: $(SRC)/Unicode.mod $(INC)/Unicode.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/Unicode.mod \
	-o $(OBJ)/Unicode.o