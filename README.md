# ColossalAI in Docker
[toc]

## Prerequisite
- Nvidia Graphic Card
- Docker(with [nvidia container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html))
- [ColossalAI](https://github.com/hpcaitech/ColossalAI)
- [ColossalAI Dockerfile](https://github.com/jhsy1209021/colossalai_docker)
- (Optional)[ColossalAI-Example](https://github.com/hpcaitech/ColossalAI-Examples)

## About Dockerfile
This docker file based on official nvidia cuda docker image(with cuDNN).
- Version
    - cuda: 11.0.3
    - cuDNN: v8
    - Ubuntu: 20.04
1. The cuda version should choose which is supported by the host nvidia-driver.
2. cuDNN library is officidally update to v8 on Dockerhub
3. This images is OS-included(ubuntu). There are another OS can choose(centos, rockylinux, ubi, etc).
4. You should choose the image with **devel**, because the includes headers and development tools is needed when compiling pytorch and torchvision.

---

- Include Package
    - pytorch: 1.13.0
    - torchvision: 0.14.0
    - titans: latest
1. ColossalAI haven't supported 2.0.0 yet, so 1.13.0 instead.

---

### Install pytorch from pip
Cause building pytorch take really much time, you can use pip source instead of building from source.

**Remove the code below**
```=Dockerfile
#Import the pytorch src(v1.13.0)
RUN wget https://github.com/pytorch/pytorch/releases/download/v1.13.0/pytorch-v1.13.0.tar.gz \
    && tar -zxvf pytorch-v1.13.0.tar.gz
#Setup pytorch
WORKDIR /workspace/pytorch-v1.13.0
##Install necessary
RUN pip3 install astunparse numpy ninja pyyaml setuptools cmake cffi typing_extensions future six requests dataclasses mkl mkl-include
##Install pytorch
ENV TORCH_CUDA_ARCH_LIST="6.1"
RUN pip3 install -r requirements.txt
RUN PATH=${PATH}:/home/${NAME}/.local/bin USE_EXPERIMENTAL_CUDNN_V8_API=0 python3 setup.py develop

WORKDIR /workspace
#Install correspond torchvision(0.14.0)
RUN wget https://github.com/pytorch/vision/archive/refs/tags/v0.14.0.tar.gz \
    && tar -zxvf v0.14.0.tar.gz \
    && cd vision-0.14.0 \
    && FORCE_CUDA=1 sudo python3 setup.py install

RUN rm pytorch-v1.13.0.tar.gz && rm v0.14.0.tar.gz
```

**And add**
```=bash
pip3 install torch==1.13.0+cu116 torchvision==0.14.0+cu116 torchaudio==0.13.0 --extra-index-url https://download.pytorch.org/whl/cu116
```


## Setup
### Clone necessary Repo
```=bash
git clone https://github.com/jhsy1209021/colossalai_docker
git clone https://github.com/hpcaitech/ColossalAI
git clone https://github.com/hpcaitech/ColossalAI-Examples
```

### Build image(This may take a while...)
To corectly build the pytorch you should check the compute compatibility [here](https://developer.nvidia.com/cuda-gpus), and change the **TORCH_CUDA_ARCH_LIST** in Dockerfile
```=Dockerfile
#For GTX-1080Ti
TORCH_CUDA_ARCH_LIST="6.1"
```
after that, run
```=bash
cd colossalai_docker
./docker_build.sh
```
The script will build with ${USER} and your UserID, so, the container **has the permission to r/w** the volume you mount.

### Run container
```=bash
export COLOSSAL_HOME=/path/to/colossalai_repo
export COLOSSAL_EXAMPLE=/path/to/colossalai_example_repo
./docker_run.sh
```

### Install and build ColossalAI
```=bash
#In docker
cd /workspace/ColossalAI
pip3 install .
```
After that, you can run test or example on the bash of the docker container.
You can install package by pip or apt, and sudo password is your user name.
