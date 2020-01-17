srcfiles := src/install.zsh.erb $(wildcard src/*/*) LICENSE

install.zsh: $(srcfiles)
	erb $< >| $@
