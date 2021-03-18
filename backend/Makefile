CONTAINER=web

run-dev:
	ENV_FILE=.env.local python apps/manage.py runserver
shell-dev:
	ENV_FILE=.env.local python apps/manage.py shell
bash:
	docker-compose exec $(CONTAINER) bash
log:
	docker-compose logs -f
up:
	docker-compose up -d
stop:
	docker-compose stop
ps:
	docker-compose ps
config:
	docker-compose config
down:
	docker-compose down
rebuild:
	docker-compose up --build --force-recreate -d
restart:
	docker-compose restart
makemigrations:
	docker-compose exec $(CONTAINER) python3 manage.py makemigrations
migrate:
	docker-compose exec $(CONTAINER) python3 manage.py migrate
shell:
	docker-compose exec $(CONTAINER) python3 manage.py shell
dbshell:
	docker-compose exec $(CONTAINER) python3 manage.py dbshell
manage:
	docker-compose exec $(CONTAINER) python3 manage.py ${cmd}
attach:
	docker attach $(shell docker ps | grep backend |  grep $(CONTAINER) | grep "^[a-zA-Z0-9_.-]*" -o)

