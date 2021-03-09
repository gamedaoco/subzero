
reset:
	cargo clean

# release

build:
	cargo +nightly build --release
run:
	./target/release/subzero --tmp --name local-node
purge:
	./target/release/subzero purge-chain -y

# dev

dev-build:
	cargo +nightly build
dev-run:
	./target/release/subzero --tmp --dev --name local-dev-node
dev-purge:
	./target/release/subzero purge-chain -y --dev

# docker

docker-build:
	docker build -t playzero/subzero:local .
docker-run:
	docker run playzero/subzero:local /usr/local/bin/subzero --name hello-joy
docker-release:
	# 	TODO:
	# 	1 bump versions of
	# 		cli
	# 		runtime
	# 		node
	# 	2 build local
	# 	3 build docker
	# 	4 tag docker
	# 	5 push docker tag + latest