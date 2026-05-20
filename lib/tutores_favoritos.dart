import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart' show ChatScreen;
import 'widgets/base64_image.dart';

/// Pantalla para elegir tutores / amigos favoritos (estilo lista + búsqueda).
class TutoresFavoritosScreen extends StatefulWidget {
  const TutoresFavoritosScreen({super.key});

  @override
  State<TutoresFavoritosScreen> createState() => _TutoresFavoritosScreenState();
}

class _TutoresFavoritosScreenState extends State<TutoresFavoritosScreen> {
  static const Color _primaryGreen = Color(0xFF6BCE7A);
  static const Color _teal = Color(0xFF00A99D);
  static const Color _darkText = Color(0xFF334A5F);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _favoritos = [];
  bool _loadingFav = true;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarFavoritos() async {
    if (_uid == null) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(_uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _favoritos = List<String>.from(data['favoritos'] ?? []);
      }
    } catch (e) {
      debugPrint('Error cargando favoritos: $e');
    } finally {
      if (mounted) setState(() => _loadingFav = false);
    }
  }

  Future<void> _guardarFavoritos() async {
    if (_uid == null) return;
    await FirebaseFirestore.instance.collection('usuarios').doc(_uid).set({
      'favoritos': _favoritos,
    }, SetOptions(merge: true));
  }

  Future<void> _toggleFavorito(String uid) async {
    setState(() {
      if (_favoritos.contains(uid)) {
        _favoritos.remove(uid);
      } else {
        _favoritos.add(uid);
      }
    });
    await _guardarFavoritos();
  }

  Widget _buildAppBackground() {
    return SizedBox.expand(
      child: Image.asset(
        'assets/Fondo_SkillSwap.png',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFFFAFDFB)),
      ),
    );
  }

  Widget _logoSkillSwap({double iconSize = 28}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/icono.png',
          height: iconSize,
          width: iconSize,
          errorBuilder: (_, __, ___) => Image.asset(
            'assets/icon.png',
            height: iconSize,
            width: iconSize,
            errorBuilder: (_, __, ___) => const Icon(Icons.swap_horiz, color: _primaryGreen, size: 28),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'SkillSwap',
          style: TextStyle(
            color: _primaryGreen,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _avatarUsuario(String photo, String name, {double radius = 28}) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: _primaryGreen.withValues(alpha: 0.2),
      child: ClipOval(
        child: photo.isNotEmpty
            ? (photo.startsWith('http')
                ? Image.network(photo, width: radius * 2, height: radius * 2, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _iniciales(name, radius))
                : Base64Image(base64Data: photo, width: radius * 2, height: radius * 2, fit: BoxFit.cover))
            : _iniciales(name, radius),
      ),
    );
  }

  Widget _iniciales(String name, double radius) {
    final t = name.trim();
    final letter = t.isNotEmpty ? t[0].toUpperCase() : '?';
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: _primaryGreen,
      alignment: Alignment.center,
      child: Text(letter, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFavoritosHorizontal(List<QueryDocumentSnapshot> todos) {
    final favDocs = todos.where((d) => _favoritos.contains(d.id)).toList();
    if (favDocs.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: Text(
          'Aún no tienes favoritos.\nToca la estrella en la lista.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favDocs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final data = favDocs[i].data() as Map<String, dynamic>;
          final uid = favDocs[i].id;
          final name = data['nombre'] ?? data['email']?.toString().split('@').first ?? 'Usuario';
          final photo = data['photoUrl'] ?? data['fotoUrl'] ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    receiverId: uid,
                    receiverName: name,
                    receiverPhoto: photo,
                  ),
                ),
              );
            },
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _avatarUsuario(photo, name, radius: 30),
                      Positioned(
                        right: -2,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_rounded, size: 14, color: _teal),
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
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = _uid;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFDFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: _darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: _logoSkillSwap(),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(child: _buildAppBackground()),
          if (_loadingFav)
            const Center(child: CircularProgressIndicator(color: _primaryGreen))
          else
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('usuarios').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: _primaryGreen));
                }

                var docs = snapshot.data!.docs.where((d) => d.id != currentUid).toList();

                if (_searchQuery.isNotEmpty) {
                  docs = docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['nombre'] ?? '').toString().toLowerCase();
                    final email = (data['email'] ?? '').toString().toLowerCase();
                    return name.contains(_searchQuery) || email.contains(_searchQuery);
                  }).toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tutores favoritos o amigos',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _darkText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Selecciona con la estrella y chatea desde aquí',
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildFavoritosHorizontal(snapshot.data!.docs),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                        decoration: InputDecoration(
                          hintText: 'Buscar tutor o amigo...',
                          prefixIcon: const Icon(Icons.search, color: _primaryGreen),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: docs.isEmpty
                          ? const Center(child: Text('No se encontraron usuarios'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final doc = docs[index];
                                final data = doc.data() as Map<String, dynamic>;
                                final uid = doc.id;
                                final name = data['nombre'] ??
                                    data['email']?.toString().split('@').first ??
                                    'Usuario';
                                final photo = data['photoUrl'] ?? data['fotoUrl'] ?? '';
                                final esFav = _favoritos.contains(uid);
                                final especialidad =
                                    data['especialidad'] ?? data['ofrece'] ?? 'Habilidades varias';

                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: ListTile(
                                    leading: _avatarUsuario(photo, name, radius: 22),
                                    title: Text(name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, color: _darkText)),
                                    subtitle: Text(
                                      especialidad,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            esFav ? Icons.star : Icons.star_border,
                                            color: esFav ? Colors.amber : Colors.grey,
                                          ),
                                          onPressed: () => _toggleFavorito(uid),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.chat_rounded, color: _teal),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => ChatScreen(
                                                  receiverId: uid,
                                                  receiverName: name,
                                                  receiverPhoto: photo,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}
