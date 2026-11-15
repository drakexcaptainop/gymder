import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ───────────────────────── Paleta deportiva (modo oscuro) ─────────────────────────
const bg = Color(0xFF080D17); // fondo de pantalla
const surface = Color(0xFF111A2B); // tarjetas
const surface2 = Color(0xFF1A2640); // elementos elevados / inputs
const line = Color(0xFF263552); // bordes
const text = Color(0xFFF2F6FC);
const muted = Color(0xFF8C9AB3);
const ink = Color(0xFF0A1220); // texto sobre lime
const lime = Color(0xFFC8FF3D); // acción principal
const cyan = Color(0xFF22D3EE); // estados / avisos
const amber = Color(0xFFFBBF24); // estrellas
const danger = Color(0xFFF87171);
final limeTint = lime.withValues(alpha: .14);
final cyanTint = cyan.withValues(alpha: .16);

// Escala de radios
const r8 = 8.0, r12 = 12.0, r20 = 20.0, r28 = 28.0;

ThemeData buildTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: lime, brightness: Brightness.dark).copyWith(primary: lime, onPrimary: ink, secondary: cyan, surface: surface),
    dividerColor: line,
    splashFactory: InkRipple.splashFactory,
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: lime, textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700))),
    textSelectionTheme: const TextSelectionThemeData(cursorColor: lime, selectionHandleColor: lime),
  );
}

BoxDecoration box({Color bg = surface, Color? bd = line, double r = r20, double bw = 1}) =>
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(r), border: bd == null ? null : Border.all(color: bd, width: bw));

/// Texto de cuerpo (Inter).
TextStyle ts(double size, {FontWeight w = FontWeight.w400, Color c = text, double? h, bool strike = false, double? ls}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: c, height: h, letterSpacing: ls, decoration: strike ? TextDecoration.lineThrough : null);

/// Titulares y números: condensada, atlética (Barlow Condensed).
TextStyle hd(double size, {FontWeight w = FontWeight.w800, Color c = text, bool italic = false, double? ls}) => GoogleFonts.barlowCondensed(
    fontSize: size, fontWeight: w, color: c, fontStyle: italic ? FontStyle.italic : FontStyle.normal, letterSpacing: ls ?? .4, height: 1.0);

// ───────────────────────── Deportes: icono y color por especialidad ─────────────────────────
IconData sportIcon(String esp) => switch (esp) {
      'Fuerza' => Icons.fitness_center,
      'Hipertrofia' => Icons.sports_gymnastics,
      'Movilidad' => Icons.self_improvement,
      'Funcional' => Icons.bolt,
      'Running' => Icons.directions_run,
      _ => Icons.sports,
    };

/// (color oscuro del degradado, color de acento) por especialidad.
(Color, Color) sportColors(String esp) => switch (esp) {
      'Fuerza' => (const Color(0xFF14307A), const Color(0xFF60A5FA)),
      'Hipertrofia' => (const Color(0xFF7A1613), const Color(0xFFF87171)),
      'Movilidad' => (const Color(0xFF0B4F4A), const Color(0xFF2DD4BF)),
      'Funcional' => (const Color(0xFF8A3A06), const Color(0xFFFB923C)),
      'Running' => (const Color(0xFF4A1D96), const Color(0xFFA78BFA)),
      _ => (surface2, lime),
    };

class _StripesPainter extends CustomPainter {
  final Color color;
  const _StripesPainter(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 14;
    for (double x = -size.height; x < size.width + size.height; x += 46) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), p);
    }
  }

  @override
  bool shouldRepaint(_StripesPainter old) => old.color != color;
}

/// Fondo "hero" sin imágenes: degradado por deporte, franjas diagonales e icono gigante.
class HeroBg extends StatelessWidget {
  final String esp;
  final Widget? child;
  final BorderRadius? radius;
  final double? height;
  const HeroBg(this.esp, {super.key, this.child, this.radius, this.height});
  @override
  Widget build(BuildContext context) {
    final (dark, accent) = sportColors(esp);
    return Container(
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.lerp(dark, accent, .35)!, dark, bg]),
      ),
      child: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: _StripesPainter(Colors.white.withValues(alpha: .035)))),
        Positioned(right: -30, top: 10, child: Transform.rotate(angle: -.2, child: Icon(sportIcon(esp), size: 220, color: Colors.white.withValues(alpha: .09)))),
        // Sin altura fija, el contenido define el tamaño; con altura fija (o dentro de un Positioned.fill) lo llena.
        if (child != null) (height == null ? child! : Positioned.fill(child: child!)),
      ]),
    );
  }
}

// ───────────────────────── Interacción ─────────────────────────
/// Envuelve un widget con un pequeño "rebote" al pulsar.
class Tap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const Tap({super.key, required this.child, this.onTap, this.scale = .95});
  @override
  State<Tap> createState() => _TapState();
}

