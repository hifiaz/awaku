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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Intermittent Fasting',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.1),
                    const Color(0xFF059669).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      size: 40,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Choose Your Fasting Plan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select an intermittent fasting schedule that fits your lifestyle',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Fasting Plans Section
            Text(
              'Popular Plans',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Fasting Plans List
            ...list.asMap().entries.map((entry) {
              final index = entry.key;
              final fasting = entry.value;
              final gradients = [
                [const Color(0xFF667EEA), const Color(0xFF764BA2)],
                [const Color(0xFF10B981), const Color(0xFF059669)],
                [const Color(0xFFFF9A8B), const Color(0xFFFECFEF)],
                [const Color(0xFF667EEA), const Color(0xFF764BA2)],
              ];
              final icons = [
                Icons.timer_outlined,
                Icons.schedule_rounded,
                Icons.access_time_rounded,
                Icons.timer_3_rounded,
              ];
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ItemFasting(
                  fasting: fasting,
                  gradient: LinearGradient(
                    colors: gradients[index % gradients.length],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: icons[index % icons.length],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 24),
            
            // Info Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'How it works',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Intermittent fasting involves cycling between periods of eating and fasting. Choose a plan that matches your schedule and gradually build the habit.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
