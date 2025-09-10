import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../commom/my_color.dart';
import 'fluro_navigator.dart';
import '../views/main/main_router.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          '未找到页面',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.watch<MyColor>().colorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 404图标
              _buildNotFoundIcon(context),
              const SizedBox(height: 32),

              // 主标题
              Text(
                '404',
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.bold,
                  color: context.watch<MyColor>().colorPrimary,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 16),

              // 副标题
              Text(
                '未找到页面',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // 描述文本
              Column(
                children: [
                  Text(
                    '抱歉，您访问的页面不存在',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '您可以返回首页继续浏览',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),

              // 操作按钮
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // 404图标组件 - 现代化和动态效果
  Widget _buildNotFoundIcon(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            context.watch<MyColor>().colorPrimary.withOpacity(0.1),
            context.watch<MyColor>().colorPrimary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(110),
        boxShadow: [
          BoxShadow(
            color: context.watch<MyColor>().colorPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景圆圈 - 动画效果
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.watch<MyColor>().colorPrimary.withOpacity(0.2),
                  context.watch<MyColor>().colorPrimary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(85),
            ),
          ),
          // 主图标 - 用户友好图标
          Icon(
            Icons.explore_off_rounded,
            size: 90,
            color: context.watch<MyColor>().colorPrimary,
          ),
          // 装饰元素 - 彩色圆点
          Positioned(
            top: 25,
            right: 35,
            child: _buildDecorativeDot(Colors.orange, 24),
          ),
          Positioned(
            bottom: 35,
            left: 35,
            child: _buildDecorativeDot(Colors.blue, 18),
          ),
          Positioned(
            top: 60,
            left: 25,
            child: _buildDecorativeDot(Colors.green, 14),
          ),
          Positioned(
            bottom: 60,
            right: 25,
            child: _buildDecorativeDot(Colors.purple, 16),
          ),
          // 添加星星装饰
          Positioned(
            top: 45,
            right: 60,
            child: Icon(
              Icons.star,
              size: 12,
              color: Colors.yellow.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 60,
            child: Icon(
              Icons.star,
              size: 10,
              color: Colors.pink.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // 装饰圆点组件
  Widget _buildDecorativeDot(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  // 操作按钮组件
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // 返回首页按钮
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              NavigatorUtils.pushAndRemoveUntil(context, MainRouter.mainPage);
            },
            icon: const Icon(Icons.home, color: Colors.white),
            label: Text(
              '返回首页',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.watch<MyColor>().colorPrimary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 返回上一页按钮
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                NavigatorUtils.goBack(context);
              } else {
                NavigatorUtils.pushAndRemoveUntil(context, MainRouter.mainPage);
              }
            },
            icon: Icon(
              Icons.arrow_back,
              color: context.watch<MyColor>().colorPrimary,
            ),
            label: Text(
              '返回上一页',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.watch<MyColor>().colorPrimary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: context.watch<MyColor>().colorPrimary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
