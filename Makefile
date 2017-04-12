all: Resources/sites.txt

shallalist.tar.gz:
	curl http://www.shallalist.de/Downloads/shallalist.tar.gz > $@

Tools/block.txt: shallalist.tar.gz
	tar xzvf $^
	cat BL/{downloads,drugs,hacking,gamble,porn,spyware,updatesites,urlshortener,violence,warez,weapons}/domains > $@

Resources:
	mkdir -p Resources

https-everywhere:
	git clone --depth 1 https://github.com/EFForg/https-everywhere.git

Resources/sites.txt: Resources Tools/block.txt Tools/parse-rules.rb https-everywhere
	ruby Tools/parse-rules.rb > $@

clean:
	rm -rf https-everywhere
	rm shallalist.tar.gz
	rm -rf BL

.PHONY: all clean
