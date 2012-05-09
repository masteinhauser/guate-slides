.PHONY: deploy watch clean touch
project=vbnet-gc
path=/usr/src/${project}
instance=\033[36;01m${project}\033[m

all: watch
deploy: server = root@vps.kastlersteinhauser.com
deploy:
	@coffee -c app.coffee
	@echo -e " ${instance} | stopping app on ${server}"
	@ssh ${server} "/bin/bash ${path}/shutdown.sh"
	@echo -e " ${instance} | stopped app on ${server}"
	@echo -e " ${instance} | deploying app on ${server}"
	@rsync -az --exclude=".git" --exclude="node_modules/*/build" --delete --delete-excluded * ${server}:${path}
	@echo -e " ${instance} | deployed app to ${server}"
	@ssh ${server} "cd ${path} && npm rebuild"
	@echo -e " ${instance} | built npm packages on ${server}"
	@echo -e " ${instance} | starting app on ${server}"
#	@ssh ${server} "/usr/bin/screen -dmS vbnet-gc /bin/bash /usr/src/vbnet-gc/startup.sh"
	@ssh -f -n ${server} "cd ${path}; /bin/bash startup.sh;"
	@echo -e " ${instance} | started app on ${server}"
	@make -s clean
	@sleep 1
	@make -s touch

touch: server = root@vps.kastlersteinhauser.com
touch:
	@wget -r -l 1 -q http://vps.kastlersteinhauser.com:8501/
	@echo -e " ${instance} | built main assets on ${server}"
	@wget -r -l 1 -q http://vps.kastlersteinhauser.com:8501/clicker
	@echo -e " ${instance} | built clicker assets on ${server}"
	@rm -rf vps.kastlersteinhauser.com*

watch:
	@if ! which supervisor > /dev/null; then echo "supervisor required, installing..."; sudo npm install -g supervisor; fi
	@supervisor -w assets,views,app.coffee app.coffee

clean:
	@rm app.js
	@echo -e " ${instance} | cleaned"
