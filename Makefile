all: compile upload

compile:
	@echo "=== Generating static files"
	@jekyll build

upload:
	@echo "=== Syncing files"
	@rsync -avz --no-o --no-g -e ssh --chmod=og=r -p --delete _site/ kempkens:/var/www/blog
	@echo "=== Changing permissions"
	@ssh kempkens chown -R www-data:www-data /var/www/blog
