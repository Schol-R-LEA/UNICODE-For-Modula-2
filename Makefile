COMPILER=$(HOME)/opt/bin/gm2
FLAGS=-g -fiso
INC=defs
SRC=impls
BIN=bin
TESTS=tests

test: $(TESTS)/testrepr.mod $(BIN)/Unicode.o
	$(COMPILER) $(FLAGS) -I.:$(INC)/ $(TESTS)/testrepr.mod $(BIN)/Unicode.o -o $(BIN)/testrepr

unicode: $(SRC)/Unicode.mod $(INC)/Unicode.def
	$(COMPILER) $(FLAGS) -I$(INC)/ -c $(SRC)/Unicode.mod -o $(BIN)/Unicode.o
