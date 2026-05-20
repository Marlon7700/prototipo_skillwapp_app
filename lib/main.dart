import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'login.dart';
import 'Interfaz_IA.dart';
import 'ventana_perfil.dart';
import 'bienvenida_perfil.dart';
import 'mis_archivos.dart';
import 'chat_screen.dart';
import 'terminos_condiciones.dart';
import 'calificaciones.dart';
import 'tutores_favoritos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDh4LU3VSh02Hfk7xUR6fDl6F7SWIRrKpk",
          authDomain: "skillswapp-b7fc0.firebaseapp.com",
          projectId: "skillswapp-b7fc0",
          storageBucket: "skillswapp-b7fc0.firebasestorage.app",
          messagingSenderId: "141826962219",
          appId: "1:141826962219:web:a9e4fb7613e727e7344b6e",
          databaseURL: "https://skillswapp-b7fc0-default-rtdb.firebaseio.com/",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }
  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6BCE7A),
          primary: const Color(0xFF6BCE7A),
          secondary: const Color(0xFF00A99D),
        ),
        primaryColor: const Color(0xFF6BCE7A),
        scaffoldBackgroundColor: const Color(0xFFFAFDFB),
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/ai': (context) => const InterfazIA(),
        '/perfil': (context) => const ventana_perfil(),
        '/archivos': (context) => const MisArchivosScreen(),
        '/bienvenida': (context) => const BienvenidaPerfil(),
        '/terminos': (context) => const TermsAndConditionsScreen(),
        '/calificaciones': (context) => const CalificacionesScreen(),
        '/favoritos': (context) => const TutoresFavoritosScreen(),
      },
    );
  }
}

// ✅ Widget optimizado para mostrar imágenes Base64 sin recalcular cada vez
class Base64Image extends StatefulWidget {
  final String base64Data;
  final BoxFit fit;
  final double? width;
  final double? height;

