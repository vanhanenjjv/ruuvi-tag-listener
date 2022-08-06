SRCS = $(wildcard src/*.vala)
PKGS = --pkg gio-2.0 --pkg gio-unix-2.0
EXEC = ruuvi-tag-listener

$(EXEC): $(SRCS)
	valac -X -w $(PKGS) $(SRCS) --output $(EXEC)
