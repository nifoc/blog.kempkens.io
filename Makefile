all: compile compress upload superfeedr

compile: clean
	@echo "=== Generating static files"
	@bundle exec jekyll build --lsi
	@echo "Done."

compress:
	@echo "=== Compressing generated files"
	@find ./_site -type f | xargs gzip -k -9
	@echo "Done."

upload:
	@echo "=== Syncing files"
	@rsync -avz --no-o --no-g -e ssh --chmod=og=r -p --delete _site/ webserver.kempkens.io:/var/www/blog
	@echo "Done."
	@echo "=== Changing permissions"
	@ssh webserver.kempkens.io chown -R www:www /var/www/blog
	@echo "Done."

superfeedr:
	@echo "=== Notifying Superfeedr"
	@curl -X POST https://kempkens.superfeedr.com -d "hub.mode=publish" -d "hub.url=https://blog.kempkens.io/feed.xml"
	@curl -X POST https://kempkens.superfeedr.com -d "hub.mode=publish" -d "hub.url=https://blog.kempkens.io/feed-with-links.xml"
	@echo "Done."

clean:
	@rm -rf ./_site