  const Base64Image({
    super.key,
    required this.base64Data,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  State<Base64Image> createState() => _Base64ImageState();
}

class _Base64ImageState extends State<Base64Image> {
  late Uint8List _bytes;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(Base64Image oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.base64Data != widget.base64Data) {
      _decode();
    }
  }

  void _decode() {
    try {
      _bytes = base64Decode(widget.base64Data);
      _error = false;
    } catch (e) {
      _error = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Icon(Icons.person, color: Colors.grey),
      );
    }
    return Image.memory(
      _bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) => Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[200],
        child: const Icon(Icons.person, color: Colors.grey),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Paleta visual SkillSwap (solo UI)
  static const Color _primaryGreen = Color(0xFF6BCE7A);
  static const Color _teal = Color(0xFF00A99D);
  static const Color _darkText = Color(0xFF334A5F);
  static const Color _mutedText = Color(0xFF8A9BA8);
  static const Color _lightGreenBg = Color(0xFFE8F8EC);
  static const double _radiusLg = 24.0;
  static const double _radiusPill = 30.0;

  // Controlador de búsqueda
  final TextEditingController _searchController = TextEditingController();
  final String _searchQuery = "";
  final bool _filterByPeople = true;
  final bool _filterBySkills = false;
  final String _currentSort = "Conexión"; // Opción seleccionada por defecto

  // Controladores para las animaciones del bot
  late AnimationController _botAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  // Controladores para la animación del globo de texto
  late AnimationController _bubbleAnimationController;
  late Animation<double> _bubbleOpacityAnimation;
  late Animation<double> _bubbleScaleAnimation;
  bool _showGreeting = false;

  // Animación de la mano
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _updatePresence();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // -- Campo de Configuración de la animación del Bot
    _botAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Repetir infinitamente

    // Animación de escala (pulso)
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _botAnimationController, curve: Curves.easeInOut),
    );

    // Animación de opacidad del brillo
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _botAnimationController, curve: Curves.easeInOut),
    );

    // --- Configuración animación del Globo de Saludo ---
    _bubbleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bubbleOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _bubbleAnimationController, curve: Curves.easeIn),
    );

    _bubbleScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
          parent: _bubbleAnimationController, curve: Curves.elasticOut),
    );

    // Mostrar el saludo después de un pequeño retraso y ocultarlo después
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _showGreeting = true;
        });
        _bubbleAnimationController.forward();
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _showGreeting) {
        _bubbleAnimationController.reverse().then((value) {
          if (mounted) {
            setState(() {
              _showGreeting = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _botAnimationController.dispose();
    _bubbleAnimationController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _userInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildAppBackground() {
    return SizedBox.expand(
      child: Image.asset(
        'assets/Fondo_SkillSwap.png',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFF0FAF3),
                Color(0xFFFAFDFB),
                Color(0xFFFFFFFF),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black26,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 80,
              right: 24,
              child: Material(
                color: const Color.fromARGB(255, 255, 242, 242),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildMenuItem(Icons.accessibility, "Accesibilidad", () {}),
                        _buildMenuItem(Icons.person_outline, "Perfil", () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/perfil');
                        }),
                        _buildMenuItem(Icons.check_box_outlined, "Calificaciones", () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/calificaciones');
                        }),
                        _buildMenuItem(Icons.calendar_today_outlined, "Calendario", () {}),
                        _buildMenuItem(Icons.folder_open_outlined, "Archivos personales", () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/archivos');
                        }),
                        _buildMenuItem(Icons.logout, "Cerrar sesión", () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/login');
                        }, isExit: true),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetallesUsuario(BuildContext context, Map<String, dynamic> data, String uid) {
    const Color primaryGreen = Color(0xFF6BCE7A);
    final String name = data['nombre'] ?? data['email']?.split('@')[0] ?? "Usuario";
    final String photo = data['photoUrl'] ?? data['fotoUrl'] ?? "";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85, // Un poco más alto para ver más datos
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: photo.isNotEmpty
                                ? (photo.startsWith('http')
                                    ? Image.network(photo, width: 130, height: 130, fit: BoxFit.cover)
                                    : Image.memory(base64Decode(photo), width: 130, height: 130, fit: BoxFit.cover))
                                : Image.network('https://ui-avatars.com/api/?name=$name&background=random', width: 130, height: 130, fit: BoxFit.cover),
                          ),
                        ),
                        StreamBuilder(
                          stream: FirebaseDatabase.instance.ref("status/$uid").onValue,
                          builder: (context, snapshot) {
                            bool isOnline = false;
                            String statusText = "Desconectado";
                            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                              final dynamic value = snapshot.data!.snapshot.value;
                              if (value is Map) {
                                isOnline = value["presence"] == "online";
                                statusText = isOnline ? "En línea" : "Desconectado";
                              }
                            }
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isOnline ? const Color(0xFF4CAF50) : Colors.grey.shade500,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isOnline ? Colors.white : Colors.white70,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    statusText.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white, 
                                      fontSize: 10, 
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF334A5F))),
<<<<<<< HEAD
                    
                    // Mostrar Promedio de Estrellas
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('usuarios').doc(uid).collection('calificaciones').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Text("Sin calificaciones aún", style: TextStyle(color: Colors.grey, fontSize: 12));
                        }
                        
                        double total = 0;
                        int count = snapshot.data!.docs.length;
                        for (var doc in snapshot.data!.docs) {
                          var d = doc.data() as Map<String, dynamic>;
                          total += ((d['ratingExplicacion'] ?? 0) + (d['ratingHabilidades'] ?? 0)) / 2;
                        }
                        double avg = total / count;
                        
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(avg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber)),
                            const SizedBox(width: 5),
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            Text(" ($count)", style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        );
                      },
                    ),

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                    Text(data['email'] ?? "", style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    
                    // Nueva sección de Datos Personales / Detalles
                    _buildFullDetailSection("Detalles del perfil", [
                      {"icon": Icons.phone, "label": "Teléfono", "value": data['telefono'] ?? "No registrado"},
                      {"icon": Icons.location_on, "label": "Ubicación", "value": data['ubicacion'] ?? "No especificada"},
                      {"icon": Icons.work, "label": "Especialidad", "value": data['especialidad'] ?? data['ofrece'] ?? "Habilidades varias"},
                    ]),
                    
                    const SizedBox(height: 20),
                    _buildInfoSection("Acerca de", data['bio'] ?? "Soy un apasionado de SkillSwap buscando nuevas formas de aprender."),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _buildBadgeSection("OFRECE", data['ofrece'] ?? "Todo tipo de ayuda", const Color(0xFF6BCE7A))),
                        const SizedBox(width: 15),
                        Expanded(child: _buildBadgeSection("NECESITA", data['necesita'] ?? "Nuevas experiencias", const Color(0xFF00A99D))),
                      ],
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              receiverId: uid,
                              receiverName: name,
                              receiverPhoto: photo,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.message_rounded),
                      label: const Text("CONTACTAR AHORA"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen, 
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
<<<<<<< HEAD
                    const SizedBox(height: 12),
                    StatefulBuilder(
                      builder: (context, setState) {
                        return OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            CalificacionesScreen.mostrarDialogoCalificar(context, uid, name);
                          },
                          icon: const Icon(Icons.star_rate_rounded, color: Colors.amber),
                          label: const Text("CALIFICAR ESTE USUARIO"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF334A5F),
                            side: const BorderSide(color: Colors.amber, width: 2),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                        );
                      }
                    ),
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullDetailSection(String title, List<Map<String, dynamic>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF334A5F))),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(item['icon'] as IconData, size: 20, color: const Color(0xFF00A99D)),
              const SizedBox(width: 10),
              Text("${item['label']}: ", style: const TextStyle(fontWeight: FontWeight.w600)),
              Expanded(child: Text(item['value'] as String, style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
            ],
          ),
