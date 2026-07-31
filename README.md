# 落·乾坤 (Luo Qiankun)

> **乾坤易 · 离线多端版** | 跨平台六爻排盘与易学工具

落·乾坤是一个基于 **Flutter** 开发的易学排盘工具。它源于著名的开源项目「乾坤易」，通过跨平台技术框架重构，实现了**离线运行**与**多端覆盖**（Android/iOS/Windows/macOS/Linux）。无论您在哪里，随时都能开启一场易学探索。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)

---

## ✨ 项目特点

- **🎯 完全离线**：基于本地数据库技术，无需联网即可使用全部排盘功能，保护隐私，随时随地方便使用。
- **📱 跨平台支持**：依托 Flutter 框架，一套代码完美运行在 Android、iOS、Windows、macOS、Linux 以及 Web 端。
- **📖 海量象意词典**：内嵌丰富的卦象、神煞、纳音字典，辅助用户进行深度解卦。
- **📅 黄历与日程结合**：整合传统黄历（宜忌、冲煞、吉神凶煞）与现代日程管理功能。
- **🎨 精美视觉设计**：适配双主题（深色/浅色），采用 HarmonyOS Sans 鸿蒙字体，提供舒适的阅读体验。
- **♻️ 开源免费**：遵循 MIT 协议开放源码，仅供易学爱好者和开发者学习交流。

---

## 🛠️ 技术栈 (Tech Stack)

- **跨平台 UI 框架**：`Flutter (Dart)`
- **状态管理**：`Provider`
- **本地持久化**：`Drift (SQLite)` - *实现本地排盘数据的存储与快速读写*
- **设置存储**：`SharedPreferences`
- **系统字体**：`HarmonyOS Sans` (鸿蒙字体)

---

## 📸 界面预览

*(此处建议您插入自己项目实际运行的截图，可以是深色模式排盘界面、象意字典、日历主界面等)*

---

## 🚀 快速开始 (Quick Start)

如果您想编译或运行本项目，请确保您的开发环境已配置好 Flutter SDK。

```bash
# 1. 克隆项目到本地
git clone https://github.com/您的用户名/luo-qiankun.git
cd luo-qiankun

# 2. 获取依赖包
flutter pub get

# 3. 运行项目 (以 Android 或 iOS 为例)
flutter run
```

**构建发布版 APK 或 IPA：**
```bash
# 构建 Android 安装包
flutter build apk

# 构建 iOS 安装包 (需使用 Xcode)
flutter build ios
```

---

## ❤️ 致谢与灵感

本应用在开发过程中，秉承着“致敬经典”的理念：

- 项目灵感来源于 **Gitee 开源项目「乾坤易」** 六爻排盘工具。
- 特别感谢原项目开发者 **@ihsang** 对易学工具的卓越贡献与开源精神。其 Web 版本 (hexagram.qiankunyi.com.cn) 提供了非常出色的排盘体验。
- **落·乾坤** 旨在原版基础上，利用 **Flutter** 进行重构，解决离线使用和多端跨平台的问题，延续这份为易学社区服务的初心。

- 本应用图标由 **Pixiv** 画师 **CyanAutumn** 倾情创作。独特且富有艺术气息的图标为“落·乾坤”增添了灵性。

---

## 📜 开源许可 (License)

- 本应用仅供学习交流使用，请尊重原作者版权。
- **乾坤易** 原始项目版权归原作者 **@ihsang** 所有。
- **落·乾坤** 修改版遵循 **MIT 协议** 开源。
- 完整的 MIT 许可证文本请查看项目根目录下的 `LICENSE` 文件。

---

## 🚧 开发计划 (Roadmap)

*(此处根据您自己的规划填写)*
- [ ] 支持更多排盘规则自定义
- [ ] 细化的卦辞、爻辞文言与现代白话解释
- [ ] 支持导入/导出排盘记录

---

© 2026 落·乾坤 Contributors. **Made with ❤️ for the I Ching community.** (为易经爱好者社区用心打造)
