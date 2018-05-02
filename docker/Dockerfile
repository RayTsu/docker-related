#ImageName: ccloud-registry.huawei.com/ccloud-centos7
#ImageVersion: v1.0
#ImageResourceDir: docker-build-slave:/app/docker-images/ccloud-centos7-image

FROM ccloud-registry.huawei.com/centos:centos7.1.1503

RUN rm -rf /etc/yum.repos.d/*
COPY config/CentOS-7-x64.repo /etc/yum.repos.d/
RUN yum -y install \
    git tar make hostname unzip \
    gcc glibc glibc-common gd gd-devel cronie ld-linus.so.2 && \
    yum clean all
ADD soft/jdk-8u60-linux-x64.gz /usr/local/
ENV JAVA8_HOME /usr/local/jdk1.8.0_60
ENV JAVA_HOME /usr/local/jdk1.8
RUN ln -s $JAVA8_HOME $JAVA_HOME
ENV PATH $JAVA_HOME/bin:$PATH

WORKDIR /app
STOPSIGNAL SIGINT

ADD start.sh /app/start.sh
ADD wait_fot_all_jobs_done.sh /app/wait_fot_all_jobs_done.sh
RUN chmod +x /app/* && \
    echo "Asia/Shanghai" > /etc/timezone && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime


ENTRYPOINT ["/app/start.sh"]
