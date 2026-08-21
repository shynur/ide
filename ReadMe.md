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

## 如何进入 container

### SSH server mode

请参考 [`/etc/systemd/system/shynur-ide.service`](./shynur-ide.service).
使用 `ssh -p 22222 root@宿主机IP` 登入.

### 直接运行

```bash
docker run -it docker.cnb.cool/shynur/ide
```

可根据需要挂载相应的文件/目录, 参考 [`/etc/systemd/system/shynur-ide.service`](./shynur-ide.service).

## 开发工具
### 前沿的工具链

[GCC](https://gcc.gnu.org/gcc-16/changes.html#cxx):

```bash
$ g++ -v
Target: x86_64-pc-linux-gnu
Thread model: posix
Supported LTO compression algorithms: zlib
gcc version 17.0.0 20260710 (experimental) (GCC)
```

[CMake](https://github.com/Kitware/CMake):

```bash
$ cmake --version
cmake version 4.4.0
```

[JFrog Conan](https://github.com/conan-io/conan):

```bash
$ conan -v
Conan version 2.30
```

[Go](https://golang.google.cn/dl/#stable):

```bash
$ go version
go version go1.26.5 linux/amd64
$ gopls version
golang.org/x/tools/gopls v0.23.0
```

[Rust](https://doc.rust-lang.org/stable/releases.html):

```bash
$ cargo version
cargo 1.97.0 (c980f4866 2026-06-30)
$ rust-analyzer --version
rust-analyzer 1.97.0 (2d8144b 2026-07-07)
```

[Emacs](https://www.gnu.org/software/emacs/#Releases):

```bash
$ emacs -version
GNU Emacs 30.2
```

## AI Coder CLI

内置 Codex / Copilot / Gemini / Claude CLI.

按照如下格式:

```json
{
  "ANTHROPIC_API_KEY": "<你的 key/token; 若 删除该行 或 值为空字符串, 则无效>",
  "OPENAI_API_KEY": "",
  "GEMINI_API_KEY": "",
  "GITHUB_TOKEN": "",
  "KIMI_ALIBABA_BAILIAN_API_KEY": ""
}
```

映射到容器内的 `/etc/shynur-ide/ai-api-keys.json` 即可自动完成注册.

> [!NOTE]
> 密钥并未存储在环境变量中.
> 仅当调用指定 AI Coder CLI 时会针对该进程设置密钥.

> [!NOTE]
> Codex / Gemini 默认使用中转站 <https://aicodemirror.com>.  <br />
> Claude 默认使用中转站 <https://llmapi.pro>.  <br />
> Kimi 使用 <https://dashscope.aliyuncs.com/compatible-mode/v1>.

## 梯子🪜

`/etc/shynur-ide/vpn.json` (这个目录放在宿主机中, 挂载到容器上):

```json
{
    "name": "XXX",
    "server": "example.com",
    "port": 443,
    "uuid": "1234-abcd",
    "servername": "www.apple.com",
    "public-key": "Abc-123",
    "short-id": "996233"
}
```

如果提供这个文件, 会自动填充到预备好的 [YAML 模板](https://github.com/shynur/HOME/blob/trunk/.config/mihomo/template.yaml) 中, 供 mihomo 使用.
如果成功用此配置启动 mihomo, 则自动设置容器内所有命令的代理.

## Web 服务

### Kimi Web

打开 <http://localhost:58628> 进入 Kimi Web 版.

<img width="2559" height="1309" alt="image" src="https://github.com/user-attachments/assets/4414f1c5-22ab-4d8d-96fd-225b286bdc47" />

### VS Code

打开 <http://localhost:28000> 进入 Web UI 版 VS Code.

<img width="2559" height="1312" alt="image" src="https://github.com/user-attachments/assets/b5d0e336-62e1-4bf3-b492-b344b2ad22c1" />

## 镜像源

软件包的源已替换成国内的镜像.
(例如, apt, npm, pip.)

____________________________

<footer>
    <small>
        Copyright &copy; 2026  <a href='https://github.com/shynur'>shynur</a> &lt;<a href='mailto:shynur@outlook.com'>shynur@outlook.com</a>&gt;.
        All rights reserved.
    </small>
</footer>
