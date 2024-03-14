CC_PATH=$(HOME)/opt/bin
COMPILER=$(CC_PATH)/gm2
FLAGS=-g -fiso -freport-bug
INC=defs
SRC=impls
BIN=bin
TESTS=tests

testucs4repr: unicode utf8 uintextio $(TESTS)/TestUCS4Repr.mod
	$(COMPILER) $(FLAGS) -I$(INC)/ $(TESTS)/TestUCS4Repr.mod \
	$(BIN)/Unicode.o $(BIN)/UTF8.o $(BIN)/UniTextIO.o \
	-o $(BIN)/TestUCS4Repr


utf8: unicode $(SRC)/UTF8.mod $(INC)/UTF8.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/UTF8.mod


sunitextio: unicode $(SRC)/SUniTextIO.mod $(INC)/SUniTextIO.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/SUniTextIO.mod


unitextio: unicode $(SRC)/UniTextIO.mod $(INC)/UniTextIO.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/UniTextIO.mod


unicode: $(SRC)/Unicode.mod $(INC)/Unicode.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/Unicode.mod