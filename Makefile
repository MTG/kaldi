build:
	docker build -t registry.sb.upf.edu/mtg/kaldi:ubuntu18.04 .

push:
	docker push registry.sb.upf.edu/mtg/kaldi:ubuntu18.04

all: build push

.PHONY: build upload all
