ARG PYTHON_VERSION=3.6

FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04 as dev

# install openssh-server gdb vim git zsh build-essential cmake curl .. 
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    openssh-server \
    gdb \
    vim \
    git \
    zsh \
    build-essential \
    cmake \
    curl \
    ca-certificates \ 
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* 
    
# oh-my-zsh & language
RUN echo "Y" | sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" \
    && chsh -s `which zsh` \
    && sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="candy"/' /root/.zshrc \
    && sh -c "echo 'LC_ALL=en_US.UTF-8\nLANG=en_US.UTF-8' >> /etc/default/locale" 
    

# configure sshd server
# the root passward is 'root'
RUN mkdir /var/run/sshd \
    && echo 'root:root' | chpasswd \
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && mkdir /root/.ssh


# install pytorch
RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && chmod +x ~/miniconda.sh \
    && ~/miniconda.sh -b -p /opt/conda \
    && rm ~/miniconda.sh 

RUN /bin/echo -e "\
channels:\n\
  - defaults\n\
show_channel_urls: true\n\
default_channels:\n\
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main\n\
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r\n\
custom_channels:\n\
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud\n\
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud\n\
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud\n\
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud\n\
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud\n\
    " >> /root/.condarc 

ENV PATH /opt/conda/bin:$PATH

RUN sh -c "echo 'export PATH=/opt/conda/bin:$PATH' >> /root/.zshrc" \
    && conda install -y python=$PYTHON_VERSION numpy pyyaml scipy ipython mkl mkl-include ninja cython typing \
    && conda install -y -c pytorch magma-cuda100 \
    && conda install -y pytorch \
    && conda clean -ya


# run sshd server daemon
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
