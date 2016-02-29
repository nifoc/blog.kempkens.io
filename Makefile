all: compile compress upload superfeedr

compile: clean
	@echo "=== Generating static files"
	@bundle exec jekyll build --lsi
	@echo "Done."

compress: compile
	@echo "=== Compressing generated files"
	@find ./_site -type f | xargs zopfli --gzip --i30
	@find ./_site -type f ! -name "*.gz" | xargs -I {} bro --quality 11 --input {} --output {}.br
	@find ./_site -type f -name "*.br" | xargs chmod 644
	@echo "Done."

upload:
	@echo "=== Syncing files"
	@rsync -avz --no-o --no-g -e ssh --chmod=og=r -p --delete _site/ kempkens.io:/iocage/jails/506fd9f8-15c0-11e5-adf5-477a0b920463/root/var/www/blog
	@echo "Done."
	@echo "=== Changing permissions"
	@ssh kempkens.io chmod 755 /iocage/jails/506fd9f8-15c0-11e5-adf5-477a0b920463/root/var/www/blog
	@ssh kempkens.io find /iocage/jails/506fd9f8-15c0-11e5-adf5-477a0b920463/root/var/www/blog -type d -exec chmod 755 {} +
	@echo "Done."

superfeedr:
	@echo "=== Notifying Superfeedr"
	@curl -X POST https://kempkens.superfeedr.com -d "hub.mode=publish" -d "hub.url=https://blog.kempkens.io/feed.xml"
	@curl -X POST https://kempkens.superfeedr.com -d "hub.mode=publish" -d "hub.url=https://blog.kempkens.io/feed-with-links.xml"
	@echo "Done."

clean:
	@rm -rf ./_site
