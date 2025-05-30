import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class ComentarioScreen extends StatefulWidget {
  const ComentarioScreen({super.key});

  @override
  State<ComentarioScreen> createState() => _ComentarioScreenState();
}

class _ComentarioScreenState extends State<ComentarioScreen> {
  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer
    if (index == 3) return; // Já estamos na tela de comentários
    Navigator.pop(context); // Volta para a tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Comentários',
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
              'Moderação de Comentários',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF663572),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // TODO: Implementar lista de comentários
          ],
        ),
      ),
    );
  }
}
