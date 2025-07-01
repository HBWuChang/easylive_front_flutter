import 'package:easylive/Funcs.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../classes.dart';
import '../../controllers/PlatformPageHomeController.dart';

class PlatformPageHome extends StatefulWidget {
  const PlatformPageHome({Key? key}) : super(key: key);
  @override
  State<PlatformPageHome> createState() => _PlatformPageHomeState();
}

class _PlatformPageHomeState extends State<PlatformPageHome> {
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    print('PlatformPageHome initState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => homeController.refreshStatisticsInfo(),
        child: Icon(Icons.refresh),
        tooltip: '刷新数据',
      ),
      body: Obx(() {
        if (homeController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final statistics = homeController.statisticsInfo.value;
        if (statistics == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('暂无数据',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => homeController.refreshStatisticsInfo(),
                  child: Text('重新加载'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsCards(statistics.totalCountInfo),
              SizedBox(height: 20),
              _buildWeekChart(),
              SizedBox(height: 20),
              _buildPreDayDataCard(statistics.preDayData),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatisticsCards(TotalCountInfo totalInfo) {
    final stats = [
      {
        'title': '播放量',
        'value': totalInfo.playCount,
        'icon': Icons.play_arrow,
        'color': Colors.blue,
        'type': 0
      },
      {
        'title': '粉丝数',
        'value': totalInfo.userCount,
        'icon': Icons.people,
        'color': Colors.green,
        'type': 1
      },
      {
        'title': '评论数',
        'value': totalInfo.commentCount,
        'icon': Icons.comment,
        'color': Colors.orange,
        'type': 5
      },
      {
        'title': '弹幕数',
        'value': totalInfo.danmuCount,
        'icon': Icons.subtitles,
        'color': Colors.purple,
        'type': 6
      },
      {
        'title': '点赞数',
        'value': totalInfo.likeCount,
        'icon': Icons.thumb_up,
        'color': Colors.red,
        'type': 2
      },
      {
        'title': '收藏数',
        'value': totalInfo.collectCount,
        'icon': Icons.bookmark,
        'color': Colors.teal,
        'type': 3
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '总体数据',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            final stat = stats[index];
            return _buildStatCard(
              title: stat['title'] as String,
              value: stat['value'] as int,
              icon: stat['icon'] as IconData,
              color: stat['color'] as Color,
              dataType: stat['type'] as int,
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    required int dataType,
  }) {
    return Obx(() {
      bool isSelected = homeController.selectedDataType.value == dataType;
      return GestureDetector(
        onTap: () => homeController.changeDataType(dataType),
        child: Card(
          elevation: isSelected ? 4 : 2,
          color: isSelected ? color.withOpacity(0.1) : null,
          child: Container(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24, color: color),
                SizedBox(height: 6),
                Text(
                  _formatNumber(value),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPreDayDataCard(PreDayData preDayData) {
    final entries = preDayData.getEntries();

    if (entries.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '昨日数据',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        SizedBox(height: 16),
        Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '类型 ${entry.key}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        _formatNumber(entry.value),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekChart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '7日趋势图',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(width: 16),
            Obx(() => Text(
                  '当前显示: ${homeController.getDataTypeName(homeController.selectedDataType.value)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                )),
          ],
        ),
        SizedBox(height: 12),
        Card(
          elevation: 2,
          child: Container(
            padding: EdgeInsets.all(16),
            height: 300,
            child: Obx(() {
              if (homeController.isLoadingWeekStats.value) {
                return Center(child: CircularProgressIndicator());
              }

              final weekData = homeController.weekStats.value.data;
              if (weekData.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.show_chart, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('暂无图表数据', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return _buildLineChart(weekData);
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(List<StatisticsInfo> data) {
    if (data.isEmpty) return SizedBox.shrink();

    // 按日期分组并汇总数据
    Map<String, int> dailyData = {};
    for (var item in data) {
      String date = item.statisticsDate;
      dailyData[date] = (dailyData[date] ?? 0) + item.statisticsCount;
    }

    // 排序日期
    List<String> sortedDates = dailyData.keys.toList()..sort();

    // 生成FlSpot数据点
    List<FlSpot> spots = [];
    for (int i = 0; i < sortedDates.length; i++) {
      String date = sortedDates[i];
      double count = dailyData[date]!.toDouble();
      spots.add(FlSpot(i.toDouble(), count));
    }

    if (spots.isEmpty) return SizedBox.shrink();

    // 获取当前数据类型对应的颜色
    Color lineColor =
        _getColorForDataType(homeController.selectedDataType.value);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey[300]!,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final index = value.toInt();
                if (index >= 0 && index < sortedDates.length) {
                  final date = sortedDates[index];
                  final shortDate = date.substring(5); // MM-dd格式
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      shortDate,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                  );
                }
                return Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: null,
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    _formatNumber(value.toInt()),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey[300]!, width: 1),
        ),
        minX: 0,
        maxX: (sortedDates.length - 1).toDouble(),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: lineColor,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: lineColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: lineColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForDataType(int dataType) {
    switch (dataType) {
      case 0:
        return Colors.blue; // 播放量
      case 1:
        return Colors.green; // 用户数
      case 2:
        return Colors.red; // 点赞数
      case 3:
        return Colors.teal; // 收藏数
      case 4:
        return Colors.amber; // 硬币数
      case 5:
        return Colors.orange; // 评论数
      case 6:
        return Colors.purple; // 弹幕数
      default:
        return Colors.grey;
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}
