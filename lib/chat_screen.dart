import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverPhoto;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverName,
    required this.receiverPhoto,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  final ImagePicker _picker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _showEmoji = false;
  bool _isUploading = false;
  bool _isRecording = false;

  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedFileType; // 'image', 'file', 'audio'

  String get _chatId {
    List<String> ids = [_currentUserId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  // ─── Texto ─────────────────────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    if (mounted) setState(() => _showEmoji = false);

    await FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ─── Selección de imagen ───────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
          _selectedFileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          _selectedFileType = 'image';
        });
      }
    } catch (e) {
      debugPrint("Error al seleccionar imagen: $e");
    }
  }

  // ─── Selección de archivo ──────────────────────────────────────────────────
  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;
        if (platformFile.path != null) {
          setState(() {
            _selectedFile = File(platformFile.path!);
            _selectedFileName = platformFile.name;
            _selectedFileType = 'file';
          });
        }
      }
    } catch (e) {
      debugPrint("Error al seleccionar archivo: $e");
    }
  }

  // ─── Audio ─────────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        if (mounted) setState(() => _isRecording = true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Permiso de micrófono denegado. Actívalo en ajustes.")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error al grabar: $e");
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (mounted) setState(() => _isRecording = false);

      if (path != null) {
        setState(() {
          _selectedFile = File(path);
          _selectedFileName =
              'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          _selectedFileType = 'audio';
        });
      }
    } catch (e) {
      debugPrint("Error al detener grabación: $e");
    }
  }

  // ✅ Upload y envío (Firestore Base64 para saltar Storage)
  Future<void> _uploadAndSendSelected() async {
    if (_selectedFile == null) return;
    if (!(await _selectedFile!.exists())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("No se pudo leer el archivo. Intenta de nuevo.")),
        );
      }
      return;
    }

    if (mounted) setState(() => _isUploading = true);

    try {
      final type = _selectedFileType ?? 'file';
      final file = _selectedFile!;
      final fileName =
          _selectedFileName ?? '${DateTime.now().millisecondsSinceEpoch}';

      String base64Content = "";

      if (type == 'image') {
        // Comprimir imagen para no exceder 1MB de Firestore
        final result = await FlutterImageCompress.compressWithFile(
          file.absolute.path,
          quality: 40, // Calidad baja para que pese poco
          minWidth: 800,
          minHeight: 800,
        );
        if (result != null) {
          base64Content = base64Encode(result);
        } else {
          base64Content = base64Encode(await file.readAsBytes());
        }
      } else {
        // Audio o Archivo (máximo recomendado ~500kb en Base64)
        final bytes = await file.readAsBytes();
        if (bytes.length > 800000) {
          throw "El archivo es muy pesado para el plan gratuito. Máximo 800KB.";
        }
        base64Content = base64Encode(bytes);
      }

      if (type == 'image') {
        await _enviarMensajeImagen(base64Content);
      } else if (type == 'audio') {
        await _enviarMensajeAudio(base64Content);
      } else {
        await _enviarMensajeArchivo(base64Content, fileName);
      }

      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedFile = null;
          _selectedFileName = null;
          _selectedFileType = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Error: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  // ✅ Enviar mensaje de imagen (Base64)
  Future<void> _enviarMensajeImagen(String base64Data) async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': base64Data,
      'type': 'image',
      'timestamp': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': "📷 Foto",
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ✅ Enviar mensaje de audio (Base64)
  Future<void> _enviarMensajeAudio(String base64Data) async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': base64Data,
      'type': 'audio',
      'timestamp': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': "🎤 Audio",
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ✅ Enviar mensaje de archivo (Base64)
  Future<void> _enviarMensajeArchivo(String base64Data, String fileName) async {
    await FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': base64Data,
      'fileName': fileName,
      'type': 'file',
      'timestamp': FieldValue.serverTimestamp(),
    });
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': "📎 $fileName",
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _downloadAndOpenFile(String url, String fileName) async {
    try {
      final file = await DefaultCacheManager().getSingleFile(url);
      await OpenFilex.open(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al abrir archivo: $e")),
        );
      }
    }
  }

  void _mostrarEmojis() {
    FocusScope.of(context).unfocus();
    setState(() => _showEmoji = !_showEmoji);
  }

  void _cancelarSeleccion() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
      _selectedFileType = null;
    });
  }

  void _iniciarLlamada(bool video) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title:
            Text("Iniciando ${video ? "videollamada" : "llamada de voz"}"),
        content: Text("Llamando a ${widget.receiverName}..."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Colgar")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF6BCE7A);
    const Color darkText = Color(0xFF334A5F);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new, color: darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: primaryGreen.withOpacity(0.2),
              child: widget.receiverPhoto.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        widget.receiverPhoto,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          widget.receiverName.isNotEmpty
                              ? widget.receiverName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  : Text(
                      widget.receiverName.isNotEmpty
                          ? widget.receiverName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          color: darkText, fontWeight: FontWeight.bold),
                    ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.receiverName,
                    style: const TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const Text("En línea ahora",
                    style: TextStyle(color: primaryGreen, fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.call, color: darkText),
              onPressed: () => _iniciarLlamada(false)),
          IconButton(
              icon: const Icon(Icons.videocam, color: darkText),
              onPressed: () => _iniciarLlamada(true)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chat')
                  .doc(_chatId)
                  .collection('mensajes')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!.docs;
                if (messages.isEmpty) {
                  return const Center(
                    child: Text("¡Di hola! 👋",
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msgData =
                        messages[index].data() as Map<String, dynamic>;
                    final bool isMe =
                        msgData['senderId'] == _currentUserId;
                    final String type = msgData['type'] ?? 'text';
                    switch (type) {
                      case 'image':
                        return _buildImageBubble(msgData['mensaje'] ?? "",
                            isMe, msgData['timestamp'] as Timestamp?);
                      case 'file':
                        return _buildFileBubble(
                            msgData['mensaje'] ?? "",
                            msgData['fileName'] ?? "Archivo",
                            isMe,
                            msgData['timestamp'] as Timestamp?);
                      case 'audio':
                        return _buildAudioBubble(msgData['mensaje'] ?? "",
                            isMe, msgData['timestamp'] as Timestamp?);
                      default:
                        return _buildMessageBubble(
                            msgData['mensaje'] ?? "",
                            isMe,
                            msgData['timestamp'] as Timestamp?);
                    }
                  },
                );
              },
            ),
          ),

          if (_selectedFile != null) _buildPreviewPanel(primaryGreen),

          if (_isUploading)
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
              color: Colors.white,
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: primaryGreen),
                  ),
                  const SizedBox(width: 10),
                  const Text("Subiendo...",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),

          _buildMessageInput(primaryGreen),

          if (_showEmoji)
            SizedBox(
              height: 250,
              child: emoji.EmojiPicker(
                textEditingController: _messageController,
                config: const emoji.Config(
                  height: 250,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: emoji.EmojiViewConfig(
                    columns: 7,
                    emojiSizeMax: 32,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    gridPadding: EdgeInsets.zero,
                    backgroundColor: Color(0xFFF2F2F2),
                  ),
                  categoryViewConfig: emoji.CategoryViewConfig(
                    initCategory: emoji.Category.RECENT,
                    indicatorColor: Color(0xFF6BCE7A),
                    iconColor: Colors.grey,
                    iconColorSelected: Color(0xFF6BCE7A),
                    backspaceColor: Color(0xFF6BCE7A),
                  ),
                  skinToneConfig: emoji.SkinToneConfig(
                    dialogBackgroundColor: Colors.white,
                    indicatorColor: Colors.grey,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Preview panel ──────────────────────────────────────────────────────────
  Widget _buildPreviewPanel(Color green) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _selectedFileType == 'image' && _selectedFile != null
                ? Image.file(
                    _selectedFile!,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 55,
                      height: 55,
                      color: green.withOpacity(0.1),
                      child: Icon(Icons.image, color: green),
                    ),
                  )
                : Container(
                    width: 55,
                    height: 55,
                    color: green.withOpacity(0.1),
                    child: Icon(
                      _selectedFileType == 'audio'
                          ? Icons.mic
                          : Icons.insert_drive_file,
                      color: green,
                      size: 30,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedFileType == 'image'
                      ? "Imagen lista para enviar"
                      : _selectedFileType == 'audio'
                          ? "Audio grabado"
                          : _selectedFileName ?? "Archivo",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                if (_selectedFile != null)
                  FutureBuilder<int>(
                    future: _selectedFile!.length(),
                    builder: (_, snap) => Text(
                      snap.hasData
                          ? "${(snap.data! / 1024).toStringAsFixed(1)} KB"
                          : "",
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: _cancelarSeleccion,
          ),
          IconButton(
            icon: Icon(Icons.check_circle, color: green, size: 32),
            onPressed: _isUploading ? null : _uploadAndSendSelected,
          ),
        ],
      ),
    );
  }

  // ── Burbujas ───────────────────────────────────────────────────────────────
  // ── Burbujas (Diseño Estilo Moderno) ───────────────────────────────────────
  Widget _buildImageBubble(String data, bool isMe, Timestamp? timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () => _openFullScreenImage(data),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: data.startsWith('http')
                    ? Image.network(
                        data,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                      )
                    : Image.memory(
                        base64Decode(data),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image, size: 80),
                      ),
              ),
            ),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(right: 4, top: 2),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openFullScreenImage(String data) {
    if (data.isEmpty) return;
    ImageProvider imageProvider;
    if (data.startsWith('http')) {
      imageProvider = NetworkImage(data);
    } else {
      try {
        imageProvider = MemoryImage(base64Decode(data));
      } catch (e) {
        debugPrint("Error al decodificar imagen: $e");
        return;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadFileToGallery(
                    data, "imagen_${DateTime.now().millisecondsSinceEpoch}.jpg"),
              ),
            ],
          ),
          body: Center(
            child: PhotoView(
              imageProvider: imageProvider,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Nueva función para descargar archivos (incluso Base64) a la carpeta de Descargas
  Future<void> _downloadFileToGallery(String data, String fileName) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Guardando en descargas...")),
        );
      }

      Uint8List bytes;
      if (data.startsWith('http')) {
        final file = await DefaultCacheManager().getSingleFile(data);
        bytes = await file.readAsBytes();
      } else {
        bytes = base64Decode(data);
      }

      // En Android/iOS usamos el directorio de aplicaciones o descargas
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getExternalStorageDirectory();
        }
      } else {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      final String filePath = "${downloadsDir!.path}/$fileName";
      final File file = File(filePath);
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("¡Guardado en: $filePath!"),
            backgroundColor: Colors.green,
            action: SnackBarAction(
                label: "Abrir",
                textColor: Colors.white,
                onPressed: () => OpenFilex.open(filePath)),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al descargar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al descargar: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Widget _buildFileBubble(
      String data, String fileName, bool isMe, Timestamp? timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () async {
                if (data.startsWith('http')) {
                  await _downloadAndOpenFile(data, fileName);
                } else {
                  try {
                    final bytes = base64Decode(data);
                    final tempDir = await getTemporaryDirectory();
                    final file =
                        await File('${tempDir.path}/$fileName').create();
                    await file.writeAsBytes(bytes);
                    await OpenFilex.open(file.path);
                  } catch (e) {
                    debugPrint("Error al abrir archivo: $e");
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.blue, size: 30),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      fileName,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_for_offline, color: Colors.blue, size: 24),
                    onPressed: () => _downloadFileToGallery(data, fileName),
                  ),
                ],
              ),
            ),
            if (timestamp != null)
              Text(
                _formatTime(timestamp),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioBubble(String data, bool isMe, Timestamp? timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.play_circle_fill,
                  size: 32, color: isMe ? Colors.green : Colors.grey),
              onPressed: () async {
                if (data.startsWith('http')) {
                  await _audioPlayer.play(UrlSource(data));
                } else {
                  try {
                    final bytes = base64Decode(data);
                    final tempDir = await getTemporaryDirectory();
                    final file =
                        await File('${tempDir.path}/temp_audio.m4a').create();
                    await file.writeAsBytes(bytes);
                    await _audioPlayer.play(DeviceFileSource(file.path));
                  } catch (e) {
                    debugPrint("Error al reproducir audio: $e");
                  }
                }
              },
            ),
            const Icon(Icons.graphic_eq, color: Colors.grey),
            const SizedBox(width: 8),
            if (timestamp != null)
              Text(
                _formatTime(timestamp),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
      String text, bool isMe, Timestamp? timestamp) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Colors.black : const Color(0xFFF1F4F7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text,
                style: TextStyle(
                    color: isMe
                        ? Colors.white
                        : const Color(0xFF334A5F),
                    fontSize: 15)),
            if (timestamp != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _formatTime(timestamp),
                  style: TextStyle(
                      color: isMe
                          ? Colors.white.withOpacity(0.6)
                          : Colors.grey.shade500,
                      fontSize: 10),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput(Color green) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon:
                  const Icon(Icons.camera_alt_outlined, color: Colors.grey),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            IconButton(
              icon: const Icon(Icons.image_outlined, color: Colors.grey),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            // Mantener presionado para grabar, soltar para detener
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopRecording(),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic_none_rounded,
                  color: _isRecording ? Colors.red : Colors.grey,
                  size: 24,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.attach_file, color: Colors.grey),
              onPressed: _pickFile,
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F4F7),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: "Escribe un mensaje...",
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 10),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.emoji_emotions_outlined,
                          color: _showEmoji ? green : Colors.grey),
                      onPressed: _mostrarEmojis,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.send_rounded, color: green),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}