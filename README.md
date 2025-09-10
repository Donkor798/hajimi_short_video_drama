# 哈吉米短剧（Hajimi Short Video Drama）

一个使用 Flutter 构建的短剧应用示例，采用 MVVM + Provider 架构；路由统一基于 Fluro，并通过 `NavigatorUtils` 进行页面跳转；本地数据统一迁移至 SQLite（sqflite）。

## 最近更新（关键改动）
- DatabaseHelper 重新设计：版本固定为 1，仅做全量建表初始化，移除升级/迁移逻辑（适配卸载后重装的场景）。
- 首页分类/推荐/最新：全面支持“下拉刷新 + 上拉加载更多”。
  - 使用 EasyRefresh，统一接入 ClassicHeader/ClassicFooter。
  - 分页策略：以“本次返回是否非空”为继续加载依据（后端不足页也能继续加载），返回空页即判定无更多。
- 持久化：移除 SharedPreferences 的 StorageUtils，所有数据改为通过 DatabaseHelper（settings、search_history、user_favorites、play_history）。
- 图片：统一使用 `SvCacheImage` 组件（头像/封面）。
- 架构：坚持 MVVM，使用 Provider 替代 setState；页面均补充了“页面说明 + author: Donkor + 创建日期”。

## 功能特性
- MVVM 架构 + Provider 状态管理，解耦视图与数据
- Fluro 路由（`NavigatorUtils` 统一封装跳转）
- SQLite 本地持久化：设置、搜索历史、收藏、播放历史
- 列表下拉刷新、上拉加载：EasyRefresh（已移除 pull_to_refresh）
- 图片加载与缓存：`SvCacheImage`
- 国际化 i18n：中英文（文本使用 `context.tr()`）
- 视频播放：chewie + video_player（为适配 SDK 已固定 chewie=1.7.5）

## 分页与刷新说明
- 推荐页 / 最新页：
  - 下拉刷新：重置到第 1 页并重新拉取。
  - 上拉加载：触底或继续上拉即触发下一页；若接口返回空列表，Footer 显示“没有更多”。
  - UI 始终绑定 onLoad，是否继续加载由 VM 内部的 `_hasMore` 与 `_isLoadingMore` 控制，避免 UI 停用导致无法上拉。
- 首页分类：
  - 切换分类后显示该分类的网格列表；支持下拉刷新与上拉加载更多。
  - 通过 `hasMoreCategory`（`_categoryPage < _categoryTotalPages`）控制是否还有更多。

## 目录结构
- lib/
  - constants/ 常量与配置（含 API、主题、路由常量）
  - database/ SQLite 封装（DatabaseHelper）
  - models/ 数据模型（如 Drama、Episode）
  - services/ 网络与业务服务（HTTP 封装、API Service）
  - viewmodels/ 视图模型（MVVM 的 VM 层）
  - views/ 页面（UI 层，使用 Provider 绑定 VM）
  - widgets/ 组件（如 DramaCard、SvCacheImage 等）
  - router/ Fluro 路由与 `NavigatorUtils`
  - utils/ 工具（StorageUtils 已移除）

## DatabaseHelper 说明
- 版本：1（仅初始化建表，无升级/迁移）
- 表：
  - settings（键值配置）
  - search_history（搜索历史）
  - user_favorites（收藏）
  - play_history（播放历史）
- 提供 CRUD 接口，ViewModel 直接调用。

## 路由与导航
- 使用 Fluro 声明式路由；所有页面跳转统一通过 `NavigatorUtils`。
- 示例：详情页、播放器页的参数化路由形如：`/detail/:id`、`/player/:dramaId/:episode`。

## 国际化（中/英）
- 使用 `context.tr(key)` 获取多语言文案。
- Footer/Header 文案可按需替换为自定义的 i18n 文案（目前使用 EasyRefresh 默认文案）。

## 开发环境
- Flutter SDK: 3.22.x
- Dart: 3.x

> 注意：为适配当前 SDK，`chewie` 固定在 1.7.5 版本。

## 运行与构建
```bash
# 拉取依赖
aflutter pub get

# 代码分析（可忽略部分 info/warning）
flutter analyze

# 运行到已连接设备/模拟器
flutter run

# 构建调试 APK（Android）
flutter build apk --debug
```

## 常见问题（FAQ）
1. 上拉加载无效果？
   - 已确保 UI 始终绑定 onLoad；若仍无触发，多为“首屏数据过少或容器未能触底”，请继续上拉即可触发；或检查服务端分页是否可能在中间页返回空列表。
2. 为什么不使用 SharedPreferences？
   - 为统一持久化与复杂数据结构管理，已迁移到 SQLite，便于扩展、查询与一致性管理。
3. 图片组件统一采用什么？
   - `SvCacheImage`，用于头像与封面，提供缓存与尺寸安全处理。

## 贡献
欢迎提交 Issue 或 PR 一起完善项目。

---
作者: Donkor
更新时间: 2025-09-10
