PROJECT_NAME := $(shell basename `pwd`)
PACKAGE_NAME := registry-modeling
DATE := $(shell date +"%F")
DATE_TIME := $(shell date +"%Y-%m-%d_%H-%M-%S")

.PHONY: clean clean-test setup benchmark-run
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

all: setup benchmark-run

setup:	## install mhc longread pipeline
	conda create -n mhc_longread_pipeline -c bioconda python=3.11 hifiasm minimap2 toml samtools && \
	sudo docker pull ghcr.io/pangenome/pggb:latest && \
	git clone https://github.com/tzhang-nmdp/Immuannot && \
	cd Immuannot/ && \
	tar xvf refData-2023Jun05.tgz && \
	conda activate mhc_longread_pipeline
   
benchmark-run: ## Benchmark test for MHC Longread Pipeline
	@echo "============================Benchmark test runs starting at $(DATE_TIME)==============================="
	python script/mhc_longread_pipeline.py "${CONFIG_TOML_PATH}"
	@echo "============================Benchmark test runs ending at $(DATE_TIME)================================="    
    
clean: clean-test ## remove all test

clean-test: ## remove test files
	rm -fr in_dir/* && \
	rm -fr out_dir/*
    
