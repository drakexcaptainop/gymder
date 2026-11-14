import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';

// ───────────────────────── Bienvenida ─────────────────────────
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: navy,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Spacer(),
              Container(width: 72, height: 72, alignment: Alignment.center, decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(24)), child: Text('G', style: ts(36, w: FontWeight.w700))),
              const SizedBox(height: 24),
              Text('Gymder', style: ts(40, w: FontWeight.w700, c: white)),
              const SizedBox(height: 8),
              Text('Encuentra a tu entrenador con un swipe y acuerden el plan por chat.', style: ts(16, c: soft, h: 1.45)),
              const SizedBox(height: 24),
              for (final t in const [
                (Icons.style_outlined, 'Desliza para descubrir entrenadores'),
                (Icons.send_outlined, 'Pregunta por sus planes al instante'),
                (Icons.chat_bubble_outline, 'Chatea y acuerda plan y mensualidad'),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(children: [Icon(t.$1, color: lime, size: 22), const SizedBox(width: 12), Expanded(child: Text(t.$2, style: ts(14, c: white)))]),
                ),
              const Spacer(),
              SizedBox(width: double.infinity, child: Btn('Crear cuenta', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())), bg: lime, fg: navy)),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())),
                  child: Container(height: 52, alignment: Alignment.center, decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white38)), child: Text('Iniciar sesión', style: ts(15, w: FontWeight.w600, c: white))),
                ),
              ),
            ]),
          ),
        ),
      );
}

// ───────────────────────── Inicio de sesión ─────────────────────────
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController(), pass = TextEditingController();
  String? error;

  void submit() {
    final err = app.login(email.text, pass.text);
    if (err != null) return setState(() => error = err);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  void demo(String mail) {
    email.text = mail;
    pass.text = 'demo123';
    submit();
  }

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Iniciar sesión',
        subtitle: 'Bienvenido de vuelta',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          label('Correo'),
          field(email, 'tu@correo.com', type: TextInputType.emailAddress, icon: Icons.mail_outline, onChanged: (_) => setState(() => error = null)),
          label('Contraseña'),
          field(pass, 'Tu contraseña', obscure: true, icon: Icons.lock_outline, onChanged: (_) => setState(() => error = null)),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: ts(13, c: Colors.red.shade700, w: FontWeight.w500))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: Btn('Entrar', submit, bg: lime, fg: navy)),
          const SizedBox(height: 24),
          Text('Cuentas demo (contraseña demo123)', style: ts(13, c: slate, w: FontWeight.w600)),
          const SizedBox(height: 8),
          for (final a in app.accounts.where((a) => ['camila@demo.com', 'diego@demo.com', 'valeria@demo.com', 'mateo@demo.com'].contains(a.email)))
            GestureDetector(
              onTap: () => demo(a.email),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: box(),
                child: Row(children: [
                  Tag(a.role == AppRole.coach ? 'Entrenador' : 'Usuario', bg: a.role == AppRole.coach ? cyanTint : lime),
                  const SizedBox(width: 10),
                  Expanded(child: Text(a.email, style: ts(14))),
                  const Icon(Icons.chevron_right, color: slate),
                ]),
              ),
            ),
          Center(child: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecuperarScreen())), child: const Text('¿Olvidaste tu contraseña?'))),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const RegisterScreen())),
              child: const Text('¿No tienes cuenta? Regístrate'),
            ),
          ),
        ]),
      );
}

// ───────────────────────── Registro ─────────────────────────
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nombre = TextEditingController(), email = TextEditingController(), pass = TextEditingController();
  AppRole role = AppRole.user;
  String esp = especialidades.first, mod = 'Online';
  String? error;

  void submit() {
    final err = app.register(role: role, nombre: nombre.text, email: email.text, password: pass.text, especialidad: esp, modalidad: mod);
    if (err != null) return setState(() => error = err);
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Crear cuenta',
        subtitle: 'Regístrate en Gymder',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          label('Soy'),
          Seg([(AppRole.user, 'Usuario'), (AppRole.coach, 'Entrenador')], role, (v) => setState(() => role = v)),
          label('Nombre completo'),
          field(nombre, 'Ej. Ana Pérez', icon: Icons.person_outline, onChanged: (_) => setState(() => error = null)),
          label('Correo'),
          field(email, 'tu@correo.com', type: TextInputType.emailAddress, icon: Icons.mail_outline, onChanged: (_) => setState(() => error = null)),
          label('Contraseña (mínimo 6 caracteres)'),
          field(pass, 'Contraseña', obscure: true, icon: Icons.lock_outline, onChanged: (_) => setState(() => error = null)),
          if (role == AppRole.coach) ...[
            label('Especialidad'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final e in especialidades) Pill(e, esp == e, () => setState(() => esp = e))]),
            label('Modalidad'),
            Seg([for (final m in ['Online', 'Presencial']) (m, m)], mod, (v) => setState(() => mod = v)),
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(error!, style: ts(13, c: Colors.red.shade700, w: FontWeight.w500))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: Btn('Crear cuenta', submit, bg: lime, fg: navy)),
        ]),
      );
}

// ───────────────────────── Recuperar contraseña ─────────────────────────
class RecuperarScreen extends StatefulWidget {
  const RecuperarScreen({super.key});
  @override
  State<RecuperarScreen> createState() => _RecuperarScreenState();
}

class _RecuperarScreenState extends State<RecuperarScreen> {
  final email = TextEditingController(), code = TextEditingController(), pass = TextEditingController();
  bool sent = false;
  String? error;

  void sendCode() {
    if (!app.emailExists(email.text)) return setState(() => error = 'No encontramos una cuenta con ese correo');
    setState(() {
      sent = true;
      error = null;
    });
  }

  void reset() {
    final err = app.resetPassword(email.text, code.text, pass.text);
    if (err != null) return setState(() => error = err);
    Navigator.of(context).pop();
    toast(context, 'Contraseña actualizada. Ya puedes iniciar sesión');
  }

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Recuperar contraseña',
        subtitle: sent ? 'Paso 2 de 2' : 'Paso 1 de 2',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          label('Correo de tu cuenta'),
          field(email, 'tu@correo.com', type: TextInputType.emailAddress, icon: Icons.mail_outline, onChanged: (_) => setState(() => error = null)),
          if (!sent) ...[
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: Btn('Enviar código', sendCode, bg: lime, fg: navy)),
          ] else ...[
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: box(bg: cyanFaint, bd: cyanTint),
              child: Text('Te enviamos un código de verificación. En esta demo el código es ${AppState.recoveryCode}.', style: ts(13, h: 1.4)),
            ),
            label('Código'),
            field(code, '6 dígitos', type: TextInputType.number, maxLen: 6, icon: Icons.pin_outlined, onChanged: (_) => setState(() => error = null)),
            label('Nueva contraseña'),
            field(pass, 'Mínimo 6 caracteres', obscure: true, icon: Icons.lock_reset, onChanged: (_) => setState(() => error = null)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: Btn('Cambiar contraseña', reset, bg: lime, fg: navy)),
          ],
          if (error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(error!, style: ts(13, c: Colors.red.shade700, w: FontWeight.w500))),
        ]),
      );
}