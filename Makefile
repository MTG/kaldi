build:
	docker build -t mtg-docker.sb.upf.edu/kaldi:ubuntu18.04 .

push:
	docker push mtg-docker.sb.upf.edu/kaldi:ubuntu18.04

all: build push

.PHONY: build upload all
