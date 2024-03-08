CC_PATH=$(HOME)/opt/bin
COMPILER=$(CC_PATH)/gm2
FLAGS=-g -fiso
INC=defs
SRC=impls
BIN=bin
TESTS=tests

testucs4repr: unicode $(TESTS)/TestUCS4Repr.mod
	$(COMPILER) $(FLAGS) -I$(INC)/ $(TESTS)/TestUCS4Repr.mod $(BIN)/Unicode.o -o $(BIN)/TestUCS4Repr

sunitextio: unicode $(SRC)/SUniTextIO.mod $(INC)/SUniTextIO.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/SUniTextIO.mod $(BIN)/Unicode.o -o $(BIN)/SUniTextIO.o

unicode: $(SRC)/Unicode.mod $(INC)/Unicode.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/Unicode.mod -o $(BIN)/Unicode.o
