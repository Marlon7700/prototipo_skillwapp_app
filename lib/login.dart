import 'package:flutter/foundation.dart'; // Importar kIsWeb
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Añadido para TextInput
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  static const String _googleWebClientId =
      '141826962219-rafvmqkucdsdpnocctg4nrea8d1mvqsn.apps.googleusercontent.com';

  // ─── Brand colors ─────────────────────────────────────────────────────────
  final Color primaryGreen = const Color(0xFF6BCE7A);
  final Color secondaryBlue = const Color(0xFF00A99D);

  // ─── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isSubmitting = false;
  List<String> _suggestedEmails = [];
  bool _showSuggestions = false;

  // ─── Typewriter ────────────────────────────────────────────────────────────
  final String _fullText = "SkillSwap";
  String _displayedText = "";
  int _charIndex = 0;
  bool _isLoading = true;

  // ─── Controllers ──────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _colorController;

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  late AnimationController _bgShiftController;
  late Animation<double> _bgShiftAnimation;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _bgShiftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    _bgShiftAnimation = Tween<double>(begin: -0.015, end: 0.015).animate(
      CurvedAnimation(parent: _bgShiftController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _emailController.addListener(_onEmailChanged);

    _startTypewriter();
  }

  void _onEmailChanged() async {
    final text = _emailController.text.trim();
    if (text.length < 2) {
      if (mounted) {
        setState(() {
        _suggestedEmails = [];
        _showSuggestions = false;
      });
      }
      return;
    }

    try {
      // Optimizamos la consulta para que sea más rápida
      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('email', isGreaterThanOrEqualTo: text)
          .where('email', isLessThanOrEqualTo: '$text\uf8ff')
          .limit(3) // Solo 3 para rapidez
          .get();

      if (mounted) {
        setState(() {
          _suggestedEmails = snapshot.docs
              .map((doc) => doc['email'] as String)
              .where((e) => e != text)
              .toList();
          _showSuggestions = _suggestedEmails.isNotEmpty;
        });
      }
    } catch (e) {
      debugPrint('Error al obtener sugerencias: $e');
    }
  }

  void _recomendarContrasena() {
    // Generar una contraseña segura y sugerirla
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#\$%';
    final random = DateTime.now().millisecondsSinceEpoch;
    String pass = '';
    for (var i = 0; i < 10; i++) {
      pass += chars[(random + i) % chars.length];
    }
    
    _passwordController.text = pass;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contraseña segura sugerida: $pass'),
        backgroundColor: secondaryBlue,
        action: SnackBarAction(label: 'OK', textColor: Colors.white, onPressed: () {}),
      ),
    );
  }

  void _startTypewriter() {
    Timer.periodic(const Duration(milliseconds: 90), (timer) {
      if (_charIndex < _fullText.length) {
        if (mounted) {
          setState(() {
            _displayedText += _fullText[_charIndex];
            _charIndex++;
          });
        }
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) {
            setState(() => _isLoading = false);
            _fadeController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _colorController.dispose();
    _floatController.dispose();
    _bgShiftController.dispose();
    _shakeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Validators ───────────────────────────────────────────────────────────
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo válido (ej. usuario@gmail.com)';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  // ─── Firestore: crea/actualiza el documento del usuario ─────────────────
  // Crea (o actualiza) el doc en la colección "usuarios" usando el uid
  // como ID. merge:true evita pisar campos editados desde el perfil.
  Future<void> _guardarUsuarioEnFirestore(User user,
      {bool esNuevo = false}) async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('usuarios').doc(user.uid);

      final email = user.email ?? '';
      final nombreInicial = (user.displayName != null &&
              user.displayName!.trim().isNotEmpty)
          ? user.displayName!
          : (email.contains('@') ? email.split('@').first : email);

      final datos = <String, dynamic>{
        'uid': user.uid,
        'email': email,
        'nombre': nombreInicial,
        'actualizadoEn': FieldValue.serverTimestamp(),
        'estado': 'online', 
      };

      // SOLO guardamos la foto si el usuario de Auth trae una (ej. Google)
      // Esto evita borrar la foto Base64 guardada manualmente si entramos por email
      if (user.photoURL != null && user.photoURL!.isNotEmpty) {
        datos['photoUrl'] = user.photoURL;
        datos['fotoUrl'] = user.photoURL;
      }

      if (esNuevo) {
        datos['bio'] = '';
        datos['ofrece'] = '';
        datos['necesita'] = '';
        datos['creadoEn'] = FieldValue.serverTimestamp();
      }

      await docRef.set(datos, SetOptions(merge: true));

      // ─── ACTUALIZACIÓN DE PRESENCIA EN REALTIME DATABASE ───
      // Esto asegura que el "punto verde" se active inmediatamente al loguear
      try {
        await FirebaseDatabase.instance.ref("status/${user.uid}").update({
          "presence": "online",
          "last_seen": DateTime.now().millisecondsSinceEpoch,
        });
      } catch (e) {
        debugPrint('Error al actualizar presencia en RTDB: $e');
      }

    } catch (e) {
      // No bloqueamos el login si falla Firestore; solo lo registramos.
      debugPrint('No se pudo guardar el usuario en Firestore: $e');
    }
  }

  // ─── Handlers ─────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }
    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await _guardarUsuarioEnFirestore(cred.user!);
      }
      
      // Activar el guardado de contraseña en el gestor del SO
      TextInput.finishAutofillContext();

      if (!mounted) return;
      _mostrarMensajeConsentimiento(context, '/bienvenida');
    } on FirebaseAuthException catch (e) {
      // SI EL USUARIO NO EXISTE O FALLA EL LOGIN CON CREDENCIALES INVÁLIDAS
      if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
        // Verificamos si es específicamente contraseña incorrecta
        if (e.code == 'wrong-password' || (e.code == 'invalid-credential' && e.message?.contains('password') == true)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Contraseña incorrecta. Inténtalo de nuevo.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          );
          return;
        }

        try {
          final cred =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );
          if (cred.user != null) {
            await _guardarUsuarioEnFirestore(cred.user!, esNuevo: true);
          }
          
          TextInput.finishAutofillContext();

          if (!mounted) return;
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('¡Cuenta nueva creada con éxito! Bienvenido.'),
              backgroundColor: primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          _mostrarMensajeConsentimiento(context, '/bienvenida');
          return;
        } catch (createError) {
          // Si falla la creación (ej. contraseña muy corta)
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear cuenta: ${createError.toString()}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      } else {
        // Otros errores (contraseña incorrecta para usuario existente, etc.)
        String message = 'Error: ${e.message}';
        if (e.code == 'wrong-password') message = 'Contraseña incorrecta para este correo.';
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isSubmitting = true);
    try {
      if (kIsWeb) {
        debugPrint("Iniciando Google Sign In en Web...");
        // Para Web, Firebase recomienda usar el Provider directamente con signInWithPopup
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.setCustomParameters({
          'prompt': 'select_account'
        });

        final webCred =
            await FirebaseAuth.instance.signInWithPopup(googleProvider);
        if (webCred.user != null) {
          await _guardarUsuarioEnFirestore(
            webCred.user!,
            esNuevo: webCred.additionalUserInfo?.isNewUser ?? false,
          );
        }
        
        if (!mounted) return;
        _mostrarMensajeConsentimiento(context, '/home');
        return;
      }

      debugPrint("Iniciando Google Sign In en Móvil...");
      
      // En Android Firebase necesita el Web Client ID para emitir un idToken
      // utilizable con GoogleAuthProvider.
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: _googleWebClientId,
        scopes: [
          'email',
          'https://www.googleapis.com/auth/contacts.readonly',
        ],
      );
      
      // Cerramos cualquier sesión previa para que SIEMPRE pida elegir cuenta
      await googleSignIn.signOut();
      
      // Abrimos el selector de cuentas
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint("El usuario cerró el selector de cuentas sin elegir ninguna");
        setState(() => _isSubmitting = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null || googleAuth.idToken!.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google no devolvió un idToken válido para Firebase.',
        );
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint("Cuenta seleccionada: ${googleUser.email}. Autenticando en Firebase...");
      final mobileCred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (mobileCred.user != null) {
        await _guardarUsuarioEnFirestore(
          mobileCred.user!,
          esNuevo: mobileCred.additionalUserInfo?.isNewUser ?? false,
        );
      }
      
      if (!mounted) return;
      debugPrint("Login exitoso. Navegando al Home...");
      _mostrarMensajeConsentimiento(context, '/home');
    } catch (e) {
      debugPrint("ERROR DETALLADO EN GOOGLE LOGIN: $e");

      final String err = e.toString();
      String friendlyError = "No se pudo conectar con Google.";

      if (err.contains("ApiException: 10") || err.contains("DEVELOPER_ERROR")) {
        friendlyError =
            "Error 10 (DEVELOPER_ERROR): la huella SHA-1 no está registrada en Firebase. "
            "Agrégala en Firebase Console y descarga el google-services.json actualizado.";
      } else if (err.contains("ApiException: 12500")) {
        friendlyError =
            "Google Play Services no está actualizado o no disponible en este dispositivo.";
      } else if (err.contains("ApiException: 7") || err.contains("network_error")) {
        friendlyError = "Error de red. Revisa tu conexión a internet.";
      } else if (err.contains("ApiException: 12501")) {
        friendlyError = "Cancelaste el inicio de sesión con Google.";
      } else if (err.contains("missing-google-id-token")) {
        friendlyError =
            "Google no devolvió el token requerido para Firebase. Actualiza el google-services.json desde Firebase.";
      } else if (err.contains("account-exists-with-different-credential")) {
        friendlyError =
            "Ese correo ya está registrado con otro método (email/contraseña). Inicia sesión con ese método primero.";
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyError),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── Diálogo de Consentimiento de Datos ──────────────────────────────────
  Future<void> _mostrarMensajeConsentimiento(BuildContext context, String navigateTo) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
        if (doc.exists && (doc.data()?['terminosAceptados'] == true)) {
          // Ya aceptó los términos, entrar directamente
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, navigateTo);
          return;
        }
      } catch (e) {
        debugPrint('Error al verificar términos: $e');
      }
    }

    if (!context.mounted) return;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.privacy_tip, color: secondaryBlue),
              const SizedBox(width: 10),
              const Text('Aviso de Privacidad'),
            ],
          ),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Para continuar, debes leer y aceptar nuestros términos de servicio y políticas de privacidad para garantizar una experiencia segura.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  'Al aceptar, confirmas que estás de acuerdo con el manejo de tus datos para las funciones principales de SkillSwap.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ver Términos y Condiciones', style: TextStyle(color: Colors.grey)),
              onPressed: () async {
                final acepto = await Navigator.pushNamed(context, '/terminos');
                if (acepto == true) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  Navigator.pushReplacementNamed(context, navigateTo);
                }
              },
            ),
            TextButton(
              child: Text('Aceptar', style: TextStyle(color: secondaryBlue, fontWeight: FontWeight.bold)),
              onPressed: () async {
                if (user != null) {
                  await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
                    'terminosAceptados': true,
                    'fechaAceptacionTerminos': FieldValue.serverTimestamp(),
                  });
                }
                if (!dialogContext.mounted) return;
                Navigator.of(dialogContext).pop();
                Navigator.pushReplacementNamed(context, navigateTo);
              },
            ),
          ],
        );
      },
    );
  }

  void _handleForgotPassword() {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo primero')),
      );
      return;
    }
    FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Se ha enviado un correo para restablecer tu contraseña'),
        backgroundColor: primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _handleCreateAccount() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) {
      _shakeController.forward(from: 0);
      return;
    }
    
    setState(() => _isSubmitting = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (cred.user != null) {
        await _guardarUsuarioEnFirestore(cred.user!, esNuevo: true);
      }
      if (!mounted) return;
      _mostrarMensajeConsentimiento(context, '/home');
    } on FirebaseAuthException catch (e) {
      String message = 'Error en el registro';
      if (e.code == 'weak-password') {
        message = 'La contraseña es muy débil';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo ya está en uso';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(),
          Container(color: Colors.black.withOpacity(0.04)),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            60,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 36),

                          // ── Logo header ──────────────────────────────────
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOutQuart,
                            padding: EdgeInsets.only(
                              top: _isLoading
                                  ? MediaQuery.of(context).size.height * 0.35
                                  : 0,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAnimatedHeader(),
                                if (_isLoading) ... [
                                  const SizedBox(height: 24),
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        primaryGreen),
                                    strokeWidth: 3,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 36),

                          // ── "Login" title ────────────────────────────────
                          if (!_isLoading)
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: _buildLoginTitle(),
                                ),
                              ),
                            ),
                          const SizedBox(height: 28),

                          // ── Form ─────────────────────────────────────────
                          if (!_isLoading)
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: SlideTransition(
                                position: _slideAnimation,
                                child: _buildForm(),
                              ),
                            )
                          else
                            const SizedBox.shrink(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Create Account (pegado al fondo) ──────────────────────
                if (!_isLoading) _buildCreateAccountButton(),
                const SizedBox(height: 12),

                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ─────────────────────────────────────────────────────────────
  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _bgShiftAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              MediaQuery.of(context).size.width * _bgShiftAnimation.value, 0),
          child: Transform.scale(
            scale: 1.04,
            child: Image.asset(
              'assets/Fondo_SkillSwap.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
            ),
          ),
        );
      },
    );
  }

  // ── Animated logo header ───────────────────────────────────────────────────
  Widget _buildAnimatedHeader() {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_colorController, _scaleAnimation, _floatAnimation]),
      builder: (context, child) {
        final t = _colorController.value;
        final stops = [
          (t - 0.35).clamp(0.0, 1.0),
          t.clamp(0.0, 1.0),
          (t + 0.35).clamp(0.0, 1.0),
        ];

        // Letras saltarinas individuales
        List<Widget> animatedChars = [];
        for (int i = 0; i < _displayedText.length; i++) {
          final charDelay = i * 0.15;
          final charBounce = (Curves.easeInOut.transform(
                      (t + charDelay) % 1.0) *
                  -6.0)
              .toDouble();

          animatedChars.add(
            Transform.translate(
              offset: Offset(0, charBounce),
              child: Text(
                _displayedText[i],
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          );
        }

        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.90),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.20),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset('assets/imagen_skillwasp.jpeg',
                          height: 44, width: 44),
                    ),
                    const SizedBox(width: 14),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          primaryGreen,
                          secondaryBlue,
                          const Color(0xFF4ADE80),
                          secondaryBlue,
                          primaryGreen,
                        ],
                        stops: [0.0, stops[0], stops[1], stops[2], 1.0],
                        tileMode: TileMode.clamp,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(bounds),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: animatedChars,
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  Positioned(
                    bottom: -10,
                    child: SizedBox(
                      width: 140,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            primaryGreen.withOpacity(0.5)),
                        minHeight: 2,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // **"Login" bold title 
  Widget _buildLoginTitle() {
    return const Text(
      'Login',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: Colors.white, // Cambiado de Color(0xFF2A3D50) a blanco
        letterSpacing: 0.3,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: Colors.black45,
            offset: Offset(2.0, 2.0),
          ),
        ],
      ),
    );
  }

  // **Form 
  Widget _buildForm() {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final progress = _shakeController.value;
        final shakeX = progress < 1.0
            ? 10.0 * (1.0 - progress) * _sineWave(progress)
            : 0.0;
        return Transform.translate(
          offset: Offset(_shakeController.isAnimating ? shakeX : 0, 0),
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // **Email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HoverAnimatedField(
                      child: _buildValidatedField(
                        controller: _emailController,
                        hintText: 'email@example.com',
                        icon: Icons.email_outlined,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    if (_suggestedEmails.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: Column(
                          children: _suggestedEmails.map((email) => ListTile(
                            title: Text(email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            leading: Icon(Icons.history, size: 18, color: primaryGreen),
                            dense: true,
                            onTap: () {
                              _emailController.text = email;
                              setState(() {
                                _suggestedEmails = [];
                                _showSuggestions = false;
                              });
                            },
                          )).toList(),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Password 
                _HoverAnimatedField(
                  child: _buildValidatedField(
                    controller: _passwordController,
                    hintText: '••••••••',
                    icon: Icons.lock_outline,
                    validator: _validatePassword,
                    obscureText: _obscureText,
                    isPassword: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLogin(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                          tooltip: 'Sugerir contraseña segura',
                          onPressed: _recomendarContrasena,
                        ),
                        IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Login button   
                _PressAnimatedButton(
                  onPressed: _isSubmitting ? () {} : _handleLogin,
                  primaryGreen: primaryGreen,
                  secondaryBlue: secondaryBlue,
                  child: _buildLoginButton(),
                ),
                const SizedBox(height: 20),

                // ── Divider "or login with" ────────────────────────────────
                _buildDivider(),
                const SizedBox(height: 20),

                // ── Google button ──────────────────────────────────────────
                _PressAnimatedButton(
                  onPressed: _handleGoogleLogin,
                  primaryGreen: primaryGreen,
                  secondaryBlue: secondaryBlue,
                  child: _buildGoogleButton(),
                ),
                const SizedBox(height: 20),

                // ── Forgot Password ────────────────────────────────────────
                GestureDetector(
                  onTap: _handleForgotPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _sineWave(double t) {
    return (t * 4 * 3.14159).abs() < 0.001
        ? 0.0
        : (t * 4 * 3.14159 * 2).truncate().isEven
            ? 1.0
            : -1.0;
  }

  // ── Validated field ───────────────────────────────────────────────────────
  Widget _buildValidatedField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    void Function(String)? onFieldSubmitted,
    Widget? suffixIcon, // Agregado parámetro opcional
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.97),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        autofillHints: isPassword 
            ? [AutofillHints.newPassword, AutofillHints.password] 
            : [AutofillHints.email, AutofillHints.username],
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: primaryGreen, size: 22),
          suffixIcon: suffixIcon ?? (isPassword
              ? IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscureText = !_obscureText),
                )
              : null),
          border: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          errorStyle: TextStyle(
            color: Colors.red.shade600,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 18,
          ),
        ),
      ),
    );
  }

  // ── Login button ──────────────────────────────────────────────────────────
  Widget _buildLoginButton() {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryGreen, secondaryBlue],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.40),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: _isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Login',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or login with',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)),
      ],
    );
  }

  // ── Google button with real logo via network image ─────────────────────────
  Widget _buildGoogleButton() {
    return Container(
      height: 58,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTbqxB37HobSQL9mtgDqpGeq5He6mTe917MTg&s',
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_circle,
                color: Colors.grey,
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Google',
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── Create Account button ─────────────────────────────────────────────────
  Widget _buildCreateAccountButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: _PressAnimatedButton(
        onPressed: _isSubmitting ? () {} : _handleCreateAccount,
        primaryGreen: primaryGreen,
        secondaryBlue: secondaryBlue,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: primaryGreen.withOpacity(0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: secondaryBlue,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  Widget _buildFooter() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Text(
        '© 2026 SkillSwap. Todos los derechos reservados.',
        style: TextStyle(
          color: Color(0xFF334A5F),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.white, blurRadius: 4)],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  _HoverAnimatedField
// ═══════════════════════════════════════════════════════════════════════════
class _HoverAnimatedField extends StatefulWidget {
  final Widget child;
  const _HoverAnimatedField({required this.child});

  @override
  State<_HoverAnimatedField> createState() => _HoverAnimatedFieldState();
}

class _HoverAnimatedFieldState extends State<_HoverAnimatedField>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _lift;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _lift = Tween<double>(begin: 0, end: -5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _glow = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) => Future.delayed(
            const Duration(milliseconds: 300), _ctrl.reverse),
        onTapCancel: () => _ctrl.reverse(),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _lift.value),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6BCE7A)
                          .withOpacity(0.16 * _glow.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  _PressAnimatedButton
// ═══════════════════════════════════════════════════════════════════════════
class _PressAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color primaryGreen;
  final Color secondaryBlue;

  const _PressAnimatedButton({
    required this.child,
    required this.onPressed,
    required this.primaryGreen,
    required this.secondaryBlue,
  });

  @override
  State<_PressAnimatedButton> createState() => _PressAnimatedButtonState();
}

class _PressAnimatedButtonState extends State<_PressAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 130));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            foregroundDecoration: _hovered
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white.withOpacity(0.06),
                  )
                : null,
            child: widget.child,
          ),
        ),
      ),
    );
  }
} 