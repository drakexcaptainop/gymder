import 'dart:async';
import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';

void openCoachProfile(BuildContext c, String id) {
  app.coachId = id;
  app.notify();
  Navigator.of(c).push(MaterialPageRoute(builder: (_) => const PerfilScreen()));
}

void startRenew(BuildContext context) {
  final a = app.active;
  if (a == null) return;
  app.coachId = a.coachId;
  app.selPkg = a.pkgId;
  app.renew = true;
  app.notify();
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaquetesScreen()));
}

// ───────────────────────── Favoritos ─────────────────────────
class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = app.favs.map(coachById).toList();
          return SubScreen(
            title: 'Favoritos',
            subtitle: '${list.length} ${list.length == 1 ? 'coach guardado' : 'coaches guardados'}',
            child: list.isEmpty
                ? Center(child: Text('Desliza a la derecha para guardar coaches.', style: ts(14, c: slate)))
                : ListView(padding: const EdgeInsets.all(16), children: [
                    for (final c in list)
                      GestureDetector(
                        onTap: () => openCoachProfile(context, c.id),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: box(),
                          child: Row(children: [
                            Avatar(c.ini, size: 52),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(c.nombre, style: ts(16, w: FontWeight.w600)),
                                Text('${c.especialidad} · ${c.modalidad} · ${c.exp} años de experiencia', style: ts(12, c: slate)),
                              ]),
                            ),
                            const Icon(Icons.chevron_right, color: slate),
                          ]),
                        ),
                      ),
                  ]),
          );
        },
      );
}

// ───────────────────────── Perfil del coach ─────────────────────────
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = coachById(app.coachId);
          final isFav = app.favs.contains(c.id);
          return SubScreen(
            title: c.nombre,
            subtitle: 'Perfil del coach',
            actions: [
              RoundBtn(isFav ? Icons.favorite : Icons.favorite_border, () {
                app.toggleFav(c.id);
                if (!isFav) toast(context, '${c.nombre} guardado en favoritos');
              }, bg: isFav ? lime : white),
            ],
            bottom: SizedBox(
              width: double.infinity,
              child: Btn('Ver paquetes', () {
                app.selPkg = null;
                app.renew = false;
                app.notify();
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PaquetesScreen()));
              }, bg: lime, fg: navy),
            ),
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Row(children: [
                Avatar(c.ini, size: 72),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(c.nombre, style: ts(22, w: FontWeight.w600)),
                    Text('${c.especialidad} · ${c.modalidad}', style: ts(13, c: slate)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Text(c.bio, style: ts(15, h: 1.5)),
              label('Datos'),
              Container(
                decoration: box(),
                child: Column(children: [
                  for (final (i, r) in [('Especialidad', c.especialidad), ('Experiencia', '${c.exp} años'), ('Modalidad', c.modalidad), ('Lugar', c.lugar)].indexed)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(border: i < 3 ? const Border(bottom: BorderSide(color: soft)) : null),
                      child: Row(children: [
                        SizedBox(width: 110, child: Text(r.$1, style: ts(13, c: slate))),
                        Expanded(child: Text(r.$2, style: ts(14, w: FontWeight.w500))),
                      ]),
                    ),
                ]),
              ),
              label('Enfoque'),
              Text(c.enfoque, style: ts(14, h: 1.5)),
              label('Temas'),
              Wrap(spacing: 6, runSpacing: 6, children: [for (final t in c.tags) Tag(t)]),
              label('Certificaciones'),
              for (final t in c.certs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [const Icon(Icons.workspace_premium_outlined, size: 20), const SizedBox(width: 10), Expanded(child: Text(t, style: ts(14)))]),
                ),
            ]),
          );
        },
      );
}

