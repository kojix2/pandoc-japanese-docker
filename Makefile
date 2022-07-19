PANDOC = pandoc
ENGINE = lualatex

NAME   = README

SOURCE = $(NAME).md
BIBTEX = $(NAME).bib
TARGET = $(NAME).pdf

$(TARGET): $(SOURCE) $(BIBTEX)
	$(PANDOC) $(SOURCE) -o $(TARGET) -C --pdf-engine=$(ENGINE) -V linkcolor=blue -V documentclass=ltjsarticle -V luatexjapresetoptions=fonts-noto-cjk

all: clean $(TARGET)

clean:
	rm -f $(TARGET)
