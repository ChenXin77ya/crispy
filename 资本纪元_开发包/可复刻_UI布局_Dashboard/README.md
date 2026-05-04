# 可复刻 UI 布局：Dashboard（Flutter）

本文件夹提供一套可直接拷贝进 Flutter 项目的 Dashboard 布局骨架（侧边栏 + 顶部搜索 + 主内容区 + 右侧信息栏），用于快速复刻你提供的 UI 结构。

## 使用方式

1. 把整个 `可复刻_UI布局_Dashboard/` 复制到你的 Flutter 工程（推荐放到：`lib/shared/components/dashboard_layout/` 或 `lib/features/home/presentation/widgets/`）。
2. 在工程里引入并打开页面：

```dart
import 'package:flutter/material.dart';
import 'dashboard_layout.dart';

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

