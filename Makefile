srcfiles := src/install.zsh.erb $(wildcard src/*/*.erb)

install.zsh: $(srcfiles)
	erb $< >| $@
