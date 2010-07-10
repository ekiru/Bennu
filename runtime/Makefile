TARGET_PATH=/usr/local/lib

CC_FLAGS = -Wall -c
LD_FLAGS = -rpath $(TARGET_PATH)
CC = /usr/local/bin/libtool --mode=compile gcc $(CC_FLAGS)
LD = /usr/local/bin/libtool --mode=link gcc $(LD_FLAGS)

TEST_CC = $(CC)
TEST_LD_FLAGS = 
TEST_LD = /usr/local/bin/libtool --mode=link gcc $(TEST_LD_FLAGS)

all: libbennu.la test

libbennu.la: bennu.lo int.lo obj.lo
	$(LD) -o libbennu.la bennu.lo obj.lo int.lo

bennu.lo: bennu.c bennu.h int.h obj.h
	$(CC) -o bennu.lo bennu.c

int.lo: int.c int.h obj.h
	$(CC) -o int.lo int.c

obj.lo: obj.c obj.h
	$(CC) -o obj.lo obj.c

test: test.o
	$(TEST_LD) -o test test.o libbennu.la

test.o: test.c
	$(TEST_CC) -o test.o test.c