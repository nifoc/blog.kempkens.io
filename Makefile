all: compile upload superfeedr

compile:
	@echo "=== Generating static files"
	@bundle exec jekyll build
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
	@echo "Done."
