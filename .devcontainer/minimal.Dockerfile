# This file is used to build the pulse-sandbox-devcontainer image which we
# routinely push to DockerHub. It will not be rebuilt by rebuilding only
# the devcontainer. An alternative is replacing the "image" field in
# the devcontainer with a "build" field, but that would make everyone
# rebuild the container (and FStar, and Pulse) everytime, which is very
# expensive.

FROM mtzguido/pulse-base-devcontainer:latest

# Get Pulse and build
RUN eval $(opam env) \
 && source $HOME/.profile \
 && git clone --depth=1 https://github.com/FStarLang/pulse \
 && cd pulse/ \
 && make -j$(nproc) \
 && make -j$(nproc) -C share/pulse/examples/

ENV PULSE_HOME $HOME/pulse
