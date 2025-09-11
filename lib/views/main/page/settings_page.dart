import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/localization.dart';
import '../../../widgets/gradient_app_bar.dart';
import '../../../viewmodels/settings_view_model.dart';
import '../../../commom/my_color.dart';
import '../../../commom/my_language.dart';

import '../../../router/fluro_navigator.dart';

/// 设置页面
/// 页面说明：应用设置中心，包含语言、主题、缓存等设置项
/// author : Donkor , 创建日期: 2025-09-11
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel()..init(),
      child: Scaffold(
        // 遵循主题的背景色，便于深色模式生效
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: GradientAppBar(
          titleText: context.tr('settings'),
          showBack: true,
        ),
        body: Consumer<SettingsViewModel>(
          builder: (context, vm, child) {
            if (vm.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDisplaySection(context, vm),
                const SizedBox(height: 16),
                _buildStorageSection(context, vm),
                const SizedBox(height: 16),
                _buildOtherSection(context, vm),
              ],
            );
          },
        ),
      ),
    );
  }

  /// 显示设置区域
  Widget _buildDisplaySection(BuildContext context, SettingsViewModel vm) {
    return _buildSection(
      context,
      title: context.tr('display_settings'),
      children: [
        _buildLanguageItem(context, vm),
        _buildDivider(context),
        _buildThemeColorItem(context, vm),
      ],
    );
  }



  /// 存储设置区域
  Widget _buildStorageSection(BuildContext context, SettingsViewModel vm) {
    return _buildSection(
      context,
      title: context.tr('storage_settings'),
      children: [
        _buildActionItem(
          context,
          icon: Icons.storage,
          title: context.tr('cache_size'),
          subtitle: '${vm.cacheSize.toStringAsFixed(1)} MB',
          onTap: () => _showCacheDialog(context, vm),
        ),
        _buildDivider(context),
        _buildActionItem(
          context,
          icon: Icons.clear_all,
          title: context.tr('clear_cache'),
          subtitle: context.tr('clear_app_cache'),
          onTap: () => _showClearCacheDialog(context, vm),
        ),
      ],
    );
  }

  /// 其他设置区域
  Widget _buildOtherSection(BuildContext context, SettingsViewModel vm) {
    return _buildSection(
      context,
      title: context.tr('other_settings'),
      children: [
        _buildActionItem(
          context,
          icon: Icons.restore,
          title: context.tr('reset_settings'),
          subtitle: context.tr('restore_default_settings'),
          onTap: () => _showResetDialog(context, vm),
        ),
      ],
    );
  }

  /// 构建设置区域容器
  Widget _buildSection(BuildContext context, {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  /// 语言选择项
  Widget _buildLanguageItem(BuildContext context, SettingsViewModel vm) {
    return _buildActionItem(
      context,
      icon: Icons.language,
      title: context.tr('language'),
      subtitle: vm.getLanguageDisplayName(vm.language),
      onTap: () => _showLanguageDialog(context, vm),
    );
  }

  /// 主题颜色选择项
  Widget _buildThemeColorItem(BuildContext context, SettingsViewModel vm) {
    return _buildActionItem(
      context,
      icon: Icons.palette,
      title: context.tr('theme_color'),
      subtitle: context.tr('choose_theme_color'),
      trailing: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: context.watch<MyColor>().color,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
      ),
      onTap: () => _showThemeColorDialog(context, vm),
    );
  }






  /// 操作设置项
  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// 分隔线
  Widget _buildDivider(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 56),
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }

  /// 显示语言选择对话框
  void _showLanguageDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('select_language')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, vm, 'zh', '中文'),
              _buildLanguageOption(context, vm, 'en', 'English'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBack(context),
              child: Text(context.tr('cancel')),
            ),
          ],
        );
      },
    );
  }

  /// 语言选项
  Widget _buildLanguageOption(BuildContext context, SettingsViewModel vm, String code, String name) {
    return RadioListTile<String>(
      title: Text(name),
      value: code,
      groupValue: vm.language,
      onChanged: (value) async {
        if (value != null) {
          await vm.setLanguage(value);
          // 更新全局语言设置
          if (context.mounted) {
            context.read<MyLanguage>().changeMode(value);
            NavigatorUtils.goBack(context);
          }
        }
      },
    );
  }

  /// 显示主题颜色选择对话框
  void _showThemeColorDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('select_theme_color')),
          content: SizedBox(
            width: double.maxFinite,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = vm.themeColorIndex == index;
                return GestureDetector(
                  onTap: () async {
                    await vm.setThemeColor(index);
                    // 更新全局主题颜色
                    if (context.mounted) {
                      context.read<MyColor>().setColor(index);
                      NavigatorUtils.goBack(context);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).dividerColor,
                        width: isSelected ? 3 : 1,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBack(context),
              child: Text(context.tr('cancel')),
            ),
          ],
        );
      },
    );
  }


  /// 显示缓存信息对话框
  void _showCacheDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('cache_info')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${context.tr('current_cache_size')}: ${vm.cacheSize.toStringAsFixed(1)} MB'),
              const SizedBox(height: 8),
              Text(
                context.tr('cache_description'),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBack(context),
              child: Text(context.tr('ok')),
            ),
          ],
        );
      },
    );
  }
  /// 显示清空缓存确认对话框
  void _showClearCacheDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('clear_cache')),
          content: Text(context.tr('clear_cache_confirm')),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBack(context),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () async {
                NavigatorUtils.goBack(context);
                await vm.clearCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.tr('cache_cleared'))),
                  );
                }
              },
              child: Text(context.tr('confirm'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// 显示重置设置确认对话框
  void _showResetDialog(BuildContext context, SettingsViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('reset_settings')),
          content: Text(context.tr('reset_settings_confirm')),
          actions: [
            TextButton(
              onPressed: () => NavigatorUtils.goBack(context),
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () async {

                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final myColor = context.read<MyColor>();
                final myLanguage = context.read<MyLanguage>();
                final resetMessage = context.tr('settings_reset');

                NavigatorUtils.goBack(context);

                // 重置所有设置
                await vm.resetSettings();

                // 重置全局主题设置
                myColor.setColor(0); // 重置为第一个颜色
                myLanguage.changeMode('zh'); // 重置为中文

                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text(resetMessage)),
                );
              },
              child: Text(context.tr('confirm'), style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
