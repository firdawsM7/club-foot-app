import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CotisationsScreen extends StatelessWidget {
  const CotisationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cotisations')),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.getGradient(context)),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 80, color: AppTheme.masYellow),
              const SizedBox(height: 24),
              const Text('Gestion des Cotisations', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.masYellow)),
              const SizedBox(height: 12),
              Text(
                'Fonctionnalité en cours de développement', 
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))
              ),
            ],
          ),
        ),
      ),
    );
  }
}
