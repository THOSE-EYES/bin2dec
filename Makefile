NASM=as
LD=ld
MKDIR=mkdir
RM=rm

NASMFLAGS=--64 -g
LDFLAGS=-m elf_x86_64
MKDIRFLAGS=-p
RMFLAGS=-rf

BUILDFOLDER=build
OUTPUTFOLDER=${BUILDFOLDER}/output

SRCFOLDER=src
SOURCES=$(wildcard ${SRCFOLDER}/*.s)
OBJECTS=$(patsubst ${SRCFOLDER}/%.s,%.o,${SOURCES})

all: folders main

main: ${OBJECTS}
	$(LD) ${LDFLAGS} -o ${OUTPUTFOLDER}/$@ $(patsubst %.o, ${BUILDFOLDER}/%.o,$?)

folders:
	${MKDIR} ${MKDIRFLAGS} ${BUILDFOLDER}
	${MKDIR} ${MKDIRFLAGS} ${OUTPUTFOLDER}

clean:
	${RM} ${RMFLAGS} ${BUILDFOLDER}

%.o: ${SRCFOLDER}/%.s
	$(NASM) -o ${BUILDFOLDER}/$@ $< $(NASMFLAGS)