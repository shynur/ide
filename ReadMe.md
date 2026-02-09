# 方便的 C++ 开发环境
## 终端工具
### 模糊搜索

### 提示符

#### Git Tag/Branch 提示

### 彩色补全



## 登录
### 直接运行

```bash
docker run -v ~/.git-credentials:/root/.git-credentials:ro -v ~/.gitconfig:/root/.gitconfig:ro --rm -it shynur/ide
```

### SSH

(以 TCP 端口号 22222 为例.)

在任意 shell session 执行以下命令 (之后可以关闭该 session):

```bash
docker run -d -p 22222:22 -v ~/.git-credentials:/root/.git-credentials:ro -v ~/.gitconfig:/root/.gitconfig:ro --rm \
shynur/ide `which sshd` -D
```

如果是同主机, 可以用

```bash
ssh -p 22222 root@localhost
```

或者从外部 SSH 进去.

## 开发工具

### 前沿的工具链

```bash
$ g++ -v
Target: x86_64-pc-linux-gnu
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 16.0.1 20260206 (experimental) (GCC)
```

```bash
$ conan -v
Conan version 2.25.2
```

```bash
$ cmake --version
cmake version 4.2.3
```

### 预安装的基础库

```bash
$ ls /opt
huaweicloud-sdk-cpp-v3
spdlog
```

____________________________

<footer>
    <small>
        Copyright &copy; 2026  <a href='https://github.com/shynur'>shynur</a> &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.
        All rights reserved.
    </small>
</footer>
