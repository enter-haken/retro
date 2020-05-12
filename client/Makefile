.PHONY: default
default: build

.PHONY: install_node_modules_if_neccessary
install_node_modules_if_neccessary:
	if [ ! -d node_modules/ ]; then npm install; fi

.PHONY: build
build: install_node_modules_if_neccessary 
	ng build --prod --build-optimizer --aot

.PHONY: clean
clean:
	rm dist/ -rf || true

.PHONY: deep_clean
deep_clean: clean
	rm node_modules/ -rf || true

.PHONY: run
run: install_node_modules_if_neccessary
	ng serve --configuration=dev --host 0.0.0.0 --disableHostCheck=true

.PHONY: loc
loc:
	find src -type f | while read line; do cat $$line; done | sed '/^\s*$$/d' | wc -l

.PHONY: ignore
ignore:
	echo "#ignore file for silver searcher" > .ignore
	echo "#currently ** is not working" >> .ignore
	echo "#https://github.com/ggreer/the_silver_searcher/wiki/Advanced-Usage" >> .ignore
	find dist/ >> .ignore | true
	echo "node_modules/" >> .ignore


