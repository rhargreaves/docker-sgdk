# Introduction

Dockerfile based [SGDK](https://github.com/Stephane-D/SGDK/) toolchain.

The Dockerfile is based on [this m68k-elf toolchain](https://gitlab.com/doragasu/docker-deb-m68k) and it includes newlib (even though SGDK does not require it). All the tools in the image (including GCC) are Linux native and replace the Windows versions bundled with upstream SGDK. Included GCC version is 6.3, that has been found to generate better code for m68k targets than newer versions.

The repository contains a GitLab CI/CD script that automatically builds the docker images on new tags, and pushes them to the GitLab registry, so you do not need to build the image yourself, you can just pull it from the GitLab registry. You can browse the [readily available images here](https://gitlab.com/doragasu/docker-sgdk/container_registry).

The Dockerfile supports generating docker images with and without MegaWiFi support and also if bank switching should be enabled.

* Images with MegaWiFi support have a version tag ending with `-mw` (e.g. `v2.00-mw` tag uses the latest `v2.00` SGDK tag when the image was built and has MegaWiFi support, while `v2.00` tag uses the latest `v2.00` SGDK tag without MegaWiFi support).
* Images with bank switching include `-bs`.

The entry point directly runs `make -f $GDK/makefile.gen`. Thus if you run the container mapping the directory of an SGDK project to `/m68k`, the container will directly try building it.

# Other Changes

This fork of [doragasu's original repo](https://gitlab.com/doragasu/docker-sgdk) patches SGDK to fix a number of issues with using the SGDK headers with projects which need to cross-compile for the Mega Drive but also Intel/ARM (to run unit tests for example).

1. Fixes `va_list` type declaration ([`fix_va_list_type.patch`](fix_va_list_type.patch))

# Usage

## Building an SGDK project

To build your SGDK project, from the project directory run:

```bash
$ docker run --rm -v $PWD:/m68k -t ghcr.io/rhargreaves/docker-sgdk:v2.00
```

You can replace `v1.70` with the version tag you want. The first time you run the command, Docker should fetch the container from the registry and run it.

You can pass additional `make` arguments. E.g. to clean the project run:

```bash
$ docker run --rm -v $PWD:/m68k -t ghcr.io/rhargreaves/docker-sgdk:v2.00 clean
```

If you prefer staying inside the docker container, you can get an interactive shell by setting the `-i` (interactive) flag and overriding the entry point:

```bash
$ docker run --rm -v $PWD:/m68k --entrypoint=/bin/bash -it ghcr.io/rhargreaves/docker-sgdk:v2.00
```

You do not want to type these long commands above, so it is recommended to use a script to launch them for you.

Note that this Docker container runs as unprivileged `m68k` user, and home is set to `/m68k`.