// ───────────────────────── Paquetes ─────────────────────────
class PaquetesScreen extends StatelessWidget {
  const PaquetesScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = coachById(app.coachId);
          final list = app.pkgs.where((p) => p.coachId == c.id && p.activo).toList();
          final sel = list.where((p) => p.id == app.selPkg).firstOrNull;
          return SubScreen(
            title: app.renew ? 'Renovar paquete' : 'Paquetes',
            subtitle: '${list.length} paquetes disponibles · ${c.nombre}',
            bottom: sel == null
                ? SizedBox(width: double.infinity, child: Btn('Continuar', null))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      Expanded(child: Text('${sel.nombre} · ${sel.sesiones} sesiones · ${sel.dias} días', style: ts(13, c: slate))),
                      Text(price(sel.precio), style: ts(18, w: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 10),
                    SizedBox(width: double.infinity, child: Btn('Continuar', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PagoScreen())))),
                  ]),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              if (app.renew)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: box(bg: cyanFaint, bd: cyan),
                  child: Text('Paquete actual preseleccionado. La renovación es manual y no genera cobros automáticos.', style: ts(13, h: 1.4)),
                ),
              for (final p in list)
                GestureDetector(
                  onTap: () {
                    app.selPkg = p.id;
                    app.notify();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: box(bg: p.id == app.selPkg ? cyanFaint : white, bd: p.id == app.selPkg ? cyan : soft, bw: p.id == app.selPkg ? 2 : 1),
                    child: Row(children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: p.id == app.selPkg ? cyan : white, border: Border.all(color: p.id == app.selPkg ? cyan : soft, width: 2)),
                        child: p.id == app.selPkg ? const Icon(Icons.check, size: 14, color: navy) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(p.nombre, style: ts(17, w: FontWeight.w600)),
                            if (app.renew && app.active?.pkgId == p.id) ...[const SizedBox(width: 8), const Tag('Actual', bg: lime)],
                          ]),
                          Text('${p.sesiones} sesiones · ${p.dias} días', style: ts(13, c: slate)),
                        ]),
                      ),
                      Text(price(p.precio), style: ts(18, w: FontWeight.w700)),
                    ]),
                  ),
                ),
            ]),
          );
        },
      );
}

// ───────────────────────── Pago simulado ─────────────────────────
class PagoScreen extends StatefulWidget {
  const PagoScreen({super.key});
  @override
  State<PagoScreen> createState() => _PagoScreenState();
}

enum _Pay { form, processing, error }

class _PagoScreenState extends State<PagoScreen> {
  final nombre = TextEditingController(), numero = TextEditingController(), exp = TextEditingController(), cvc = TextEditingController();
  _Pay st = _Pay.form;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String digits(String s) => s.replaceAll(RegExp(r'\D'), '');
  bool get complete => nombre.text.trim().length > 1 && digits(numero.text).length == 16 && exp.text.length == 5 && cvc.text.length == 3;

  void fmt(TextEditingController c, String Function(String) f) {
    final v = f(c.text);
    if (v != c.text) c.value = TextEditingValue(text: v, selection: TextSelection.collapsed(offset: v.length));
    setState(() {});
  }

  void pay() {
    if (st == _Pay.processing || !complete) return;
    setState(() => st = _Pay.processing);
    timer = Timer(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      if (digits(numero.text).endsWith('0002')) {
        setState(() => st = _Pay.error);
        return;
      }
      app.completePayment();
      final nav = Navigator.of(context);
      nav.popUntil((r) => r.isFirst);
      nav.push(MaterialPageRoute(builder: (_) => const ExitoScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = app.pkgs.firstWhere((x) => x.id == app.selPkg);
    final c = coachById(app.coachId);
    final processing = st == _Pay.processing;
    return PopScope(
      canPop: !processing,
      child: SubScreen(
        title: 'Pago simulado',
        subtitle: 'Sin cobros reales',
        canBack: !processing,
        bottom: SizedBox(
          width: double.infinity,
          child: processing
              ? Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: slate)),
                    const SizedBox(width: 10),
                    Text('Procesando pago…', style: ts(15, w: FontWeight.w600, c: slate)),
                  ]),
                )
              : Btn('Pagar ${price(p.precio)}', complete ? pay : null, bg: lime, fg: navy),
        ),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: box(bg: navy, bd: null),
            child: Row(children: [
              Avatar(c.ini, size: 44),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${p.nombre} · ${c.nombre}', style: ts(15, w: FontWeight.w600, c: white)),
                  Text('${p.sesiones} sesiones · ${p.dias} días', style: ts(12, c: soft)),
                ]),
              ),
              Text(price(p.precio), style: ts(18, w: FontWeight.w700, c: lime)),
            ]),
          ),
          if (st == _Pay.error)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(14),
              decoration: box(bg: const Color(0xFFFDECEC), bd: const Color(0xFFE57373)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [const Icon(Icons.error_outline, color: Color(0xFFB3261E)), const SizedBox(width: 8), Text('No pudimos procesar el pago', style: ts(15, w: FontWeight.w600))]),
                const SizedBox(height: 4),
                Text('Es un error simulado. No se hizo ningún cobro. Puedes reintentar.', style: ts(13, c: slate)),
                const SizedBox(height: 10),
                Btn('Reintentar', () {
                  setState(() => st = _Pay.form);
                  pay();
                }, height: 40),
              ]),
            ),
          label('Nombre en la tarjeta'),
          field(nombre, 'Ana Torres', maxLen: 26, onChanged: (_) => setState(() {})),
          label('Número de tarjeta'),
          field(numero, '0000 0000 0000 0000', type: TextInputType.number, icon: Icons.credit_card, onChanged: (_) => fmt(numero, (v) => digits(v).substring(0, digits(v).length.clamp(0, 16)).replaceAllMapped(RegExp(r'.{4}'), (m) => '${m[0]} ').trim())),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [label('Vence'), field(exp, 'MM/AA', type: TextInputType.number, onChanged: (_) => fmt(exp, (v) { final d = digits(v); final s = d.substring(0, d.length.clamp(0, 4)); return s.length > 2 ? '${s.substring(0, 2)}/${s.substring(2)}' : s; }))])),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [label('CVC'), field(cvc, '123', type: TextInputType.number, onChanged: (_) => fmt(cvc, (v) => digits(v).substring(0, digits(v).length.clamp(0, 3))))])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(complete ? 'Datos completos' : 'Completa los datos de la tarjeta para continuar', style: ts(12, c: slate))),
            TextButton(
              onPressed: () {
                nombre.text = 'Ana Torres';
                numero.text = '4242 4242 4242 4242';
                exp.text = '12/29';
                cvc.text = '123';
                setState(() {});
              },
              child: const Text('Rellenar demo'),
            ),
          ]),
          Text('Tip: una tarjeta que termine en 0002 simula un error de pago.', style: ts(12, c: slate)),
        ]),
      ),
    );
  }
}

