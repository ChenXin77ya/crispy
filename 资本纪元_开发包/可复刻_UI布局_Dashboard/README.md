# 可复刻 UI 布局：Dashboard（Flutter）

本文件夹提供一套可直接拷贝进 Flutter 项目的 Dashboard 布局骨架（侧边栏 + 顶部搜索 + 主内容区 + 右侧信息栏），用于快速复刻你提供的 UI 结构。

## 使用方式

1. 把本文件夹里的 `lib/` 内容复制到你的 Flutter 工程中（推荐目标：`lib/shared/components/dashboard_layout/`）。
2. 在工程里引入并打开页面（按你的工程目录调整 import 路径）：

```dart
import 'package:flutter/material.dart';
import 'shared/components/dashboard_layout/dashboard_layout.dart';

class DashboardDemoPage extends StatelessWidget {
  const DashboardDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardLayoutPage();
  }
}
```

## 适配策略

- 宽屏（默认阈值：1100px）：左侧导航 + 中间主内容 + 右侧信息栏三栏布局
- 窄屏：右侧信息栏下移到主内容下方，左侧导航变为抽屉

你可以在 `dashboard_layout.dart` 里调整 `breakpointWide` 来匹配项目的 Web/Pad 断点。
