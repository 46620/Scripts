# fnf

Im gonna be real, im writing this at 1:18am and i do not plan to update this literally ever, once it works it works.

`docker build --tag fnf-build .`

then go into the source path you wanna build and do `docker run -i -t --rm -v "$(pwd):/fnf" fnf-build`

this took 45 minutes to get working. I stole the entire concept from [docker-arch-build](https://github.com/nubs/docker-arch-build) so go star the repo or some shit.