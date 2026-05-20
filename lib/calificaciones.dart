import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/base64_image.dart';

class CalificacionesScreen extends StatefulWidget {
  const CalificacionesScreen({super.key});

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();

  // Movido aquí para que sea accesible desde main.dart como CalificacionesScreen.mostrarDialogoCalificar
  static void mostrarDialogoCalificar(BuildContext context, String targetUid, String targetName) {
    int ratingExplicacion = 0;
    int ratingHabilidades = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Calificar a $targetName", 
                style: const TextStyle(color: Color(0xFF334A5F), fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("¿Qué tan bien explica?", 
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  _buildStarRatingBar((val) => setStateDialog(() => ratingExplicacion = val), ratingExplicacion),
                  const SizedBox(height: 20),
                  const Text("¿Qué tal sus habilidades?", 
                    style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
                  _buildStarRatingBar((val) => setStateDialog(() => ratingHabilidades = val), ratingHabilidades),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cerrar", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: (ratingExplicacion == 0 || ratingHabilidades == 0)
                      ? null
                      : () async {
                          await _guardarCalificacionStatic(targetUid, ratingExplicacion, ratingHabilidades);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("¡Calificación enviada correctamente!"),
                                backgroundColor: Color(0xFF6BCE7A),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6BCE7A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("CALIFICAR"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildStarRatingBar(Function(int) onRatingChanged, int currentRating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return IconButton(
          onPressed: () => onRatingChanged(index + 1),
          icon: Icon(
            index < currentRating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 35,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 2),
          constraints: const BoxConstraints(),
        );
      }),
    );
  }

  static Future<void> _guardarCalificacionStatic(String targetUid, int explicacion, int habilidades) async {
    final myUid = FirebaseAuth.instance.currentUser?.uid;
    if (myUid == null) return;

    final ref = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(targetUid)
        .collection('calificaciones')
        .doc(myUid);

    await ref.set({
      'ratingExplicacion': explicacion,
      'ratingHabilidades': habilidades,
      'fecha': FieldValue.serverTimestamp(),
      'autorId': myUid,
    });
  }
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  Widget _buildAppBackground() {
    return SizedBox.expand(
      child: Image.asset(
        'assets/Fondo_SkillSwap.png',
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFFFAFDFB),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFB),
      appBar: AppBar(
        title: const Text("Calificar Usuarios", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6BCE7A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildAppBackground()),
          Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: InputDecoration(
                hintText: "Buscar usuario para calificar...",
                prefixIcon: const Icon(Icons.search, color: Color(0xFF6BCE7A)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No hay usuarios registrados"));
                }

                var docs = snapshot.data!.docs.where((doc) {
                  if (doc.id == currentUser?.uid) return false;
                  if (_searchQuery.isEmpty) return true;
                  
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['nombre'] ?? "").toString().toLowerCase();
                  String email = (data['email'] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                if (docs.isEmpty) {
                  return const Center(child: Text("No se encontraron usuarios"));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    var userData = docs[index].data() as Map<String, dynamic>;
                    String uid = docs[index].id;
                    String name = userData['nombre'] ?? userData['email']?.split('@')[0] ?? "Usuario";
                    String photo = userData['photoUrl'] ?? userData['fotoUrl'] ?? "";

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: photo.isNotEmpty
                                ? (photo.startsWith('http')
                                    ? Image.network(photo, width: 40, height: 40, fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 25, color: Colors.grey))
                                    : Base64Image(base64Data: photo, width: 40, height: 40, fit: BoxFit.cover))
                                : const Icon(Icons.person, color: Colors.grey),
                          ),
                        ),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(userData['especialidad'] ?? userData['ofrece'] ?? "Habilidades varias", maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: ElevatedButton(
                          onPressed: () => CalificacionesScreen.mostrarDialogoCalificar(context, uid, name),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00A99D),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("Calificar"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
          ),
        ],
      ),
    );
  }
}
