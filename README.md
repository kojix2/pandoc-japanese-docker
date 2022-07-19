# 楽にDockerで日本語Pandocする

いろいろな方法があるかも知れないが、学習コストを支払う余裕がなく、もともと知識もないため細かいことがしたいわけでもなく、なおかつ3年後でも再利用できるようなロバストそうな方法を求めた結果、公式のDockerに追加で日本語関連をインストールするのが楽だろうという結論。

https://hub.docker.com/r/pandoc/latex

## 公式のDockerに日本語関連パッケージを入れる

こんな感じのDockefileを作ることにした。

```dockerfile:Dockerfile
FROM "pandoc/latex"
LABEL maintainer="kojix2 <2xijok@gmail.com>"
RUN apk --update add make && \
    tlmgr update --self --all && \
    tlmgr install collection-langjapanese
```

1. Pandoc公式はUbuntu版のDockerも公開しているが、なぜかうまく動作しなかった。また、Alpine版が数日前にアップデートされていたのに対して、Ubuntu版はアップデートが数ヶ月前で、メンテナンス状況がいまいちのように思えたので、Alpine版を使うことにした。
1. `tlmgr` コマンドが動作するので雑に `collection-langjapanese` を入れる。
1. Pandocコマンドを直打ちすると長くなるので、MakefileでPandocコマンドを動かしているが、Alpineさんは最小限なので `make` は付属していない。自分で入れる必要がある。

適当にビルド

```sh
docker build -t kojix2/pandoc-japanese .
```

素の状態ではentrypointがpandocコマンドになっている。

```sh
docker run kojix2/pandoc-japanese --version
```

```
pandoc 2.18
Compiled with pandoc-types 1.22.2, texmath 0.12.5, skylighting 0.12.3,
citeproc 0.7, ipynb 0.2, hslua 2.1.0
Scripting engine: Lua 5.3
User data directory: /root/.local/share/pandoc
Copyright (C) 2006-2022 John MacFarlane. Web:  https://pandoc.org
This is free software; see the source for copying conditions. There is no
warranty, not even for merchantability or fitness for a particular purpose.
```

このままでは不便な場合もある。
コマンドでシェルに入りたい場合、エントリーポイントをshに上書きする。

```sh
docker run --entrypoint="sh" -v $(pwd):/data -it kojix2/pandoc-japanese
```

これで `make` など動かすことができる。

Gitlab CIで動かしたい場合は、

https://gitlab.com/pandoc/pandoc-ci-example


```yaml:.gitlab-ci.yml 
  image:
    name: "pandoc/latex"
    entrypoint: ["/bin/sh", "-c"]
  script:
    - apk --update add make
    - tlmgr update --self --all
    - tlmgr install collection-langjapanese
    - make # MakefileからPandocを呼ぶ
  ```

みたいにしておけばいいらしい。
ちなみにMakefileはこんな感じにしてみた。

```sh
# ファイルの配置
.
├── hoge-huga-piyo.bib
├── hoge-huga-piyo.md
└── Makefile
```

```makefile:Makefile
PANDOC = pandoc
ENGINE = lualatex

NAME   = hoge-huga-piyo

SOURCE = $(NAME).md
BIBTEX = $(NAME).bib
TARGET = $(NAME).pdf

$(TARGET): $(SOURCE) $(BIBTEX)
	$(PANDOC) $(SOURCE) -o $(TARGET) -C --pdf-engine=$(ENGINE) -V linkcolor=blue -V documentclass=ltjsarticle -V luatexjapresetoptions=fonts-noto-cjk

all: clean $(TARGET)

clean:
	rm -f $(TARGET)
```

引用文献もちゃんと載るようだ。
この記事は以上です。

参考文献：

https://zenn.dev/sky_y/articles/pandoc-advent-2020-bib2
