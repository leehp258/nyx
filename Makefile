CC       ?= gcc
CXXFLAGS := -Wall -Wextra -std=gnu89

INCLUDES := -I.
LIBS     := -lyaml -lpthread

# DEBUG/RELEASE BUILD

DEBUG ?= 0
ifeq ($(DEBUG), 1)
    CXXFLAGS+= -O0 -ggdb
    BUILD=DEBUG
else
    CXXFLAGS+= -O2 -DNDEBUG -Wno-unused-parameter
    BUILD=RELEASE
endif

# FILES

SRCS     := $(wildcard src/*.c)
OBJECTS  := $(patsubst src/%.c,src/%.o, $(SRCS))
DEPS     := $(OBJECTS:.o=.d)

TSRCS    := $(wildcard tests/*.c)
TOBJECTS := $(patsubst tests/%.c,tests/%.o, $(TSRCS))
TLIBS    := -lcmocka
TDEPS    := $(filter-out src/main.o, $(OBJECTS))

# PLUGINS

PLUGINS ?= 0
ifeq ($(PLUGINS), 1)
    LIBS+= -ldl -rdynamic
    CXXFLAGS+= -DUSE_PLUGINS
else
    OBJECTS := $(filter-out src/plugins.o, $(OBJECTS))
    TDEPS   := $(filter-out src/plugins.o, $(TDEPS))
endif

# TRY TO DETERMINE GIT VERSION

GITVERSION ?= $(shell ./utils/git-version.sh)
CXXFLAGS   += $(GITVERSION)

# INSTALL DIRECTORIES

PREFIX     ?= /usr/local
MANPREFIX  ?= $(PREFIX)/share/man
DOCDIR     ?= $(PREFIX)/share/doc

INSTALLDIR := $(DESTDIR)$(PREFIX)
MANPREFIX  := $(DESTDIR)$(MANPREFIX)
DOCDIR     := $(DESTDIR)$(DOCDIR)

.PHONY: all options clean rebuild check install uninstall

all: options nyx nyx.1.gz

-include $(DEPS)

options:
	@echo nyx build options
	@echo "build      : $(BUILD)"
	@echo "CC         : $(CC)"
	@echo "CXXFLAGS   : $(CXXFLAGS)"
	@echo "INSTALLDIR : $(INSTALLDIR)"
	@echo "MANPREFIX  : $(MANPREFIX)"
	@echo "DOCDIR     : $(DOCDIR)"
	@echo

nyx: $(OBJECTS)
	$(CC) $(OBJECTS) -o nyx $(LIBS)

check: test
	@./test

test: $(TOBJECTS) $(TDEPS)
	$(CC) $(TOBJECTS) $(TDEPS) -o test $(LIBS) $(TLIBS)

tests/%.o: tests/%.c
	$(CC) -c $(CXXFLAGS) $(INCLUDES) -o $@ $<

src/%.o: src/%.c
	$(CC) -c $(CXXFLAGS) $(INCLUDES) -MMD -MF $(patsubst %.o,%.d,$@) -o $@ $<

nyx.1.gz: nyx.1
	@gzip -c $< > $@

tags: $(SRCS)
	ctags -R --c-kinds=+lp --fields=+iaS --extra=+q --language-force=C .

install: all
	install -d $(INSTALLDIR)/bin
	install nyx $(INSTALLDIR)/bin/nyx
	install -d $(DOCDIR)/nyx
	install -m644 README.markdown LICENSE $(DOCDIR)/nyx
	install -d $(MANPREFIX)/man1
	install -m644 nyx.1.gz $(MANPREFIX)/man1/

uninstall:
	rm -f $(INSTALLDIR)/bin/nyx
	rm -f $(MANPREFIX)/man1/nyx.1.gz
	rm -rf $(DOCDIR)/nyx

clean:
	@rm -rf src/*.o
	@rm -rf src/*.d
	@rm -rf tests/*.o
	@rm -f nyx
	@rm -f test
	@rm -f nyx.1.gz

rebuild: clean all
