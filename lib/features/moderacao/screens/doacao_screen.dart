import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class DoacaoScreen extends StatefulWidget {
  const DoacaoScreen({super.key});

  @override
  State<DoacaoScreen> createState() => _DoacaoScreenState();
}

class _DoacaoScreenState extends State<DoacaoScreen> {
  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer
    if (index == 2) return; // Já estamos na tela de doações
    Navigator.pop(context); // Volta para a tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Doações',
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
              'Moderação de Doações',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF663572),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            // TODO: Implementar lista de doações
          ],
        ),
      ),
    );
  }
}