class _TapState extends State<Tap> {
  bool down = false;
  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: widget.onTap == null ? null : (_) => setState(() => down = true),
        onTapUp: (_) => setState(() => down = false),
        onTapCancel: () => setState(() => down = false),
        child: AnimatedScale(scale: down ? widget.scale : 1, duration: const Duration(milliseconds: 110), curve: Curves.easeOut, child: widget.child),
      );
}

/// Entrada escalonada (fade + desliza) para listas.
class Reveal extends StatelessWidget {
  final int index;
  final Widget child;
  const Reveal(this.index, this.child, {super.key});
  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 320 + (index.clamp(0, 8)) * 70),
        curve: Curves.easeOutCubic,
        builder: (_, v, c) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: c)),
        child: child,
      );
}

/// Bloque que "late" mientras carga (skeleton).
class Pulse extends StatefulWidget {
  final double? width, height;
  final double radius;
  const Pulse({super.key, this.width, this.height, this.radius = 12});
  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: c,
        builder: (_, _) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(color: Color.lerp(surface, surface2, c.value), borderRadius: BorderRadius.circular(widget.radius)),
        ),
      );
}

void toast(BuildContext c, String msg) {
  final m = ScaffoldMessenger.of(c);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Row(children: [
      const Icon(Icons.bolt, color: lime, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: ts(14, w: FontWeight.w600))),
    ]),
    backgroundColor: surface2,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(r12), side: const BorderSide(color: line)),
    duration: const Duration(milliseconds: 2200),
  ));
}

Future<T?> showSheet<T>(BuildContext c, WidgetBuilder b) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(r28))),
      builder: b,
    );

// ───────────────────────── Componentes ─────────────────────────
class Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  const Pill(this.label, this.selected, this.onTap, {super.key, this.leading});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(color: selected ? lime : surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? lime : line)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(label, style: ts(13, w: FontWeight.w700, c: selected ? ink : text)),
          ]),
        ),
      );
}

class Seg<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool Function(T)? enabled;
  const Seg(this.options, this.value, this.onChanged, {super.key, this.enabled});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: surface2, borderRadius: BorderRadius.circular(r12)),
        child: Row(children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => (enabled?.call(o.$1) ?? true) ? onChanged(o.$1) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: o.$1 == value ? lime : Colors.transparent, borderRadius: BorderRadius.circular(9)),
                  child: Text(o.$2, style: ts(13, w: FontWeight.w700, c: !(enabled?.call(o.$1) ?? true) ? muted.withValues(alpha: .5) : o.$1 == value ? ink : muted)),
                ),
              ),
            ),
        ]),
      );
}

class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color bg, fg;
  final IconData? icon;
  final bool outlined;
  final double height;
  const Btn(this.label, this.onTap, {super.key, this.bg = lime, this.fg = ink, this.icon, this.outlined = false, this.height = 52});
  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    final fgc = !on ? muted : (outlined ? text : fg);
    return Tap(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : (on ? bg : surface2),
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: line, width: 1.5) : null,
          boxShadow: on && !outlined && bg == lime ? [BoxShadow(color: lime.withValues(alpha: .28), blurRadius: 18, offset: const Offset(0, 6))] : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 19, color: fgc), const SizedBox(width: 8)],
          Text(label.toUpperCase(), style: ts(14, w: FontWeight.w800, c: fgc, ls: .6)),
        ]),
      ),
    );
  }
}

/// Paleta de avatares: (fondo, texto). El usuario elige una en "Foto de perfil".
const avatarTones = <(Color, Color)>[
  (lime, ink),
  (cyan, ink),
  (Color(0xFFFB923C), ink),
  (Color(0xFFA78BFA), ink),
  (Color(0xFFF472B6), ink),
  (Color(0xFF34D399), ink),
];

class Avatar extends StatelessWidget {
  final String ini;
  final double size;
  final int tone;
  const Avatar(this.ini, {super.key, this.size = 48, this.tone = 0});
  @override
  Widget build(BuildContext context) {
    final t = avatarTones[tone % avatarTones.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 3.2),
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [t.$1, Color.lerp(t.$1, Colors.black, .28)!]),
      ),
      child: Text(ini, style: hd(size * .46, c: t.$2, italic: true)),
    );
  }
}

class Stars extends StatelessWidget {
  final double value;
  final double size;
  const Stars(this.value, {super.key, this.size = 16});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 1; i <= 5; i++) Icon(value >= i - .25 ? Icons.star_rounded : value >= i - .75 ? Icons.star_half_rounded : Icons.star_outline_rounded, size: size, color: amber),
      ]);
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  const IconTile(this.icon, {super.key, this.bg = surface2, this.fg = lime, this.size = 40});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(r12)),
        child: Icon(icon, size: size * .5, color: fg),
      );
}

class Tag extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final IconData? icon;
  const Tag(this.label, {super.key, this.bg = surface2, this.fg = text, this.icon});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(r8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 12, color: fg), const SizedBox(width: 4)],
          Text(label.toUpperCase(), style: ts(10.5, w: FontWeight.w800, c: fg, ls: .6)),
        ]),
      );
}

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color bg, fg;
  const RoundBtn(this.icon, this.onTap, {super.key, this.size = 40, this.bg = surface, this.fg = text});
  @override
  Widget build(BuildContext context) => Tap(
        onTap: onTap,
        child: Container(width: size, height: size, decoration: box(bg: bg, r: r12), child: Icon(icon, size: 20, color: fg)),
      );
}

