import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';

// ───────────────────────── Bienvenida ─────────────────────────
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: bg,
        body: Stack(children: [
          const Positioned(left: 0, right: 0, top: 0, height: 420, child: HeroBg('Funcional')),
          Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [bg.withValues(alpha: 0), bg.withValues(alpha: 0), bg], stops: const [0, .3, .62])))),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Spacer(),
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: lime.withValues(alpha: .45), blurRadius: 28)]),
                  child: Icon(Icons.bolt, size: 38, color: ink),
                ),
                const SizedBox(height: 18),
                Text('GYMDER', style: hd(84, italic: true, ls: 1)),
                const SizedBox(height: 6),
                Text('Encuentra a tu entrenador con un swipe y acuerden el plan por chat.', style: ts(16, c: text.withValues(alpha: .8), h: 1.45)),
                const SizedBox(height: 22),
                for (final (i, t) in const [
                  'Desliza para descubrir entrenadores',
                  'Pregunta por sus planes al instante',
                  'Chatea y acuerda plan y mensualidad',
                ].indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(children: [
                      Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: limeTint, shape: BoxShape.circle, border: Border.all(color: lime.withValues(alpha: .6))), child: Text('${i + 1}', style: hd(16, c: lime, italic: true))),
                      const SizedBox(width: 12),
                      Expanded(child: Text(t, style: ts(14, w: FontWeight.w600))),
                    ]),
                  ),
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, child: Btn('Crear cuenta', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen())), icon: Icons.arrow_forward_rounded)),
                const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: Btn('Iniciar sesión', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoginScreen())), outlined: true)),
              ]),
            ),
          ),
        ]),
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
          if (error != null) errorText(error!),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: Btn('Entrar', submit)),
          Center(child: TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RecuperarScreen())), child: const Text('¿Olvidaste tu contraseña?'))),
          label('Acceso rápido demo · contraseña demo123'),
          for (final a in app.accounts.where((a) => ['camila@demo.com', 'diego@demo.com', 'valeria@demo.com', 'mateo@demo.com'].contains(a.email)))
            Tap(
              scale: .98,
              onTap: () => demo(a.email),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: box(),
                child: Row(children: [
                  if (a.role == AppRole.coach) Avatar(coachById(a.profileId).ini, size: 40, tone: coachById(a.profileId).tone) else Avatar(app.userById(a.profileId).ini, size: 40, tone: app.userById(a.profileId).tone),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(a.role == AppRole.coach ? coachById(a.profileId).nombre : app.userById(a.profileId).nombre, style: ts(14, w: FontWeight.w700)),
                      Text(a.email, style: ts(12, c: muted)),
                    ]),
                  ),
                  Tag(a.role == AppRole.coach ? 'Entrenador' : 'Usuario', bg: a.role == AppRole.coach ? cyan : lime, fg: ink),
                ]),
              ),
            ),
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

  Widget _roleCard(AppRole r, IconData icon, String title, String desc) {
    final sel = role == r;
    return Expanded(
      child: Tap(
        onTap: () => setState(() => role = r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: sel ? limeTint : surface, borderRadius: BorderRadius.circular(r20), border: Border.all(color: sel ? lime : line, width: sel ? 1.6 : 1)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: sel ? lime : surface2, borderRadius: BorderRadius.circular(r12)), child: Icon(icon, size: 22, color: sel ? ink : muted)),
              const Spacer(),
              if (sel) const Icon(Icons.check_circle, color: lime, size: 22),
            ]),
            const SizedBox(height: 12),
            Text(title.toUpperCase(), style: hd(22, italic: true)),
            const SizedBox(height: 4),
            Text(desc, style: ts(12, c: muted, h: 1.35)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => SubScreen(
        title: 'Crear cuenta',
        subtitle: 'Regístrate en Gymder',
        child: ListView(padding: const EdgeInsets.all(16), children: [
          label('¿Qué buscas?'),
          Row(children: [
            _roleCard(AppRole.user, Icons.search, 'Busco entrenador', 'Descubre coaches y acuerda tu plan.'),
            const SizedBox(width: 10),
            _roleCard(AppRole.coach, Icons.sports, 'Soy entrenador', 'Publica tus planes y consigue alumnos.'),
          ]),
          label('Nombre completo'),
          field(nombre, 'Ej. Ana Pérez', icon: Icons.person_outline, onChanged: (_) => setState(() => error = null)),
          label('Correo'),
          field(email, 'tu@correo.com', type: TextInputType.emailAddress, icon: Icons.mail_outline, onChanged: (_) => setState(() => error = null)),
          label('Contraseña (mínimo 6 caracteres)'),
          field(pass, 'Contraseña', obscure: true, icon: Icons.lock_outline, onChanged: (_) => setState(() => error = null)),
          if (role == AppRole.coach) ...[
            label('Especialidad'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (final e in especialidades) Pill(e, esp == e, () => setState(() => esp = e), leading: Icon(sportIcon(e), size: 15, color: esp == e ? ink : sportColors(e).$2))]),
            label('Modalidad'),
            Seg([for (final m in ['Online', 'Presencial']) (m, m)], mod, (v) => setState(() => mod = v)),
          ],
          if (error != null) errorText(error!),
          const SizedBox(height: 22),
          SizedBox(width: double.infinity, child: Btn('Crear cuenta', submit)),
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
            SizedBox(width: double.infinity, child: Btn('Enviar código', sendCode)),
          ] else ...[
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: box(bg: cyanTint, bd: cyan.withValues(alpha: .3), r: r12),
              child: Text('Te enviamos un código de verificación. En esta demo el código es ${AppState.recoveryCode}.', style: ts(13, h: 1.4)),
            ),
            label('Código'),
            field(code, '6 dígitos', type: TextInputType.number, maxLen: 6, icon: Icons.pin_outlined, onChanged: (_) => setState(() => error = null)),
            label('Nueva contraseña'),
            field(pass, 'Mínimo 6 caracteres', obscure: true, icon: Icons.lock_reset, onChanged: (_) => setState(() => error = null)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: Btn('Cambiar contraseña', reset)),
          ],
          if (error != null) errorText(error!),
        ]),
      );
}
