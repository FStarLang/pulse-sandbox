# This file is used to build the pulse-sandbox-devcontainer image which we
# routinely push to DockerHub. It will not be rebuilt by rebuilding only
# the devcontainer. An alternative is replacing the "image" field in
# the devcontainer with a "build" field, but that would make everyone
# rebuild the container (and FStar, and Pulse) everytime, which is very
# expensive.

# Base container already includes: FStar, karamel, z3, opam/OCaml
FROM ghcr.io/fstarlang/pulse-base-devcontainer:latest

# Get Pulse and build
RUN eval $(opam env) \
 && . $HOME/.profile \
 && git clone --depth=1 https://github.com/FStarLang/pulse \
 && cd pulse/ \
 && make -j$(nproc) ADMIT=1 \
 && make -j$(nproc) -C share/pulse/examples/

ENV PULSE_ROOT $HOME/pulse
# PULSE_HOME should actually be $PULSE_ROOT/out
ENV PULSE_HOME $PULSE_ROOT

# Get fstar-mcp and build
RUN git clone --depth=1 https://github.com/FStarLang/fstar-mcp \
 && cd fstar-mcp/ \
 && cargo build --release

ENV FSTAR_MCP_HOME $HOME/fstar-mcp
