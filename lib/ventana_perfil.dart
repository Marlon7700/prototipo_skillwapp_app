import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
<<<<<<< HEAD
import 'package:file_picker/file_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:convert';
=======
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

// La pantalla de perfil real del usuario con animaciones y fondo.
// Lee y guarda los datos en la colección "usuarios" de Cloud Firestore,
// usando como ID el uid del usuario autenticado.
class ventana_perfil extends StatefulWidget {
  const ventana_perfil({super.key});

  @override
  State<ventana_perfil> createState() => _ventana_perfilState();
}

class _ventana_perfilState extends State<ventana_perfil> with SingleTickerProviderStateMixin {
  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _acercaDeController = TextEditingController();
  final TextEditingController _habilidadesController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _rolController = TextEditingController();
  final TextEditingController _fechaNacController = TextEditingController();

  late TabController _tabController;
  bool _isEditing = false; // Control de modo edición para animaciones

  // Paleta de colores
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color secondaryTeal = const Color(0xFF00A99D);
  final Color darkText = const Color(0xFF334A5F);
  final Color lightGray = const Color(0xFFF5F7F9);

  bool _isLoading = true;
  bool _isSaving = false;
  String _email = '';
  String _uid = '';
  String? _photoUrl;
  String? _bannerUrl;
  File? _imageFile;

<<<<<<< HEAD
  // Nuevas listas para experiencias y publicaciones
  List<Map<String, dynamic>> _experiencias = [];
  List<Map<String, dynamic>> _publicaciones = [];

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _cargarPerfil();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _acercaDeController.dispose();
    _habilidadesController.dispose();
    _ubicacionController.dispose();
    _telefonoController.dispose();
    _rolController.dispose();
    _fechaNacController.dispose();
    _tabController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
  // Método para seleccionar y procesar la imagen (Base64 para persistencia)
=======
  // Corregido: Ahora guarda la referencia local o URL en Firestore
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (pickedFile != null) {
<<<<<<< HEAD
      // Compresión para que no exceda el límite de Firestore (1MB)
      final result = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 40,
        minWidth: 500,
        minHeight: 500,
      );

