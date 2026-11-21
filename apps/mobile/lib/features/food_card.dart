import 'package:material_ui/material_ui.dart';

import '../domain/companion_food.dart';
import 'garden.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.food,
    required this.affinity,
    required this.action,
    this.count,
  });

  final CompanionFood food;
  final int affinity;
  final Widget action;
  final int? count;

  @override
  Widget build(BuildContext context) => GardenCard(
    child: Row(
      children: [
        CustomPaint(size: const Size.square(46), painter: _FoodPainter(food)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count == null ? food.label : '${food.label} × $count',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text('亲密度 +$affinity', style: const TextStyle(color: mutedInk)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 144),
          child: action,
        ),
      ],
    ),
  );
}

class _FoodPainter extends CustomPainter {
  const _FoodPainter(this.food);

  final CompanionFood food;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 48, size.height / 48);
    final paint = Paint();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 48, 48),
        const Radius.circular(14),
      ),
      paint..color = const Color(0xFFF6E8D4),
    );
    switch (food) {
      case CompanionFood.candy:
        canvas.save();
        canvas.translate(24, 24);
        canvas.rotate(-0.28);
        final wrappers = Path()
          ..moveTo(-10, 0)
          ..lineTo(-18, -6)
          ..quadraticBezierTo(-21, 0, -18, 6)
          ..close()
          ..moveTo(10, 0)
          ..lineTo(18, -6)
          ..quadraticBezierTo(21, 0, 18, 6)
          ..close();
        canvas.drawPath(wrappers, paint..color = const Color(0xFFBC7385));
        canvas.drawOval(
          const Rect.fromLTWH(-12, -9, 24, 18),
          paint..color = const Color(0xFFD18B9B),
        );
        canvas.drawOval(
          const Rect.fromLTWH(-7, -6, 10, 4),
          paint..color = const Color(0xFFF9DCE0),
        );
        canvas.restore();
      case CompanionFood.cookie:
        canvas.drawCircle(
          const Offset(24, 25),
          15,
          paint..color = const Color(0xFFA66A3D),
        );
        canvas.drawCircle(
          const Offset(24, 23),
          14,
          paint..color = const Color(0xFFDCAB6D),
        );
        paint.color = const Color(0xFF825538);
        for (final chip in const [
          Offset(18, 18),
          Offset(28, 16),
          Offset(25, 24),
          Offset(16, 28),
          Offset(30, 30),
        ]) {
          canvas.drawCircle(chip, 2, paint);
        }
      case CompanionFood.pudding:
        canvas.drawOval(
          const Rect.fromLTWH(5, 31, 38, 9),
          paint..color = const Color(0xFFD9A99D),
        );
        final custard = Path()
          ..moveTo(13, 17)
          ..quadraticBezierTo(11, 25, 10, 32)
          ..quadraticBezierTo(24, 39, 38, 32)
          ..lineTo(35, 17)
          ..close();
        canvas.drawPath(custard, paint..color = const Color(0xFFEEC06F));
        canvas.drawOval(
          const Rect.fromLTWH(13, 12, 22, 10),
          paint..color = const Color(0xFF9D5936),
        );
        canvas.drawOval(
          const Rect.fromLTWH(18, 14, 9, 3),
          paint..color = const Color(0xFFCC8961),
        );
    }
  }

  @override
  bool shouldRepaint(_FoodPainter oldDelegate) => food != oldDelegate.food;
}
