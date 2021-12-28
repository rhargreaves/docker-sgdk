# Introduction

Dockerfile based SGDK toolchain.

The Dockerfile is based on [this m68k-elf toolchain](https://gitlab.com/doragasu/docker-deb-m68k) and it includes newlib (even though SGDK does not use it).

The repository contains a GitLab CI/CD script that automatically builds the docker images on new tags, and pushes them to the GitLab registry, so you do not need to build the image yourself, you can just pull it from the GitLab registry.

The entry point directly runs `make -f $GDK/makefile.gen`. Thus if you run the container mapping the directory of an SGDK project to `/m68k`, the container will directly try building it.

# Usage

## Building an SGDK project

To build your SGDK project, from the project directory run:

```bash
$ docker run --rm -v $PWD:/m68k -t registry.gitlab.com/doragasu/docker-sgdk
```

The first time you run the command, Docker should fetch the container from the registry and run it.

You can pass additional `make` arguments. E.g. to clean the project run:

```bash
$ docker run --rm -v $PWD:/m68k -t registry.gitlab.com/doragasu/docker-sgdk clean
```

If you prefer staying inside the docker container, you can get an interactive shell by setting the `-i` (interactive) flag and overriding the entry point:

```bash
$ docker run --rm -v $PWD:/m68k --entrypoint=/bin/bash -it registry.gitlab.com/doragasu/docker-sgdk
```

You do not want to type these long commands above, so it is recommended to use a script to launch them for you.

Note that this Docker container runs as unprivileged `m68k` user, and home is set to `/m68k`.
