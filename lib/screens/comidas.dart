import 'package:flutter/material.dart';
import '../data.dart';
import '../state.dart';
import '../ui.dart';

const _goal = (kcal: 2200, p: 150, c: 240, g: 70);

class ComidasTab extends StatelessWidget {
  const ComidasTab({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(listenable: app, builder: (c, _) => _body(c));

  Widget _body(BuildContext context) {
    final w = app.week;
    final mon = mondayOf(w);
    final dayPlan = app.plan[w]![app.mDay];
    final tot = Macro(0, 0, 0, 0);
    for (final sl in dayPlan) {
      for (final it in sl) {
        final t = dishCalc(it.dish);
        tot.k += t.k;
        tot.p += t.p;
        tot.c += t.c;
        tot.g += t.g;
      }
    }
    int pct(num a, num b) => (a / b * 100).round().clamp(0, 100);
    final dd = addDays(mon, app.mDay);

    return ListView(padding: const EdgeInsets.only(bottom: 24), children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Semana del ${rangeOfWeek(w)}', style: ts(13, c: slate, w: FontWeight.w500)),
              Text('Comidas', style: ts(30, w: FontWeight.w600)),
            ]),
          ),
          Btn('Compras', () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShoppingScreen())), icon: Icons.shopping_cart_outlined, outlined: true, height: 40),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Seg([for (final ww in [-1, 0, 1]) (ww, ['Anterior', 'Actual', 'Siguiente'][ww + 1])], w, (v) {
          app.week = v;
          app.justMeal = null;
          app.notify();
        }),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 64,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 7,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final dt = addDays(mon, i);
            final sel = app.mDay == i;
            final isToday = w == 0 && i == 3;
            return GestureDetector(
              onTap: () {
                app.mDay = i;
                app.notify();
              },
              child: Container(
                width: 48,
                decoration: box(bg: sel ? navy : white, bd: sel ? navy : soft, r: 14),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(dayShort[i], style: ts(11, c: sel ? white : slate, w: FontWeight.w500)),
                  Text('${dt.day}', style: ts(17, w: FontWeight.w600, c: sel ? white : navy)),
                  Container(width: 4, height: 4, decoration: BoxDecoration(color: isToday ? cyan : Colors.transparent, shape: BoxShape.circle)),
                ]),
              ),
            );
          },
        ),
      ),
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: box(bg: navy, bd: null),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${dayLong[app.mDay]} ${dd.day} ${monthShort[dd.month - 1]}', style: ts(13, c: soft)),
          const SizedBox(height: 4),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(thou(tot.k), style: ts(30, w: FontWeight.w600, c: white)),
            const SizedBox(width: 6),
            Flexible(child: Padding(padding: const EdgeInsets.only(bottom: 5), child: Text('de 2.200 kcal', style: ts(13, c: soft), overflow: TextOverflow.ellipsis))),
          ]),
          const SizedBox(height: 8),
          _bar(pct(tot.k, _goal.kcal) / 100, lime, track: Colors.white24),
          const SizedBox(height: 14),
          Row(children: [
            for (final (l, v, g) in [('Proteínas', tot.p, _goal.p), ('Carbohidratos', tot.c, _goal.c), ('Grasas', tot.g, _goal.g)])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(l, style: ts(11, c: soft)),
                    Text('$v g', style: ts(15, w: FontWeight.w600, c: white)),
                    Text('de $g g', style: ts(11, c: soft)),
                    const SizedBox(height: 4),
                    _bar(pct(v, g) / 100, cyan, track: Colors.white24, h: 4),
                  ]),
                ),
              ),
          ]),
        ]),
      ),
      for (var si = 0; si < 4; si++) _SlotCard(si, dayPlan[si]),
    ]);
  }
}

Widget _bar(double v, Color c, {Color track = soft, double h = 6}) => ClipRRect(
      borderRadius: BorderRadius.circular(h),
      child: LinearProgressIndicator(value: v, minHeight: h, color: c, backgroundColor: track),
    );