      if (result != null) {
        final base64String = base64Encode(result);
        setState(() {
          _imageFile = File(pickedFile.path);
          _photoUrl = base64String; // Guardamos la base64 temporalmente
        });

        // AUTO-GUARDAR inmediatamente para asegurar que la imagen se suba
        await _guardarFotoFirestore(base64String);
      }
    }
  }

  Future<void> _guardarFotoFirestore(String base64Image) async {
    if (_uid.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(_uid).update({
        'photoUrl': base64Image,
        'fotoUrl': base64Image,
        'actualizadoEn': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto de perfil guardada correctamente.")),
        );
      }
    } catch (e) {
      debugPrint('Error al guardar foto: $e');
=======
      setState(() {
        _imageFile = File(pickedFile.path);
        // Para que se guarde el cambio, actualizamos la referencia que irá a Firestore
        _photoUrl = pickedFile.path; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto seleccionada. Dale a 'Guardar' para confirmar.")),
      );
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    }
  }

  // Método para el fondo de perfil (Banner)
  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
<<<<<<< HEAD
      final result = await FlutterImageCompress.compressWithFile(
        pickedFile.path,
        quality: 35,
        minWidth: 800,
        minHeight: 400,
      );
      if (result != null) {
        setState(() {
          _bannerUrl = base64Encode(result);
        });
      }
=======
      setState(() {
        _bannerUrl = pickedFile.path;
      });
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    }
  }

  // Carga el documento del usuario desde Firestore.
  // Si no existe (primer ingreso), lo crea con los datos básicos del Auth.
  Future<void> _cargarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    _uid = user.uid;
    _email = user.email ?? '';

    final docRef =
        FirebaseFirestore.instance.collection('usuarios').doc(_uid);

    try {
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() ?? <String, dynamic>{};
        _nombreController.text = (data['nombre'] ?? '').toString();
        _rolController.text = (data['rol'] ?? '').toString();
        _acercaDeController.text = (data['acercaDe'] ?? '').toString();
        _habilidadesController.text = (data['habilidades'] ?? '').toString();
        _ubicacionController.text = (data['ubicacion'] ?? '').toString();
        _telefonoController.text = (data['telefono'] ?? '').toString();
        _fechaNacController.text = (data['fechaNacimiento'] ?? '').toString();
<<<<<<< HEAD
        
        // Priorizar el campo que tenga contenido real para no perder la foto
        final f1 = data['photoUrl']?.toString() ?? '';
        final f2 = data['fotoUrl']?.toString() ?? '';
        _photoUrl = f1.isNotEmpty ? f1 : (f2.isNotEmpty ? f2 : null);
        
        _bannerUrl = data['bannerUrl'];

        // Cargar experiencias y publicaciones
        _experiencias = List<Map<String, dynamic>>.from(data['experiencias'] ?? []);
        _publicaciones = List<Map<String, dynamic>>.from(data['publicaciones'] ?? []);
=======
        _photoUrl = data['photoUrl'];
        _bannerUrl = data['bannerUrl'];
        
        // Si la foto es una ruta local de una sesión anterior
        if (_photoUrl != null && _photoUrl!.startsWith('/')) {
           _imageFile = File(_photoUrl!);
        }
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
      } else {
        // Estructura inicial mejorada
        await docRef.set({
          'uid': _uid,
          'email': _email,
          'nombre': _email.split('@').first,
          'rol': 'Usuario SkillSwap',
          'acercaDe': '¡Hola! Estoy usando SkillSwap.',
          'habilidades': '',
          'ubicacion': '',
          'telefono': '',
          'fechaNacimiento': '',
          'photoUrl': '',
          'bannerUrl': '',
          'creadoEn': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Corregido: Guarda todos los campos incluyendo la foto
  Future<void> _guardarPerfil() async {
    if (_uid.isEmpty) return;
    setState(() => _isSaving = true);

    try {
      Map<String, dynamic> datos = {
        'nombre': _nombreController.text.trim(),
        'rol': _rolController.text.trim(),
        'acercaDe': _acercaDeController.text.trim(),
        'habilidades': _habilidadesController.text.trim(),
        'ubicacion': _ubicacionController.text.trim(),
        'telefono': _telefonoController.text.trim(),
        'fechaNacimiento': _fechaNacController.text.trim(),
<<<<<<< HEAD
        'bannerUrl': _bannerUrl ?? "",
        'experiencias': _experiencias,
        'publicaciones': _publicaciones,
        'actualizadoEn': FieldValue.serverTimestamp(),
      };

      // Solo incluimos la foto si tenemos un valor válido, para no sobrescribir con vacío
      if (_photoUrl != null && _photoUrl!.isNotEmpty) {
        datos['photoUrl'] = _photoUrl;
        datos['fotoUrl'] = _photoUrl;
      }

=======
        'photoUrl': _photoUrl ?? "",
        'bannerUrl': _bannerUrl ?? "",
        'actualizadoEn': FieldValue.serverTimestamp(),
      };

>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
      await FirebaseFirestore.instance.collection('usuarios').doc(_uid).set(datos, SetOptions(merge: true));
      
      setState(() => _isEditing = false);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: primaryGreen, content: const Text('¡Perfil actualizado con éxito!')),
      );
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nombreParaAvatar = _nombreController.text.trim().isEmpty
        ? (_email.isEmpty ? 'User' : _email.split('@').first)
        : _nombreController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Acción de eliminar perfil (Simulada para el UI)
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Eliminar Perfil"),
                  content: const Text("¿Estás seguro de que deseas eliminar tu perfil? Esta acción no se puede deshacer."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                    TextButton(
                      onPressed: () => Navigator.pop(context), 
                      child: const Text("Eliminar", style: TextStyle(color: Colors.red))
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          ),
          const SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryGreen))
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Fondo_SkillSwap.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                       _buildHeaderModerno(nombreParaAvatar).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
                       const SizedBox(height: 10),
                       _buildTabBar().animate().fadeIn(delay: 200.ms),
                       const SizedBox(height: 20),
                       _buildTabContent(),
                       const SizedBox(height: 20),
                       _buildBotonesAccion().animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),
                       const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBotonesAccion() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildBotonLlamativo(
              label: "CREAR",
              icon: Icons.add_circle_outline,
              color: secondaryTeal,
              onPressed: () {
                // Lógica para crear algo nuevo
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Funcionalidad para Crear")));
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _buildBotonLlamativo(
              label: _isSaving ? "GUARDANDO..." : "EDITAR",
              icon: Icons.edit_note_rounded,
              color: primaryGreen,
              onPressed: _isSaving ? null : _guardarPerfil,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonLlamativo({required String label, required IconData icon, required Color color, VoidCallback? onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
        shadowColor: color.withOpacity(0.5),
      ),
    );
  }

  Widget _buildHeaderModerno(String nombre) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [primaryGreen, secondaryTeal]),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: _imageFile != null
                            ? Image.file(_imageFile!, fit: BoxFit.cover)
                            : (_photoUrl != null && _photoUrl!.isNotEmpty
<<<<<<< HEAD
                                ? (_photoUrl!.startsWith('http')
                                    ? Image.network(_photoUrl!, fit: BoxFit.cover)
                                    : Image.memory(
                                        base64Decode(_photoUrl!),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Image.network('https://ui-avatars.com/api/?name=$nombre&background=6BCE7A&color=fff&size=200'),
                                      ))
=======
                                ? Image.network(_photoUrl!, fit: BoxFit.cover)
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                                : Image.network('https://ui-avatars.com/api/?name=$nombre&background=6BCE7A&color=fff&size=200')),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: secondaryTeal, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nombre, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: darkText)),
                    Text(_rolController.text.isEmpty ? "Tu Profesión" : _rolController.text, style: TextStyle(fontSize: 15, color: darkText.withOpacity(0.6))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 15,
            runSpacing: 5,
            children: [
              _buildInfoMini(Icons.location_on_outlined, _ubicacionController.text.isEmpty ? "Sin ubicación" : _ubicacionController.text),
              _buildInfoMini(Icons.link, "tuportfolio.com"),
              _buildInfoMini(Icons.calendar_today_outlined, "Miembro desde 2024"),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Text("1,234", style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
              Text(" Conexiones", style: TextStyle(color: darkText.withOpacity(0.6))),
              const SizedBox(width: 20),
              Text("567", style: TextStyle(fontWeight: FontWeight.bold, color: darkText)),
              Text(" Seguidores", style: TextStyle(color: darkText.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMini(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: darkText.withOpacity(0.4)),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(fontSize: 13, color: darkText.withOpacity(0.6))),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: secondaryTeal,
        unselectedLabelColor: darkText.withOpacity(0.5),
        indicatorColor: secondaryTeal,
        indicatorWeight: 3,
        tabs: const [
          Tab(text: "Acerca de"),
          Tab(text: "Experiencia"),
          Tab(text: "Publicaciones"),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return [
      _buildAcercaDeTab(),
<<<<<<< HEAD
      _buildExperienciaTab(),
      _buildPublicacionesTab(),
    ][_tabController.index];
  }

  /// Fondo SkillSwap reutilizable para tarjetas y secciones.
  BoxDecoration _fondoSkillSwapDecoration({double radius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      image: const DecorationImage(
        image: AssetImage('assets/Fondo_SkillSwap.png'),
        fit: BoxFit.cover,
        alignment: Alignment.center,
      ),
    );
  }

  Widget _buildFondoOverlay({
    required Widget child,
    double radius = 20,
    double overlayOpacity = 0.88,
  }) {
    return Container(
      decoration: _fondoSkillSwapDecoration(radius: radius),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(overlayOpacity),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildExperienciaTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildBotonLlamativo(
            label: "AGREGAR EXPERIENCIA",
            icon: Icons.add_business_outlined,
            color: secondaryTeal,
            onPressed: () => _mostrarDialogoItem(esExperiencia: true),
          ),
          const SizedBox(height: 20),
          ..._experiencias.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            return _buildItemCard(
              title: item['titulo'] ?? "",
              subtitle: item['entidad'] ?? "",
              description: item['descripcion'] ?? "",
              archivo: item['archivoNombre'],
              onEdit: () => _mostrarDialogoItem(esExperiencia: true, index: index),
              onDelete: () {
                setState(() => _experiencias.removeAt(index));
                _guardarPerfil();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPublicacionesTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildBotonLlamativo(
            label: "NUEVA PUBLICACIÓN",
            icon: Icons.post_add_rounded,
            color: secondaryTeal,
            onPressed: () => _mostrarDialogoItem(esExperiencia: false),
          ),
          const SizedBox(height: 20),
          ..._publicaciones.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> item = entry.value;
            return _buildItemCard(
              title: item['titulo'] ?? "",
              subtitle: item['fecha'] ?? "",
              description: item['descripcion'] ?? "",
              archivo: item['archivoNombre'],
              onEdit: () => _mostrarDialogoItem(esExperiencia: false, index: index),
              onDelete: () {
                setState(() => _publicaciones.removeAt(index));
                _guardarPerfil();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemCard({
    required String title,
    required String subtitle,
    required String description,
    String? archivo,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: _fondoSkillSwapDecoration(radius: 15),
      child: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: lightGray.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: darkText)),
              ),
              IconButton(icon: const Icon(Icons.edit, size: 18, color: Colors.blue), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: onDelete),
            ],
          ),
          Text(subtitle, style: TextStyle(color: secondaryTeal, fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 8),
          Text(description, style: TextStyle(color: darkText.withOpacity(0.7), fontSize: 14)),
          if (archivo != null && archivo.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.description_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(archivo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }

  void _mostrarDialogoItem({required bool esExperiencia, int? index}) {
    final tituloController = TextEditingController(text: index != null ? (esExperiencia ? _experiencias[index]['titulo'] : _publicaciones[index]['titulo']) : "");
    final entidadController = TextEditingController(text: index != null ? (esExperiencia ? _experiencias[index]['entidad'] : _publicaciones[index]['fecha']) : "");
    final descController = TextEditingController(text: index != null ? (esExperiencia ? _experiencias[index]['descripcion'] : _publicaciones[index]['descripcion']) : "");
    String? archivoBase64 = index != null ? (esExperiencia ? _experiencias[index]['archivo'] : _publicaciones[index]['archivo']) : null;
    String? nombreArchivo = index != null ? (esExperiencia ? _experiencias[index]['archivoNombre'] : _publicaciones[index]['archivoNombre']) : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(index == null ? "Agregar ${esExperiencia ? 'Experiencia' : 'Publicación'}" : "Editar ${esExperiencia ? 'Experiencia' : 'Publicación'}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: tituloController, decoration: InputDecoration(labelText: esExperiencia ? "Cargo / Título" : "Título de Publicación")),
                TextField(controller: entidadController, decoration: InputDecoration(labelText: esExperiencia ? "Empresa / Lugar" : "Fecha / Enlace")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Descripción"), maxLines: 3),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform.pickFiles();
                    if (result != null) {
                      File file = File(result.files.single.path!);
                      setDialogState(() {
                        nombreArchivo = result.files.single.name;
                        archivoBase64 = base64Encode(file.readAsBytesSync());
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(nombreArchivo ?? "Cargar Documento/Imagen"),
                  style: ElevatedButton.styleFrom(backgroundColor: lightGray, foregroundColor: darkText),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () {
                Map<String, dynamic> nuevoItem = {
                  'titulo': tituloController.text,
                  esExperiencia ? 'entidad' : 'fecha': entidadController.text,
                  'descripcion': descController.text,
                  'archivo': archivoBase64,
                  'archivoNombre': nombreArchivo,
                };
                setState(() {
                  if (index == null) {
                    esExperiencia ? _experiencias.add(nuevoItem) : _publicaciones.add(nuevoItem);
                  } else {
                    esExperiencia ? _experiencias[index] = nuevoItem : _publicaciones[index] = nuevoItem;
                  }
                });
                Navigator.pop(context);
                _guardarPerfil();
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

=======
      const Center(child: Text("Próximamente: Historial laboral")),
      const Center(child: Text("Próximamente: Tus posts")),
    ][_tabController.index];
  }

>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  Widget _buildAcercaDeTab() {
    List<String> skills = _habilidadesController.text.split(',').where((s) => s.trim().isNotEmpty).toList();
    if (skills.isEmpty) skills = ["Flutter", "Dart", "Firebase"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildEditCard(
            title: "Sobre mí",
            child: TextField(
              controller: _acercaDeController,
              maxLines: null,
              decoration: const InputDecoration(border: InputBorder.none, hintText: "Escribe algo sobre ti..."),
              style: TextStyle(height: 1.5, color: darkText.withOpacity(0.8)),
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
          const SizedBox(height: 20),
          _buildEditCard(
            title: "Habilidades",
            icon: Icons.workspace_premium_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _habilidadesController,
                  decoration: InputDecoration(
                    hintText: "Agrega habilidades separadas por coma",
                    hintStyle: TextStyle(fontSize: 12, color: darkText.withOpacity(0.3)),
                    border: InputBorder.none,
                  ),
                  onChanged: (v) => setState(() {}),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: skills.asMap().entries.map((entry) {
                    return _buildSkillChip(entry.value.trim())
                        .animate()
                        .fadeIn(delay: (400 + (entry.key * 100)).ms)
                        .scale();
                  }).toList(),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1, end: 0),
          const SizedBox(height: 20),
          _buildEditCard(
            title: "Datos de contacto",
            child: Column(
              children: [
                _buildSimpleField(Icons.phone, "Teléfono", _telefonoController),
                _buildSimpleField(Icons.location_on, "Ubicación", _ubicacionController),
                _buildSimpleField(Icons.work, "Rol Actual", _rolController),
              ],
            ),
          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }

  Widget _buildEditCard({required String title, required Widget child, IconData? icon}) {
    return Container(
<<<<<<< HEAD
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: _buildFondoOverlay(
        radius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) Icon(icon, size: 20, color: secondaryTeal),
                if (icon != null) const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
=======
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9), // Glassmorphism ligero
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) Icon(icon, size: 20, color: secondaryTeal),
              if (icon != null) const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: darkText)),
            ],
          ),
          const SizedBox(height: 15),
          child,
        ],
      ),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(color: secondaryTeal, fontWeight: FontWeight.w600, fontSize: 13)),
    );
  }

  Widget _buildSimpleField(IconData icon, String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        icon: Icon(icon, size: 18, color: primaryGreen),
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: darkText.withOpacity(0.4)),
        border: InputBorder.none,
      ),
      style: TextStyle(fontSize: 14, color: darkText),
    );
  }
}

