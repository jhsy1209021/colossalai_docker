FROM nvidia/cuda:11.0.3-devel-ubuntu20.04

ARG UID=1000
ARG GID=1000
ARG NAME=base

RUN mkdir -p /workspace/ColossalAI
WORKDIR /workspace

# Change time zone
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata locales
RUN TZ=Asia/Taipei \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata \
    && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

#Install necessary packages
RUN DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y build-essential python3 python3-pip git wget sudo

#Make a non-root user
RUN groupadd -g $GID -o $NAME \
    && useradd -u $UID -m -g $NAME -G plugdev $NAME \
	&& usermod -aG sudo $NAME
RUN adduser $NAME sudo \
    && echo "$NAME:$NAME" | chpasswd

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
RUN PATH=${PATH}:/home/${NAME}/.local/bin python3 setup.py develop

WORKDIR /workspace
#Install correspond torchvision(0.14.0)
RUN wget https://github.com/pytorch/vision/archive/refs/tags/v0.14.0.tar.gz \
    && tar -zxvf v0.14.0.tar.gz \
    && cd vision-0.14.0 \
    && FORCE_CUDA=1 sudo python3 setup.py install

RUN rm pytorch-v1.13.0.tar.gz && rm v0.14.0.tar.gz

# Change the owner of /workspace
RUN chown -R $NAME:$NAME /home/$NAME \
    && chown -R $NAME:$NAME /workspace
#*********Change User*********#
USER $NAME
#*********Change User*********#

#Install ColossalAI model zoo package
RUN pip3 install --no-deps titans

#setup bash
RUN /bin/cp /etc/skel/.bashrc ~/
RUN echo "export PS1=\"\[\e[0;31m\]\u@\[\e[m\e[0;34m\]\h\[\e[m \e[0;32m\] \w[\!]\$\[\e[m\]  \"" >> ~/.bashrc
# Setup PATH for python package
RUN echo "export PATH=\${PATH}:${HOME}/.local/bin" >> ~/.bashrc

CMD ["/bin/bash"]