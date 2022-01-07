# syntax=docker/dockerfile:1

# From cuda 10.0 / cudnn 7
FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

# Labels

LABEL version="0.1"
LABEL description="Docker image for baowenbo/DAIN"

# Envs
ENV DAIN_PATH=/usr/local/dain

# ignore interactive mode, just install everything
ENV DEBIAN_FRONTEND noninteractive

# Start as root
USER root

# install conda (thank you https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile)

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

# hadolint ignore=DL3008
RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
        bzip2 \
        ca-certificates \
        git \
        libglib2.0-0 \
        libsm6 \
        libxext6 \
        libxrender1 \
        mercurial \
        openssh-client \
        procps \
        subversion \
        wget \
        unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH /opt/conda/bin:$PATH

CMD [ "/bin/bash" ]

# Leave these args here to better use the Docker build cache
ARG CONDA_VERSION=4.6.14

RUN set -x && \
    UNAME_M="$(uname -m)" && \
    if [ "${UNAME_M}" = "x86_64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh"; \
        SHA256SUM="1ea2f885b4dbc3098662845560bc64271eb17085387a70c2ba3f29fff6f8d52f"; \
    elif [ "${UNAME_M}" = "s390x" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-s390x.sh"; \
        SHA256SUM="1faed9abecf4a4ddd4e0d8891fc2cdaa3394c51e877af14ad6b9d4aadb4e90d8"; \
    elif [ "${UNAME_M}" = "aarch64" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-aarch64.sh"; \
        SHA256SUM="4879820a10718743f945d88ef142c3a4b30dfc8e448d1ca08e019586374b773f"; \
    elif [ "${UNAME_M}" = "ppc64le" ]; then \
        MINICONDA_URL="https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-ppc64le.sh"; \
        SHA256SUM="fa92ee4773611f58ed9333f977d32bbb64769292f605d518732183be1f3321fa"; \
    fi && \
    wget "${MINICONDA_URL}" -O miniconda.sh -q && \
    echo "${SHA256SUM} miniconda.sh" > shasum && \
#    if [ "${CONDA_VERSION}" != "latest" ]; then sha256sum --check --status shasum; fi && \
    mkdir -p /opt && \
    sh miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh shasum && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

# Fetch DAIN

RUN git clone https://github.com/JamesPerlman/DAIN.git ${DAIN_PATH} && \
    # Install DAIN dependencies
    conda env create -f ${DAIN_PATH}/environment.yaml

SHELL ["conda", "run", "-n", "pytorch1.0.0", "/bin/bash", "-c"]

# Compile packages
RUN cd ${DAIN_PATH}/my_package && \
    ./build.sh && \
    cd ${DAIN_PATH}/PWCNet/correlation_package_pytorch1_0 && \
    ./build.sh

# Fetch model weights
RUN mkdir ${DAIN_PATH}/model_weights && \
    cd ${DAIN_PATH}/model_weights && \
    wget http://vllab1.ucmerced.edu/~wenbobao/DAIN/best.pth

# Download MiddleBury dataset
RUN mkdir ${DAIN_PATH}/MiddleBurySet && \
    cd ${DAIN_PATH}/MiddleBurySet && \
    wget http://vision.middlebury.edu/flow/data/comp/zip/other-color-allframes.zip && \
    unzip other-color-allframes.zip && \
    rm other-color-allframes.zip && \
    wget http://vision.middlebury.edu/flow/data/comp/zip/other-gt-interp.zip && \
    unzip other-gt-interp.zip && \
    rm other-gt-interp.zip
