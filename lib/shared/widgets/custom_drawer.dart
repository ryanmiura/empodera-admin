import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onNavigate;
  final AuthService _authService = AuthService();

  CustomDrawer({
    super.key,
    required this.onNavigate,
  });

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black87,
        ),
      ),
      onTap: () => onNavigate(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(_authService.currentUser?.email ?? 'Moderador'),
            accountEmail: const Text('Painel de Moderação'),
            currentAccountPicture: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person, color: Color(0xFF663572)),
                            title: const Text('Meu Perfil'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Implementar navegação para perfil
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF663572)),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF663572)),
            title: const Text('Perfil'),
            onTap: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
          _buildMenuItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            index: 0,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'MODERAÇÃO',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.forum,
            title: 'Fórum',
            index: 1,
          ),
          _buildMenuItem(
            icon: Icons.card_giftcard,
            title: 'Doações',
            index: 2,
          ),
          _buildMenuItem(
            icon: Icons.comment,
            title: 'Comentários',
            index: 3,
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'GESTÃO',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.warning,
            title: 'Denúncias',
            index: 4,
          ),
          _buildMenuItem(
            icon: Icons.people,
            title: 'Usuários',
            index: 5,
          ),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Configurações',
            index: 6,
          ),
        ],
      ),
    );
  }
} 