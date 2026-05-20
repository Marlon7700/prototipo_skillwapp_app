import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:flutter/services.dart';
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
<<<<<<< HEAD
import 'dart:async';
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
<<<<<<< HEAD
  bool _isLocked = false;
  bool _isTextEmpty = true;
  int _recordSeconds = 0;
  var _recordTimer; // Timer? de dart:async

  String? _backgroundData; // Base64 de la imagen de fondo
  Uint8List? _cachedBgBytes; // Cache de bytes para rendimiento
  Color _backgroundColor = Colors.white; // Color de fondo por defecto
  Color _bubbleMeColor = const Color(0xFFE7FFDB); // Color defecto burbuja propia
  Color _bubbleOtherColor = Colors.white; // Color defecto burbuja ajena
  String _bubbleDesign = 'modern'; // 'modern', 'classic', 'rounded'
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

  File? _selectedFile;
  String? _selectedFileName;
  String? _selectedFileType; // 'image', 'file', 'audio'

<<<<<<< HEAD
  // Modo selección y edición de mensajes (estilo WhatsApp)
  bool _selectionMode = false;
  final Set<String> _selectedMessageIds = {};
  final Map<String, bool> _selectedIsMe = {};
  final Map<String, String> _selectedCopyText = {};
  final Map<String, String> _selectedType = {};
  String? _editingMessageId;
  Map<String, dynamic>? _mensajeRespondiendo;

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  String get _chatId {
    List<String> ids = [_currentUserId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

<<<<<<< HEAD
  Map<String, dynamic> _camposBaseMensaje() {
    final campos = <String, dynamic>{
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    };
    if (_mensajeRespondiendo != null) {
      campos['replyTo'] = Map<String, dynamic>.from(_mensajeRespondiendo!);
    }
    return campos;
  }

  void _limpiarRespuesta() {
    if (_mensajeRespondiendo != null && mounted) {
      setState(() => _mensajeRespondiendo = null);
    }
  }

  void _configurarRespuesta({
    required String messageId,
    required String text,
    required bool isMe,
    required String type,
    required Map<String, dynamic> msgData,
  }) {
    setState(() {
      _mensajeRespondiendo = {
        'messageId': messageId,
        'text': text,
        'type': type,
        'senderId': msgData['senderId'] ?? (isMe ? _currentUserId : widget.receiverId),
        'senderName': isMe ? 'Tú' : widget.receiverName,
      };
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  void _cancelarRespuesta() {
    setState(() => _mensajeRespondiendo = null);
  }

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  // ─── Texto ─────────────────────────────────────────────────────────────────
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

<<<<<<< HEAD
    if (_editingMessageId != null) {
      await _guardarEdicionMensaje(text);
      return;
    }

    _messageController.clear();
    if (mounted) {
      setState(() {
        _showEmoji = false;
        _mensajeRespondiendo = null;
      });
    }

    final data = _camposBaseMensaje()
      ..addAll({
        'mensaje': text,
        'type': 'text',
      });
=======
    _messageController.clear();
    if (mounted) setState(() => _showEmoji = false);
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

    FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
<<<<<<< HEAD
        .add(data);
=======
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': text,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': text,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

<<<<<<< HEAD
  Future<void> _guardarEdicionMensaje(String nuevoTexto) async {
    final id = _editingMessageId;
    if (id == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('chat')
          .doc(_chatId)
          .collection('mensajes')
          .doc(id)
          .update({
        'mensaje': nuevoTexto,
        'edited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
        'lastMessage': nuevoTexto,
        'lastTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _editingMessageId = null;
          _messageController.clear();
          _showEmoji = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje editado'),
            backgroundColor: Color(0xFF6BCE7A),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al editar mensaje: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo editar: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
    return null;
  }

  void _cancelarEdicion() {
    setState(() {
      _editingMessageId = null;
      _messageController.clear();
    });
  }

  void _salirModoSeleccion() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds.clear();
      _selectedIsMe.clear();
      _selectedCopyText.clear();
      _selectedType.clear();
    });
  }

  void _entrarModoSeleccion(String messageId, bool isMe, String copyText, String type) {
    setState(() {
      _selectionMode = true;
      _selectedMessageIds.add(messageId);
      _selectedIsMe[messageId] = isMe;
      _selectedCopyText[messageId] = copyText;
      _selectedType[messageId] = type;
    });
  }

  void _alternarSeleccionMensaje(String messageId, bool isMe, String copyText, String type) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        _selectedIsMe.remove(messageId);
        _selectedCopyText.remove(messageId);
        _selectedType.remove(messageId);
        if (_selectedMessageIds.isEmpty) _selectionMode = false;
      } else {
        _selectedMessageIds.add(messageId);
        _selectedIsMe[messageId] = isMe;
        _selectedCopyText[messageId] = copyText;
        _selectedType[messageId] = type;
      }
    });
  }

  void _onMensajeTap({
    required String messageId,
    required bool isMe,
    required String type,
    required String copyText,
    VoidCallback? onTapNormal,
  }) {
    if (_selectionMode) {
      _alternarSeleccionMensaje(messageId, isMe, copyText, type);
      return;
    }
    onTapNormal?.call();
  }

  void _mostrarMenuMensaje({
    required String messageId,
    required bool isMe,
    required String type,
    required String copyText,
    required Map<String, dynamic> msgData,
  }) {
    final bool puedeEditar = isMe && type == 'text';
    final String textoMensaje = type == 'text' ? (msgData['mensaje']?.toString() ?? '') : copyText;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline, color: Color(0xFF00A99D)),
              title: const Text('Info'),
              onTap: () {
                Navigator.pop(ctx);
                _mostrarInfoMensaje(messageId, isMe, type, msgData);
              },
            ),
            ListTile(
              leading: const Icon(Icons.reply, color: Color(0xFF6BCE7A)),
              title: const Text('Responder'),
              onTap: () {
                Navigator.pop(ctx);
                _configurarRespuesta(
                  messageId: messageId,
                  text: copyText,
                  isMe: isMe,
                  type: type,
                  msgData: msgData,
                );
              },
            ),
            if (puedeEditar)
              ListTile(
                leading: const Icon(Icons.edit_outlined, color: Color(0xFF6BCE7A)),
                title: const Text('Editar texto'),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _editingMessageId = messageId;
                    _messageController.text = textoMensaje;
                    _mensajeRespondiendo = null;
                    _salirModoSeleccion();
                  });
                },
              ),
            if (isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _eliminarMensajes({messageId}, esPropio: true);
                },
              ),
            if (copyText.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Copiar'),
                onTap: () {
                  Navigator.pop(ctx);
                  Clipboard.setData(ClipboardData(text: copyText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copiado'), duration: Duration(seconds: 2)),
                  );
                },
              ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: const Text('Seleccionar'),
              onTap: () {
                Navigator.pop(ctx);
                _entrarModoSeleccion(messageId, isMe, copyText, type);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarInfoMensaje(
    String messageId,
    bool isMe,
    String type,
    Map<String, dynamic> msgData,
  ) {
    final ts = msgData['timestamp'] as Timestamp?;
    final edited = msgData['edited'] == true;
    final editedAt = msgData['editedAt'] as Timestamp?;
    String fecha = 'Pendiente';
    if (ts != null) {
      final dt = ts.toDate();
      fecha =
          '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Info del mensaje', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Enviado por', isMe ? 'Tú' : widget.receiverName),
            _infoRow('Tipo', type),
            _infoRow('Fecha', fecha),
            if (edited)
              _infoRow(
                'Editado',
                editedAt != null
                    ? '${editedAt.toDate().day}/${editedAt.toDate().month}/${editedAt.toDate().year}'
                    : 'Sí',
              ),
            _infoRow('ID', messageId.substring(0, messageId.length > 12 ? 12 : messageId.length)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _responderSeleccionado() {
    if (_selectedMessageIds.length != 1) return;
    final id = _selectedMessageIds.first;
    _configurarRespuesta(
      messageId: id,
      text: _selectedCopyText[id] ?? '',
      isMe: _selectedIsMe[id] ?? false,
      type: _selectedType[id] ?? 'text',
      msgData: {'senderId': _selectedIsMe[id] == true ? _currentUserId : widget.receiverId},
    );
    _salirModoSeleccion();
  }

  bool _tieneMiosSeleccionados() =>
      _selectedMessageIds.any((id) => _selectedIsMe[id] == true);

  bool _puedeEditarSeleccion() {
    if (_selectedMessageIds.length != 1) return false;
    final id = _selectedMessageIds.first;
    return _selectedIsMe[id] == true && _selectedType[id] == 'text';
  }

  void _editarMensajeSeleccionado() {
    if (!_puedeEditarSeleccion()) return;
    final id = _selectedMessageIds.first;
    final texto = _selectedCopyText[id] ?? '';
    setState(() {
      _editingMessageId = id;
      _messageController.text = texto;
      _salirModoSeleccion();
    });
  }

  Future<void> _copiarSeleccionados() async {
    if (_selectedMessageIds.isEmpty) return;
    final textos = _selectedMessageIds
        .map((id) => _selectedCopyText[id] ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
    if (textos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay texto para copiar en la selección')),
      );
      return;
    }
    await Clipboard.setData(ClipboardData(text: textos.join('\n')));
    _salirModoSeleccion();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copiado al portapapeles'), duration: Duration(seconds: 2)),
      );
    }
    return null;
  }

  Future<void> _eliminarMensajes(Set<String> ids, {bool esPropio = false}) async {
    final aEliminar = esPropio
        ? ids.toList()
        : ids.where((id) => _selectedIsMe[id] == true).toList();

    if (aEliminar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solo puedes eliminar tus propios mensajes')),
      );
      return;
    }

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (final id in aEliminar) {
        final ref = FirebaseFirestore.instance
            .collection('chat')
            .doc(_chatId)
            .collection('mensajes')
            .doc(id);
        batch.delete(ref);
      }
      await batch.commit();
      _salirModoSeleccion();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mensaje(s) eliminado(s)'),
            backgroundColor: Color(0xFF6BCE7A),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al eliminar: $e');
    }
    return null;
  }

  Future<void> _eliminarSeleccionados() async {
    await _eliminarMensajes(_selectedMessageIds.toSet());
    return null;
  }

  String _textoParaCopiar(Map<String, dynamic> msgData, String type) {
    switch (type) {
      case 'image':
        return '📷 Imagen';
      case 'audio':
        return '🎤 Audio';
      case 'file':
        return '📎 ${msgData['fileName'] ?? 'Archivo'}';
      default:
        return msgData['mensaje']?.toString() ?? '';
    }
  }

  Widget _envolverMensajeSeleccionable({
    required String messageId,
    required bool isMe,
    required String type,
    required String copyText,
    required Map<String, dynamic> msgData,
    required Widget child,
    VoidCallback? onTapNormal,
  }) {
    final isSelected = _selectedMessageIds.contains(messageId);

    return Dismissible(
      key: ValueKey('msg_$messageId'),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (_) async {
        HapticFeedback.lightImpact();
        _configurarRespuesta(
          messageId: messageId,
          text: copyText,
          isMe: isMe,
          type: type,
          msgData: msgData,
        );
        return false;
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF6BCE7A).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.reply, color: Color(0xFF6BCE7A)),
            SizedBox(width: 8),
            Text('Responder', style: TextStyle(color: Color(0xFF6BCE7A), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: () => _onMensajeTap(
          messageId: messageId,
          isMe: isMe,
          type: type,
          copyText: copyText,
          onTapNormal: onTapNormal,
        ),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          if (_selectionMode) {
            _alternarSeleccionMensaje(messageId, isMe, copyText, type);
          } else {
            _mostrarMenuMensaje(
              messageId: messageId,
              isMe: isMe,
              type: type,
              copyText: copyText,
              msgData: msgData,
            );
          }
        },
        child: ColoredBox(
          color: isSelected ? const Color(0xFF6BCE7A).withValues(alpha: 0.22) : Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_selectionMode) ...[
                const SizedBox(width: 6),
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFF6BCE7A) : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: AbsorbPointer(absorbing: _selectionMode, child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitaRespuesta(Map<String, dynamic>? replyTo, bool bubbleIsMe) {
    if (replyTo == null) return const SizedBox.shrink();
    final replySenderId = replyTo['senderId']?.toString() ?? '';
    final replyIsMe = replySenderId == _currentUserId;
    final name = replyTo['senderName']?.toString() ??
        (replyIsMe ? 'Tú' : widget.receiverName);
    final text = replyTo['text']?.toString() ?? '';
    final accent = replyIsMe ? const Color(0xFF6BCE7A) : const Color(0xFF00A99D);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: bubbleIsMe
                  ? const Color(0xFF334A5F).withValues(alpha: 0.8)
                  : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
    return null;
  }

  // ─── Audio ─────────────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
<<<<<<< HEAD
        HapticFeedback.heavyImpact(); // Vibración al empezar
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        final directory = await getApplicationDocumentsDirectory();
        final path =
            '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
<<<<<<< HEAD
        if (mounted) {
          setState(() {
            _isRecording = true;
            _isLocked = false;
            _recordSeconds = 0;
          });
          _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (mounted) {
              setState(() => _recordSeconds++);
            } else {
              timer.cancel();
            }
          });
        }
=======
        if (mounted) setState(() => _isRecording = true);
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
    return null;
  }

<<<<<<< HEAD
  Future<void> _stopRecording({bool cancel = false}) async {
    try {
      _recordTimer?.cancel();
      final path = await _audioRecorder.stop();
      HapticFeedback.lightImpact(); // Vibración al terminar
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isLocked = false;
          _recordSeconds = 0;
        });
      }

      if (path != null && !cancel) {
        // Si el audio es muy corto (< 1s), cancelamos
        final file = File(path);
        if (await file.length() < 1000) {
          debugPrint("Audio muy corto, cancelando...");
          return;
        }

        setState(() {
          _selectedFile = file;
=======
  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      if (mounted) setState(() => _isRecording = false);

      if (path != null) {
        setState(() {
          _selectedFile = File(path);
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
          _selectedFileName =
              'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
          _selectedFileType = 'audio';
        });
<<<<<<< HEAD
        // ✅ Enviar automáticamente al terminar de grabar
        uploadAndSendSelected();
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
      }
    } catch (e) {
      debugPrint("Error al detener grabación: $e");
    }
  }

<<<<<<< HEAD
  String formatDuration(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  // ✅ Upload y envío (Firestore Base64 para saltar Storage)
  Future<void> uploadAndSendSelected() async {
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
        await enviarMensajeImagen(base64Content);
      } else if (type == 'audio') {
        await enviarMensajeAudio(base64Content);
      } else {
        await enviarMensajeArchivo(base64Content, fileName);
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
    return null;
  }

  // ✅ Enviar mensaje de imagen (Base64)
  Future<void> enviarMensajeImagen(String base64Data) async {
<<<<<<< HEAD
    final data = _camposBaseMensaje()
      ..addAll({'mensaje': base64Data, 'type': 'image'});
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
<<<<<<< HEAD
        .add(data);
    _limpiarRespuesta();
=======
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': base64Data,
      'type': 'image',
      'timestamp': FieldValue.serverTimestamp(),
    });
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': "📷 Foto",
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return null;
  }

  // ✅ Enviar mensaje de audio (Base64)
  Future<void> enviarMensajeAudio(String base64Data) async {
<<<<<<< HEAD
    final data = _camposBaseMensaje()
      ..addAll({'mensaje': base64Data, 'type': 'audio'});
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
<<<<<<< HEAD
        .add(data);
    _limpiarRespuesta();
=======
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': base64Data,
      'type': 'audio',
      'timestamp': FieldValue.serverTimestamp(),
    });
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': "🎤 Audio",
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return null;
  }

  // ✅ Enviar mensaje de archivo (Base64)
  Future<void> enviarMensajeArchivo(String base64Data, String fileName) async {
<<<<<<< HEAD
    final data = _camposBaseMensaje()
      ..addAll({
        'mensaje': base64Data,
        'fileName': fileName,
        'type': 'file',
      });
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    FirebaseFirestore.instance
        .collection('chat')
        .doc(_chatId)
        .collection('mensajes')
<<<<<<< HEAD
        .add(data);
    _limpiarRespuesta();
=======
        .add({
      'senderId': _currentUserId,
      'receiverId': widget.receiverId,
      'mensaje': base64Data,
      'fileName': fileName,
      'type': 'file',
      'timestamp': FieldValue.serverTimestamp(),
    });
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'users': [_currentUserId, widget.receiverId],
      'lastMessage': "📎 $fileName",
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return null;
  }

  Future<void> downloadAndOpenFile(String url, String fileName) async {
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
    return null;
  }

  void mostrarEmojis() {
    FocusScope.of(context).unfocus();
    setState(() => _showEmoji = !_showEmoji);
  }

  void cancelarSeleccion() {
    setState(() {
      _selectedFile = null;
      _selectedFileName = null;
      _selectedFileType = null;
    });
  }

  void iniciarLlamada(bool video) {
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

<<<<<<< HEAD
  // ─── Tema del Chat ────────────────────────────────────────────────────────
  Future<void> cargarTemaChat() async {
    final doc = await FirebaseFirestore.instance.collection('chat').doc(_chatId).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      if (mounted) {
        setState(() {
          _backgroundData = data['bgImage'];
          if (_backgroundData != null) {
            _cachedBgBytes = base64Decode(_backgroundData!);
          }
          if (data['bgColor'] != null) {
            _backgroundColor = Color(data['bgColor']);
            actualizarColoresBurbujas(Color(data['bgColor']));
          }
          if (data['bubbleDesign'] != null) {
            _bubbleDesign = data['bubbleDesign'];
          }
        });
      }
    }
    return null;
  }

  void actualizarColoresBurbujas(Color bgColor) {
    if (bgColor == Colors.white) {
      _bubbleMeColor = const Color(0xFFE7FFDB);
      _bubbleOtherColor = Colors.white;
    } else if (bgColor == const Color(0xFFE5DDD5)) {
      _bubbleMeColor = const Color(0xFFDCF8C6);
      _bubbleOtherColor = Colors.white;
    } else {
      HSLColor hsl = HSLColor.fromColor(bgColor);
      // Burbuja propia: Un poco más clara que el fondo, pero adaptable
      _bubbleMeColor = hsl.withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0)).toColor();
      // Burbuja ajena: Casi blanca o un gris muy suave para que resalte sobre fondos de colores
      _bubbleOtherColor = Colors.white.withOpacity(0.95);
    }
  }

  Future<void> cambiarColorPieza(Color color) async {
    setState(() {
      _backgroundColor = color;
      _backgroundData = null;
      _cachedBgBytes = null;
      actualizarColoresBurbujas(color);
    });
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'bgColor': color.value,
      'bgImage': null,
    }, SetOptions(merge: true));
    return null;
  }

  Future<void> cambiarImagenFondo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      final bytes = await File(image.path).readAsBytes();
      final base64 = base64Encode(bytes);
      setState(() {
        _backgroundData = base64;
        _cachedBgBytes = bytes;
        _backgroundColor = Colors.white;
      });
      await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
        'bgImage': base64,
        'bgColor': null,
      }, SetOptions(merge: true));
    }
    return null;
  }

  Future<void> cambiarDisenoBurbujas(String diseno) async {
    setState(() {
      _bubbleDesign = diseno;
    });
    await FirebaseFirestore.instance.collection('chat').doc(_chatId).set({
      'bubbleDesign': diseno,
    }, SetOptions(merge: true));
    return null;
  }

  void mostrarMenuTema() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: ListView(
            controller: scrollController,
            children: [
              const Text("Personalizar Chat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.image_outlined, color: Colors.blue),
                title: const Text("Poner foto de fondo"),
                onTap: () {
                  Navigator.pop(context);
                  cambiarImagenFondo();
                },
              ),
              const Divider(),
              const Text("Diseño de burbujas", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  designOption("Moderno", "modern", Icons.rectangle_rounded),
                  designOption("Clásico", "classic", Icons.chat_bubble_outline),
                  designOption("Redondo", "rounded", Icons.circle_outlined),
                ],
              ),
              const SizedBox(height: 20),
              const Text("Colores sólidos", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    colorOption(Colors.white),
                    colorOption(const Color(0xFFE5DDD5)), // WhatsApp clásico
                    colorOption(const Color(0xFFF1F1F1)),
                    colorOption(const Color(0xFFFFE0B2)),
                    colorOption(const Color(0xFFC8E6C9)),
                    colorOption(const Color(0xFFBBDEFB)),
                    colorOption(const Color(0xFFD1C4E9)),
                    colorOption(const Color(0xFFF8BBD0)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget designOption(String label, String value, IconData icon) {
    bool isSelected = _bubbleDesign == value;
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        cambiarDisenoBurbujas(value);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF6BCE7A).withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF6BCE7A) : Colors.grey.shade300),
            ),
            child: Icon(icon, color: isSelected ? const Color(0xFF6BCE7A) : Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isSelected ? const Color(0xFF6BCE7A) : Colors.grey)),
        ],
      ),
    );
  }

  Widget colorOption(Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        cambiarColorPieza(color);
      },
      child: Container(
        width: 45,
        height: 45,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    cargarTemaChat();
    _messageController.addListener(() {
      if (mounted) {
        setState(() {
          _isTextEmpty = _messageController.text.trim().isEmpty;
        });
      }
    });
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
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _selectionMode ? const Color(0xFF6BCE7A) : Colors.white,
        elevation: 0.5,
        iconTheme: IconThemeData(
          color: _selectionMode ? Colors.white : darkText,
        ),
        leading: IconButton(
          icon: Icon(
            _selectionMode ? Icons.close : Icons.arrow_back_ios_new,
            size: 20,
          ),
          onPressed: () {
            if (_selectionMode) {
              _salirModoSeleccion();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        titleSpacing: 0,
        title: _selectionMode
            ? Text(
                '${_selectedMessageIds.length} seleccionado${_selectedMessageIds.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryGreen.withOpacity(0.2),
                    child: widget.receiverPhoto.isNotEmpty
                        ? ClipOval(
                            child: widget.receiverPhoto.startsWith('http')
                                ? Image.network(
                                    widget.receiverPhoto,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _buildAvatarLetter(),
                                  )
                                : Base64Image(
                                    base64Data: widget.receiverPhoto,
                                    width: 36,
                                    height: 36,
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : _buildAvatarLetter(),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.receiverName,
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "En línea ahora",
                        style: TextStyle(color: primaryGreen, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
        actions: _selectionMode
            ? [
                if (_selectedMessageIds.length == 1)
                  IconButton(
                    icon: const Icon(Icons.reply, color: Colors.white),
                    onPressed: _responderSeleccionado,
                  ),
                if (_puedeEditarSeleccion())
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.white),
                    onPressed: _editarMensajeSeleccionado,
                  ),
                IconButton(
                  icon: const Icon(Icons.copy_outlined, color: Colors.white),
                  onPressed: _copiarSeleccionados,
                ),
                if (_tieneMiosSeleccionados())
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _eliminarSeleccionados,
                  ),
              ]
            : [
                IconButton(
                  icon: const Icon(Icons.palette_outlined, color: darkText),
                  onPressed: mostrarMenuTema,
                ),
                IconButton(
                  icon: const Icon(Icons.call, color: darkText),
                  onPressed: () => iniciarLlamada(false),
                ),
                IconButton(
                  icon: const Icon(Icons.videocam, color: darkText),
                  onPressed: () => iniciarLlamada(true),
                ),
              ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _backgroundColor,
          image: _cachedBgBytes != null
              ? DecorationImage(
                  image: MemoryImage(_cachedBgBytes!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
<<<<<<< HEAD
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final doc = messages[index];
                    final msgData = doc.data() as Map<String, dynamic>;
                    final String messageId = doc.id;
                    final bool isMe = msgData['senderId'] == _currentUserId;
                    final String type = msgData['type'] ?? 'text';
                    final String copyText = _textoParaCopiar(msgData, type);
                    final Timestamp? ts = msgData['timestamp'] as Timestamp?;
                    final bool edited = msgData['edited'] == true;
                    final Map<String, dynamic>? replyTo = msgData['replyTo'] is Map
                        ? Map<String, dynamic>.from(msgData['replyTo'] as Map)
                        : null;

                    Widget bubble;
                    switch (type) {
                      case 'image':
                        bubble = _buildImageBubble(
                          msgData['mensaje'] ?? "",
                          isMe,
                          ts,
                          replyTo: replyTo,
                        );
                        break;
                      case 'file':
                        bubble = _buildFileBubble(
                          msgData['mensaje'] ?? "",
                          msgData['fileName'] ?? "Archivo",
                          isMe,
                          ts,
                          replyTo: replyTo,
                        );
                        break;
                      case 'audio':
                        bubble = Column(
                          crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            if (replyTo != null)
                              Padding(
                                padding: EdgeInsets.only(
                                  left: isMe ? 40 : 0,
                                  right: isMe ? 0 : 40,
                                ),
                                child: _buildCitaRespuesta(replyTo, isMe),
                              ),
                            AudioMessageBubble(
                              data: msgData['mensaje'] ?? "",
                              isMe: isMe,
                              bubbleColor: isMe ? _bubbleMeColor : _bubbleOtherColor,
                              timestamp: ts,
                              borderRadius: _getBubbleRadius(isMe),
                            ),
                          ],
                        );
                        break;
                      default:
                        bubble = _buildMessageBubble(
                          msgData['mensaje'] ?? "",
                          isMe,
                          ts,
                          edited: edited,
                          replyTo: replyTo,
                        );
                    }

                    return _envolverMensajeSeleccionable(
                      messageId: messageId,
                      isMe: isMe,
                      type: type,
                      copyText: copyText,
                      msgData: msgData,
                      child: bubble,
                      onTapNormal: type == 'image'
                          ? () => _openFullScreenImage(msgData['mensaje'] ?? "")
                          : null,
                    );
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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

<<<<<<< HEAD
          if (_editingMessageId != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFE8F5E9),
              child: Row(
                children: [
                  const Icon(Icons.edit, size: 18, color: Color(0xFF6BCE7A)),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Editando mensaje',
                      style: TextStyle(
                        color: Color(0xFF334A5F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _cancelarEdicion,
                    child: const Icon(Icons.close, size: 20, color: Colors.grey),
                  ),
                ],
              ),
            ),

          if (_mensajeRespondiendo != null && _editingMessageId == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: const BorderSide(color: Color(0xFF6BCE7A), width: 4),
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.reply, size: 20, color: Color(0xFF6BCE7A)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mensajeRespondiendo!['senderName']?.toString() ?? '',
                          style: const TextStyle(
                            color: Color(0xFF6BCE7A),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          _mensajeRespondiendo!['text']?.toString() ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: _cancelarRespuesta,
                  ),
                ],
              ),
            ),

          if (!_selectionMode) _buildMessageInput(primaryGreen),

          if (_showEmoji && !_selectionMode)
=======
          _buildMessageInput(primaryGreen),

          if (_showEmoji)
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
<<<<<<< HEAD
    ),
  );
}
=======
    );
  }
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

  // ── Preview panel ──────────────────────────────────────────────────────────
  Widget buildPreviewPanel(Color green) {
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
<<<<<<< HEAD
  Widget buildImageBubble(
    String data,
    bool isMe,
    Timestamp? timestamp, {
    Map<String, dynamic>? replyTo,
  }) {
=======
  Widget _buildImageBubble(String data, bool isMe, Timestamp? timestamp) {
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: isMe ? _bubbleMeColor : _bubbleOtherColor,
          borderRadius: _getBubbleRadius(isMe),
=======
          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.circular(15),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
<<<<<<< HEAD
            if (replyTo != null) _buildCitaRespuesta(replyTo, isMe),
            ClipRRect(
              borderRadius: _bubbleDesign == 'rounded'
                  ? BorderRadius.circular(22)
                  : BorderRadius.circular(12),
              child: data.startsWith('http')
                  ? Image.network(
                      data,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image, size: 80),
                    )
                  : Base64Image(
                      base64Data: data,
                      fit: BoxFit.cover,
                    ),
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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

  void openFullScreenImage(String data) {
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
                onPressed: () => downloadFileToGallery(
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

<<<<<<< HEAD
  Widget buildAvatarLetter() {
    const Color darkText = Color(0xFF334A5F);
    return Text(
      widget.receiverName.isNotEmpty ? widget.receiverName[0].toUpperCase() : '?',
      style: const TextStyle(color: darkText, fontWeight: FontWeight.bold),
    );
  }

=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
  // ✅ Nueva función para descargar archivos (incluso Base64) a la carpeta de Descargas
  Future<void> downloadFileToGallery(String data, String fileName) async {
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
    return null;
  }

  Widget buildFileBubble(
<<<<<<< HEAD
    String data,
    String fileName,
    bool isMe,
    Timestamp? timestamp, {
    Map<String, dynamic>? replyTo,
  }) {
=======
      String data, String fileName, bool isMe, Timestamp? timestamp) {
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: isMe ? _bubbleMeColor : _bubbleOtherColor,
          borderRadius: _getBubbleRadius(isMe),
=======
          color: isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.circular(15),
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
<<<<<<< HEAD
            if (replyTo != null) _buildCitaRespuesta(replyTo, isMe),
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
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
                    onPressed: () => downloadFileToGallery(data, fileName),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  String _formatTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Widget buildMessageInput(Color green) {
    if (_isRecording) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.0, end: 0.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, value, child) {
                return Icon(Icons.mic,
                  color: Colors.red.withOpacity(value < 0.5 ? 2 * value : 2 * (1 - value)),
                  size: 28);
              },
              onEnd: () {}, // Handled by repeating tween if we use a controller, but for now this is better than nothing
            ),
            // Volvemos al simple por rendimiento si no queremos complicar con AnimationControllers
            const SizedBox(width: 8),
            Text(
              _formatDuration(_recordSeconds),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  "← Desliza para cancelar",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ),
            if (!_isLocked)
              const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 16),
                  Text("Bloquear", style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () => _stopRecording(cancel: true),
            ),
            GestureDetector(
                onTap: () => _stopRecording(),
                child: CircleAvatar(
                  backgroundColor: green,
                  radius: 24,
                  child: const Icon(Icons.send, color: Colors.white),
                )),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.grey, size: 28),
                  onPressed: () => mostrarOpcionesAdjuntos(green),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F4F7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _messageController,
                      maxLines: 5,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: _editingMessageId != null
                            ? "Editar mensaje..."
                            : "Escribe un mensaje...",
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.emoji_emotions_outlined,
                              color: _showEmoji ? green : Colors.grey),
                          onPressed: _mostrarEmojis,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _isTextEmpty
                    ? GestureDetector(
                        onLongPressStart: (_) => _startRecording(),
                        onLongPressEnd: (_) {
                          if (!_isLocked) _stopRecording();
                        },
                        onVerticalDragUpdate: (details) {
                          if (details.primaryDelta! < -50 && _isRecording) {
                            setState(() => _isLocked = true);
                            HapticFeedback.mediumImpact();
                          }
                        },
                        onHorizontalDragUpdate: (details) {
                          if (details.primaryDelta! < -50 && _isRecording) {
                            _stopRecording(cancel: true);
                          }
                        },
                        child: CircleAvatar(
                          backgroundColor: _isRecording ? Colors.red : green,
                          radius: 24,
                          child: Icon(
                            _isRecording ? (_isLocked ? Icons.stop : Icons.mic) : Icons.mic,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : CircleAvatar(
                        backgroundColor: green,
                        radius: 24,
                        child: IconButton(
                          icon: Icon(
                            _editingMessageId != null
                                ? Icons.check_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _sendMessage,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void mostrarOpcionesAdjuntos(Color green) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: green),
              title: const Text("Cámara"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.image, color: green),
              title: const Text("Galería"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file, color: green),
              title: const Text("Documento"),
              onTap: () {
                Navigator.pop(context);
                _pickFile();
              },
            ),
            const SizedBox(height: 20),
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  BorderRadius _getBubbleRadius(bool isMe) {
    switch (_bubbleDesign) {
      case 'classic':
        return BorderRadius.only(
          topLeft: const Radius.circular(12),
          topRight: const Radius.circular(12),
          bottomLeft: Radius.circular(isMe ? 12 : 0),
          bottomRight: Radius.circular(isMe ? 0 : 12),
        );
      case 'rounded':
        return BorderRadius.circular(25);
      case 'modern':
      default:
        return BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        );
    }
  }

  Widget _buildMessageBubble(
    String text,
    bool isMe,
    Timestamp? timestamp, {
    bool edited = false,
    Map<String, dynamic>? replyTo,
  }) {
=======
  Widget _buildMessageBubble(
      String text, bool isMe, Timestamp? timestamp) {
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
<<<<<<< HEAD
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? _bubbleMeColor : _bubbleOtherColor,
          borderRadius: _getBubbleRadius(isMe),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
<<<<<<< HEAD
            if (replyTo != null) _buildCitaRespuesta(replyTo, isMe),
            Text(
              text,
              style: TextStyle(
                color: isMe
                    ? (_bubbleMeColor.computeLuminance() > 0.5
                        ? const Color(0xFF334A5F)
                        : Colors.white)
                    : const Color(0xFF334A5F),
                fontSize: 15,
              ),
            ),
            if (timestamp != null || edited)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (edited) ...[
                      Text(
                        'editado',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: isMe
                              ? (_bubbleMeColor.computeLuminance() > 0.5
                                  ? Colors.black45
                                  : Colors.white70)
                              : Colors.grey.shade500,
                        ),
                      ),
                      if (timestamp != null) const SizedBox(width: 6),
                    ],
                    if (timestamp != null)
                      Text(
                        _formatTime(timestamp),
                        style: TextStyle(
                          color: isMe
                              ? (_bubbleMeColor.computeLuminance() > 0.5
                                  ? Colors.black54
                                  : Colors.white70)
                              : Colors.grey.shade500,
                          fontSize: 10,
                        ),
                      ),
                  ],
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
                ),
              ),
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
}

class AudioMessageBubble extends StatefulWidget {
  final String data;
  final bool isMe;
  final Timestamp? timestamp;
  final Color bubbleColor;
  final BorderRadius borderRadius;

  const AudioMessageBubble({
    super.key,
    required this.data,
    required this.isMe,
    required this.bubbleColor,
    required this.borderRadius,
    this.timestamp,
  });

  @override
  State<AudioMessageBubble> createState() => _AudioMessageBubbleState();
}

class _AudioMessageBubbleState extends State<AudioMessageBubble> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
    } else {
      try {
        if (widget.data.startsWith('http')) {
          await _player.play(UrlSource(widget.data));
        } else {
          final bytes = base64Decode(widget.data);
          final tempDir = await getTemporaryDirectory();
          // Usamos una ruta única basada en el hash de la data o timestamp si estuviera disponible
          final file = File('${tempDir.path}/temp_${widget.data.hashCode}.m4a');
          if (!await file.exists()) {
            await file.writeAsBytes(bytes);
          }
          await _player.play(DeviceFileSource(file.path));
        }
        setState(() => _isPlaying = true);
      } catch (e) {
        debugPrint("Error play audio: $e");
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
=======
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

  String _formatTime(Timestamp timestamp) {
    final dt = timestamp.toDate();
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    final Color green = const Color(0xFF6BCE7A);

    return Align(
      alignment: widget.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: widget.bubbleColor,
          borderRadius: widget.borderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                    size: 38,
                    color: widget.isMe 
                        ? (widget.bubbleColor.computeLuminance() > 0.5 ? green : Colors.white)
                        : green,
                  ),
                  onPressed: _playPause,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          trackHeight: 2,
                          activeTrackColor: widget.isMe 
                              ? (widget.bubbleColor.computeLuminance() > 0.5 ? green : Colors.white)
                              : green,
                          thumbColor: widget.isMe 
                              ? (widget.bubbleColor.computeLuminance() > 0.5 ? green : Colors.white)
                              : green,
                        ),
                        child: Slider(
                          value: _position.inSeconds.toDouble(),
                          max: _duration.inSeconds > 0
                              ? _duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) async {
                            await _player.seek(Duration(seconds: value.toInt()));
                          },
                          inactiveColor: widget.isMe 
                              ? (widget.bubbleColor.computeLuminance() > 0.5 ? Colors.black12 : Colors.white24)
                              : Colors.grey.shade300,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(_position),
                              style: TextStyle(
                                  fontSize: 10, 
                                  color: widget.isMe 
                                      ? (widget.bubbleColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70)
                                      : Colors.grey),
                            ),
                            Text(
                              _formatDuration(_duration),
                              style: TextStyle(
                                  fontSize: 10, 
                                  color: widget.isMe 
                                      ? (widget.bubbleColor.computeLuminance() > 0.5 ? Colors.black54 : Colors.white70)
                                      : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(Icons.graphic_eq, 
                      color: widget.isMe 
                          ? (widget.bubbleColor.computeLuminance() > 0.5 ? green.withOpacity(0.5) : Colors.white54)
                          : green.withOpacity(0.5)),
                ),
              ],
            ),
            if (widget.timestamp != null)
              Padding(
                padding: const EdgeInsets.only(right: 12, bottom: 4),
                child: Text(
                  _formatTime(widget.timestamp!),
                  style: TextStyle(
                      color: widget.isMe 
                          ? (widget.bubbleColor.computeLuminance() > 0.5 ? Colors.black45 : Colors.white60)
                          : Colors.grey.shade600, 
                      fontSize: 10),
                ),
              ),
=======
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
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518
          ],
        ),
      ),
    );
  }
<<<<<<< HEAD
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
    if (_error) return const Icon(Icons.broken_image);
    return Image.memory(
      _bytes,
      fit: widget.fit,
      width: widget.width,
      height: widget.height,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
    );
  }
}

=======
}
>>>>>>> b3c7d01f64649bd67d2177e2cdb71d65d3165518

    return null;