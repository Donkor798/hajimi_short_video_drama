import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '../../router/i_router.dart';
import 'fragment/home_fragment.dart';
import 'page/search_page.dart';
import 'page/hot_page.dart';
import 'page/latest_page.dart';
import 'page/recommend_page.dart';
import 'page/drama_detail_page.dart';
import '../../models/drama.dart';
import 'page/player_page.dart';

/// 主模块路由
/// author : Donkor , 创建日期: 2025-09-10
class MainRouter implements IRouterProvider{

  // 路由路径常量
  static String mainPage = '/main';
  static String searchPage = '/search';
  static String hotPage = '/hot';
  static String latestPage = '/latest';
  static String recommendPage = '/recommend';
  static String detailPage = '/detail'; // 使用 /detail/:id 形式
  static String playerPage = '/player'; // 使用 /player/:dramaId/:episode 形式

  @override
  void initRouter(FluroRouter router) {
    // 主页（这里直接进入 HomePage）
    router.define(mainPage, handler: Handler(handlerFunc: (_, __) => const HomeFragment()));

    // 搜索页（可通过 arguments 传 initialKeyword）
    router.define(searchPage, handler: Handler(handlerFunc: (context, params) {
      final keyword = context?.settings?.arguments as String?;
      return SearchPage(initialKeyword: keyword);
    }));

    // 列表页
    router.define(hotPage, handler: Handler(handlerFunc: (_, __) => const HotPage()));
    router.define(latestPage, handler: Handler(handlerFunc: (_, __) => const LatestPage()));
    router.define(recommendPage, handler: Handler(handlerFunc: (_, __) => const RecommendPage()));

    // 详情页：优先使用 arguments 传入的 Drama，其次使用 path 参数 id
    router.define('$detailPage/:id', handler: Handler(handlerFunc: (context, params) {
      final argDrama = context?.settings?.arguments as Drama?;
      if (argDrama != null) {
        return DramaDetailPage(drama: argDrama);
      }
      final idStr = params['id']?.first;
      final id = int.tryParse(idStr ?? '') ?? 0;
      final placeholder = Drama(id: id, name: '', cover: '', updateTime: '', score: 0);
      return DramaDetailPage(drama: placeholder);
    }));

    // 详情页（无 path 参数，完全依赖 arguments）
    router.define(detailPage, handler: Handler(handlerFunc: (context, params) {
      final argDrama = context?.settings?.arguments as Drama?;
      final drama = argDrama ?? Drama(id: 0, name: '', cover: '', updateTime: '', score: 0);
      return DramaDetailPage(drama: drama);
    }));

    // 播放页：/player/:dramaId/:episode ；通过 arguments 传入 {drama, videoUrl}
    router.define('$playerPage/:dramaId/:episode', handler: Handler(handlerFunc: (context, params) {
      final dramaId = int.tryParse(params['dramaId']?.first ?? '') ?? 0;
      final episode = int.tryParse(params['episode']?.first ?? '') ?? 1;

      final arg = context?.settings?.arguments;
      Drama? argDrama;
      String? videoUrl;
      if (arg is Map) {
        argDrama = arg['drama'] as Drama?;
        videoUrl = arg['videoUrl'] as String?;
      } else if (arg is Drama) {
        argDrama = arg;
      }

      final drama = argDrama ?? Drama(id: dramaId, name: '', cover: '', updateTime: '', score: 0);
      return PlayerPage(drama: drama, episodeNumber: episode, videoUrl: videoUrl);
    }));
  }
}
