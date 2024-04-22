#!/bin/bash

arch=$(uname -m)
if [ "$arch" = "x86_64" ]; then
    arch_suffix="x64"
else
    echo "Error: handling for architecture $arch unsupported"
    exit 1
fi

target_arch="linux-$arch_suffix"
url=$(curl -sL https://api.github.com/repos/It4innovations/hyperqueue/releases/latest | \
      grep -o "\"browser_download_url\": \"https://[^\"]*-${target_arch}.tar.gz\"" | \
      cut -d '"' -f 4)

filename="hq-${target_arch}.tar.gz"
[[ ! -f $filename ]] && wget $url -O $filename
[[ ! -f "hq" ]] && tar xzf $filename