/// Insignia numérica (contador sobre un icono).
Widget countBadge(int n) => Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: lime, borderRadius: BorderRadius.circular(9), border: Border.all(color: bg, width: 2)),
      child: Text('$n', style: ts(10, w: FontWeight.w800, c: ink)),
    );

class StatTile extends StatelessWidget {
  final String value, caption;
  final IconData icon;
  final Color accent;
  const StatTile(this.value, this.caption, this.icon, {super.key, this.accent = lime});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: accent),
          const SizedBox(height: 10),
          Text(value, style: hd(30, italic: true)),
          const SizedBox(height: 2),
          Text(caption, style: ts(11.5, c: muted, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );
}

/// Estado vacío con "halo" de círculos concéntricos (sin imágenes).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final Widget? action;
  const EmptyState(this.icon, this.title, this.message, {super.key, this.action});
  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Stack(alignment: Alignment.center, children: [
              Container(width: 132, height: 132, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: line.withValues(alpha: .6)))),
              Container(width: 98, height: 98, decoration: BoxDecoration(shape: BoxShape.circle, color: limeTint)),
              Container(width: 64, height: 64, decoration: const BoxDecoration(shape: BoxShape.circle, color: lime), child: Icon(icon, size: 30, color: ink)),
            ]),
            const SizedBox(height: 22),
            Text(title.toUpperCase(), style: hd(26, italic: true), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: ts(14, c: muted, h: 1.45), textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ]),
        ),
      );
}

/// Cabecera de pestaña principal: sobretítulo + título grande.
class ScreenHeader extends StatelessWidget {
  final String kicker, title;
  final List<Widget> actions;
  const ScreenHeader(this.kicker, this.title, {super.key, this.actions = const []});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 16, 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(kicker.toUpperCase(), style: ts(11, c: lime, w: FontWeight.w800, ls: 1.4)),
              const SizedBox(height: 4),
              Text(title.toUpperCase(), style: hd(38, italic: true)),
            ]),
          ),
          for (final a in actions) Padding(padding: const EdgeInsets.only(left: 8), child: a),
        ]),
      );
}

class StepperRow extends StatelessWidget {
  final String label, value;
  final VoidCallback dec, inc;
  const StepperRow(this.label, this.value, this.dec, this.inc, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(child: Text(label, style: ts(15, w: FontWeight.w500))),
        RoundBtn(Icons.remove, dec, size: 36),
        SizedBox(width: 64, child: Center(child: Text(value, style: hd(22)))),
        RoundBtn(Icons.add, inc, size: 36),
      ]);
}

/// Pantalla estándar con flecha de volver, usada por las rutas empujadas.
class SubScreen extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? bottom;
  final List<Widget> actions;
  final bool canBack;
  const SubScreen({super.key, required this.title, required this.child, this.subtitle, this.bottom, this.actions = const [], this.canBack = true});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(children: [
                if (canBack) RoundBtn(Icons.chevron_left, () => Navigator.of(context).maybePop()) else const SizedBox(width: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (subtitle != null) Text(subtitle!.toUpperCase(), style: ts(10.5, c: lime, w: FontWeight.w800, ls: 1.2)),
                    Text(title.toUpperCase(), style: hd(26, italic: true), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                ...actions,
              ]),
            ),
            Expanded(child: child),
            if (bottom != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(color: surface, border: Border(top: BorderSide(color: line))),
                child: bottom,
              ),
          ]),
        ),
      );
}

Widget sheetHandle() => Center(
      child: Container(margin: const EdgeInsets.only(top: 10, bottom: 6), width: 40, height: 4, decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(2))),
    );

Widget label(String t) => Padding(padding: const EdgeInsets.only(top: 20, bottom: 8), child: Text(t.toUpperCase(), style: ts(11.5, w: FontWeight.w800, c: muted, ls: 1.1)));

Widget field(TextEditingController c, String hint, {ValueChanged<String>? onChanged, TextInputType? type, int? maxLen, bool obscure = false, IconData? icon}) => TextField(
      controller: c,
      onChanged: onChanged,
      keyboardType: type,
      maxLength: maxLen,
      obscureText: obscure,
      style: ts(15),
      decoration: InputDecoration(
        counterText: '',
        filled: true,
        fillColor: surface,
        hintText: hint,
        hintStyle: ts(15, c: muted.withValues(alpha: .75)),
        prefixIcon: icon == null ? null : Icon(icon, size: 20, color: muted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(r12), borderSide: const BorderSide(color: lime, width: 1.6)),
      ),
    );

Widget errorText(String t) => Padding(padding: const EdgeInsets.only(top: 12), child: Text(t, style: ts(13, c: danger, w: FontWeight.w600)));
