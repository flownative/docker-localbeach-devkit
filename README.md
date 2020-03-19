# Local Beach Dev Kit

![Nightly Builds](https://github.com/flownative/docker-localbeach-devkit/workflows/Nightly%20Builds/badge.svg)

This Docker image is used as a sidecar-container in Local Beach
development environments and takes care of synchronizing files from the
host (your machine) to a shared volume. This is usually only necessary
in MacOS environments, because file access is too slow when you are
mounting a host directory to the container directly.

## Background

A sync daemon, based on inotify, watches a source directory and
synchronizes all changes – that is, files or directories created,
modified or deleted – to a target directory.

In a Local Beach setup, the source directory is called
"application-on-host" and is a direct mount of the application directory
on the developer's computer. The target directory is called
"application" and is a Docker volume which is shared across the Nginx
and PHP-FPM container.

See Local Beach for further details about which directory mounts exist.

## Usage

Make sure that a shared volume – for example called "application" -
exists in your Docker Compose configuration:

````yaml
volumes:
  application:
    name: myproject-application
    driver: local
````

Then include the Local Beach Dev Kit image as an additional container:

```yaml
  devkit:
    image: flownative/localbeach-devkit
    volumes:
      - application:/application
      - .:/application-on-host:delegated
```

## Configuration

You can override source and target paths by setting the environment
variables `SYNC_APPLICATION_ON_HOST_PATH` and `SYNC_APPLICATION_PATH`
respectively.
