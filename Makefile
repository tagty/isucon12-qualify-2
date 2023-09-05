deploy:
	ssh isucon12-qualify-1 " \
		cd /home/isucon; \
		git checkout .; \
		git fetch; \
		git checkout $(BRANCH); \
		git reset --hard origin/$(BRANCH)"

build:
	ssh isucon12-qualify-1 " \
		cd /home/isucon/webapp/go/cmd/isuports; \
		/usr/bin/go build -o isuports"

go-deploy:
	scp ./webapp/go/isuports isucon12-qualify-1:/home/isucon/webapp/go/

go-deploy-dir:
	scp -r ./webapp/go isucon12-qualify-1:/home/isucon/webapp/

restart:
	ssh isucon12-qualify-1 "sudo systemctl restart isuports.service"

mysql-deploy:
	ssh isucon12-qualify-1 "sudo dd of=/etc/mysql/mysql.conf.d/mysqld.cnf" < ./etc/mysql/mysql.conf.d/mysqld.cnf

mysql-rotate:
	ssh isucon12-qualify-1 "sudo rm -f /var/log/mysql/mysql-slow.log"

mysql-restart:
	ssh isucon12-qualify-1 "sudo systemctl restart mysql.service"

nginx-deploy:
	ssh isucon12-qualify-1 "sudo dd of=/etc/nginx/nginx.conf" < ./etc/nginx/nginx.conf

nginx-rotate:
	ssh isucon12-qualify-1 "sudo rm -f /var/log/nginx/access.log"

nginx-reload:
	ssh isucon12-qualify-1 "sudo systemctl reload nginx.service"

nginx-restart:
	ssh isucon12-qualify-1 "sudo systemctl restart nginx.service"

.PHONY: bench
bench:
	ssh isucon12-qualify-bench " \
		cd /home/isucon/bench; \
		./bench -target-addr 172.31.41.209:443"

pt-query-digest:
	ssh isucon12-qualify-1 "sudo pt-query-digest --limit 10 /var/log/mysql/mysql-slow.log"

ALPSORT=sum
# /api/player/competition/[0-9a-z\-]+/ranking
# /api/player/player/[0-9a-z]+
# /api/organizer/competition/[0-9a-z\-]+/finish
# /api/organizer/competition/[0-9a-z\-]+/score
# /api/organizer/player/[0-9a-z\-]+/disqualified
# /api/admin/tenants/billing
ALPM=/api/player/competition/[0-9a-z\-]+/ranking,/api/player/player/[0-9a-z]+,/api/organizer/competition/[0-9a-z\-]+/finish,/api/organizer/competition/[0-9a-z\-]+/score,/api/organizer/player/[0-9a-z\-]+/disqualified,/api/admin/tenants/billing
OUTFORMAT=count,method,uri,min,max,sum,avg,p99

alp:
	ssh isucon12-qualify-1 "sudo alp ltsv --file=/var/log/nginx/access.log --nosave-pos --pos /tmp/alp.pos --sort $(ALPSORT) --reverse -o $(OUTFORMAT) -m $(ALPM) -q"

.PHONY: pprof
pprof:
	ssh isucon12-qualify-1 " \
		/usr/bin/go tool pprof -seconds=75 /home/isucon/webapp/go/isuports http://localhost:6060/debug/pprof/profile"

pprof-show:
	$(eval latest := $(shell ssh isucon12-qualify-1 "ls -rt ~/pprof/ | tail -n 1"))
	scp isucon12-qualify-1:~/pprof/$(latest) ./pprof
	go tool pprof -http=":1080" ./pprof/$(latest)

pprof-kill:
	ssh isucon12-qualify-1 "pgrep -f 'pprof' | xargs kill;"