<<<<<<< HEAD
        )),
=======
        )).toList(),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
      ],
    )
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334A5F), fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
          child: Text(content, style: const TextStyle(color: Colors.blueGrey)),
        ),
      ],
    );
  }

  Widget _buildBadgeSection(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(value, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 13)),
        ),
      ],
    );
  }

  // Helper actualizado para un look más integrado
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap,
      {bool isExit = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 15), // Más espacio interno
        child: Row(
          children: [
            Icon(icon,
                color: isExit ? Colors.redAccent : const Color(0xFF6BCE7A),
                size: 22),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                color: isExit ? Colors.redAccent : const Color(0xFF334A5F),
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updatePresence() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Referencias a Realtime Database (RTDB)
    DatabaseReference presenceRef =
        FirebaseDatabase.instance.ref("status/${user.uid}");

    FirebaseDatabase.instance.ref(".info/connected").onValue.listen((event) {
      if (event.snapshot.value == true) {
        // Cuándo el usuario se desconecta de RTDB
        presenceRef.onDisconnect().update({
          "presence": "offline",
          "last_seen": ServerValue.timestamp,
        });

        // Cuándo el usuario está conectado a RTDB (Asegurar timestamp numérico)
        presenceRef.update({
          "presence": "online",
          "last_seen": DateTime.now().millisecondsSinceEpoch,
        });

        // Actualizar Firestore también para la lista global
        FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
          'estado': 'online',
          'ultimoIngreso': FieldValue.serverTimestamp(),
        }).catchError((e) => debugPrint("Error actualizando Firestore: $e"));
      }
    });

    // Escuchar cambios de desconexión también para Firestore si es posible
    presenceRef.onDisconnect().set({
      "presence": "offline",
      "last_seen": ServerValue.timestamp,
    }).then((_) {
       // Esto se ejecuta cuando el servidor de Firebase detecta la desconexión
    });
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    const Color primaryGreen = _primaryGreen;
=======
    const Color primaryGreen = const Color(0xFF6BCE7A);
    const Color darkText = Color(0xFF334A5F);
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

    // Obtener el usuario actual
    final user = FirebaseAuth.instance.currentUser;
    String userName = "Guest";
    if (user != null && user.email != null) {
<<<<<<< HEAD
=======
      // Extrae la parte antes del @ del correo
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
      userName = user.email!.split('@')[0];
    }

    return Scaffold(
<<<<<<< HEAD
      body: user == null 
        ? const Center(child: CircularProgressIndicator())
        : StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('usuarios').doc(user.uid).snapshots(),
            builder: (context, snapshot) {
              String photo = "";
              List<String> favoritosIds = [];
              if (snapshot.hasData && snapshot.data!.exists) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                userName = data['nombre'] ?? userName;
                photo = data['photoUrl'] ?? data['fotoUrl'] ?? "";
                favoritosIds = List<String>.from(data['favoritos'] ?? []);
              }

              final String initials = _userInitials(userName);

              return Stack(
                children: [
                  // 1. FONDO con gradiente suave
                  Positioned.fill(child: _buildAppBackground()),

                  // 2. CONTENIDO
                  SafeArea(
                    child: Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // --- Header con Logo y Perfil ---
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(20),
                                          child: Image.asset(
                                            'assets/icon.png',
                                            height: 36,
                                            width: 36,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Image.asset(
                                              'assets/icon.png',
                                              height: 36,
                                              width: 36,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.swap_horiz_rounded,
                                                color: _teal,
                                                size: 36,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "SkillSwap",
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: _primaryGreen,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => _showProfileMenu(context),
                                      child: Container(
                                        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(_radiusPill),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.06),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor: _primaryGreen,
                                              child: photo.isNotEmpty
                                                  ? ClipOval(
                                                      child: photo.startsWith('http')
                                                          ? Image.network(
                                                              photo,
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.memory(
                                                              base64Decode(photo),
                                                              width: 32,
                                                              height: 32,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    )
                                                  : Text(
                                                      initials,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              userName,
                                              style: const TextStyle(
                                                color: _darkText,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                            const Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: _mutedText,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),

                        // --- Saludo con mano animada al lado ---
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "¡Bienvenido, $userName!",
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: _darkText,
                              ),
                            ),
                            const SizedBox(width: 10),
                            AnimatedBuilder(
                              animation: _waveAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _waveAnimation.value,
                                  child: const Text("👋", style: TextStyle(fontSize: 32)),
                                );
                              },
                            ),
                          ],
                        ),
                        const Text(
                          "What skills do you want to swap?",
                          style: TextStyle(fontSize: 16, color: _darkText),
                        ),
                        const SizedBox(height: 25),

                        // --- Buscador y filtros ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(_radiusPill),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.06),
                                blurRadius: 14,
=======
      body: Stack(
        children: [
          // 1. FONDO
          Positioned.fill(
            child: Image.asset('assets/Fondo_SkillSwap.png', fit: BoxFit.cover),
          ),

          // 2. CONTENIDO
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header con Logo y Perfil clickable ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/imagen_skillwasp.jpeg',
                                    height: 30,
                                    errorBuilder: (context, error, stackTrace) =>
                                        const Icon(Icons.swap_calls,
                                            color: Color(0xFF00A99D), size: 30),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    "SkillSwap",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6BCE7A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar interactivo (Imagen 2)
                            GestureDetector(
                              onTap: () {
                                _showProfileMenu(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                  boxShadow: [
                                    // ignore: deprecated_member_use
                                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundImage: NetworkImage(
                                          'https://ui-avatars.com/api/?name=$userName&background=6BCE7A&color=fff'),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      userName,
                                      style: const TextStyle(
                                          color: Color(0xFF334A5F),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // --- BUSCADOR Y FILTROS TIPO IMAGEN ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          height: 55,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
<<<<<<< HEAD
                              Icon(Icons.search_rounded, color: _primaryGreen.withValues(alpha: 0.85), size: 22),
                              const SizedBox(width: 10),
=======
                              const Icon(Icons.search, color: Color(0xFF6BCE7A)),
                              const SizedBox(width: 12),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value.toLowerCase();
                                    });
                                  },
<<<<<<< HEAD
                                  style: const TextStyle(color: _darkText, fontSize: 15),
                                  decoration: const InputDecoration(
                                    hintText: "Buscar personas o habilidades",
                                    hintStyle: TextStyle(color: _mutedText, fontSize: 15),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
=======
                                  decoration: const InputDecoration(
                                    hintText: "Buscar personas o habilidades",
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                                    border: InputBorder.none,
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                  ),
                                ),
                              ),
                              Container(
<<<<<<< HEAD
                                height: 28,
                                width: 1,
                                color: Colors.grey.withValues(alpha: 0.25),
                                margin: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              const Icon(Icons.tune_rounded, color: _primaryGreen, size: 20),
                              const SizedBox(width: 6),
                              const Text(
                                "Filtros",
                                style: TextStyle(
                                  color: _primaryGreen,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
=======
                                height: 25,
                                width: 1,
                                color: Colors.grey.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(horizontal: 10),
                              ),
                              const Icon(Icons.tune, color: Color(0xFF6BCE7A)),
                              const SizedBox(width: 4),
                              const Text(
                                "Filtros",
                                style: TextStyle(
                                  color: Color(0xFF6BCE7A),
                                  fontWeight: FontWeight.w600,
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
<<<<<<< HEAD
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
=======
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              GestureDetector(
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                onTap: () {
                                  setState(() {
                                    _filterByPeople = !_filterByPeople;
                                    if (!_filterByPeople && !_filterBySkills) {
                                      _filterByPeople = true; // Al menos uno activo
                                    }
                                  });
                                },
                                child: _buildFilterChip(Icons.person, "Personas", _filterByPeople),
                              ),
<<<<<<< HEAD
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: GestureDetector(
=======
                              const SizedBox(width: 10),
                              GestureDetector(
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                onTap: () {
                                  setState(() {
                                    _filterBySkills = !_filterBySkills;
                                    if (!_filterByPeople && !_filterBySkills) {
                                      _filterBySkills = true; // Al menos uno activo
                                    }
                                  });
                                },
                                child: _buildFilterChip(Icons.lightbulb_outline, "Habilidades", _filterBySkills),
                              ),
<<<<<<< HEAD
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
=======
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- Saludo ---
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              "Bienvenido, $userName!",
                              style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: darkText),
                            ),
                            const SizedBox(width: 10),
                            AnimatedBuilder(
                              animation: _waveAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _waveAnimation.value,
                                  child: const Text("👋",
                                      style: TextStyle(fontSize: 32)),
                                );
                              },
                            ),
                          ],
                        ),
                        const Text("What skills do you want to swap?",
                            style: TextStyle(fontSize: 16, color: darkText)),
                        const SizedBox(height: 15),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

                        // --- Menú de Ordenar ---
                        Row(
                          children: [
                            const Text(
                              "Ordenar por: ",
                              style: TextStyle(
<<<<<<< HEAD
                                fontWeight: FontWeight.w600,
                                color: _darkText,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.22)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
=======
                                  fontWeight: FontWeight.bold, color: darkText),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _currentSort,
<<<<<<< HEAD
                                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _primaryGreen, size: 22),
                                  style: const TextStyle(
                                    color: _darkText,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
=======
                                  icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
                                  style: const TextStyle(
                                      color: Color(0xFF334A5F),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        _currentSort = newValue;
                                      });
                                    }
                                  },
                                  items: <String>[
                                    'Conexión',
                                    'Nombre',
                                    'Habilidades'
                                  ].map<DropdownMenuItem<String>>((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
<<<<<<< HEAD
                        const SizedBox(height: 24),
=======
                        const SizedBox(height: 30),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

                        // --- Offer / Need ---
                        Row(
                          children: [
                            Expanded(child: _buildOfferCard(primaryGreen)),
<<<<<<< HEAD
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.swap_horiz_rounded,
                                color: primaryGreen.withValues(alpha: 0.9),
                                size: 32,
                              ),
=======
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.swap_horiz_rounded,
                                  color: primaryGreen, size: 35),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                            ),
                            Expanded(child: _buildNeedCard()),
                          ],
                        ),
                        const SizedBox(height: 30),

                        _buildFindMatchButton(primaryGreen),
                        const SizedBox(height: 40),

                        // --- Matches ---
<<<<<<< HEAD
                        const Text(
                          "Suggested Matches",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _darkText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Toca ⭐ en una persona para añadirla a Tutores favoritos",
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 12),
=======
                        const Text("Suggested Matches",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkText)),
                        const SizedBox(height: 15),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

                        // StreamBuilder para mostrar usuarios desde Firestore (Lista oficial)
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Text("No hay usuarios registrados");
                            }

                            final currentUserId = FirebaseAuth.instance.currentUser?.uid;
                            
                            // Primero obtenemos todos los usuarios (excepto el actual)
                            var docs = snapshot.data!.docs.where((doc) => doc.id != currentUserId).toList();

                            // SI HAY UNA BÚSQUEDA ACTIVA, FILTRAMOS LOS RESULTADOS
                            if (_searchQuery.isNotEmpty) {
                              docs = docs.where((doc) {
                                var userData = doc.data() as Map<String, dynamic>;
                                String name = (userData['nombre'] ?? "").toString().toLowerCase();
                                String email = (userData['email'] ?? "").toString().toLowerCase();
                                String needs = (userData['necesita'] ?? "").toString().toLowerCase();
                                String offers = (userData['ofrece'] ?? "").toString().toLowerCase();

                                bool matchesQuery = false;
                                
                                // Si el filtro de Personas está activo, buscamos por nombre/email
                                if (_filterByPeople) {
                                  if (name.contains(_searchQuery) || email.contains(_searchQuery)) {
                                    matchesQuery = true;
                                  }
                                }
                                
                                // Si el filtro de Habilidades está activo, buscamos por ofrece/necesita
                                if (_filterBySkills) {
                                  if (needs.contains(_searchQuery) || offers.contains(_searchQuery)) {
                                    matchesQuery = true;
                                  }
                                }

                                return matchesQuery;
                              }).toList();
                            } else {
                              // SI NO HAY BÚSQUEDA, NO MOSTRAR NADA (según lo solicitado)
                              // Solo se muestran si el usuario busca algo.
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: Text(
                                    "Escribe en el buscador para encontrar personas o habilidades",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey, fontSize: 16),
                                  ),
                                ),
                              );
                            }

                            if (docs.isEmpty) {
                              return const Center(
                                child: Text(
                                  "No se encontraron resultados para tu búsqueda.",
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              );
                            }

                            // AHORA OBTENEMOS LOS ESTADOS DE PRESENCIA PARA ORDENAR POR CONECTADOS
                            return StreamBuilder<DatabaseEvent>(
                              stream: FirebaseDatabase.instance.ref('status').onValue,
                              builder: (context, statusSnapshot) {
                                Map<dynamic, dynamic> statuses = {};
                                if (statusSnapshot.hasData && statusSnapshot.data!.snapshot.value != null) {
                                  statuses = statusSnapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                                }
                                  
                                // Aplicar orden según selección del menú
                                docs.sort((a, b) {
                                  var userDataA = a.data() as Map<String, dynamic>;
                                  var userDataB = b.data() as Map<String, dynamic>;

                                  if (_currentSort == "Nombre") {
                                    String nameA = (userDataA['nombre'] ?? "").toString().toLowerCase();
                                    String nameB = (userDataB['nombre'] ?? "").toString().toLowerCase();
                                    return nameA.compareTo(nameB);
                                  } else if (_currentSort == "Habilidades") {
                                    String skillA = (userDataA['ofrece'] ?? "").toString().toLowerCase();
                                    String skillB = (userDataB['ofrece'] ?? "").toString().toLowerCase();
                                    return skillA.compareTo(skillB);
                                  } else {
                                    // Orden por Conexión (Por defecto)
                                    var statusA = statuses[a.id];
                                    var statusB = statuses[b.id];
                                    
                                    bool isOnlineA = false;
                                    bool isOnlineB = false;
                                    int lastSeenA = 0;
                                    int lastSeenB = 0;

                                    if (statusA is Map) {
                                      isOnlineA = (statusA['presence'] ?? statusA['state']) == 'online';
                                      lastSeenA = statusA['last_seen'] ?? 0;
                                    }
                                    
                                    if (statusB is Map) {
                                      isOnlineB = (statusB['presence'] ?? statusB['state']) == 'online';
                                      lastSeenB = statusB['last_seen'] ?? 0;
                                    }

                                    if (isOnlineA && !isOnlineB) return -1;
                                    if (!isOnlineA && isOnlineB) return 1;
                                    return lastSeenB.compareTo(lastSeenA);
                                  }
                                });

                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: docs.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 15),
                                  itemBuilder: (context, index) {
                                    var userData = docs[index].data() as Map<String, dynamic>;
                                    String uid = docs[index].id;
                                    String name = userData['nombre'] ?? userData['email']?.split('@')[0] ?? "Usuario";
<<<<<<< HEAD
                                    // Corregido: Buscar en photoUrl (inglés) o fotoUrl (español) para que se vea siempre
                                    String photo = userData['photoUrl'] ?? userData['fotoUrl'] ?? "";
=======
                                    String photo = userData['fotoUrl'] ?? 'https://ui-avatars.com/api/?name=$name&background=random';
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                    
                                    return GestureDetector(
                                      onTap: () => _mostrarDetallesUsuario(context, userData, uid),
                                      child: _buildMatchCard(
                                        context,
                                        name: name,
                                        userId: uid,
                                        needs: userData['necesita'] ?? "Por definir",
                                        offers: userData['ofrece'] ?? "Por definir",
                                        imageUrl: photo,
<<<<<<< HEAD
                                        isFavorite: favoritosIds.contains(uid),
                                        onToggleFavorite: () => _toggleFavorito(uid),
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
<<<<<<< HEAD
                        const SizedBox(height: 28),
                        _buildSeccionFavoritos(favoritosIds),
                        const SizedBox(height: 20),
=======
                        const SizedBox(height: 30),
                        const SizedBox(height: 10),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                      ],
                    ),
                  ),
                ),

                // --- Copyright ---
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
<<<<<<< HEAD
                  child: Center(
                    child: Text(
                      '© 2026 SkillSwap. Todos los derechos reservados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
=======
                  child: Text(
                    '© 2026 SkillSwap. Todos los derechos reservados.',
                    style: TextStyle(
                        color: darkText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                  ),
                ),
              ],
            ),
          ),

