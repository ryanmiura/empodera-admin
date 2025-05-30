import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer atual
    if (index == 5) {
      // Já estamos na tela de usuários
      return;
    }
    Navigator.pop(context); // Volta para a tela anterior
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Gestão de Usuários',
      ),
      drawer: CustomDrawer(
        onNavigate: _handleNavigation,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TODO: Implementar lista de usuários
          ],
        ),
      ),
    );
  }
}
