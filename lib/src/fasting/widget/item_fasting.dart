import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/src/fasting/fasting_detail.dart';
import 'package:flutter/material.dart';

class ItemFasting extends StatelessWidget {
  final FastingModel fasting;
  final IconData icon;
  final Color color;
  const ItemFasting({
    Key? key,
    required this.fasting,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FastingDetail(fasting: fasting),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fasting.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('• ${fasting.start} hours fasting',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text('• ${fasting.end} hours eating period',
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            Icon(icon, size: 50)
          ],
        ),
      ),
    );
  }
}
