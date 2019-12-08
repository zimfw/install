srcfiles := src/install.zsh.erb $(wildcard src/*/*)

install.zsh: $(srcfiles)
	erb $< >| $@
