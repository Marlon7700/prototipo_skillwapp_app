import 'package:flutter/material.dart';

class BienvenidaPerfil extends StatefulWidget {
  const BienvenidaPerfil({super.key});

  @override
  State<BienvenidaPerfil> createState() => _BienvenidaPerfilState();
}

class _BienvenidaPerfilState extends State<BienvenidaPerfil> {
  // Controlamos en qué "paso" o pantalla estamos (0 = Bienvenida, 1 = Selección de Áreas, 2 = Cargando)
  int _currentStep = 0;

  // Colores corporativos basados en el diseño de SkillSwap
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color darkText = const Color(0xFF1D1B20); // Color oscuro para títulos
  final Color greyText = const Color(0xFF49454F); // Color gris para descripción

  // Áreas para la segunda pantalla
  final List<Map<String, dynamic>> _areas = [
    {'nombre': 'Techologia', 'icono': Icons.code, 'color': const Color(0xFFA5D6A7)},
    {'nombre': 'Arte y Diseño', 'icono': Icons.palette, 'color': const Color(0xFFFFCCBC)},
    {'nombre': 'Bienotas', 'icono': Icons.chat_bubble_outline, 'color': const Color(0xFFB2EBF2)},
    {'nombre': 'Negocios', 'icono': Icons.business_center, 'color': const Color(0xFFFFF9C4)},
    {'nombre': 'Bienestar', 'icono': Icons.filter_vintage, 'color': const Color(0xFFC5CAE9)},
    {'nombre': 'Música', 'icono': Icons.music_note, 'color': const Color(0xFFFFE0B2)},
    {'nombre': 'Ciencia', 'icono': Icons.science, 'color': const Color(0xFFD1C4E9)},
    {'nombre': 'Mecins', 'icono': Icons.restaurant, 'color': const Color(0xFFF8BBD0)},
  ];

  final Set<int> _selectedAreas = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fondo de pantalla
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo_SkillSwap.png',
              fit: BoxFit.cover,
            ),
          ),
          
          SafeArea(
            child: _currentStep == 0 
                ? _buildStep1() 
                : (_currentStep == 1 ? _buildStep2() : _buildLoadingScreen()),
          ),
        ],
      ),
    );
  }

  // --- PANTALLA DE CARGA ---
  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo de SkillSwap arriba
          Image.asset('assets/imagen_skillwasp.jpeg', height: 80),
          const SizedBox(height: 40),
          // Animación de carga circular con el color verde
          CircularProgressIndicator(
            color: primaryGreen,
            strokeWidth: 6,
          ),
          const SizedBox(height: 30),
          Text(
            "Preparando tu experiencia...",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Estamos personalizando SkillSwap para ti",
            style: TextStyle(color: greyText, fontSize: 16),
          ),
          const SizedBox(height: 60),
          // Versión y Autores
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                const Text(
                  "SkillSwap v1.2",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D5A4C),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Autores: SkillSwap Team",
                  style: TextStyle(
                    color: greyText,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- PRIMERA PANTALLA: BIENVENIDA ---
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader("Paso 1: Tu Base"),
          const SizedBox(height: 40),
          Text(
            "BIENVENIDO A TU\nCAMINO INTERCAMBIO \nDE HABILIDADES",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: darkText,
              height: 1.1,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/imagenes_preguntas.png', 
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Completa tu perfil para obtener las coincidencias perfectas. Te preguntaremos tus intereses para personalizar tu experiencia.",
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 16,
              color: greyText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Introduce tu nombre",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: "Tu Nombre",
              fillColor: Colors.white.withOpacity(0.8),
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Selecciona tu idioma nativo",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: const Text("Seleccionar Idioma"),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: "es", child: Text("Español 🇪🇸")),
                  DropdownMenuItem(value: "en", child: Text("Inglés 🇺🇸")),
                ],
                onChanged: (val) {},
              ),
            ),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _currentStep = 1);
              },
              style: _buttonStyle(primaryGreen),
              child: const Text("Siguiente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- SEGUNDA PANTALLA: SELECCIÓN DE CONOCIMIENTOS ---
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          _buildHeader("Paso 2: Conocimientos"),
          const SizedBox(height: 30),
          Text(
            "¿QUÉ CONOCIMIENTO\nPUEDES COMPARTIR?",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: darkText,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Selecciona hasta 5 áreas",
            style: TextStyle(fontSize: 16, color: greyText, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 30),
          
          // Grid de categorías
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: _areas.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedAreas.contains(index);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedAreas.remove(index);
                    } else if (_selectedAreas.length < 5) {
                      _selectedAreas.add(index);
                    }
                  });
                },
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryGreen.withOpacity(0.5) : _areas[index]['color'],
                        shape: BoxShape.circle,
                        border: isSelected ? Border.all(color: primaryGreen, width: 3) : null,
                      ),
                      child: Icon(_areas[index]['icono'], color: isSelected ? Colors.white : Colors.black87, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _areas[index]['nombre'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                    ),
                  ],
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Ilustración del grupo en la mesa
          Center(
            child: Image.asset(
              'assets/imsgene_intercambio.png',
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Botones Atrás y Siguiente
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() => _currentStep = 0);
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Atrás", style: TextStyle(fontSize: 16)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _currentStep = 2); // Ir a la pantalla de carga
                  
                  // Esperar 3 segundos antes de ir al Home
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  });
                },
                style: _buttonStyle(primaryGreen),
                child: const Text("Siguiente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Widget reutilizable para el logo de arriba
  Widget _buildHeader(String stepText) {
    return Row(
      children: [
        Image.asset('assets/imagen_skillwasp.jpeg', height: 30),
        const SizedBox(width: 8),
        Text(
          "SkillSwap",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
            letterSpacing: -0.5,
          ),
        ),
        const Spacer(),
        Text(
          stepText,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  // Estilo reutilizable de botones
  ButtonStyle _buttonStyle(Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      elevation: 0,
    );
  }
}