class _SlotCard extends StatelessWidget {
  final int si;
  final List<PlanItem> meals;
  const _SlotCard(this.si, this.meals);
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(14),
        decoration: box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(slotNames[si], style: ts(17, w: FontWeight.w600)),
                Text(meals.isEmpty ? 'Vacía' : meals.length == 1 ? '1 plato' : '${meals.length} platos', style: ts(12, c: slate)),
              ]),
            ),
            RoundBtn(Icons.add, () => showSheet(context, (_) => DishSheet.add(day: app.mDay, slot: si))),
          ]),
          for (final it in meals) _MealCard(it, si),
        ]),
      );
}

class _MealCard extends StatelessWidget {
  final PlanItem it;
  final int si;
  const _MealCard(this.it, this.si);
  @override
  Widget build(BuildContext context) {
    final d = it.dish;
    final t = dishCalc(d);
    final mx = d.servido == 'mezclado';
    final xp = app.expanded.contains(it.uid);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: box(bg: cyanFaint.withValues(alpha: .03), bd: it.uid == app.justMeal ? cyan : soft, bw: it.uid == app.justMeal ? 2 : 1, r: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(d.nombre.isEmpty ? 'Plato sin nombre' : d.nombre, style: ts(15, w: FontWeight.w600))),
          Text('${t.k} kcal', style: ts(15, w: FontWeight.w600)),
        ]),
        const SizedBox(height: 2),
        Text('P ${t.p} g · C ${t.c} g · G ${t.g} g', style: ts(12, c: slate)),
        const SizedBox(height: 8),
        Tag(mx ? 'Mezclado' : 'Por separado', bg: mx ? navy : white, fg: mx ? white : navy, bd: mx ? navy : soft),
        const SizedBox(height: 8),
        Text(mx ? '${d.comps.length} ingredientes: ${d.comps.map((c) => foods[c.foodId]!.n.toLowerCase()).join(', ')}' : dishTxt(d), style: ts(13, c: slate, h: 1.4)),
        if (xp)
          for (final c in d.comps)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: box(r: 10),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${compTxt(c)}${c.aceite != 'ninguno' ? ' · ${c.aceite} de aceite' : ''}', style: ts(13, w: FontWeight.w500)),
                    Text('P ${compCalc(c).p} g · C ${compCalc(c).c} g · G ${compCalc(c).g} g', style: ts(11, c: slate)),
                  ]),
                ),
                Text('${compCalc(c).k} kcal', style: ts(13, w: FontWeight.w600)),
              ]),
            ),
        const SizedBox(height: 6),
        Row(children: [
          Flexible(child: TextButton.icon(
            onPressed: () {
              xp ? app.expanded.remove(it.uid) : app.expanded.add(it.uid);
              app.notify();
            },
            icon: Icon(xp ? Icons.expand_less : Icons.expand_more, size: 18),
            label: Text(xp ? 'Ocultar desglose' : 'Ver desglose', overflow: TextOverflow.ellipsis),
          )),
          const SizedBox(width: 4),
          Flexible(child: TextButton.icon(
            onPressed: () => showSheet(context, (_) => DishSheet.copy(dish: d.clone(), fromDay: app.mDay, fromSlot: si)),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copiar'),
          )),
        ]),
      ]),
    );
  }
}

// ───────────────────────── Add / copy dish sheet ─────────────────────────
class DishSheet extends StatefulWidget {
  final bool copy;
  final Dish? dish;
  final int day, slot, fromDay, fromSlot;
  const DishSheet.add({super.key, required this.day, required this.slot})
      : copy = false, dish = null, fromDay = 0, fromSlot = 0;
  const DishSheet.copy({super.key, required Dish this.dish, required this.fromDay, required this.fromSlot})
      : copy = true, day = 0, slot = 0;
  @override
  State<DishSheet> createState() => _DishSheetState();
}

