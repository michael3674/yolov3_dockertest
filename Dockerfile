FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    libopencv-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt
RUN git clone https://github.com/pjreddie/darknet.git

WORKDIR /opt/darknet
RUN make -j"$(nproc)" && \
    wget https://pjreddie.com/media/files/yolov3.weights -O yolov3.weights

RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    '' \
    'IMG_URL="$1"' \
    'if [ -z "$IMG_URL" ]; then' \
    '  echo "Usage: docker run <image> <image_url>"' \
    '  exit 1' \
    'fi' \
    '' \
    'echo "Downloading image from: $IMG_URL"' \
    'wget -O input.jpg "$IMG_URL"' \
    '' \
    'echo "Running YOLOv3 on input.jpg..."' \
    './darknet detector test cfg/coco.data cfg/yolov3.cfg yolov3.weights input.jpg -dont_show' \
    '' \
    'echo "Done. predictions.jpg generated in: $(pwd)"' \
    > /usr/local/bin/run_yolov3.sh && \
    chmod +x /usr/local/bin/run_yolov3.sh

WORKDIR /opt/darknet
ENTRYPOINT ["/usr/local/bin/run_yolov3.sh"]

