FROM centos:7
LABEL maintainer "Fabric8 <fabric8@googlegroups.com>"
LABEL author "Konrad Kleine <kkleine@redhat.com>"
ENV LANG=en_US.utf8

# Some packages might seem weird but they are required by the RVM installer.
RUN yum --enablerepo=centosplus install -y --quiet \
    findutils \
    git \
    golang \
    make \
    mercurial \
    procps-ng \
    tar \
    wget \
    which \
    && yum clean all

# Create a non-root user and a group with the same name: "test"
ENV F8_USER_NAME=test
RUN useradd -s /bin/bash ${F8_USER_NAME}

# From here onwards, any RUN, CMD, or ENTRYPOINT will be run under the following user
USER ${F8_USER_NAME}

# Setup the GOPATH
ENV GOPATH=/home/${F8_USER_NAME}/go
RUN mkdir -p ${GOPATH}/bin

# Setup install prefix
ENV F8_INSTALL_PREFIX=${GOPATH}/src/github.com/fabric8-services/fabric8-apitest
RUN mkdir -p ${F8_INSTALL_PREFIX}
WORKDIR ${F8_INSTALL_PREFIX}

# Get glide for Go package management
RUN cd /tmp \
    && wget https://github.com/Masterminds/glide/releases/download/v0.13.1/glide-v0.13.1-linux-amd64.tar.gz \
    && tar xzf glide-v*.tar.gz \
    && mv linux-amd64/glide ${GOPATH}/bin \
    && rm -rfv glide-v* linux-amd64

# COPY . ${F8_INSTALL_PREFIX}
# RUN make deps
# RUN make generate

ENTRYPOINT ["/bin/bash"]