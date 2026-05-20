import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart'; // Para la cámara
import 'package:file_picker/file_picker.dart';   // Para los archivos
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- SERVICIO DE IA ---
class AIService {
  // REEMPLAZA ESTAS LLAVES POR TUS LLAVES REALES
  static const String _geminiKey = "AIzaSyCpsLCJLg3VpdFS1TgNOYcylxsXH11QykQ";

  // Lógica para Gemini
  Future<String> askGemini(String prompt, List<XFile> files) async {
    final cleanPrompt = prompt.toLowerCase();
    
    // Lista de palabras clave para detectar intención de crear imagen
    final triggerWords = ["genera", "crea", "hazme", "dibújame", "dibuja", "muéstrame una imagen", "imagina", "generate", "create", "imagine"];
    final targetWords = ["imagen", "foto", "dibujo", "retrato", "image", "picture", "drawing", "pintura", "ilustración"];
    
    bool isImageRequest = triggerWords.any((word) => cleanPrompt.contains(word)) && 
                          targetWords.any((word) => cleanPrompt.contains(word));

    // Refuerzo: si solo dice "genera...", "dibuja..." o "imagina..." seguido de algo, también intentamos
    if (!isImageRequest) {
      if (cleanPrompt.startsWith("dibuja") || cleanPrompt.startsWith("imagina") || cleanPrompt.startsWith("genera")) {
        isImageRequest = true;
      }
    }

    if (isImageRequest) {
      return await generateImage(prompt);
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash', // El modelo más estable y gratuito
      apiKey: _geminiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: 2048,
        temperature: 0.7,
      ),
    );

    try {
      final List<Content> contentList = [];
      final List<Part> parts = [TextPart(prompt)];

      for (var file in files) {
        final bytes = await file.readAsBytes();
        final mimeType = _getMimeType(file.name);
        parts.add(DataPart(mimeType, bytes));
      }

      contentList.add(Content.multi(parts));
      final response = await model.generateContent(contentList);
      return response.text ?? "Gemini no pudo generar una respuesta.";
    } catch (e) {
      debugPrint("Error detallado de Gemini: $e");
      return "ERROR_API: $e";
    }
  }

  String _getMimeType(String fileName) {
    if (fileName.endsWith('.png')) return 'image/png';
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) return 'image/jpeg';
    if (fileName.endsWith('.pdf')) return 'application/pdf';
    return 'application/octet-stream';
  }

  // Lógica para generar imágenes (Usando Pollinations.ai que es GRATIS y rápido)
  Future<String> generateImage(String prompt) async {
    // Pollinations es una API gratuita que genera imágenes basándose en una URL
    final encodedPrompt = Uri.encodeComponent(prompt);
    final imageUrl = "https://pollinations.ai/p/$encodedPrompt?width=1024&height=1024&seed=${DateTime.now().millisecond}&model=flux";
    return "IMAGE_URL:$imageUrl";
  }
}

class InterfazIA extends StatefulWidget {
  const InterfazIA({super.key});

  @override
  State<InterfazIA> createState() => _InterfazIAState();
}

