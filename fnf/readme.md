# fnf

Wanna be able to build fnf mods without having to deal with the nightmare of haxe? I gotchu, run one of the following commands for the engine you wanna build for.

`docker build --tag fnf-kade -f kade.Dockerfile .`

`docker build --tag fnf-psych -f psych.Dockerfile .`

then go into the source path you wanna build and do `docker run -i -t --rm -v "$(pwd):/fnf" fnf-engine` (replace engine with which one you wanna build)

this took 45 minutes to get working. I stole the entire concept from [docker-arch-build](https://github.com/nubs/docker-arch-build) so go star the repo or some shit.