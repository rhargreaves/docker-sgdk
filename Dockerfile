FROM registry.gitlab.com/doragasu/docker-deb-m68k AS buildstage
USER root
RUN apt-get update && apt-get install -y git wget flex bison gperf zlib1g-dev build-essential openjdk-17-jre-headless
RUN mkdir -p /tmp

# Use --build-arg=SGDK_RELEASE=<branch> switch to change
ARG SGDK_RELEASE=master
# Use --build-arg=ENABLE_MEGAWIFI=y to enable MegaWiFi support
ARG ENABLE_MEGAWIFI=y
RUN cd /tmp && git clone -b $SGDK_RELEASE --depth=1 https://github.com/Stephane-D/SGDK.git
RUN test "$ENABLE_MEGAWIFI" = "y" && sed -i 's/#define ENABLE_MEGAWIFI     0/#define ENABLE_MEGAWIFI     1/' /tmp/SGDK/inc/config.h
# Download compatible SJASM sources
RUN mkdir -p "/tmp/build/sjasm" && cd "/tmp/build/sjasm" && \
	wget https://github.com/Konamiman/Sjasm/archive/v0.39h.tar.gz -O sjasm-0.39h.tar.gz
COPY build_sgdk /tmp/SGDK
RUN cd /tmp/SGDK && ./build_sgdk

# Second stage
FROM registry.gitlab.com/doragasu/docker-deb-m68k
USER root
RUN apt-get update && apt-get install -y openjdk-17-jre-headless
COPY --from=buildstage /tmp/SGDK /sgdk
ENV GDK=/sgdk

USER m68k
WORKDIR /m68k
ENTRYPOINT [ "make", "-f", "/sgdk/makefile.gen" ]