<<<<<<< HEAD
          // --- Bot IA abajo a la derecha (grande) ---
=======
          // --- Chat AI Bot con Saludo Animado ---
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
          Positioned(
            bottom: 60,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
<<<<<<< HEAD
=======
                // Globo de saludo animado
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                if (_showGreeting)
                  FadeTransition(
                    opacity: _bubbleOpacityAnimation,
                    child: ScaleTransition(
                      scale: _bubbleScaleAnimation,
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, right: 10),
                        padding: const EdgeInsets.symmetric(
<<<<<<< HEAD
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _teal,
                          borderRadius: const BorderRadius.only(
=======
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00A99D), // Color secundario para el chat
                          borderRadius: BorderRadius.only(
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(0),
                          ),
                          boxShadow: [
                            BoxShadow(
<<<<<<< HEAD
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
=======
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2))
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                          ],
                        ),
                        child: const Text(
                          "Hola, bienvenido a SkillSwap",
                          style: TextStyle(
<<<<<<< HEAD
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
=======
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                        ),
                      ),
                    ),
                  ),
<<<<<<< HEAD
=======
                // Botón del Bot IA animado
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                _buildAIBotButton(primaryGreen),
              ],
            ),
          ),
        ],
<<<<<<< HEAD
      );
    },
  ),
);
}

  Widget _buildOfferCard(Color green) {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
=======
      ),
    );
  }

  Widget _buildOfferCard(Color green) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
