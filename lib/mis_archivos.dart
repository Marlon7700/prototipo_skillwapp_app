import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class MisArchivosScreen extends StatefulWidget {
  const MisArchivosScreen({super.key});

  @override
  State<MisArchivosScreen> createState() => _MisArchivosScreenState();
}

class _MisArchivosScreenState extends State<MisArchivosScreen> {
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String nombreColeccion = 'archivos_unificados';

  String? _idCarpetaActual;
  bool _esVistaLista = false;
  bool _esVistaCarpetas = false; 

  // --- LOGICA DE FIREBASE ---
  Future<void> _guardarEnFirebase({
    required String nombre, 
    required String extension, 
    required String tamano, 
    required bool esCarpeta, 
    String? pathLocal,
    String? parentId
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection(nombreColeccion).add({
      'nombre': nombre,
      'extension': extension,
      'tamano': tamano,
      'fecha': FieldValue.serverTimestamp(),
      'esCarpeta': esCarpeta,
      'idPadre': parentId ?? _idCarpetaActual,
      'propietarioId': user.uid,
      'pathLocal': pathLocal, // Guardamos la ruta local para previsualizar en el prototipo
    });
  }

  Future<void> _subirArchivo({String? targetFolderId}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      String fileSize = "${(file.size / 1024).toStringAsFixed(1)} KB";
      await _guardarEnFirebase(
        nombre: file.name, 
        extension: file.extension ?? "file", 
        tamano: fileSize, 
        esCarpeta: false, 
        pathLocal: file.path,
        parentId: targetFolderId
      );
    }
  }

