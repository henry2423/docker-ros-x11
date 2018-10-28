# This Dockerfile is used to build an ROS + OpenGL + Gazebo + Tensorflow image based on Ubuntu 16.04
FROM nvidia/opengl:1.0-glvnd-devel-ubuntu18.04

LABEL maintainer "Henry Huang https://github.com/henry2423"
MAINTAINER Henry Huang "https://github.com/henry2423"
ENV REFRESHED_AT 2018-10-28

## nvidia-cuda and cudnn library (cuda:10.0-cudnn7-devel-ubuntu18.04)
# CUDA 10.0-base
RUN apt-get update && apt-get install -y --no-install-recommends gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl && \
    rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.0.130

ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
        cuda-compat-10-0=410.48-1 && \
    ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

ENV PATH /usr/local/cuda/bin:${PATH}

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility,graphics
ENV NVIDIA_REQUIRE_CUDA "cuda>=10.0 brand=tesla,driver>=384,driver<385"


# CUDA 10.0-runtime
ENV NCCL_VERSION 2.3.5

RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-$CUDA_PKG_VERSION \
        cuda-nvtx-$CUDA_PKG_VERSION \
        libnccl2=$NCCL_VERSION-2+cuda10.0 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*

# CUDA 10.0-devel
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-libraries-dev-$CUDA_PKG_VERSION \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-2+cuda10.0 && \
    rm -rf /var/lib/apt/lists/*

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

# CUDA 10.0-cudnn7
ENV CUDNN_VERSION 7.3.1.20
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda10.0 \
            libcudnn7-dev=$CUDNN_VERSION-1+cuda10.0 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*

# Install sudo
RUN apt-get update && \
    apt-get install -y sudo apt-utils curl

#Add new sudo user
ARG user=ros
ARG passwd=ros
ARG uid=1000
ARG gid=1000
ENV USER=$user
ENV PASSWD=$passwd
ENV UID=$uid
ENV GID=$gid
RUN useradd --create-home -m $USER && \
        echo "$USER:$PASSWD" | chpasswd && \
        usermod --shell /bin/bash $USER && \
        usermod -aG sudo $USER && \
        echo "$USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USER && \
        chmod 0440 /etc/sudoers.d/$USER && \
        # Replace 1000 with your user/group id
        usermod  --uid $UID $USER && \
        groupmod --gid $GID $USER

### ROS and Gazebo Installation
# Install other utilities
RUN apt-get update && \
    apt-get install -y vim \
    tmux \
    git \
    wget \
    lsb_release \
    lsb-core

# Install ROS
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros-latest.list' && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116 && \
    apt-get update && apt-get install -y ros-melodic-desktop && \
    apt-get install -y python-rosinstall && \
    rosdep init

# Install Gazebo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list' && \
    wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add - && \
    apt-get update && \
    apt-get install -y gazebo9 libgazebo9-dev && \
    apt-get install -y ros-melodic-gazebo-ros-pkgs ros-melodic-gazebo-ros-control

# Setup ROS
USER $USER
RUN rosdep fix-permissions && rosdep update
RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"


###Tensorflow Installation
# Install pip
USER root
RUN apt-get install -y wget python-pip python-dev libgtk2.0-0 unzip libblas-dev liblapack-dev libhdf5-dev && \
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py

# prepare default python 2.7 environment
USER root
RUN pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/gpu/tensorflow_gpu-1.11.0-cp27-none-linux_x86_64.whl && \
    pip install keras==2.2.4 matplotlib pandas scipy h5py testresources scikit-learn

# Expose Tensorboard
EXPOSE 6006

### Switch to root user to install additional software
USER $USER