# Retro

These are the source for [retro.hake.one][1]

## try it for free

goto [retro.hake.one][1]

## run it on your machine

```
$ docker run -p 4050:4050 enterhaken/retro
```

and go to `http://localhost:4050`.

## build it on your machine with docker

```
$ make docker
```

and run it with

```
$ make docker_run
```

(hint: target `docker_run` uses port `5043`)

or run it with 

```
$ make docker run \
    -p 4050:4050 \
    --name retro \
    -d \
    -t hake/retro:latest
```

## build it on your machine

### requirements

* Elixir ~ 1.9
* Angular CLI ~ 8.x

To start `retro` locally, you can

```
$ make run
```

This will build the client and the backend and start a server on port `4040`.


# Contact

Jan Frederik Hake, <jan_hake@gmx.de>. [@enter_haken](https://twitter.com/enter_haken) on Twitter.

[1]: https://retro.hake.one


