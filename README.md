# ubuntu-devbox
I just want a clean ubuntu environment for development. 

It is mainly for pytorch development on GPU. 

# Usage

## Build
```sh
sudo docker build -t ubuntu-devbox .
```

## Run
```sh
sudo nvidia-docker run -itd --name ubuntu-devbox ubuntu-devbox
```

To get the container's ip, run
```sh
sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ubuntu-devbox
```

Then access to it via ssh,
```sh
ssh root@your_container_ip
```

---
Have fun!
