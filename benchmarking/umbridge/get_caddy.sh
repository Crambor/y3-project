#!/bin/bash

arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
    arch_suffix="amd64"
else
    echo "Error: handling for architecture $arch unsupported"
    exit 1
fi

target_arch="linux_$arch_suffix"
url=$(curl -sL https://api.github.com/repos/caddyserver/caddy/releases/latest | \
      grep -o "\"browser_download_url\": \"https://[^\"]*${target_arch}.tar.gz\"" | \
      cut -d '"' -f 4)

filename="caddy-${target_arch}.tar.gz"
[[ ! -f $filename ]] && wget $url -O $filename
[[ ! -f "hq" ]] && tar xzf $filename
