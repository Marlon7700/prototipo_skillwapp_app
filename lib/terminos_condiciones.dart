import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  _TermsAndConditionsScreenState createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  bool _hasAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Aspectos Legales', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Fondo de la aplicación
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo_SkillSwap.png',
              fit: BoxFit.cover,
            ),
          ),
          // Capa de difuminado o semitransparente para legibilidad
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Icon(Icons.verified_user_rounded, size: 70, color: Color(0xFF6BCE7A)),
                          ),
                          const SizedBox(height: 15),
                          const Center(
                            child: Text(
                              'Compromiso SkillSwap',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Tu seguridad y privacidad son nuestra prioridad.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700], fontStyle: FontStyle.italic),
                            ),
                          ),
                          const Divider(height: 40, thickness: 1.2),
                          _buildSectionTitle('1. El intercambio de conocimiento'),
                          _buildBodyText(
                            'SkillSwap es una comunidad basada en la confianza. Al usar esta plataforma, te comprometes a compartir tus habilidades de manera honesta y respetuosa con los demás usuarios.'
                          ),
                          _buildSectionTitle('2. Tus Datos están Seguros'),
                          _buildBodyText(
                            'Utilizamos "datos condicionales" (como tu ubicación aproximada y preferencias de aprendizaje) para conectarte con los mejores perfiles cerca de ti. Estos datos nunca serán vendidos a terceros.'
                          ),
                          _buildSectionTitle('3. Reglas de Convivencia'),
                          _buildBodyText(
                            'Cualquier comportamiento abusivo, spam o uso indebido de las herramientas de IA resultará en la suspensión inmediata de la cuenta. Queremos un ambiente de crecimiento mutuo.'
                          ),
                          _buildSectionTitle('4. Uso de la IA'),
                          _buildBodyText(
                            'Nuestra IA está diseñada para asistirte, no para sustituir el intercambio humano. Los datos generados en el chat de IA se utilizan para mejorar tus sugerencias de habilidades.'
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildAcceptancePanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00A99D)),
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
    );
  }

  Widget _buildAcceptancePanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CheckboxListTile(
            value: _hasAccepted,
            activeColor: const Color(0xFF6BCE7A),
            title: const Text(
              'He leído y acepto los términos de compromiso y privacidad.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onChanged: (value) => setState(() => _hasAccepted = value!),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A99D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _hasAccepted ? () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).set({
                    'terminosAceptados': true,
                    'fechaAceptacionTerminos': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                }
                if (!mounted) return;
                Navigator.pop(context, true);
              } : null,
              child: const Text('EMPEZAR AHORA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
            ),
          ),
        ],
      ),
    );
  }
}
