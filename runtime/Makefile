TARGET_PATH=/usr/local/lib

CC_FLAGS = -Wall -c
LD_FLAGS = -rpath $(TARGET_PATH)
CC = /usr/local/bin/libtool --mode=compile gcc $(CC_FLAGS)
LD = /usr/local/bin/libtool --mode=link gcc $(LD_FLAGS)

TEST_CC = $(CC)
TEST_LD_FLAGS = 
TEST_LD = /usr/local/bin/libtool --mode=link gcc $(TEST_LD_FLAGS)

all: libbennu.la test

libbennu.la: bennu.lo int.lo obj.lo setting.lo
	$(LD) -o libbennu.la bennu.lo obj.lo int.lo setting.lo

bennu.lo: bennu.c bennu.h int.h obj.h setting.h
	$(CC) -o bennu.lo bennu.c

int.lo: int.c int.h obj.h setting.h
	$(CC) -o int.lo int.c

obj.lo: obj.c obj.h
	$(CC) -o obj.lo obj.c

setting.lo: setting.c setting.h obj.h
	$(CC) -o setting.lo setting.c

test: test.o libbennu.la
	$(TEST_LD) -o test test.o libbennu.la

test.o: test.c bennu.h int.h setting.h
	$(TEST_CC) -o test.o test.c

clean:
	/usr/local/bin/libtool --mode=clean rm -r *.lo libbennu.la test

install: all
	/usr/local/bin/libtool --mode=install cp libbennu.la /usr/local/lib/libbennu.la

uninstall:
	/usr/local/bin/libtool --mode=uninstall rm /usr/local/lib/libbennu.la