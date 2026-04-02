# OpenClaw for HarmonyOS

基于 OpenClaw 框架的鸿蒙原生应用，提供终端模拟器和 AI 助手功能。

## 项目结构

```
harmony-openclaw/
├── entry/                      # 主入口模块
│   └── src/
│       └── main/
│           ├── ets/            # ArkTS 源码
│           │   ├── entryability/
│           │   │   └── EntryAbility.ets
│           │   ├── pages/
│           │   │   ├── Index.ets       # 主页面
│           │   │   ├── TerminalPage.ets # 终端页面
│           │   │   └── SetupPage.ets    # 设置页面
│           │   ├── components/
│           │   │   ├── TerminalView.ets # 终端视图组件
│           │   │   ├── ExtraKeys.ets    # 额外按键组件
│           │   │   └── SessionTabs.ets  # 会话标签组件
│           │   ├── models/
│           │   │   ├── TerminalSession.ets
│           │   │   └── BootstrapManager.ets
│           │   ├── utils/
│           │   │   ├── CommandRunner.ets
│           │   │   ├── EnvironmentBuilder.ets
│           │   │   └── JsBridge.ets
│           │   └── common/
│           │       └── Constants.ets
│           ├── resources/      # 资源文件
│           │   ├── base/
│           │   │   ├── element/
│           │   │   │   ├── color.json
│           │   │   │   └── string.json
│           │   │   └── media/
│           │   └── rawfile/
│           └── module.json5
├── terminal/                   # 终端模拟器模块
│   └── src/main/
│       ├── ets/
│       │   ├── TerminalEmulator.ets
│       │   ├── TerminalView.ets
│       │   └── TerminalSession.ets
│       └── cpp/                # C++ 原生代码
│           ├── terminal.cpp
│           └── terminal_jni.cpp
├── bootstrap/                  # 引导安装模块
│   └── src/main/ets/
│       ├── BootstrapManager.ets
│       └── SetupWizard.ets
├── docs/                       # 文档
│   ├── ARCHITECTURE.md
│   ├── BUILD.md
│   └── API.md
├── build-profile.json5         # 构建配置
├── hvigorfile.ts              # 构建脚本
├── oh-package.json5           # 依赖配置
└── README.md
```

## 技术栈

- **开发语言**: ArkTS (TypeScript 扩展)
- **UI 框架**: ArkUI 声明式开发
- **终端模拟**: Native C++ + NAPI
- **状态管理**: AppStorage + LocalStorage
- **网络请求**: @ohos.net.http
- **文件系统**: @ohos.file.fs

## 核心功能

### 1. 终端模拟器
- 多会话管理
- 自定义字体和颜色
- 额外按键栏
- 复制/粘贴支持

### 2. 引导安装
- Termux bootstrap 安装
- 环境配置
- 工具安装

### 3. AI 助手集成
- OpenClaw 平台集成
- WebView 交互
- 命令执行

## 系统要求

- HarmonyOS 4.0+
- DevEco Studio 4.0+
- API Version 10+

## 构建说明

详见 [BUILD.md](docs/BUILD.md)

## 许可证

MIT License
