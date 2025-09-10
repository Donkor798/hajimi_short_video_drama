import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../utils/localization.dart';
import '../../../router/fluro_navigator.dart';
import '../../../viewmodels/search_view_model.dart';
import '../../../widgets/drama_card.dart';
import '../../../widgets/category_chip.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/error_widget.dart' as custom_widgets;
import '../main_router.dart';

/// 搜索页面
/// Author: Donkor
/// Created: 2024-12-19
class SearchPage extends StatefulWidget {
  final String? initialKeyword;

  const SearchPage({
    super.key,
    this.initialKeyword,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late SearchViewModel _viewModel;
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<SearchViewModel>();
    _searchController = TextEditingController(text: widget.initialKeyword);
    _searchFocusNode = FocusNode();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.init();
      if (widget.initialKeyword != null && widget.initialKeyword!.isNotEmpty) {
        _viewModel.searchDramas(widget.initialKeyword!);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          return Column(
            children: [
              // 搜索框
              _buildSearchBar(viewModel),
              
              // 内容区域
              Expanded(
                child: _buildContent(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        context.tr('search'),
        style: AppTextStyles.h5.copyWith(color: AppColors.textLight),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textLight),
        onPressed: () => NavigatorUtils.goBack(context),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar(SearchViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          viewModel.clearSearchResults();
                          _searchFocusNode.requestFocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  viewModel.searchDramas(value.trim());
                  _searchFocusNode.unfocus();
                }
              },
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              final keyword = _searchController.text.trim();
              if (keyword.isNotEmpty) {
                viewModel.searchDramas(keyword);
                _searchFocusNode.unfocus();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.search,
                color: AppColors.textLight,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建内容区域
  Widget _buildContent(SearchViewModel viewModel) {
    if (viewModel.isLoading) {
      return LoadingWidget(message: context.tr('loading'));
    }

    if (viewModel.hasError) {
      return custom_widgets.CustomErrorWidget(
        message: viewModel.errorMessage,
        onRetry: () => viewModel.retry(),
      );
    }

    if (viewModel.showResults) {
      return _buildSearchResults(viewModel);
    }

    return _buildSearchSuggestions(viewModel);
  }

  /// 构建搜索结果
  Widget _buildSearchResults(SearchViewModel viewModel) {
    if (!viewModel.hasResults) {
      return custom_widgets.SearchEmptyWidget(
        keyword: viewModel.currentKeyword,
        onClearSearch: () {
          _searchController.clear();
          viewModel.clearSearchResults();
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 结果标题
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${context.tr('search_result')} (${viewModel.searchResults.length})',
            style: AppTextStyles.h6,
          ),
        ),
        
        // 结果列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: viewModel.searchResults.length,
            itemBuilder: (context, index) {
              final drama = viewModel.searchResults[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: HorizontalDramaCard(
                  drama: drama,
                  onTap: () => NavigatorUtils.push(context, '${MainRouter.detailPage}/${drama.id}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 构建搜索建议
  Widget _buildSearchSuggestions(SearchViewModel viewModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 热门搜索
          Text(
            '热门搜索',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 12),
          _buildHotSearchTags(viewModel),
          
          const SizedBox(height: 24),
          
          // 搜索历史
          if (viewModel.hasHistory) ...[
            Row(
              children: [
                Text(
                  context.tr('search_history'),
                  style: AppTextStyles.h6,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showClearHistoryDialog(viewModel),
                  child: Text(
                    context.tr('clear_search_history'),
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildSearchHistory(viewModel),
          ],
        ],
      ),
    );
  }

  /// 构建热门搜索标签
  Widget _buildHotSearchTags(SearchViewModel viewModel) {
    final hotKeywords = viewModel.getHotSearchKeywords();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: hotKeywords.map((keyword) {
        return CategoryChip(
          label: keyword,
          onTap: () {
            _searchController.text = keyword;
            viewModel.searchDramas(keyword);
            _searchFocusNode.unfocus();
          },
        );
      }).toList(),
    );
  }

  /// 构建搜索历史
  Widget _buildSearchHistory(SearchViewModel viewModel) {
    return Column(
      children: viewModel.searchHistory.map((keyword) {
        return ListTile(
          leading: const Icon(
            Icons.history,
            color: AppColors.textSecondary,
          ),
          title: Text(
            keyword,
            style: AppTextStyles.bodyMedium,
          ),
          trailing: IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.textSecondary,
              size: 20,
            ),
            onPressed: () => viewModel.removeFromSearchHistory(keyword),
          ),
          onTap: () {
            _searchController.text = keyword;
            viewModel.searchFromHistory(keyword);
            _searchFocusNode.unfocus();
          },
        );
      }).toList(),
    );
  }

  /// 显示清空历史对话框
  void _showClearHistoryDialog(SearchViewModel viewModel) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清空搜索历史'),
        content: const Text('确定要清空所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        viewModel.clearSearchHistory();
      }
    });
  }
}
