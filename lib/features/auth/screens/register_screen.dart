import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  bool _isLoading = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmarSenha = false;

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Criar usuário no Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instanceFor(
        app: Firebase.app('admin-auth'),
      ).createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text.trim(),
      );

      // Adicionar informações adicionais no Firestore
      await FirebaseFirestore.instanceFor(
        app: Firebase.app('admin-auth'),
      ).collection('admin_users').doc(userCredential.user!.uid).set({
        'nome': _nomeController.text.trim(),
        'email': _emailController.text.trim(),
        'telefone': _telefoneController.text.trim(),
        'created_at': FieldValue.serverTimestamp(),
        'approved_at': null,
        'last_login': null,
        'mfa_enabled': false,
        'role': 'moderator',
        'status': 'pending',
        'uid': userCredential.user!.uid,
      });

      if (mounted) {
        _showSuccessDialog('Cadastro realizado com sucesso! Aguarde a aprovação do administrador.');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Ocorreu um erro durante o cadastro.';
      if (e.code == 'weak-password') {
        errorMessage = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'O email fornecido já está em uso.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'O email fornecido é inválido.';
      }
      _showErrorDialog(errorMessage);
    } catch (e) {
      _showErrorDialog('Erro durante o cadastro: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sucesso'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String label,
      {
        bool isPassword = false,
        bool isPhone = false,
        bool isConfirmPassword = false,
        String? Function(String?)? customValidator,
      }
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDBC8E0),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_mostrarSenha : isConfirmPassword ? !_mostrarConfirmarSenha : false,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(11),
        ] : null,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          suffixIcon: isPassword || isConfirmPassword
              ? IconButton(
            icon: Icon(
              (isPassword ? _mostrarSenha : _mostrarConfirmarSenha)
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                if (isPassword) {
                  _mostrarSenha = !_mostrarSenha;
                } else {
                  _mostrarConfirmarSenha = !_mostrarConfirmarSenha;
                }
              });
            },
          )
              : null,
        ),
        validator: customValidator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, preencha este campo';
          }
          if (label == 'Email' && !value.contains('@')) {
            return 'Por favor, insira um email válido';
          }
          if (isPhone && value.length < 10) {
            return 'Telefone inválido';
          }
          if (isPassword && value.length < 6) {
            return 'A senha deve ter pelo menos 6 caracteres';
          }
          if (isConfirmPassword && value != _senhaController.text) {
            return 'As senhas não coincidem';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EEE2),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),
                  Image.asset(
                    'assets/logo_horizontal.png',
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Registro de Moderador',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD13B83),
                      fontFamily: 'Crewniverse',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Após o cadastro, aguarde a aprovação do administrador',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontFamily: 'Inter',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _buildInputField(_nomeController, 'Nome completo'),
                  _buildInputField(_emailController, 'Email'),
                  _buildInputField(
                    _telefoneController,
                    'Telefone (apenas números)',
                    isPhone: true,
                  ),
                  _buildInputField(
                    _senhaController,
                    'Senha',
                    isPassword: true,
                  ),
                  _buildInputField(
                    _confirmarSenhaController,
                    'Confirmar senha',
                    isConfirmPassword: true,
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD13B83),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'REGISTRAR',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'Crewniverse',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Já possuo uma conta',
                      style: TextStyle(
                        color: Color(0xFFD13B83),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }
}