<<<<<<< HEAD
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "I OFFER",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Icon(Icons.laptop_mac_rounded, size: 56, color: _teal),
          const SizedBox(height: 12),
          const Text(
            "Graphic Design",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: _darkText,
            ),
          ),
=======
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: green, borderRadius: BorderRadius.circular(20)),
            child: const Text("I OFFER",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.laptop_chromebook_rounded,
              size: 60, color: Color(0xFF00A99D)),
          const SizedBox(height: 10),
          const Text("Graphic Design",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF334A5F))),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        ],
      ),
    )
  }

<<<<<<< HEAD
  Future<void> _toggleFavorito(String uid) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final ref = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
      final doc = await ref.get();
      final List<String> favs = List<String>.from(doc.data()?['favoritos'] ?? []);

      final bool agregar = !favs.contains(uid);
      if (agregar) {
        favs.add(uid);
      } else {
        favs.remove(uid);
      }

      await ref.set({'favoritos': favs}, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              agregar
                  ? 'Añadido a Tutores favoritos o amigos'
                  : 'Eliminado de favoritos',
            ),
            backgroundColor: const Color(0xFF6BCE7A),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error favorito: $e');
    }
  }

  Widget _buildNeedCard() {
    return Container(
      height: 210,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
=======
  Widget _buildNeedCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
<<<<<<< HEAD
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: _teal,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "I NEED",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Icon(Icons.forum_rounded, size: 56, color: _primaryGreen),
          const SizedBox(height: 12),
          const Text(
            "English Practice",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: _darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionFavoritos(List<String> favoritosIds) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(_radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tutores favoritos o amigos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _darkText,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            favoritosIds.isEmpty
                ? 'Aún vacío — usa ⭐ en Suggested Matches'
                : '${favoritosIds.length} contacto${favoritosIds.length == 1 ? '' : 's'}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
        SizedBox(
          height: 118,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _primaryGreen),
                  ),
                );
              }

              final docs = snap.data!.docs
                  .where((d) => favoritosIds.contains(d.id))
                  .toList();

              if (docs.isEmpty) {
                return SizedBox(
                  height: 90,
                  child: Center(
                    child: Text(
                      'Busca personas arriba y toca ⭐',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 108,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 4),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final uid = doc.id;
                    final name = data['nombre'] ??
                        data['email']?.toString().split('@').first ??
                        'Usuario';
                    final fPhoto = data['photoUrl'] ?? data['fotoUrl'] ?? '';
                    return _buildFavoritoAvatarItem(
                      uid: uid,
                      name: name,
                      photo: fPhoto,
                      onRemove: () => _toggleFavorito(uid),
                    );
                  },
                ),
              );
            },
          ),
        ),
