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
 && source $HOME/.profile \
 && git clone --depth=1 https://github.com/FStarLang/pulse \
 && cd pulse/ \
 && make -j$(nproc) \
 && make -j$(nproc) -C share/pulse/examples/

ENV PULSE_HOME $HOME/pulse

# Install Rust via rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="$HOME/.cargo/bin:$PATH"

# Get fstar-mcp and build
RUN source $HOME/.cargo/env \
 && git clone --depth=1 https://github.com/FStarLang/fstar-mcp \
 && cd fstar-mcp/ \
 && cargo build --release

ENV FSTAR_MCP_HOME $HOME/fstar-mcp
