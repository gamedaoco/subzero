FROM phusion/baseimage:0.11 AS builder

LABEL maintainer="devops@zero.io"
LABEL description="This is the build stage for subzero."

ENV DEBIAN_FRONTEND=noninteractive

ARG PROFILE=release
WORKDIR /subzero

COPY . /subzero

RUN apt-get update && \
	apt-get dist-upgrade -y -o Dpkg::Options::="--force-confold" && \
	apt-get install -y cmake pkg-config libssl-dev git clang

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y && \
	export PATH="$PATH:$HOME/.cargo/bin" && \
	rustup install 1.45.1 && \
	rustup default 1.45.1 &&\
	rustup toolchain install nightly-2020-08-19 && \
	rustup target add wasm32-unknown-unknown --toolchain nightly-2020-08-19 && \
	rustup toolchain list && \
	cargo build "--$PROFILE"

# ===== SECOND STAGE ======

FROM phusion/baseimage:0.11
LABEL maintainer="devops@zero.io"
LABEL description="This is the 2nd stage: a very small image where we copy the subzero binary."
ARG PROFILE=release

RUN mv /usr/share/ca* /tmp && \
	rm -rf /usr/share/*  && \
	mv /tmp/ca-certificates /usr/share/ && \
	useradd -m -u 1000 -U -s /bin/sh -d /subzero subzero && \
	mkdir -p /subzero/.local/share/subzero && \
	chown -R subzero:subzero /subzero/.local && \
	ln -s /subzero/.local/share/subzero /data

COPY --from=builder /subzero/target/$PROFILE/subzero /usr/local/bin
COPY --from=builder /subzero/target/$PROFILE/subkey /usr/local/bin
COPY --from=builder /subzero/target/$PROFILE/chain-spec-builder /usr/local/bin

# checks
RUN ldd /usr/local/bin/subzero && \
	/usr/local/bin/subzero --version

# Shrinking
RUN rm -rf /usr/lib/python* && \
	rm -rf /usr/bin /usr/sbin /usr/share/man

USER subzero
EXPOSE 30333 9933 9944 9615
VOLUME ["/data"]

CMD ["/usr/local/bin/subzero"]