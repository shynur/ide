# 通用开发环境

> [!TIP]
> Docker 镜像在多个站点皆可用:
> - [`shynur/ide`](https://hub.docker.com/r/shynur/ide)
> - [`docker.cnb.cool/shynur/ide`](https://docker.cnb.cool/shynur/ide)

> [!TIP]
> 支持的 platform:
> - `linux/amd64`
> - `linux/arm64`
>
> (示例仅从 `linux/amd64` 平台摘取.)

## 终端工具
### 模糊搜索

按下 <kbd>Ctrl</kbd>-<kbd>t</kbd>:

<img width="2536" height="1263" alt="Image" src="https://github.com/user-attachments/assets/29403b51-b9b3-41c3-a057-a1ac77130488" />

### 提示符

<img width="2529" height="243" alt="Image" src="https://github.com/user-attachments/assets/6710b3b5-ab44-45b2-b728-2086ae133719" />

- 上一条命令的退出码
- 后台任务的数量
- CPU 负载: 上限 = 100% x CPU 核心数
- 内存 与 swap 占用
- 当前 session 下流逝的时间
- CPU 运行在 user/kernel-mode 的时间: 递归计算 subprocess
- 在某些目录下显示当前目录下所有文件的磁盘占用
- 当前是 bash 执行的第几条命令
- 当前 Git 仓库的 tag/branch

### 花哨的补全

<img width="2280" height="184" alt="Image" src="https://github.com/user-attachments/assets/1868e98d-a212-4e54-8622-f9044071b7be" />

- 显示彩色
- 根据文件类型显示后缀

## 登录

(以下以 latest 版本为例, 但实际开发应使用 git tag 列出的版本.)

### 直接运行

```bash
docker run  \
  --rm -it                                         \
  -v ~/.git-credentials:/root/.git-credentials:ro  \
  -v /etc/shynur-ide/:/etc/shynur-ide/:ro          \
  -v ~/.conan2/p/:/root/.conan2/p/                 \
  docker.cnb.cool/shynur/ide
```

### SSH

(以 TCP 端口号 22222 为例.)

在任意 shell session 执行以下命令 (之后可以关闭该 session):

```bash
docker run  \
  --rm -d                                          \
  -p 22222:22                                      \
  -v ~/.git-credentials:/root/.git-credentials:ro  \
  -v ~/.conan2/p/:/root/.conan2/p/                 \
  -v /etc/shynur-ide/:/etc/shynur-ide/:ro          \
  docker.cnb.cool/shynur/ide /usr/sbin/sshd -D
```

如果是同主机, 可以用

```bash
ssh -p 22222 root@localhost
```

或者从外部 SSH 进去.

### systemd

开机时自动更新 image 并启动它作为 SSH server.
See [`/etc/systemd/system/shynur-ide.service`](./shynur-ide.service).

## 开发工具
### 前沿的工具链

[GCC](https://gcc.gnu.org/gcc-16/changes.html#cxx):

```bash
$ g++ -v
Target: x86_64-pc-linux-gnu
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 16.0.1 20260323 (experimental) (GCC)
```

[CMake](https://github.com/Kitware/CMake):

```bash
$ cmake --version
cmake version 4.3.0
```

[JFrog Conan](https://github.com/conan-io/conan):

```bash
$ conan -v
Conan version 2.26.2
```

[Go](https://golang.google.cn/dl/#stable):

```bash
$ go version
go version go1.26.1 linux/amd64
$ gopls version
golang.org/x/tools/gopls v0.21.1
```

[Rust](https://doc.rust-lang.org/stable/releases.html):

```bash
$ cargo version
cargo 1.94.0 (85eff7c80 2026-01-15)
$ rust-analyzer --version
rust-analyzer 1.94.0 (4a4ef49 2026-03-02)
```

Emacs:

```bash
$ emacs -version
GNU Emacs 29.3
```

## AI Coder CLI

内置 Codex / Copilot / Gemini / Claude CLI.

按照如下格式:

```json
{
  "ANTHROPIC_API_KEY": "<你的 key/token; 若 删除该行 或 值为空字符串, 则无效>",
  "OPENAI_API_KEY": "",
  "GEMINI_API_KEY": "",
  "GITHUB_TOKEN": ""
}
```

映射到容器内的 `/etc/shynur-ide/ai-api-keys.json` 即可自动完成注册.

> [!NOTE]
> 密钥并未存储在环境变量中.
> 仅当调用指定 AI Coder CLI 时会针对该进程设置密钥.

> [!NOTE]
> Codex / Gemini / Claude 默认使用中转站 <https://aicodemirror.com>.

____________________________

<footer>
    <small>
        Copyright &copy; 2026  <a href='https://github.com/shynur'>shynur</a> &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.
        All rights reserved.
    </small>
</footer>