  Future<void> _reemplazarArchivo(String docId) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      String fileSize = "${(file.size / 1024).toStringAsFixed(1)} KB";
      await _firestore.collection(nombreColeccion).doc(docId).update({
        'nombre': file.name,
        'extension': file.extension ?? "file",
        'tamano': fileSize,
        'pathLocal': file.path,
        'fecha': FieldValue.serverTimestamp(),
      });
    }
  }

  // --- VISOR DE ARCHIVOS ---
  Future<void> _verArchivo(Map<String, dynamic> data) async {
    String? path = data['pathLocal'];
    String nombre = data['nombre'];
    bool esImagen = ['jpg', 'jpeg', 'png', 'gif'].contains(data['extension']?.toLowerCase());

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(nombre, style: const TextStyle(fontSize: 16, color: Colors.black)),
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: esImagen && path != null && File(path).existsSync()
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.file(File(path), fit: BoxFit.contain),
                    )
                  : Column(
                      children: [
                        Icon(_getIcon(data['extension']), size: 100, color: primaryGreen),
                        const SizedBox(height: 20),
                        const Text("Vista previa no disponible para este formato", textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        if (path != null) 
                          ElevatedButton.icon(
                            onPressed: () async {
                              final Uri uri = Uri.file(path);
                              if (await canLaunchUrl(uri)) {
                                await launchUrl(uri);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("No se pudo abrir el archivo localmente"))
                                );
                              }
                            }, 
                            icon: const Icon(Icons.open_in_new), 
                            label: const Text("INTENTAR ABRIR"),
                            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _crearCarpeta({String? targetFolderId}) async {
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Carpeta"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Nombre")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), style: TextButton.styleFrom(foregroundColor: Colors.grey), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                _guardarEnFirebase(nombre: controller.text, extension: 'folder', tamano: 'Carpeta', esCarpeta: true, parentId: targetFolderId);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryGreen),
            child: const Text("Crear"),
          )
        ],
      ),
    );
  }

  void _abrirCarpetaEnVentana(String folderId, String folderName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(color: Color(0xFFF8FAF9), borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.folder_open, color: Colors.amber, size: 30),
                  const SizedBox(width: 15),
                  Expanded(child: Text(folderName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D5A4C)))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection(nombreColeccion).where('idPadre', isEqualTo: folderId).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      String docId = docs[index].id;
                      return Card(
                        elevation: 0, margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.shade100)),
                        child: ListTile(
                          onTap: () => _verArchivo(data),
                          leading: _buildFilePreview(data),
                          title: Text(data['nombre'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(data['tamano']),
                          trailing: PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == 'e') _reemplazarArchivo(docId);
                              if (v == 'd') _firestore.collection(nombreColeccion).doc(docId).delete();
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: 'e', child: Text("REEMPLAZAR")),
                              const PopupMenuItem(value: 'd', child: Text("ELIMINAR", style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: ElevatedButton.icon(
                onPressed: () => _subirArchivo(targetFolderId: folderId),
                icon: const Icon(Icons.add),
                label: const Text("SUBIR ARCHIVO A CARPETA"),
                style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(Map<String, dynamic> data) {
    String? path = data['pathLocal'];
    bool esImagen = ['jpg', 'jpeg', 'png', 'gif'].contains(data['extension']?.toLowerCase());
    
    if (esImagen && path != null && File(path).existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(File(path), width: 45, height: 45, fit: BoxFit.cover),
      );
    }
    return Icon(_getIcon(data['extension']), color: primaryGreen, size: 30);
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F7F4),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/Fondo_SkillSwap.png', fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.4))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Image.asset('assets/imagen_skillwasp.jpeg', height: 45),
                      const SizedBox(width: 12),
                      const Text("SkillSwap", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D5A4C))),
                    ]),
                    const CircleAvatar(backgroundImage: AssetImage('assets/imagen_skillwasp.jpeg'), radius: 24),
                  ]),
                  const SizedBox(height: 35),
                  const Text("Mis Archivos", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF2D5A4C))),
                  const Text("Administra y organiza tus archivos personales", style: TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  const SizedBox(height: 30),
                  Row(children: [
                    _buildTab("Archivos", !_esVistaCarpetas),
                    const SizedBox(width: 25),
                    _buildTab("Carpetas", _esVistaCarpetas),
                    const Spacer(),
                    ElevatedButton.icon(onPressed: () => _subirArchivo(), icon: const Icon(Icons.add), label: const Text("Subir"), style: ElevatedButton.styleFrom(backgroundColor: primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)))),
                  ]),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                    child: Row(children: [
                      const Text("Mis Datos", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(onPressed: () => setState(() => _esVistaLista = false), icon: Icon(Icons.grid_view_rounded, color: !_esVistaLista ? primaryGreen : Colors.grey[300])),
                      IconButton(onPressed: () => setState(() => _esVistaLista = true), icon: Icon(Icons.list, color: _esVistaLista ? primaryGreen : Colors.grey[300])),
                      IconButton(onPressed: _crearCarpeta, icon: const Icon(Icons.create_new_folder_outlined, color: Colors.grey)),
                    ]),
                  ),
                  const SizedBox(height: 25),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection(nombreColeccion).where('propietarioId', isEqualTo: user?.uid).where('idPadre', isEqualTo: null).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        var docs = snapshot.data!.docs;
                        var filtered = _esVistaCarpetas ? docs.where((d) => d['esCarpeta'] == true).toList() : docs.where((d) => d['esCarpeta'] == false).toList();
                        
                        return _esVistaLista 
                          ? ListView.builder(itemCount: filtered.length, itemBuilder: (context, i) => _buildListTile(filtered[i]))
                          : GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 18, crossAxisSpacing: 18, childAspectRatio: 0.85),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) => _buildGridTile(filtered[i]),
                            );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridTile(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    bool esC = data['esCarpeta'] ?? false;
    return GestureDetector(
      onTap: esC ? () => _abrirCarpetaEnVentana(doc.id, data['nombre']) : () => _verArchivo(data),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(children: [
            Container(
              width: double.infinity, margin: const EdgeInsets.all(10), 
              decoration: BoxDecoration(color: esC ? Colors.amber.withOpacity(0.1) : primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), 
              child: _buildFilePreview(data)
            ),
            Positioned(right: 5, top: 5, child: PopupMenuButton<String>(
              onSelected: (v) {
                if(v == 'e') _reemplazarArchivo(doc.id);
                if(v == 'd') _firestore.collection(nombreColeccion).doc(doc.id).delete();
              },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'e', child: Text("REEMPLAZAR")),
                const PopupMenuItem(value: 'd', child: Text("ELIMINAR", style: TextStyle(color: Colors.red))),
              ],
            ))
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(15, 0, 15, 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['nombre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(data['tamano'], style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ])),
        ]),
      ),
    );
  }

  Widget _buildListTile(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return ListTile(
      leading: _buildFilePreview(data),
      title: Text(data['nombre']),
      subtitle: Text(data['tamano']),
      onTap: data['esCarpeta'] ? () => _abrirCarpetaEnVentana(doc.id, data['nombre']) : () => _verArchivo(data),
    );
  }

  Widget _buildTab(String label, bool active) {
    return GestureDetector(
      onTap: () => setState(() => _esVistaCarpetas = label == "Carpetas"),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 18, fontWeight: active ? FontWeight.bold : FontWeight.normal, color: active ? const Color(0xFF2D5A4C) : Colors.grey[400])),
        const SizedBox(height: 5),
        AnimatedContainer(duration: const Duration(milliseconds: 300), height: 4, width: active ? 40 : 0, decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(10))),
      ]),
    );
  }

  IconData _getIcon(String? ext) {
    if (ext == 'pdf') return Icons.picture_as_pdf;
    if (ext == 'xls' || ext == 'xlsx') return Icons.table_chart;
    if (ext == 'doc' || ext == 'docx') return Icons.description;
    return Icons.insert_drive_file;
  }
}