=======
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: const Color(0xFF00A99D),
                borderRadius: BorderRadius.circular(20)),
            child: const Text("I NEED",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.forum_rounded, size: 60, color: Color(0xFF8CC63F)),
          const SizedBox(height: 10),
          const Text("English Practice",
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: Color(0xFF334A5F))),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildFavoritoAvatarItem({
    required String uid,
    required String name,
    required String photo,
    VoidCallback? onRemove,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverId: uid,
              receiverName: name,
              receiverPhoto: photo,
            ),
          ),
        );
      },
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 8),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: _primaryGreen.withValues(alpha: 0.15),
                  child: ClipOval(
                    child: photo.isNotEmpty
                        ? (photo.startsWith('http')
                            ? Image.network(photo, width: 62, height: 62, fit: BoxFit.cover)
                            : Image.memory(
                                base64Decode(photo),
                                width: 62,
                                height: 62,
                                fit: BoxFit.cover,
                              ))
                        : Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                              color: _primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
                if (onRemove != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.redAccent),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _darkText),
            ),
          ],
        ),
      ),
    );
  }

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  Widget _buildFindMatchButton(Color green) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: green,
<<<<<<< HEAD
        borderRadius: BorderRadius.circular(_radiusPill),
        boxShadow: [
          BoxShadow(
            color: green.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Find a Match",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.2,
          ),
        ),
