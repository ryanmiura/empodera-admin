import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer
    if (index == 1) return; // Já estamos na tela do fórum
    Navigator.pop(context); // Volta para a tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Fórum',
      ),
      drawer: CustomDrawer(
        onNavigate: _handleNavigation,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Moderação do Fórum',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF663572),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // TODO: Implementar lista de tópicos do fórum
          ],
        ),
      ),
    );
  }
}