// ───────────────────────── Éxito / Recibo ─────────────────────────
class ExitoScreen extends StatelessWidget {
  const ExitoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final c = coachById(app.receipt.coachId);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const Spacer(),
            Container(width: 96, height: 96, decoration: const BoxDecoration(color: lime, shape: BoxShape.circle), child: const Icon(Icons.check, size: 52, color: navy)),
            const SizedBox(height: 24),
            Text('¡Pago simulado exitoso!', style: ts(26, w: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Tu paquete con ${c.nombre} ya está activo. No se realizó ningún cobro real.', style: ts(15, c: slate, h: 1.45), textAlign: TextAlign.center),
            const Spacer(),
            SizedBox(width: double.infinity, child: Btn('Ver mi rutina', () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              app.setTab(2);
            }, bg: lime, fg: navy)),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: Btn('Ver recibo', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReciboScreen())), outlined: true)),
            const SizedBox(height: 4),
            TextButton(onPressed: () {
              Navigator.of(context).popUntil((r) => r.isFirst);
              app.setTab(4);
            }, child: const Text('Ir a Mi coach')),
          ]),
        ),
      ),
    );
  }
}

class ReciboScreen extends StatelessWidget {
  const ReciboScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final r = app.receipt;
    final p = app.pkgs.firstWhere((x) => x.id == r.pkgId);
    final rows = [
      ('Coach', coachById(r.coachId).nombre),
      ('Paquete', p.nombre),
      ('Sesiones', '${p.sesiones} sesiones'),
      ('Duración', '${p.dias} días'),
      ('Fecha', '5 nov 2026'),
      ('Recibo', r.num),
    ];
    return SubScreen(
      title: 'Recibo',
      subtitle: 'Simulado · sin valor fiscal',
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: box(),
          child: Column(children: [
            for (final x in rows)
              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Row(children: [Expanded(child: Text(x.$1, style: ts(14, c: slate))), Text(x.$2, style: ts(14, w: FontWeight.w600))])),
            const Divider(color: soft),
            Row(children: [Expanded(child: Text('Total', style: ts(16, w: FontWeight.w600))), Text(price(p.precio), style: ts(20, w: FontWeight.w700))]),
          ]),
        ),
      ]),
    );
  }
}

// ───────────────────────── Chat ─────────────────────────
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final c = TextEditingController();
  final sc = ScrollController();

  void send() {
    app.sendMsg(c.text);
    c.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (sc.hasClients) sc.jumpTo(sc.position.maxScrollExtent);
          });
          final coach = app.activeCoach;
          return SubScreen(
            title: coach?.nombre ?? 'Chat',
            subtitle: 'Chat con tu coach',
            child: !app.paid
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.lock_outline, size: 40, color: slate),
                        const SizedBox(height: 12),
                        Text('Chat bloqueado', style: ts(18, w: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Se habilita cuando contratas un paquete con un coach.', style: ts(14, c: slate), textAlign: TextAlign.center),
                      ]),
                    ),
                  )
                : Column(children: [
                    Expanded(
                      child: ListView(controller: sc, padding: const EdgeInsets.all(16), children: [
                        for (final m in app.msgs)
                          Align(
                            alignment: m.user ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .75),
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: m.user ? navy : soft,
                                borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(m.user ? 16 : 4), bottomRight: Radius.circular(m.user ? 4 : 16)),
                              ),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(m.text, style: ts(14, c: m.user ? white : navy, h: 1.4)),
                                const SizedBox(height: 2),
                                Text(m.time, style: ts(10, c: m.user ? soft : slate)),
                              ]),
                            ),
                          ),
                      ]),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: soft))),
                      child: Row(children: [
                        Expanded(child: TextField(controller: c, onChanged: (_) => setState(() {}), onSubmitted: (_) => send(), decoration: InputDecoration(hintText: 'Escribe un mensaje', border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: const BorderSide(color: soft)), contentPadding: const EdgeInsets.symmetric(horizontal: 16)))),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: c.text.trim().isEmpty ? null : send,
                          child: Container(width: 44, height: 44, decoration: BoxDecoration(color: c.text.trim().isEmpty ? soft : lime, shape: BoxShape.circle), child: Icon(Icons.send, size: 20, color: c.text.trim().isEmpty ? slate : navy)),
                        ),
                      ]),
                    ),
                  ]),
          );
        },
      );
}

