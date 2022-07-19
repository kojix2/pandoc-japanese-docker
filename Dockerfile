FROM "pandoc/latex"
LABEL maintainer="kojix2 <2xijok@gmail.com>"
RUN apk --update add make && \
    tlmgr update --self --all && \
    tlmgr install collection-langjapanese