class _DishSheetState extends State<DishSheet> {
  late Dish dish = widget.dish ?? dishT(mealPools[widget.slot][0]).make();
  late int day = widget.copy ? (widget.fromDay + 1) % 7 : widget.day;
  late int slot = widget.copy ? widget.fromSlot : widget.slot;
  String? open;
  final nameC = TextEditingController();
  final qC = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameC.text = dish.nombre;
  }

  void upd(Comp c, Comp n) => setState(() => dish.comps[dish.comps.indexWhere((x) => x.uid == c.uid)] = n);

  void confirm() {
    if (dish.comps.isEmpty) return;
    final ns = dish.comps.map((c) => foods[c.foodId]!.n).toList();
    dish.nombre = dish.nombre.trim().isNotEmpty ? dish.nombre.trim() : ns[0] + (ns.length > 1 ? ' con ${ns.skip(1).map((x) => x.toLowerCase()).join(' y ')}' : '');
    app.addToPlan(app.week, day, slot, PlanItem(newUid(), dish));
    Navigator.pop(context);
    toast(context, '${widget.copy ? 'Copia creada en' : 'Comida agregada a'} ${dayShort[day]} · ${slotNames[slot]}');
  }

  @override
  Widget build(BuildContext context) {
    final dt = dishCalc(dish);
    final fq = norm(qC.text.trim());
    final results = fq.isEmpty ? <Food>[] : foods.values.where((f) => norm(f.n).contains(fq)).take(6).toList();
    final ok = dish.comps.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        sheetHandle(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
          child: Row(children: [
            Expanded(child: Text(widget.copy ? 'Copiar comida' : 'Agregar comida', style: ts(20, w: FontWeight.w600))),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
          ]),
        ),
        Flexible(
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 0, 20, 12), children: [
            if (widget.copy)
              Text('Copia de ${dayShort[widget.fromDay]} · ${slotNames[widget.fromSlot]}. La comida original se mantiene; puedes ajustar esta copia.', style: ts(13, c: slate, h: 1.4))
            else ...[
              label('Plantillas'),
              SizedBox(
                height: 36,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (final t in dishTemplates)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Pill(t.nombre, false, () => setState(() {
                            dish = t.make();
                            nameC.text = dish.nombre;
                            open = null;
                          })),
                    ),
                ]),
              ),
            ],
            label('Nombre del plato'),
            field(nameC, dish.servido == 'mezclado' ? 'Ej. Arroz con pollo' : 'Ej. Pollo con arroz', maxLen: 40, onChanged: (v) => dish.nombre = v),
            label('Cómo se sirve'),
            Seg([('separado', 'Por separado'), ('mezclado', 'Mezclado')], dish.servido, (v) => setState(() => dish.servido = v)),
            const SizedBox(height: 6),
            Text(dish.servido == 'mezclado' ? 'Los componentes se agrupan bajo el nombre del plato; el desglose se ve al expandir.' : 'Cada componente se sirve por separado en el plato.', style: ts(12, c: slate)),
            label('${dish.comps.length} ${dish.comps.length == 1 ? 'componente' : 'componentes'}'),
            if (dish.comps.isEmpty) Text('Busca un alimento para agregar el primer componente.', style: ts(13, c: slate)),
            for (final c in dish.comps) _compTile(c),
            label('Agregar alimento'),
            field(qC, 'Buscar alimento', maxLen: 30, icon: Icons.search, onChanged: (_) => setState(() {})),
            if (fq.isNotEmpty && results.isEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Sin resultados.', style: ts(13, c: slate))),
            for (final f in results)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(f.n, style: ts(15, w: FontWeight.w600)),
                subtitle: Text('${nfmt(f.k)} kcal · P ${nfmt(f.p)} g · C ${nfmt(f.c)} g · G ${nfmt(f.g)} g por 100 g${f.cook != null ? ' en crudo' : ''}', style: ts(12, c: slate)),
                onTap: () {
                  final c = mkComp(f.id);
                  setState(() {
                    qC.clear();
                    open = c.uid;
                    dish.comps.add(c);
                  });
                },
              ),
            label(widget.copy ? 'Destino' : 'Se agregará a'),
            Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < 7; i++) Pill(dayShort[i], day == i, () => setState(() => day = i))]),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [for (var i = 0; i < 4; i++) Pill(slotNames[i], slot == i, () => setState(() => slot = i))]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: box(bg: navy, bd: null),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                for (final (l, v) in [('kcal', thou(dt.k)), ('Prot.', '${dt.p} g'), ('Carb.', '${dt.c} g'), ('Grasas', '${dt.g} g')])
                  Column(children: [Text(v, style: ts(16, w: FontWeight.w600, c: white)), Text(l, style: ts(11, c: soft))]),
              ]),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(width: double.infinity, child: Btn(widget.copy ? 'Copiar aquí' : 'Agregar', ok ? confirm : null)),
        ),
      ]),
    );
  }

  Widget _compTile(Comp c) {
    final f = foods[c.foodId]!;
    final r = compCalc(c);
    final isOpen = open == c.uid;
    final oilOk = c.prep != null && oilPreps.contains(c.prep);
    final step = unitStep[c.unit] ?? 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: box(bd: isOpen ? cyan : soft, bw: isOpen ? 1.5 : 1, r: 14),
      child: Column(children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => open = isOpen ? null : c.uid),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(compTxt(c), style: ts(14, w: FontWeight.w600)),
                  Text('P ${r.p} g · C ${r.c} g · G ${r.g} g', style: ts(11, c: slate)),
                ]),
              ),
              Text('${r.k} kcal', style: ts(13, w: FontWeight.w600)),
              Icon(isOpen ? Icons.expand_less : Icons.expand_more, color: slate),
            ]),
          ),
        ),
        if (isOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (!f.np) ...[
                Text('Preparación', style: ts(12, c: slate, w: FontWeight.w600)),
                const SizedBox(height: 6),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final p in preps)
                    Pill(p[1], c.prep == p[0], () => upd(c, c.with_(prep: p[0], aceite: oilPreps.contains(p[0]) ? (oilPreps.contains(c.prep) ? c.aceite : '1 cdta') : 'ninguno'))),
                ]),
                const SizedBox(height: 12),
              ],
              Text('Cantidad', style: ts(12, c: slate, w: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(children: [
                RoundBtn(Icons.remove, () => upd(c, c.with_(qty: ((c.qty - step) * 10).round() / 10 < step ? step : ((c.qty - step) * 10).round() / 10)), size: 36),
                SizedBox(width: 70, child: Center(child: Text(nfmt(c.qty), style: ts(16, w: FontWeight.w600)))),
                RoundBtn(Icons.add, () => upd(c, c.with_(qty: (((c.qty + step) * 10).round() / 10).clamp(0, 5000).toDouble())), size: 36),
                const SizedBox(width: 12),
                Wrap(spacing: 6, children: [
                  for (final u in f.u)
                    Pill(u, c.unit == u, () {
                      if (u == c.unit) return;
                      final g = c.unit == 'unidad' ? c.qty * (f.gu ?? 100) : c.unit == 'taza' ? c.qty * (f.gt ?? 200) : c.qty;
                      final q = u == 'unidad'
                          ? (g / (f.gu ?? 100) * 2).round() / 2
                          : u == 'taza'
                              ? (g / (f.gt ?? 200) * 2).round() / 2
                              : (g / 10).round() * 10.0;
                      upd(c, c.with_(unit: u, qty: q < (u == 'unidad' || u == 'taza' ? .5 : 10) ? (u == 'unidad' || u == 'taza' ? .5 : 10) : q));
                    }),
                ]),
              ]),
              if (f.cook != null) ...[
                const SizedBox(height: 12),
                Text('Estado del alimento', style: ts(12, c: slate, w: FontWeight.w600)),
                const SizedBox(height: 6),
                Seg([('crudo', 'Crudo'), ('cocido', 'Cocido')], c.estado, (v) => upd(c, c.with_(estado: v))),
              ],
              const SizedBox(height: 12),
              Text('Aceite de cocción', style: ts(12, c: slate, w: FontWeight.w600)),
              const SizedBox(height: 6),
              if (oilOk)
                Seg([for (final o in oils) (o[0] as String, o[1] as String)], c.aceite, (v) => upd(c, c.with_(aceite: v)))
              else
                Text('No aplica para esta preparación.', style: ts(12, c: slate)),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(() {
                    open = null;
                    dish.comps.removeWhere((x) => x.uid == c.uid);
                  }),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Quitar'),
                ),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ───────────────────────── Shopping list ─────────────────────────
class ShoppingScreen extends StatelessWidget {
  const ShoppingScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final w = app.week;
          final agg = <String, ({double g, int n})>{};
          var oilMl = 0;
          for (final day in app.plan[w]!) {
            for (final sl in day) {
              for (final it in sl) {
                final seen = <String>{};
                for (final c in it.dish.comps) {
                  final a = agg[c.foodId] ?? (g: 0.0, n: 0);
                  agg[c.foodId] = (g: a.g + compGrams(c), n: a.n + (seen.add(c.foodId) ? 1 : 0));
                  oilMl += oilMlOf(c.aceite);
                }
              }
            }
          }
          final keys = agg.keys.toList()..sort((a, b) => foods[a]!.n.compareTo(foods[b]!.n));
          if (oilMl > 0) keys.add('aceite');
          String qty(String id) {
            if (id == 'aceite') return '$oilMl ml';
            final f = foods[id]!, a = agg[id]!;
            if (f.u[0] == 'unidad') {
              final u = (a.g / f.gu! * 2).ceil() / 2;
              return nfmt(u) + (u == 1 ? ' unidad' : ' unidades');
            }
            final r = thou((a.g / 10).round() * 10);
            return f.u[0] == 'ml' ? '$r ml' : '$r g${f.cook != null ? ' crudo' : ''}';
          }

          final done = keys.where((k) => app.shopChecked.contains('$w$k')).length;
          return SubScreen(
            title: 'Lista de compras',
            subtitle: 'Semana del ${rangeOfWeek(w)}',
            child: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Text('${keys.length} productos · $done marcados', style: ts(13, c: slate)),
              const SizedBox(height: 8),
              _bar(keys.isEmpty ? 0 : done / keys.length, lime),
              const SizedBox(height: 12),
              for (final k in keys)
                Builder(builder: (_) {
                  final ck = app.shopChecked.contains('$w$k');
                  return GestureDetector(
                    onTap: () {
                      ck ? app.shopChecked.remove('$w$k') : app.shopChecked.add('$w$k');
                      app.notify();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: box(),
                      child: Row(children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(color: ck ? lime : white, border: Border.all(color: ck ? lime : slate, width: 1.5), borderRadius: BorderRadius.circular(7)),
                          child: ck ? const Icon(Icons.check, size: 16, color: navy) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(k == 'aceite' ? 'Aceite de oliva' : foods[k]!.n, style: ts(15, w: FontWeight.w600, c: ck ? slate : navy, strike: ck)),
                            Text(k == 'aceite' ? 'para cocinar' : 'en ${agg[k]!.n} ${agg[k]!.n == 1 ? 'plato' : 'platos'}', style: ts(12, c: slate)),
                          ]),
                        ),
                        Text(qty(k), style: ts(14, w: FontWeight.w600, c: ck ? slate : navy, strike: ck)),
                      ]),
                    ),
                  );
                }),
            ]),
          );
        },
      );
}
