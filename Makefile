#
# Makefile for AmigaOS4 version of awk.
#

.PHONY: all clean debug

CRT = newlib

CC = gcc
YACC = yacc
STRIP = strip -R.comment $@
RM = rm -f
CP = cp

OPTIMIZE = -O3
WARNING = -Wall -Wwrite-strings
CFLAGS = -mcrt=$(CRT) $(OPTIMIZE) $(WARNING)
CPPFLAGS = -mcrt=$(CRT) -D__USE_INLINE__ -DAUTOINIT
LDFLAGS = -mcrt=$(CRT)

LIBS = -lm -lunix

SRCS = ytab.c lex.c b.c main.c parse.c proctab.c tran.c lib.c run.c environ.c
OBJS = $(SRCS:.c=.o)
DEPS = $(OBJS:.o=.d)

all: ytab.c proctab.c maketab awk nawk
	@echo done.

debug: CFLAGS  += -ggdb
debug: LDFLAGS += -ggdb
debug: STRIP    = 
debug: OPTIMIZE = 
debug: all

nawk:
	$(CP) awk nawk

awk: $(OBJS)
	$(CC) $(LDFLAGS) -o $@ $(OBJS) $(LIBS)
	$(STRIP)

ytab.c: awkgram.y
	$(YACC) -d awkgram.y
	rename y.tab.c ytab.c
	rename y.tab.h ytab.h

proctab.c: maketab
	./maketab >./proctab.c

maketab: ytab.h maketab.c
	$(CC) $(CFLAGS) maketab.c -o $@

%.o : %.c
	$(CC) -MM -MP $(INCDIRS) $< >$*.d
	$(CC) -c $(CPPFLAGS) -I. $(CFLAGS) $<

clean:
	$(RM) awk nawk $(OBJS) $(DEPS) proctab.c maketab ytab.c ytab.h

-include $(SRCS:.c=.d)
