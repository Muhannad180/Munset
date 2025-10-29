import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFC8E6C9), // Light green background
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .end, // Align text to the right for Arabic
                    children: [
                      _buildProgressChart(),
                      SizedBox(height: 24),
                      _buildLegend(),
                      SizedBox(height: 24),
                      Text(
                        'المهام', // Tasks
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildTaskCard(
                        title: 'مهام الجلسات', // Session Tasks
                        uncompleted: 1,
                        completed: 2,
                        color: Colors.lightGreen,
                      ),
                      SizedBox(height: 16),
                      _buildTaskCard(
                        title: 'عادات', // Habits
                        uncompleted: 2,
                        completed: 1,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle add task
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add, color: Colors.white, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: Colors.black),
              onPressed: () {
                // Handle back button
              },
            ),
          ),
          Text(
            'المهام', // Tasks
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              onPressed: () {
                // Handle more options
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(painter: ChartPainter()),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '65%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                'اكتمل', // Completed
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(color: Colors.red, text: 'لم تكتمل'), // Not Completed
        SizedBox(width: 16),
        _buildLegendItem(color: Colors.blue, text: 'عادات'), // Habits
        SizedBox(width: 16),
        _buildLegendItem(color: Colors.green, text: 'الجلسات'), // Sessions
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  Widget _buildTaskCard({
    required String title,
    required int uncompleted,
    required int completed,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.more_horiz, color: Colors.white),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '$completed مكتمله', // Completed
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '$uncompleted لم تكتمل', // Not completed
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 20.0;
    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2 - strokeWidth / 2;

    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    Paint greenPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint bluePaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint redPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Angles for the segments (total 2*pi for a full circle)
    double totalAngle = 2 * 3.1415926535;

    // Assuming the percentages are roughly:
    // Green: 65% (completed)
    // Blue: 20% (habits)
    // Red: 15% (not completed)

    double greenAngle = totalAngle * 0.65;
    double blueAngle = totalAngle * 0.20;
    double redAngle = totalAngle * 0.15;

    // Start drawing from the top (12 o'clock)
    double startAngle = -3.1415926535 / 2; // -pi/2 for the top

    // Green segment
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      greenAngle,
      false,
      greenPaint,
    );

    // Blue segment
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + greenAngle,
      blueAngle,
      false,
      bluePaint,
    );

    // Red segment
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + greenAngle + blueAngle,
      redAngle,
      false,
      redPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

// To run this code, you would typically use it in a main function:
void main() {
  runApp(
    MaterialApp(
      home: TasksScreen(),
      debugShowCheckedModeBanner: false, // Hide debug banner
    ),
  );
}
