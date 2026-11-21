# 安全策略 / Security policy

| 中文 | English |
| --- | --- |
| 支持的版本：只有 `master` 分支的最新版本会收到安全修复。 | Supported versions: only the latest version on the `master` branch gets security fixes. |
| 报告漏洞：请不要在公开 issue 中报告。请使用 GitHub 的 [私密漏洞报告](https://github.com/ChenYilong/CYLTableViewPlaceHolder/security/advisories/new)（Security → Report a vulnerability），写明受影响的版本、复现步骤和影响。 | Reporting a vulnerability: please do not report it in a public issue. Use GitHub's [private vulnerability reporting](https://github.com/ChenYilong/CYLTableViewPlaceHolder/security/advisories/new) (Security → Report a vulnerability), with the affected version, the steps to reproduce and the impact. |
| 如果该入口尚未开启：开一个只写“请求私下报告安全问题”、不含任何漏洞细节的 issue，维护者会提供私下联系方式。 | If that entry is not enabled yet: open an issue that only says "requesting a private channel for a security report", without any details of the vulnerability, and the maintainer will provide a private contact. |
| 处理流程：维护者确认收到后评估影响，在私密 advisory 中讨论修复，修复发布后再公开 advisory。 | Process: the maintainer confirms receipt, assesses the impact, discusses the fix in the private advisory, and publishes the advisory after the fix is released. |
| 范围：本库只在设备上绘制占位图、HUD 和刷新控件，不收集或发送数据；隐私清单见 `PrivacyInfo.xcprivacy`。第三方动画引擎（Lottie、PAG、Rive、SVGA）的漏洞请报告给各自项目。 | Scope: the library only draws placeholders, HUDs and refresh controls on the device; it neither collects nor sends data; see `PrivacyInfo.xcprivacy` for the privacy manifest. Report vulnerabilities in third-party animation engines (Lottie, PAG, Rive, SVGA) to their own projects. |
