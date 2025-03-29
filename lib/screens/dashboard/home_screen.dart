import 'package:fitness_tracker/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void logout(BuildContext context)  { 
  context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Hello, User 👋', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Daily Stats',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            _buildStatsCards(),
            SizedBox(height: 16),
            Text('Steps Progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildStepChart(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  /// Builds the fitness stats cards
  Widget _buildStatsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard('Steps', '10,234', Icons.directions_walk, Colors.blue),
        _buildStatCard(
            'Calories', '520 kcal', Icons.local_fire_department, Colors.red),
        _buildStatCard('Distance', '5.2 km', Icons.map, Colors.green),
      ],
    );
  }

  /// Builds a single fitness stat card
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// Builds a simple steps progress chart
  Widget _buildStepChart() {
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, 5000),
                FlSpot(1, 7000),
                FlSpot(2, 8000),
                FlSpot(3, 12000),
                FlSpot(4, 10000),
                FlSpot(5, 11000),
                FlSpot(6, 9000),
              ],
              isCurved: true,
              color: Colors.blue, // ✅ Fixed: Use 'color' instead of 'colors'
              barWidth: 4,
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue
                    .withValues(alpha: (0.3 * 255).toDouble()), // ✅ Fixed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
