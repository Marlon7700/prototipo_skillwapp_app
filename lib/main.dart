import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'Interfaz_IA.dart';
import 'ventana_perfil.dart';
import 'bienvenida_perfil.dart';
import 'mis_archivos.dart';
import 'chat_screen.dart';
import 'terminos_condiciones.dart';

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
        scaffoldBackgroundColor: Colors.transparent,
        fontFamily: 'Arial',
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
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Controlador de búsqueda
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  bool _filterByPeople = true;
  bool _filterBySkills = false;
  String _currentSort = "Conexión"; // Opción seleccionada por defecto

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

  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return Stack(
          children: [
            Positioned(
              top: 80,
              right: 24,
              child: Material(
                color: Colors.transparent,
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
                        _buildMenuItem(Icons.check_box_outlined, "Calificaciones", () {}),
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
    final Color primaryGreen = const Color(0xFF6BCE7A);
    final String name = data['nombre'] ?? data['email']?.split('@')[0] ?? "Usuario";
    final String photo = data['fotoUrl'] ?? 'https://ui-avatars.com/api/?name=$name&background=random';

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
                        CircleAvatar(radius: 65, backgroundImage: NetworkImage(photo)),
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
        )).toList(),
      ],
    );
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
    const Color primaryGreen = Color(0xFF6BCE7A);
    const Color darkText = Color(0xFF334A5F);

    // Obtener el usuario actual
    final user = FirebaseAuth.instance.currentUser;
    String userName = "Guest";
    if (user != null && user.email != null) {
      // Extrae la parte antes del @ del correo
      userName = user.email!.split('@')[0];
    }

    return Scaffold(
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
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: Color(0xFF6BCE7A)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value.toLowerCase();
                                    });
                                  },
                                  decoration: const InputDecoration(
                                    hintText: "Buscar personas o habilidades",
                                    hintStyle: TextStyle(color: Colors.grey, fontSize: 15),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Container(
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              GestureDetector(
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
                              const SizedBox(width: 10),
                              GestureDetector(
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

                        // --- Menú de Ordenar ---
                        Row(
                          children: [
                            const Text(
                              "Ordenar por: ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, color: darkText),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _currentSort,
                                  icon: const Icon(Icons.arrow_drop_down, color: primaryGreen),
                                  style: const TextStyle(
                                      color: Color(0xFF334A5F),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
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
                        const SizedBox(height: 30),

                        // --- Offer / Need ---
                        Row(
                          children: [
                            Expanded(child: _buildOfferCard(primaryGreen)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(Icons.swap_horiz_rounded,
                                  color: primaryGreen, size: 35),
                            ),
                            Expanded(child: _buildNeedCard()),
                          ],
                        ),
                        const SizedBox(height: 30),

                        _buildFindMatchButton(primaryGreen),
                        const SizedBox(height: 40),

                        // --- Matches ---
                        const Text("Suggested Matches",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: darkText)),
                        const SizedBox(height: 15),

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
                                    String photo = userData['fotoUrl'] ?? 'https://ui-avatars.com/api/?name=$name&background=random';
                                    
                                    return GestureDetector(
                                      onTap: () => _mostrarDetallesUsuario(context, userData, uid),
                                      child: _buildMatchCard(
                                        context,
                                        name: name,
                                        userId: uid,
                                        needs: userData['necesita'] ?? "Por definir",
                                        offers: userData['ofrece'] ?? "Por definir",
                                        imageUrl: photo,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 30),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),

                // --- Copyright ---
                const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text(
                    '© 2026 SkillSwap. Todos los derechos reservados.',
                    style: TextStyle(
                        color: darkText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

          // --- Chat AI Bot con Saludo Animado ---
          Positioned(
            bottom: 60,
            right: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Globo de saludo animado
                if (_showGreeting)
                  FadeTransition(
                    opacity: _bubbleOpacityAnimation,
                    child: ScaleTransition(
                      scale: _bubbleScaleAnimation,
                      alignment: Alignment.bottomRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10, right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00A99D), // Color secundario para el chat
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(0),
                          ),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2))
                          ],
                        ),
                        child: const Text(
                          "Hola, bienvenido a SkillSwap",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14),
                        ),
                      ),
                    ),
                  ),
                // Botón del Bot IA animado
                _buildAIBotButton(primaryGreen),
              ],
            ),
          ),
        ],
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
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
        ],
      ),
    );
  }

  Widget _buildNeedCard() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          // ignore: deprecated_member_use
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
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
        ],
      ),
    );
  }

  Widget _buildFindMatchButton(Color green) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: green,
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
                    backgroundImage: (imageUrl.isNotEmpty && imageUrl.startsWith('http'))
                        ? NetworkImage(imageUrl)
                        : null,
                    child: (imageUrl.isEmpty || !imageUrl.startsWith('http'))
                        ? const Icon(Icons.person, size: 40, color: Colors.grey)
                        : null,
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
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(5), // Espacio para el borde blanco
              child: ClipOval(
                child: Image.asset(
                  'assets/Chatbot_SkillSwap.png', // Tu imagen proporcionada
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(IconData icon, String label, bool isSelected) {
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
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF6BCE7A) : const Color(0xFF334A5F),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}