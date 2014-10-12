all: compile upload

compile:
	@echo "=== Generating static files"
	@jekyll build

upload:
	@echo "=== Syncing files"
	@rsync -avz --no-o --no-g -e ssh --chmod=og=r -p --delete _site/ kempkens.io:/var/www/blog
	@echo "=== Changing permissions"
	@ssh kempkens.io chown -R www-data:www-data /var/www/blog