// ───────────────────────── Editor de paquetes (modo coach) ─────────────────────────
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});
  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String? edId = 'p1a';
  final nombre = TextEditingController(), precio = TextEditingController(), sesiones = TextEditingController(), dias = TextEditingController();
  bool activo = true;

  @override
  void initState() {
    super.initState();
    load(app.pkgs.firstWhere((p) => p.id == 'p1a'));
  }

  void load(Pkg? p) {
    edId = p?.id;
    nombre.text = p?.nombre ?? '';
    precio.text = p == null ? '' : '${p.precio}';
    sesiones.text = p == null ? '' : '${p.sesiones}';
    dias.text = p == null ? '' : '${p.dias}';
    activo = p?.activo ?? true;
  }

  bool get valid => nombre.text.trim().isNotEmpty && precio.text.isNotEmpty && sesiones.text.isNotEmpty && dias.text.isNotEmpty;

  void save() {
    if (!valid) return toast(context, 'Completa los cuatro campos del paquete');
    final p = Pkg(edId ?? 'p${DateTime.now().millisecondsSinceEpoch}', 'c1', nombre.text.trim(), int.parse(precio.text), int.parse(sesiones.text), int.parse(dias.text), activo);
    app.savePkg(p);
    setState(() => edId = p.id);
    toast(context, activo ? 'Paquete guardado y visible' : 'Paquete guardado como oculto');
  }

  Widget num_(TextEditingController c, String h) => field(c, h, type: TextInputType.number, maxLen: 5, onChanged: (v) {
        final d = v.replaceAll(RegExp(r'\D'), '');
        if (d != v) c.text = d;
        setState(() {});
      });

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final list = app.pkgs.where((p) => p.coachId == 'c1').toList();
          return SubScreen(
            title: edId == null ? 'Nuevo paquete' : 'Editar paquete',
            subtitle: 'Modo coach · Valeria Ríos',
            bottom: Row(children: [
              Expanded(child: Btn('Cancelar', () => setState(() => load(app.pkgs.firstWhere((p) => p.id == (edId ?? 'p1a'), orElse: () => app.pkgs.first))), outlined: true)),
              const SizedBox(width: 10),
              Expanded(flex: 2, child: Btn('Guardar', save)),
            ]),
            child: ListView(padding: const EdgeInsets.all(16), children: [
              SizedBox(
                height: 40,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final p in list) Padding(padding: const EdgeInsets.only(right: 8), child: Pill(p.activo ? p.nombre : '${p.nombre} · Oculto', edId == p.id, () => setState(() => load(p)))),
                  Pill('+ Nuevo paquete', edId == null, () => setState(() => load(null))),
                ]),
              ),
              label('Nombre'),
              field(nombre, 'Ej. Esencial', maxLen: 32, onChanged: (_) => setState(() {})),
              label('Precio (¤)'),
              num_(precio, '120'),
              label('Sesiones'),
              num_(sesiones, '8'),
              label('Duración (días)'),
              num_(dias, '30'),
              label('Visibilidad'),
              Seg([(true, 'Activo'), (false, 'Oculto')], activo, (v) => setState(() => activo = v)),
              label('Vista previa'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: box(),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(nombre.text.trim().isEmpty ? 'Nombre del paquete' : nombre.text.trim(), style: ts(17, w: FontWeight.w600)),
                      Text('${sesiones.text.isEmpty ? 0 : sesiones.text} sesiones · ${dias.text.isEmpty ? 0 : dias.text} días', style: ts(13, c: slate)),
                    ]),
                  ),
                  Text(price(precio.text.isEmpty ? '0' : precio.text), style: ts(18, w: FontWeight.w700)),
                ]),
              ),
            ]),
          );
        },
      );
}
