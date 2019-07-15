##Available commands:

##
## Default
## -------
##

.DEFAULT_GOAL := help
help: ## Show this help message
	@grep -E '(^[a-zA-Z_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[32m%-15s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'
.PHONY: help

##
## Project
## -------
##

install: ## Install dependencies
	docker-compose run --rm jekyll bundle install

start: ## Start the project
	docker-compose up -d

stop: ## Stop the project
	docker-compose down

restart: stop start ## Restart the project

new: start ## Create a new blog post
	docker-compose exec jekyll ruby generate_page.rb
