CC = g++

CFLAGS = -g -Wall
CFLAGS = -O3

# Executables
2048: main.o cell.o key.o clearscreen.o
	$(CC) $(CFLAGS) main.o cell.o key.o clearscreen.o -o $@

key_test: key_test.o key_t.o
	$(CC) $(CFLAGS) key_test.o key_t.o -o $@

# Object Files
main.o: main.cpp key.h cell.h clearscreen.h
	$(CC) -c $(CFLAGS) main.cpp -o $@

cell.o: cell.cpp cell.h
	$(CC) -c $(CFLAGS) cell.cpp -o $@

key_test.o: key_test.cpp
	$(CC) -c $(CFLAGS) key_test.cpp -o $@

key.o: key.cpp key.h
	$(CC) -c $(CFLAGS) key.cpp -o $@

key_t.o: key.cpp key.h
	$(CC) -c $(CFLAGS) key.cpp -DKEY_TEST -o $@

clearscreen.o: clearscreen.cpp clearscreen.h
	$(CC) -c $(CFLAGS) clearscreen.cpp -o $@

# Clean
clean:
	rm -f *.o *.exe
