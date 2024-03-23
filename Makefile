# This is a list of all non-source files that are part of the distribution.
AUX      := Makefile README.md LICENSE .gitignore


CC_PATH  := $(HOME)/opt/bin
COMPILER := $(CC_PATH)/gm2
FLAGS    := -g
INC      := defs
SRC      := impls
OBJ      := objs
BIN      := bin
TESTS    := tests
BITWISE  := CardBitOps

testucs4repr: unicode utf8 sunitextio $(TESTS)/TestUCS4Repr.mod
	$(COMPILER) $(FLAGS) -I$(INC)/ $(TESTS)/TestUCS4Repr.mod \
	$(OBJ)/Unicode.o $(OBJ)/UTF8.o $(OBJ)/UniTextIO.o $(OBJ)/SUniTextIO.o \
	$(BITWISE)/$(OBJ)/gnu/x86/CardBitOps.o \
	-o $(BIN)/TestUCS4Repr


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