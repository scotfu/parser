CC=gnat 
TARGETS=imp3ada

all: $(TARGETS)

imp3ada: imp3.adb
	 $(CC) make -gnat83 imp3.adb -o imp3ada
clean:
	rm imp3.o imp3.ali  $(TARGETS)
