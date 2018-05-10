all: compile compress upload superfeedr

compile: clean
	@echo "=== Generating static files"
	@bundle exec jekyll build --lsi
	@echo "Done."

compress: compile
	@echo "=== Compressing generated files"
	@find ./_site -type f | xargs zopfli --gzip --i30
	@find ./_site -type f ! -name "*.gz" | xargs -I {} brotli --quality=11 --output={}.br {}
	@find ./_site -type f -name "*.br" | xargs chmod 644
	@echo "Done."

upload:
	@echo "=== Syncing files"
	@rsync --rsync-path="sudo rsync" -avz --no-o --no-g -e ssh --chmod=og=r -p --delete _site/ kempkens.io:/iocage/jails/webserver/root/var/www/blog
	@echo "Done."
	@echo "=== Changing permissions"
	@ssh kempkens.io sudo /usr/home/daniel/bin/chmodweb /iocage/jails/webserver/root/var/www/blog
	@echo "Done."

superfeedr:
	@echo "=== Notifying Superfeedr"
	@curl -X POST https://kempkens.superfeedr.com -d "hub.mode=publish" -d "hub.url=https://blog.kempkens.io/feed.xml"
	@curl -X POST https://kempkens.superfeedr.com -d "hub.mode=publish" -d "hub.url=https://blog.kempkens.io/feed-with-links.xml"
	@echo "Done."

clean:
	@rm -rf ./_site
