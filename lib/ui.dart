import 'package:flutter/material.dart';

const navy = Color(0xFF0B1F3A);
const lime = Color(0xFFB6F23A);
const cyan = Color(0xFF22D3EE);
const soft = Color(0xFFE5E9F0);
const slate = Color(0xFF5B6B82);
const white = Colors.white;
final cyanTint = cyan.withValues(alpha: .18);
final cyanFaint = cyan.withValues(alpha: .06);

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: white,
      colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy, secondary: cyan, surface: white),
      textTheme: ThemeData.light().textTheme.apply(bodyColor: navy, displayColor: navy),
      splashFactory: InkRipple.splashFactory,
    );

BoxDecoration box({Color bg = white, Color? bd = soft, double r = 16, double bw = 1}) =>
    BoxDecoration(color: bg, borderRadius: BorderRadius.circular(r), border: bd == null ? null : Border.all(color: bd, width: bw));

TextStyle ts(double size, {FontWeight w = FontWeight.w400, Color c = navy, double? h, bool strike = false}) =>
    TextStyle(fontSize: size, fontWeight: w, color: c, height: h, decoration: strike ? TextDecoration.lineThrough : null);

void toast(BuildContext c, String msg) {
  final m = ScaffoldMessenger.of(c);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    content: Text(msg, style: ts(14, w: FontWeight.w500, c: white)),
    backgroundColor: navy,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 96),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    duration: const Duration(milliseconds: 2200),
  ));
}

Future<T?> showSheet<T>(BuildContext c, WidgetBuilder b) => showModalBottomSheet<T>(
      context: c,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: b,
    );

class Pill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? leading;
  const Pill(this.label, this.selected, this.onTap, {super.key, this.leading});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
              color: selected ? navy : white, borderRadius: BorderRadius.circular(18), border: Border.all(color: selected ? navy : soft)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(label, style: ts(13, w: FontWeight.w500, c: selected ? white : navy)),
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
        decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => (enabled?.call(o.$1) ?? true) ? onChanged(o.$1) : null,
                child: Container(
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o.$1 == value ? white : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                    boxShadow: o.$1 == value ? [BoxShadow(color: navy.withValues(alpha: .14), blurRadius: 3, offset: const Offset(0, 1))] : null,
                  ),
                  child: Text(o.$2,
                      style: ts(13, w: FontWeight.w600, c: !(enabled?.call(o.$1) ?? true) ? slate.withValues(alpha: .5) : o.$1 == value ? navy : slate)),
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
  const Btn(this.label, this.onTap, {super.key, this.bg = navy, this.fg = white, this.icon, this.outlined = false, this.height = 52});
  @override
  Widget build(BuildContext context) {
    final on = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: outlined ? white : (on ? bg : soft),
          borderRadius: BorderRadius.circular(14),
          border: outlined ? Border.all(color: soft) : null,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 18, color: on ? fg : slate), const SizedBox(width: 8)],
          Text(label, style: ts(15, w: FontWeight.w600, c: on ? (outlined ? navy : fg) : slate)),
        ]),
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String ini;
  final double size;
  const Avatar(this.ini, {super.key, this.size = 48});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(size / 3)),
        child: Text(ini, style: ts(size * .36, w: FontWeight.w600, c: lime)),
      );
}

class IconTile extends StatelessWidget {
  final IconData icon;
  final Color bg, fg;
  final double size;
  final Color? border;
  const IconTile(this.icon, {super.key, this.bg = navy, this.fg = white, this.size = 40, this.border});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: border == null ? null : Border.all(color: border!, width: 1.5)),
        child: Icon(icon, size: size * .5, color: fg),
      );
}

class Tag extends StatelessWidget {
  final String label;
  final Color bg, fg;
  final Color? bd;
  const Tag(this.label, {super.key, this.bg = soft, this.fg = navy, this.bd});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10), border: bd == null ? null : Border.all(color: bd!)),
        child: Text(label, style: ts(12, w: FontWeight.w600, c: fg)),
      );
}

class RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color bg, fg;
  const RoundBtn(this.icon, this.onTap, {super.key, this.size = 40, this.bg = white, this.fg = navy});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: box(bg: bg, r: 12),
          child: Icon(icon, size: 20, color: fg),
        ),
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
        SizedBox(width: 64, child: Center(child: Text(value, style: ts(16, w: FontWeight.w600)))),
        RoundBtn(Icons.add, inc, size: 36),
      ]);
}

/// Standard screen with back arrow header used by pushed routes.
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
        backgroundColor: white,
        body: SafeArea(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(children: [
                if (canBack) RoundBtn(Icons.chevron_left, () => Navigator.of(context).maybePop()) else const SizedBox(width: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (subtitle != null) Text(subtitle!, style: ts(12, c: slate, w: FontWeight.w500)),
                    Text(title, style: ts(20, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
                ...actions,
              ]),
            ),
            Expanded(child: child),
            if (bottom != null)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: const BoxDecoration(color: white, border: Border(top: BorderSide(color: soft))),
                child: bottom,
              ),
          ]),
        ),
      );
}

Widget sheetHandle() => Center(
      child: Container(margin: const EdgeInsets.only(top: 10, bottom: 6), width: 40, height: 4, decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(2))),
    );

Widget label(String t) => Padding(padding: const EdgeInsets.only(top: 18, bottom: 8), child: Text(t, style: ts(13, w: FontWeight.w600, c: slate)));

Widget field(TextEditingController c, String hint, {ValueChanged<String>? onChanged, TextInputType? type, int? maxLen, bool obscure = false, IconData? icon}) => TextField(
      controller: c,
      onChanged: onChanged,
      keyboardType: type,
      maxLength: maxLen,
      style: ts(15),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: ts(15, c: slate.withValues(alpha: .75)),
        prefixIcon: icon == null ? null : Icon(icon, size: 20, color: slate),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: soft)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: soft)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: cyan, width: 2)),
      ),
    );

IconData eqIcon(String eq) => switch (eq) {
      'barra' => Icons.fitness_center,
      'mancuernas' => Icons.fitness_center,
      'kettlebell' => Icons.sports_gymnastics,
      'corporal' => Icons.accessibility_new,
      'smith' || 'maquina' => Icons.precision_manufacturing_outlined,
      'polea' => Icons.settings_input_component,
      'banda' => Icons.waves,
      _ => Icons.fitness_center,
    };

Widget tipoMarker(String t) {
  switch (t) {
    case 'ejercicio':
      return Container(width: 6, height: 6, decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(3)));
    case 'comida':
      return Container(width: 7, height: 7, decoration: BoxDecoration(color: lime, border: Border.all(color: navy), borderRadius: BorderRadius.circular(2)));
    default:
      return Transform.rotate(angle: .785, child: Container(width: 6, height: 6, color: cyan));
  }
}
