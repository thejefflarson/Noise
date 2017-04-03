all: Resources/sites.txt

Resources:
	mkdir -p Resources
Resources/sites.txt: Resources
	git clone --depth 1 https://github.com/EFForg/https-everywhere.git
	ruby Tools/parse-rules.rb > $@
	rm -rf https-everywhere

.PHONY: all