=======
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
              // ignore: deprecated_member_use
              color: green.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: const Center(
        child: Text("Find a Match",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
      ),
    );
  }

  Widget _buildMatchCard(
    BuildContext context, {
    required String name,
    required String needs,
    required String offers,
    required String imageUrl,
    required String userId,
<<<<<<< HEAD
    bool isFavorite = false,
    VoidCallback? onToggleFavorite,
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          StreamBuilder(
            stream: FirebaseDatabase.instance.ref("status/$userId").onValue,
            builder: (context, snapshot) {
              bool isOnline = false;
              if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                final dynamic value = snapshot.data!.snapshot.value;
                if (value is Map) {
                  isOnline = value["presence"] == "online";
                } else if (value is Map<dynamic, dynamic>) {
                  isOnline = value["presence"] == "online";
                }
              }

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade200,
<<<<<<< HEAD
                    child: ClipOval(
                      child: imageUrl.isNotEmpty
                          ? (imageUrl.startsWith('http')
                              ? Image.network(imageUrl, width: 70, height: 70, fit: BoxFit.cover)
                              : Image.memory(base64Decode(imageUrl), width: 70, height: 70, fit: BoxFit.cover))
                          : const Icon(Icons.person, size: 40, color: Colors.grey),
                    ),
=======
                    backgroundImage: (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl.isEmpty || !imageUrl.startsWith('http'))
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      height: 18,
                      width: 18,
                      decoration: BoxDecoration(
                        color: isOnline ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: isOnline ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            blurRadius: 4,
                            spreadRadius: 1,
                          )
                        ] : null,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334A5F))),
                  const Spacer(),
                  StreamBuilder(
                    stream: FirebaseDatabase.instance.ref("status/$userId").onValue,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                        final dynamic value = snapshot.data!.snapshot.value;
                        bool online = false;
                        dynamic lastSeen;

                        if (value is Map) {
                          online = value["presence"] == "online";
                          lastSeen = value["last_seen"];
                        } else if (value is Map<dynamic, dynamic>) {
                          online = value["presence"] == "online";
                          lastSeen = value["last_seen"];
                        }

                        if (online) {
                          return const Text(
                            "Activo(a)",
                            style: TextStyle(
                              fontSize: 12, 
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold
                            ),
                          );
                        } else if (lastSeen != null) {
                          try {
                            int lastSeenTimestamp = 0;
                            if (lastSeen is int) {
                              lastSeenTimestamp = lastSeen;
                            } else if (lastSeen is double) {
                              lastSeenTimestamp = lastSeen.toInt();
                            }

                            if (lastSeenTimestamp == 0) return const SizedBox.shrink();

                            DateTime date = DateTime.fromMillisecondsSinceEpoch(lastSeenTimestamp);
                            final now = DateTime.now();
                            final diff = now.difference(date);
                            
                            String status = "";
                            if (diff.inMinutes < 1) {
                              status = "Reciente";
                            } else if (diff.inMinutes < 60) {
                              status = "${diff.inMinutes}m";
                            } else if (diff.inHours < 24) {
                              status = "${date.hour}:${date.minute.toString().padLeft(2, '0')}";
                            } else {
                              status = "${date.day}/${date.month}";
                            }

                            return Text(
                              status,
                              style: const TextStyle(
                                fontSize: 12, 
                                color: Colors.grey,
                                fontWeight: FontWeight.w500
                              ),
                            );
                          } catch (e) {
                            return const SizedBox.shrink();
                          }
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ]),
                const SizedBox(height: 4),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Color(0xFF334A5F)),
                        children: [
                      const TextSpan(
                          text: "Needs: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6BCE7A))),
                      TextSpan(text: needs),
                    ])),
                RichText(
                    text: TextSpan(
                        style: const TextStyle(color: Color(0xFF334A5F)),
                        children: [
                      const TextSpan(
                          text: "Offers: ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6BCE7A))),
                      TextSpan(text: offers),
                    ])),
              ],
            ),
          ),
