# 基础镜像使用Ubuntu 20.04
FROM ubuntu:20.04

# 避免交互模式下的配置提示
ENV DEBIAN_FRONTEND=noninteractive

# 更新系统并安装依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libgrpc-dev \
    libprotobuf-dev \
    protobuf-compiler-grpc \
    libabsl-dev \
    && rm -rf /var/lib/apt/lists/*

# 安装cpp-httplib（轻量级HTTP库，单头文件）
RUN git clone https://github.com/yhirose/cpp-httplib.git /usr/local/include/cpp-httplib \
    && ln -s /usr/local/include/cpp-httplib/httplib.h /usr/local/include/httplib.h

# 创建工作目录
WORKDIR /app

# 复制项目文件到容器（排除.gitignore中的内容）
COPY . .

# 创建构建目录并编译项目
RUN mkdir -p build && cd build \
    && cmake .. -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc)

# 暴露HTTP端口（2000）和RPC端口（3000）
EXPOSE 2000 3000

# 容器启动时运行SDCS服务
CMD ["/app/build/bin/SDCS"]