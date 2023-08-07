import 'package:awaku/service/model/fasting_model.dart';
import 'package:awaku/src/fasting/widget/item_fasting.dart';
import 'package:flutter/material.dart';

class FastingView extends StatefulWidget {
  const FastingView({super.key});

  @override
  State<FastingView> createState() => _FastingViewState();
}

class _FastingViewState extends State<FastingView> {
  List<FastingModel> list = [
    FastingModel(id: 1, title: '14-10', start: 14, end: 10),
    FastingModel(id: 1, title: '16-8', start: 16, end: 8),
    FastingModel(id: 1, title: '18-6', start: 18, end: 6),
    FastingModel(id: 1, title: '20-4', start: 20, end: 4),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          FastingModel fasting = list[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: ItemFasting(
              color: Colors.yellow,
              icon: Icons.battery_3_bar_outlined,
              fasting: fasting,
            ),
          );
        },
      ),
    );
  }
}