<<<<<<< HEAD
          if (onToggleFavorite != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? Colors.amber : Colors.grey.shade400,
                    size: 28,
                  ),
                  tooltip: isFavorite ? 'Quitar de favoritos' : 'Añadir a favoritos',
                ),
                Text(
                  isFavorite ? 'Favorito' : 'Favorito',
                  style: TextStyle(
                    fontSize: 10,
                    color: isFavorite ? Colors.amber.shade700 : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        ],
      ),
    );
  }

  // --- Widget del Bot IA Animado ---
  Widget _buildAIBotButton(Color green) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/ai'),
      child: AnimatedBuilder(
        animation: _botAnimationController,
        builder: (context, child) {
          return ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
<<<<<<< HEAD
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: green.withValues(alpha: _glowAnimation.value),
                    blurRadius: 20 * _scaleAnimation.value,
                    spreadRadius: 5 * _scaleAnimation.value,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
=======
              height: 70, // Un poco más grande para que resalte la imagen
              width: 70,
              decoration: BoxDecoration(
                color: Colors.white, // Fondo blanco para que resalte el robot verde
                shape: BoxShape.circle,
                boxShadow: [
                  // Brillo parpadeante animado
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: green.withOpacity(_glowAnimation.value),
                    blurRadius: 20 * _scaleAnimation.value,
                    spreadRadius: 5 * _scaleAnimation.value,
                  ),
                  // Sombra base
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.1),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
<<<<<<< HEAD
              padding: const EdgeInsets.all(5),
              child: ClipOval(
                child: Image.asset(
                  'assets/Chatbot_SkillSwap.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.smart_toy_rounded,
                    color: green,
                    size: 38,
                  ),
=======
              padding: const EdgeInsets.all(5), // Espacio para el borde blanco
              child: ClipOval(
                child: Image.asset(
                  'assets/Chatbot_SkillSwap.png', // Tu imagen proporcionada
                  fit: BoxFit.contain,
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, bool isSelected) {
<<<<<<< HEAD
    final bool isPersonas = label == "Personas";
    final Color inactiveIcon = isPersonas ? _mutedText : const Color(0xFFE6B422);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? _lightGreenBg : Colors.white,
        borderRadius: BorderRadius.circular(_radiusPill),
        border: Border.all(
          color: isSelected ? _primaryGreen.withValues(alpha: 0.35) : const Color(0xFFE4E8EC),
          width: isSelected ? 1.2 : 1,
        ),
        boxShadow: isSelected
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isSelected ? _primaryGreen : inactiveIcon,
          ),
=======
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFF6BCE7A).withOpacity(0.3) : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: isSelected ? const Color(0xFF6BCE7A) : Colors.amber),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
<<<<<<< HEAD
              color: isSelected ? _primaryGreen : _darkText,
=======
              color: isSelected ? const Color(0xFF6BCE7A) : const Color(0xFF334A5F),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}