class _InterfazIAState extends State<InterfazIA> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  late AnimationController _animationController;
  late Animation<double> _waveAnimation;

  // Variables de Estado
  List<Map<String, dynamic>> _messages = [];
  final List<XFile> _selectedFiles = [];
  String _selectedProvider = 'Gemini';
  bool _isLoading = false;
  String? _currentChatId;

  // Lista de chats guardados
  List<Map<String, dynamic>> _savedChats = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _cargarChats();
    _saludarUsuario();
  }

  void _saludarUsuario() {
    final user = _auth.currentUser;
    if (user != null) {
      String name = user.displayName ?? user.email?.split('@')[0] ?? "Usuario";
      setState(() {
        _messages.add({
          "text": "👋 ¡Hola $name! Soy tu asistente SkillSwap. ¿En qué puedo ayudarte hoy?",
          "isUser": false,
          "isAnimated": true
        });
      });
    }
  }

  Future<void> _cargarChats() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('conversaciones')
        .where('userId', isEqualTo: user.uid)
        .orderBy('fecha', descending: true)
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          _savedChats = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              "id": doc.id,
              "title": data['titulo'] ?? "Chat sin título",
              "date": data['fecha'] != null 
                  ? (data['fecha'] as Timestamp).toDate().toString().substring(0, 10) 
                  : "Reciente"
            };
          }).toList();
        });
      }
    });
  }

  void _createNewChat() {
    setState(() {
      _messages = [];
      _currentChatId = null;
    });
    _saludarUsuario();
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _loadChat(String chatId) async {
    setState(() => _isLoading = true);
    try {
      final doc = await _firestore.collection('conversaciones').doc(chatId).get();
      if (doc.exists) {
        final data = doc.data()!;
        final List<dynamic> history = data['mensajes'] ?? [];
        setState(() {
          _messages = history.cast<Map<String, dynamic>>();
          _currentChatId = chatId;
        });
      }
    } catch (e) {
      debugPrint("Error al cargar chat: $e");
    } finally {
      setState(() => _isLoading = false);
      if (Navigator.canPop(context)) Navigator.pop(context);
    }
  }

  Future<void> _deleteChat(String chatId) async {
    try {
      // Confirmación rápida
      bool? confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Eliminar Chat"),
          content: const Text("¿Estás seguro de que quieres eliminar esta conversación?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("Eliminar", style: TextStyle(color: Colors.red))
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestore.collection('conversaciones').doc(chatId).delete();
        if (_currentChatId == chatId) {
          _createNewChat();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conversación eliminada")),
        );
      }
    } catch (e) {
      debugPrint("Error al eliminar chat: $e");
    }
  }

  Future<void> _saveMessageToFirestore() async {
    final user = _auth.currentUser;
    if (user == null || _messages.isEmpty) return;

    try {
      // Buscar el primer mensaje del usuario para el título
      String chatTitle = "Nuevo Chat";
      for (var m in _messages) {
        if (m['isUser'] == true && m['text'] != "(Imagen/Archivo)") {
          chatTitle = m['text'];
          break;
        }
      }
      
<<<<<<< HEAD
      if (chatTitle.length > 35) chatTitle = "${chatTitle.substring(0, 32)}...";
=======
      if (chatTitle.length > 35) chatTitle = chatTitle.substring(0, 32) + "...";
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

      if (_currentChatId == null) {
        // Crear nuevo documento
        final docRef = await _firestore.collection('conversaciones').add({
          'userId': user.uid,
          'titulo': chatTitle,
          'fecha': FieldValue.serverTimestamp(),
          'mensajes': _messages,
        });
        _currentChatId = docRef.id;
      } else {
        // Actualizar documento existente
        await _firestore.collection('conversaciones').doc(_currentChatId).update({
          'mensajes': _messages,
          'titulo': chatTitle, // Actualizamos el título por si cambió la primera petición
          'fecha': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      debugPrint("Error al guardar en Firestore: $e");
    }
  }

  // Color definitions (Ensure these exist if not found globally)
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color secondaryTeal = const Color(0xFF00A99D);
  final Color darkText = const Color(0xFF334A5F);
  final Color lightGray = const Color(0xFFF5F7F9);

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // FUNCIÓN PARA ABRIR LA CÁMARA
  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // Opcional: comprime un poco la imagen
      );
      
      if (photo != null) {
        setState(() {
          _selectedFiles.add(photo);
        });
      }
    } catch (e) {
      debugPrint("Error al abrir la cámara: $e");
    }
  }

  // FUNCIÓN PARA SUBIR ARCHIVOS (PDF, DOCX, IMÁGENES, ETC.)
  Future<void> _pickFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, // Permite elegir varios a la vez
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          _selectedFiles.addAll(result.paths.whereType<String>().map((path) => XFile(path)));
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivos: $e");
    }
  }

  // Lógica de Envío
  Future<void> _sendMessage() async {
    String userPrompt = _controller.text.trim();
    if (userPrompt.isEmpty && _selectedFiles.isEmpty) return;

    setState(() {
      _messages.add({"text": userPrompt.isEmpty ? "(Imagen/Archivo)" : userPrompt, "isUser": true});
      _controller.clear();
      _isLoading = true;
    });

    try {
      String aiResponse = await _aiService.askGemini(userPrompt, _selectedFiles);

      setState(() {
        if (aiResponse.startsWith("ERROR_API:")) {
          _messages.add({
            "text": "Error Técnico: ${aiResponse.replaceFirst("ERROR_API:", "")}\n\nRevisa si tu API Key está activa en Google AI Studio.",
            "isUser": false
          });
        } else {
          _messages.add({"text": aiResponse, "isUser": false});
        }
        _selectedFiles.clear();
      });
      // Guardar en Firestore después de cada respuesta
      await _saveMessageToFirestore();
    } catch (e) {
      setState(() {
        _messages.add({
          "text": "Error crítico de conexión. Por favor reintenta.",
          "isUser": false
        });
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // FUNCIÓN PARA GENERAR IMAGEN
  Future<void> _handleGenerateImage() async {
    String userPrompt = _controller.text.trim();
    if (userPrompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Escribe lo que quieres generar")),
      );
      return;
    }

    setState(() {
      _messages.add({"text": "Generando imagen de: $userPrompt", "isUser": true});
      _controller.clear();
      _isLoading = true;
    });

    try {
      String aiResponse = await _aiService.generateImage(userPrompt);
      setState(() {
        _messages.add({"text": aiResponse, "isUser": false});
      });
      // Guardar también las imágenes generadas
      await _saveMessageToFirestore();
    } catch (e) {
      setState(() {
        _messages.add({"text": "Error al generar imagen.", "isUser": false});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: darkText),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          "AI Assistant",
          style: TextStyle(color: darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      drawer: Drawer(
        backgroundColor: lightGray,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryGreen),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/Chatbot SkillSwap re.png', // Usando la imagen del bot que me pasaste
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Mis Conversaciones",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: secondaryTeal),
              title: const Text("Nueva Conversación", style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: _createNewChat,
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _savedChats.length,
                itemBuilder: (context, index) {
                  final chat = _savedChats[index];
                  return ListTile(
                    leading: Icon(Icons.chat_bubble_outline, color: primaryGreen),
                    title: Text(
                      chat["title"],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(chat["date"], style: const TextStyle(fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                      onPressed: () => _deleteChat(chat["id"]),
                    ),
                    onTap: () => _loadChat(chat["id"]),
                  );
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.grey),
              title: const Text("Configuración"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Fondo_SkillSwap.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Icono e Informacion en la parte superior central
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 5),
                  child: Column(
                    children: [
                      RotationTransition(
                        turns: _waveAnimation,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(color: primaryGreen, width: 2),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/Chatbot SkillSwap re.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Removí el texto estático para no duplicar el saludo animado
                      const SizedBox(height: 10),
                      // Acciones rápidas (Botones)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildQuickAction(Icons.camera_alt, "Foto", _takePhoto),
                            const SizedBox(width: 8),
                            _buildQuickAction(Icons.folder, "Archivo", _pickFiles),
                            const SizedBox(width: 8),
                            _buildQuickAction(Icons.auto_awesome, "IA Imagen", _handleGenerateImage),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Lista de Mensajes Dinámica
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(child: Text("Hablemos...", style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) => _buildChatBubble(
                            message: _messages[index]["text"],
                            isUser: _messages[index]["isUser"],
                          ),
                        ),
                ),
                if (_isLoading) 
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LinearProgressIndicator(color: secondaryTeal),
                  ),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotationTransition(
            turns: _waveAnimation,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: primaryGreen, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/Chatbot SkillSwap re.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("Hola Master, elige una IA y hablemos.", 
            style: TextStyle(color: darkText, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          // Acciones rápidas (Tomar Foto, Subir Archivo, etc.)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQuickAction(Icons.camera_alt, "Tomar\nFoto", _takePhoto),
              _buildQuickAction(Icons.folder, "Subir\nArchivo", _pickFiles),
              _buildQuickAction(Icons.auto_awesome, "Generar\nImagen", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['Gemini', 'ChatGPT', 'Claude'].map((p) {
          bool sel = _selectedProvider == p;
          return GestureDetector(
            onTap: () => setState(() => _selectedProvider = p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: sel ? secondaryTeal : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: sel ? secondaryTeal : Colors.grey.shade300),
                boxShadow: sel ? [BoxShadow(color: secondaryTeal.withOpacity(0.3), blurRadius: 4)] : [],
              ),
              child: Text(p, 
                style: TextStyle(
                  color: sel ? Colors.white : darkText, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold
                )),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryGreen.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble({required String message, required bool isUser}) {
    // Definimos los colores aquí para consistencia
    final bubbleColor = isUser ? primaryGreen : Colors.white;
    final textColor = isUser ? Colors.white : darkText;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                    border: Border.all(color: primaryGreen, width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/Chatbot SkillSwap re.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: isUser ? const Radius.circular(22) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
                  ),
                  child: (message.startsWith("IMAGE_URL:"))
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Imagen generada con Éxito",
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isUser ? Colors.white70 : Colors.blueGrey),
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                message.replaceFirst("IMAGE_URL:", ""),
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return const Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Text("Error al cargar la imagen"),
                              ),
                            ),
                          ],
                        )
                      : SelectableText(
                          message,
                          style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              height: 1.4),
                        ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 19,
                  backgroundColor: secondaryTeal,
                  child: const Icon(Icons.person, color: Colors.white, size: 22),
                ),
              ],
            ],
          ),
          const SizedBox(height: 2),
          Padding(
            padding: EdgeInsets.only(
              left: isUser ? 0 : 46,
              right: isUser ? 46 : 0,
            ),
            child: Text(
              isUser ? "Tú" : "SkillBot",
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]
      ),
      child: Column(
        children: [
          if (_selectedFiles.isNotEmpty)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, size: 14, color: Colors.blueGrey),
                        const SizedBox(width: 5),
                        Text(_selectedFiles[index].name, style: const TextStyle(fontSize: 11)),
                        GestureDetector(
                          onTap: () => setState(() => _selectedFiles.removeAt(index)),
                          child: const Icon(Icons.close, size: 14, color: Colors.red),
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add_circle_outline, color: secondaryTeal), 
                onPressed: _pickFiles,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(color: lightGray, borderRadius: BorderRadius.circular(25)),
                  child: TextField(
                    controller: _controller,
                    maxLines: 5,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: TextStyle(color: darkText),
                    decoration: const InputDecoration(hintText: "Escribe un mensaje...", border: InputBorder.none),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Selector de IA pegado al botón de enviar
              Container(
                decoration: BoxDecoration(
                  color: secondaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: PopupMenuButton<String>(
                  initialValue: _selectedProvider,
                  onSelected: (String value) {
                    setState(() {
                      _selectedProvider = value;
                    });
                  },
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedProvider.substring(0, 1), style: TextStyle(color: secondaryTeal, fontWeight: FontWeight.bold)),
                      Icon(Icons.arrow_drop_down, color: secondaryTeal, size: 16),
                    ],
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(value: 'Gemini', child: Text('Gemini')),
                    const PopupMenuItem<String>(value: 'ChatGPT', child: Text('ChatGPT')),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              CircleAvatar(
                backgroundColor: secondaryTeal,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}