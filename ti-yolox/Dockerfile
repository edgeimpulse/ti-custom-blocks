# syntax = docker/dockerfile:experimental
ARG UBUNTU_VERSION=18.04

ARG ARCH=
ARG CUDA=11.2
FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}.1-base-ubuntu${UBUNTU_VERSION} as base
ARG CUDA
ARG CUDNN=8.1.0.77-1
ARG CUDNN_MAJOR_VERSION=8
ARG LIB_DIR_PREFIX=x86_64
ARG LIBNVINFER=8.0.0-1
ARG LIBNVINFER_MAJOR_VERSION=8
# Let us install tzdata painlessly
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Avoid confirmation dialogs
ENV DEBIAN_FRONTEND=noninteractive
# Makes Poetry behave more like npm, with deps installed inside a .venv folder
# See https://python-poetry.org/docs/configuration/#virtualenvsin-project
ENV POETRY_VIRTUALENVS_IN_PROJECT=true

# CUDA drivers
SHELL ["/bin/bash", "-c"]
COPY ./install_cuda.sh ./install_cuda.sh
RUN ./install_cuda.sh && \
    rm install_cuda.sh

# Install base dependencies
RUN apt update
RUN apt install -y build-essential software-properties-common wget git
#RUN apt-get install -y python3
RUN apt install -y python3-pip python3-setuptools python3-dev
RUN pip3 install --upgrade pip

# ubuntu package dependencies
# libsm6 libxext6 libxrender1 : needed by opencv
# cmake protobuf-compiler libprotoc-dev : needed by onnx
# graphviz : needed by tvm
# swig : needed by model selection tool
# curl vim git wget gdb : needeed by baseline dev
RUN apt install -y libsm6 libxext6 libxrender1 cmake libprotobuf-dev protobuf-compiler libprotoc-dev graphviz swig curl vim git wget gdb nano zip gcc-5 g++-5 pkg-config libgtk-3-dev libyaml-cpp-dev
#RUN apt update && apt install -y ffmpeg libsm6 libxext6 libgl1 moreutils

# # Install TensorFlow
# COPY install_tensorflow.sh install_tensorflow.sh
# RUN /bin/bash install_tensorflow.sh && \
#     rm install_tensorflow.sh

COPY requirements.txt ./
RUN pip3 install -r requirements.txt

RUN ln -s /usr/bin/python3 /usr/bin/python

# update to latest cmake since need for yolox build
RUN wget -O cmake.sh https://github.com/Kitware/CMake/releases/download/v3.24.2/cmake-3.24.2-linux-x86_64.sh
# make executable
RUN chmod +x cmake.sh
# install
RUN ./cmake.sh --prefix=/usr/local/ --exclude-subdir --skip-license

#install yolox
RUN git clone https://github.com/TexasInstruments/edgeai-yolox.git && \
    cd edgeai-yolox && \
#    pip3 install -U pip && pip3 install -r requirements.txt && \
    pip3 install -v -e .

#install pycocotools
RUN pip3 install cython && \
    pip3 install 'git+https://github.com/cocodataset/cocoapi.git#subdirectory=PythonAPI'

# Grab TI yolox-s pth file (pretrained weights)
RUN wget -O yolox_s.pth https://github.com/Megvii-BaseDetection/YOLOX/releases/download/0.1.1rc0/yolox_s.pth

COPY custom_exps.py ./

WORKDIR /scripts

COPY . ./ 
# This is the script our application should run (-u to disable buffering)
ENTRYPOINT ["/bin/bash", "run.sh"]

