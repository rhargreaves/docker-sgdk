FROM registry.gitlab.com/doragasu/docker-deb-m68k AS buildstage
USER root
RUN apt-get update && apt-get install -y git wget flex bison gperf zlib1g-dev build-essential openjdk-17-jre-headless

RUN mkdir -p /tmp
# TODO: Replace by upstream SGDK when Linux support gets merged
# TODO: Add support for specific tags
RUN cd /tmp && git clone -b devel_linux --depth=1 https://github.com/doragasu/SGDK.git
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
