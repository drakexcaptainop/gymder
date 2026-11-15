import 'dart:math' as math;

// ───────────────────────── Coaches & packages ─────────────────────────
class Coach {
  final String id, nombre, ini, especialidad, modalidad, lugar, lugarCorto, resumen, bio, enfoque;
  final int exp;
  final List<String> tags, certs;
  const Coach(this.id, this.nombre, this.ini, this.especialidad, this.modalidad, this.exp, this.lugar,
      this.lugarCorto, this.resumen, this.bio, this.tags, this.enfoque, this.certs);
}

const coaches = <Coach>[
  Coach('c1', 'Valeria Ríos', 'VR', 'Fuerza', 'Presencial', 8, 'Gimnasio Central · Sala de fuerza', 'Gimnasio Central',
      'Fuerza con técnica limpia y progresión medible.',
      'Acompaño a personas que empiezan o vuelven a entrenar a ganar fuerza con técnica limpia, progresión medible y sesiones que se adaptan a su semana.',
      ['Fuerza', 'Técnica', 'Principiantes'], 'Sesiones de 60 minutos: calentamiento, bloque principal de fuerza y movilidad final.',
      ['Certificación en entrenamiento de fuerza', 'Primeros auxilios deportivos']),
  Coach('c2', 'Mateo Salas', 'MS', 'Hipertrofia', 'Presencial', 6, 'Gimnasio Norte · Zona de pesas', 'Gimnasio Norte',
      'Planes de volumen muscular con revisión semanal.',
      'Diseño bloques de hipertrofia con cargas y volumen controlados. Revisamos cada semana cómo responde tu cuerpo para ajustar el plan.',
      ['Hipertrofia', 'Pesas', 'Técnica'], 'Bloques de 4 semanas con revisión semanal de cargas y técnica.',
      ['Especialización en hipertrofia', 'Nutrición aplicada al entrenamiento']),
  Coach('c3', 'Lucía Andrade', 'LA', 'Movilidad', 'Online', 10, 'Sesiones guiadas online', 'Online',
      'Movilidad, postura y control corporal.',
      'Trabajo movilidad, postura y control del core para que entrenes y te muevas sin molestias. Ideal si pasas muchas horas sentado.',
      ['Movilidad', 'Postura', 'Core'], 'Sesiones de 45 minutos con progresiones suaves y pausas guiadas.',
      ['Instructora de pilates', 'Movilidad articular']),
  Coach('c4', 'Daniel Okafor', 'DO', 'Funcional', 'Presencial', 7, 'Gimnasio Central · Zona funcional', 'Gimnasio Central',
      'Entrenamiento funcional y acondicionamiento.',
      'Combino fuerza, resistencia y coordinación en circuitos funcionales para que ganes energía en tu día a día.',
      ['Funcional', 'Circuitos', 'Resistencia'], 'Circuitos de intensidad progresiva con descansos programados.',
      ['Entrenamiento funcional', 'Preparación física general']),
  Coach('c5', 'Sofía Méndez', 'SM', 'Running', 'Online', 5, 'Plan online y pista local', 'Online',
      'Planes de carrera desde 5K hasta media maratón.',
      'Preparo planes de carrera por objetivos, con fuerza complementaria para cuidar tus articulaciones y mejorar tu ritmo.',
      ['Running', 'Resistencia', 'Fuerza complementaria'], 'Plan semanal con rodajes, series y una sesión de fuerza.',
      ['Entrenadora de atletismo', 'Fuerza para corredores']),
  Coach('c6', 'Andrés Lima', 'AL', 'Hipertrofia', 'Online', 4, 'Plan online con revisión de técnica', 'Online',
      'Ganancia muscular con rutinas claras.',
      'Rutinas de hipertrofia sencillas de seguir, con progresiones semanales y revisión de técnica por video.',
      ['Hipertrofia', 'Rutinas en casa', 'Progresión'], 'Cuatro sesiones por semana con progresión de cargas.',
      ['Entrenamiento de fuerza e hipertrofia']),
];
Coach coachById(String id) => coaches.firstWhere((c) => c.id == id);
const especialidades = ['Fuerza', 'Hipertrofia', 'Movilidad', 'Funcional', 'Running'];

class Pkg {
  String id, coachId, nombre;
  int precio, sesiones, dias;
  bool activo;
  Pkg(this.id, this.coachId, this.nombre, this.precio, this.sesiones, this.dias, [this.activo = true]);
  Pkg copy() => Pkg(id, coachId, nombre, precio, sesiones, dias, activo);
}

List<Pkg> initialPkgs() => [
      Pkg('p1a', 'c1', 'Esencial', 120, 8, 30),
      Pkg('p1b', 'c1', 'Progreso', 210, 16, 45),
      Pkg('p1c', 'c1', 'Intensivo', 290, 24, 60),
      Pkg('p1d', 'c1', 'Prueba', 40, 2, 7, false),
      Pkg('p2a', 'c2', 'Base', 110, 8, 30),
      Pkg('p2b', 'c2', 'Volumen', 250, 20, 60),
      Pkg('p3a', 'c3', 'Movilidad', 90, 8, 30),
      Pkg('p3b', 'c3', 'Postura', 160, 16, 60),
      Pkg('p4a', 'c4', 'Funcional', 100, 8, 30),
      Pkg('p4b', 'c4', 'Total', 230, 20, 60),
      Pkg('p5a', 'c5', '5K', 80, 8, 45),
      Pkg('p5b', 'c5', 'Media maratón', 200, 20, 90),
      Pkg('p6a', 'c6', 'Inicio', 95, 8, 30),
      Pkg('p6b', 'c6', 'Avanzado', 220, 18, 60),
    ];

String price(Object p) => '¤ $p';

// ───────────────────────── Foods & dishes ─────────────────────────
class Food {
  final String id, n, gn;
  final double k, p, c, g;
  final double? cook, gu, gt;
  final List<String> u;
  final String? dp, de;
  final double dq;
  final bool np;
  const Food(this.id, this.n, this.gn, this.k, this.p, this.c, this.g, this.u, this.dq,
      {this.cook, this.gu, this.gt, this.dp, this.de, this.np = false});
}

const foods = <String, Food>{
  'pollo': Food('pollo', 'Pechuga de pollo', 'f', 120, 23, 0, 2.6, ['g', 'unidad'], 150, cook: 0.75, gu: 180, dp: 'plancha'),
  'arroz': Food('arroz', 'Arroz blanco', 'm', 360, 7, 79, 0.6, ['g', 'taza'], 100, cook: 2.5, gt: 160, dp: 'hervido', de: 'cocido'),
  'arrozi': Food('arrozi', 'Arroz integral', 'm', 370, 8, 77, 2.9, ['g', 'taza'], 100, cook: 2.4, gt: 160, dp: 'hervido', de: 'cocido'),
  'avena': Food('avena', 'Avena en hojuelas', 'f', 389, 17, 66, 7, ['g', 'taza'], 50, gt: 80, dp: 'hervido'),
  'frutos': Food('frutos', 'Frutos rojos', 'mp', 50, 1, 12, 0.3, ['g', 'taza'], 80, gt: 140, np: true),
  'leche': Food('leche', 'Leche semidescremada', 'f', 46, 3.3, 4.8, 1.6, ['ml', 'taza'], 200, gt: 240, np: true),
  'miel': Food('miel', 'Miel', 'f', 304, 0, 82, 0, ['g'], 10, np: true),
  'huevo': Food('huevo', 'Huevo', 'm', 143, 12.6, 0.7, 9.5, ['unidad', 'g'], 2, gu: 50, dp: 'hervido'),
  'pan': Food('pan', 'Pan integral', 'm', 250, 13, 41, 4, ['unidad', 'g'], 2, gu: 30, np: true),
  'espinaca': Food('espinaca', 'Espinaca', 'f', 23, 2.9, 3.6, 0.4, ['g', 'taza'], 60, gt: 30, dp: 'vapor'),
  'brocoli': Food('brocoli', 'Brócoli', 'm', 34, 2.8, 7, 0.4, ['g', 'taza'], 100, gt: 90, dp: 'vapor'),
  'salmon': Food('salmon', 'Salmón', 'm', 208, 20, 0, 13, ['g'], 140, cook: 0.8, dp: 'horno'),
  'quinoa': Food('quinoa', 'Quinoa', 'f', 368, 14, 64, 6, ['g', 'taza'], 120, cook: 2.7, gt: 185, dp: 'hervido', de: 'cocido'),
  'esparragos': Food('esparragos', 'Espárragos', 'mp', 20, 2.2, 3.9, 0.1, ['g'], 100, dp: 'plancha'),
  'garbanzos': Food('garbanzos', 'Garbanzos', 'mp', 364, 19, 61, 6, ['g', 'taza'], 150, cook: 2.4, gt: 165, dp: 'hervido', de: 'cocido'),
  'tomate': Food('tomate', 'Tomate', 'm', 18, 0.9, 3.9, 0.2, ['unidad', 'g'], 1, gu: 120, dp: 'crudo'),
  'pepino': Food('pepino', 'Pepino', 'm', 15, 0.7, 3.6, 0.1, ['unidad', 'g'], 0.5, gu: 200, dp: 'crudo'),
  'cebolla': Food('cebolla', 'Cebolla morada', 'f', 40, 1.1, 9.3, 0.1, ['g', 'unidad'], 30, gu: 110, dp: 'crudo'),
  'aguacate': Food('aguacate', 'Aguacate', 'm', 160, 2, 9, 15, ['unidad', 'g'], 0.5, gu: 140, np: true),
  'yogur': Food('yogur', 'Yogur griego natural', 'm', 97, 9, 4, 5, ['g', 'taza'], 170, gt: 245, np: true),
  'granola': Food('granola', 'Granola', 'f', 471, 10, 64, 20, ['g', 'taza'], 40, gt: 110, np: true),
  'platano': Food('platano', 'Plátano', 'm', 89, 1.1, 23, 0.3, ['unidad', 'g'], 1, gu: 120, np: true),
  'pavo': Food('pavo', 'Pavo molido', 'm', 150, 20, 0, 8, ['g'], 120, cook: 0.75, dp: 'plancha'),
  'tortilla': Food('tortilla', 'Tortillas de maíz', 'fp', 218, 5.7, 45, 2.9, ['unidad', 'g'], 3, gu: 30, np: true),
  'lechuga': Food('lechuga', 'Lechuga', 'f', 15, 1.4, 2.9, 0.2, ['g', 'taza'], 40, gt: 50, np: true),
  'pasta': Food('pasta', 'Pasta integral', 'f', 348, 13, 72, 2.5, ['g', 'taza'], 180, cook: 2.3, gt: 140, dp: 'hervido', de: 'cocido'),
  'atun': Food('atun', 'Atún en agua', 'm', 116, 26, 0, 1, ['unidad', 'g'], 1, gu: 120, np: true),
  'proteina': Food('proteina', 'Proteína en polvo', 'f', 380, 80, 8, 5, ['unidad', 'g'], 1, gu: 30, np: true),
  'pimiento': Food('pimiento', 'Pimiento', 'm', 31, 1, 6, 0.3, ['g', 'unidad'], 60, gu: 150, dp: 'plancha'),
  'champi': Food('champi', 'Champiñones', 'mp', 22, 3.1, 3.3, 0.3, ['g'], 60, dp: 'plancha'),
  'papa': Food('papa', 'Papa', 'f', 77, 2, 17, 0.1, ['g', 'unidad'], 150, gu: 170, dp: 'horno'),
};

/// id, label, adjective stem
const preps = <List<String>>[
  ['plancha', 'A la plancha', 'a la plancha'],
  ['horno', 'Al horno', 'al horno'],
  ['hervido', 'Hervido', 'hervid'],
  ['vapor', 'Al vapor', 'al vapor'],
  ['frito', 'Frito', 'frit'],
  ['crudo', 'Crudo', 'crud'],
];
const oilPreps = ['plancha', 'horno', 'frito'];
const oils = <List<Object>>[
  ['ninguno', 'Ninguno', 0],
  ['1 cdta', '1 cdta', 5],
  ['1 cda', '1 cda', 15],
];
int oilMlOf(String id) => oils.firstWhere((o) => o[0] == id, orElse: () => oils[0])[2] as int;
const unitStep = {'g': 10.0, 'ml': 50.0, 'unidad': 0.5, 'taza': 0.5};

String nfmt(num v) {
  final r = (v * 10).round() / 10;
  return r == r.roundToDouble() ? r.round().toString() : r.toString().replaceAll('.', ',');
}

String thou(num v) {
  final s = v.round().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return b.toString();
}

String norm(String t) {
  const from = 'áàäâéèëêíìïîóòöôúùüûñ';
  const to = 'aaaaeeeeiiiioooouuuun';
  var s = t.toLowerCase();
  for (var i = 0; i < from.length; i++) {
    s = s.replaceAll(from[i], to[i]);
  }
  return s;
}

int _cuid = 1;

class Comp {
  String uid, foodId, unit, estado, aceite;
  String? prep;
  double qty;
  Comp(this.uid, this.foodId, this.prep, this.qty, this.unit, this.estado, this.aceite);
  Comp copy() => Comp('k${_cuid++}', foodId, prep, qty, unit, estado, aceite);
  Comp with_({String? prep, double? qty, String? unit, String? estado, String? aceite}) =>
      Comp(uid, foodId, prep ?? this.prep, qty ?? this.qty, unit ?? this.unit, estado ?? this.estado, aceite ?? this.aceite);
}

Comp mkComp(String foodId,
    {String? prep, double? qty, String? unit, String? estado, String? aceite}) {
  final f = foods[foodId]!;
  final p = f.np ? null : (prep ?? f.dp ?? 'crudo');
  return Comp('k${_cuid++}', foodId, p, qty ?? f.dq, unit ?? f.u[0], estado ?? f.de ?? 'crudo',
      aceite ?? (p != null && oilPreps.contains(p) ? '1 cdta' : 'ninguno'));
}

class Dish {
  String nombre, servido;
  List<Comp> comps;
  Dish(this.nombre, this.servido, this.comps);
  Dish clone() => Dish(nombre, servido, comps.map((c) => c.copy()).toList());
}

class Macro {
  int k, p, c, g;
  Macro(this.k, this.p, this.c, this.g);
}

String prepTxt(Food f, String? prep) {
  final p = preps.where((x) => x[0] == prep);
  if (p.isEmpty) return '';
  if (prep == 'hervido' || prep == 'frito' || prep == 'crudo') {
    return p.first[2] + {'m': 'o', 'f': 'a', 'mp': 'os', 'fp': 'as'}[f.gn]!;
  }
  return p.first[2];
}

String qtyTxt(Comp c) {
  final q = nfmt(c.qty);
  if (c.unit == 'unidad') return q + (c.qty == 1 ? ' unidad' : ' unidades');
  if (c.unit == 'taza') return q + (c.qty == 1 ? ' taza' : ' tazas');
  return '$q ${c.unit}';
}

double compGrams(Comp c) {
  final f = foods[c.foodId]!;
  final g = c.unit == 'unidad' ? c.qty * (f.gu ?? 100) : c.unit == 'taza' ? c.qty * (f.gt ?? 200) : c.qty;
  return f.cook != null && c.estado == 'cocido' ? g / f.cook! : g;
}

Macro compCalc(Comp c) {
  final f = foods[c.foodId]!;
  final raw = compGrams(c);
  final r = raw / 100;
  var k = f.k * r, p = f.p * r, cb = f.c * r, g = f.g * r;
  if (c.prep == 'frito' && !f.np) {
    g += raw * 0.08;
    k += raw * 0.72;
  }
  final o = oilMlOf(c.aceite);
  if (o > 0) {
    g += o * 0.9;
    k += o * 8;
  }
  return Macro(k.round(), p.round(), cb.round(), g.round());
}

String compTxt(Comp c) {
  final f = foods[c.foodId]!;
  return '${f.n}${f.np ? '' : ' ${prepTxt(f, c.prep)}'}, ${qtyTxt(c)}${f.cook != null ? ' (${c.estado})' : ''}';
}

Macro dishCalc(Dish d) {
  final t = Macro(0, 0, 0, 0);
  for (final c in d.comps) {
    final r = compCalc(c);
    t.k += r.k;
    t.p += r.p;
    t.c += r.c;
    t.g += r.g;
  }
  return t;
}

String dishTxt(Dish d) =>
    d.comps.map(compTxt).join(' + ') + (d.comps.length > 1 ? (d.servido == 'mezclado' ? ', mezclado' : ', por separado') : '');

class DishT {
  final String id, nombre, servido;
  final List<(String, Map<String, Object>)> comps;
  const DishT(this.id, this.nombre, this.servido, this.comps);
  Dish make() => Dish(
      nombre,
      servido,
      comps
          .map((e) => mkComp(e.$1,
              prep: e.$2['prep'] as String?,
              qty: (e.$2['qty'] as num?)?.toDouble(),
              estado: e.$2['estado'] as String?,
              aceite: e.$2['aceite'] as String?))
          .toList());
}

const dishTemplates = <DishT>[
  DishT('m1', 'Avena con frutos rojos', 'mezclado', [('avena', {'prep': 'hervido', 'qty': 50, 'aceite': 'ninguno'}), ('leche', {'qty': 200}), ('frutos', {'qty': 80}), ('miel', {'qty': 10})]),
  DishT('m2', 'Huevos con pan integral', 'separado', [('huevo', {'prep': 'frito', 'qty': 2, 'aceite': '1 cdta'}), ('pan', {'qty': 2}), ('espinaca', {'prep': 'vapor', 'qty': 40})]),
  DishT('m3', 'Pollo con arroz y brócoli', 'separado', [('pollo', {'prep': 'plancha', 'qty': 150, 'estado': 'crudo', 'aceite': '1 cdta'}), ('arroz', {'prep': 'hervido', 'qty': 100, 'estado': 'cocido'}), ('brocoli', {'prep': 'vapor', 'qty': 100})]),
  DishT('m4', 'Salmón con quinoa', 'separado', [('salmon', {'prep': 'horno', 'qty': 140, 'aceite': '1 cdta'}), ('quinoa', {'prep': 'hervido', 'qty': 120, 'estado': 'cocido'}), ('esparragos', {'prep': 'plancha', 'qty': 100, 'aceite': '1 cdta'})]),
  DishT('m5', 'Ensalada de garbanzos', 'mezclado', [('garbanzos', {'prep': 'hervido', 'qty': 150, 'estado': 'cocido'}), ('tomate', {'qty': 1}), ('pepino', {'qty': 0.5}), ('cebolla', {'qty': 30})]),
  DishT('m6', 'Yogur griego con granola', 'mezclado', [('yogur', {'qty': 170}), ('granola', {'qty': 40}), ('platano', {'qty': 1})]),
  DishT('m7', 'Tacos de pavo', 'mezclado', [('pavo', {'prep': 'plancha', 'qty': 120, 'aceite': '1 cdta'}), ('tortilla', {'qty': 3}), ('aguacate', {'qty': 0.5}), ('lechuga', {'qty': 40})]),
  DishT('m8', 'Pasta integral con atún', 'mezclado', [('pasta', {'prep': 'hervido', 'qty': 180, 'estado': 'cocido'}), ('atun', {'qty': 1}), ('tomate', {'qty': 1})]),
  DishT('m9', 'Batido de proteína', 'mezclado', [('proteina', {'qty': 1}), ('leche', {'qty': 250}), ('platano', {'qty': 1})]),
  DishT('m10', 'Tortilla de verduras', 'mezclado', [('huevo', {'prep': 'plancha', 'qty': 3, 'aceite': '1 cdta'}), ('pimiento', {'prep': 'plancha', 'qty': 60, 'aceite': 'ninguno'}), ('champi', {'prep': 'plancha', 'qty': 60, 'aceite': 'ninguno'}), ('cebolla', {'prep': 'plancha', 'qty': 30, 'aceite': 'ninguno'})]),
];
DishT dishT(String id) => dishTemplates.firstWhere((t) => t.id == id);

const mealPools = [
  ['m1', 'm2', 'm6', 'm10'],
  ['m3', 'm5', 'm7', 'm8'],
  ['m4', 'm7', 'm10', 'm5'],
  ['m6', 'm9'],
];
const slotNames = ['Desayuno', 'Almuerzo', 'Cena', 'Snack'];

class PlanItem {
  final String uid;
  final Dish dish;
  PlanItem(this.uid, this.dish);
}

int _uid = 1;
String newUid() => 'u${_uid++}';

/// plan[week][day][slot] -> list of items
Map<int, List<List<List<PlanItem>>>> genPlan() {
  final plan = <int, List<List<List<PlanItem>>>>{};
  for (final w in [-1, 0, 1]) {
    plan[w] = [];
    for (var d = 0; d < 7; d++) {
      final day = <List<PlanItem>>[];
      for (var s = 0; s < 4; s++) {
        final empty = ((d + s + w + 10) % 5 == 4) || (s == 3 && (d + w + 10) % 2 == 1);
        final pool = mealPools[s];
        day.add(empty ? [] : [PlanItem(newUid(), dishT(pool[(d + w * 3 + 9 + s) % pool.length]).make())]);
      }
      plan[w]!.add(day);
    }
  }
  plan[0]![3][1] = [PlanItem(newUid(), dishT('m3').make())];
  return plan;
}

// ───────────────────────── Exercises ─────────────────────────
class EqInfo {
  final String name;
  final int icon; // index into icon map (see ui)
  const EqInfo(this.name, this.icon);
}

const eqNames = {
  'barra': 'Barra',
  'mancuernas': 'Mancuernas',
  'kettlebell': 'Kettlebell',
  'corporal': 'Sin equipo',
  'smith': 'Máquina Smith',
  'maquina': 'Máquina',
  'polea': 'Polea',
  'banda': 'Banda elástica',
  'libre': 'Equipo por definir',
};

class ExVar {
  final String id, eq, nombre;
  const ExVar(this.id, this.eq, this.nombre);
}

class Ex {
  final String id, nombre, grupo;
  final bool video, d3, custom;
  final List<ExVar> vars;
  Ex(this.id, this.nombre, this.grupo, this.video, this.d3, List<List<String>> v, {this.custom = false})
      : vars = v.map((x) => ExVar('$id-${x[0]}', x[0], x[1])).toList();
}

final exercises = <Ex>[
  Ex('e0', 'Sentadilla', 'Piernas', true, true, [['barra', 'Sentadilla con barra'], ['mancuernas', 'Sentadilla con mancuernas'], ['kettlebell', 'Sentadilla goblet con kettlebell'], ['corporal', 'Sentadilla sin equipo (peso corporal)'], ['smith', 'Sentadilla en máquina Smith']]),
  Ex('e1', 'Sentadilla goblet', 'Piernas', true, true, [['kettlebell', 'Sentadilla goblet con kettlebell'], ['mancuernas', 'Sentadilla goblet con mancuerna']]),
  Ex('eb', 'Sentadilla búlgara', 'Piernas', true, false, [['mancuernas', 'Sentadilla búlgara con mancuernas'], ['corporal', 'Sentadilla búlgara sin equipo'], ['barra', 'Sentadilla búlgara con barra']]),
  Ex('ep', 'Press de pecho', 'Pecho', true, true, [['barra', 'Press de pecho con barra'], ['mancuernas', 'Press de pecho con mancuernas'], ['maquina', 'Press de pecho en máquina'], ['corporal', 'Flexiones sin equipo']]),
  Ex('e2', 'Press de banca', 'Pecho', true, true, [['barra', 'Press de banca con barra'], ['mancuernas', 'Press de banca con mancuernas']]),
  Ex('er', 'Remo', 'Espalda', true, true, [['barra', 'Remo con barra'], ['mancuernas', 'Remo con mancuernas'], ['polea', 'Remo en polea'], ['banda', 'Remo con banda elástica']]),
  Ex('e3', 'Remo con mancuerna', 'Espalda', true, false, [['mancuernas', 'Remo con mancuerna a una mano'], ['banda', 'Remo a una mano con banda elástica']]),
  Ex('e4', 'Peso muerto rumano', 'Piernas', true, true, [['barra', 'Peso muerto rumano con barra'], ['mancuernas', 'Peso muerto rumano con mancuernas'], ['kettlebell', 'Peso muerto rumano con kettlebell']]),
  Ex('e5', 'Press militar', 'Hombros', true, false, [['barra', 'Press militar con barra'], ['mancuernas', 'Press militar con mancuernas'], ['maquina', 'Press militar en máquina']]),
  Ex('e6', 'Curl de bíceps', 'Brazos', true, true, [['mancuernas', 'Curl de bíceps con mancuernas'], ['barra', 'Curl de bíceps con barra'], ['banda', 'Curl de bíceps con banda elástica']]),
  Ex('e7', 'Plancha', 'Core', false, true, [['corporal', 'Plancha frontal']]),
  Ex('e8', 'Dominadas asistidas', 'Espalda', true, false, [['maquina', 'Dominadas en máquina asistida'], ['banda', 'Dominadas con banda elástica']]),
];
const muscles = ['Todos', 'Piernas', 'Pecho', 'Espalda', 'Hombros', 'Brazos', 'Core'];
const fmts = [['video', 'Video'], ['3d', '3D'], ['ambos', 'Ambos']];
const exSteps = [
  'Colócate en la posición inicial con la espalda neutra y el abdomen activo.',
  'Realiza el movimiento de forma controlada durante todo el recorrido.',
  'Vuelve a la posición inicial sin perder la postura y respira de forma constante.',
];

class ExCfg {
  String exId, fmt, principal;
  List<String> alts;
  int series, reps, descanso;
  String? unit;
  ExCfg(this.exId, this.fmt, this.principal, this.alts, this.series, this.reps, this.descanso, {this.unit});
}

ExCfg cfg0() => ExCfg('e0', 'ambos', 'e0-barra', ['e0-mancuernas', 'e0-kettlebell', 'e0-corporal'], 4, 8, 90);
List<ExCfg> routine() => [
      cfg0(),
      ExCfg('e4', 'video', 'e4-barra', ['e4-mancuernas'], 3, 10, 90),
      ExCfg('e7', '3d', 'e7-corporal', [], 3, 40, 45, unit: 's'),
    ];

// ───────────────────────── Calendar ─────────────────────────
const monthNames = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];
const monthShort = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
const dayLong = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
const dayShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
const dayInitials = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
final today = DateTime(2026, 11, 5);
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
DateTime mondayOf(int w) => DateTime(2026, 11, 2 + 7 * w);
DateTime addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
int weekdayIdx(DateTime d) => (d.weekday + 6) % 7; // Monday=0
String cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
String fmtDate(DateTime d) => '${d.day} ${monthShort[d.month - 1]} ${d.year}';
String rangeOfWeek(int w) {
  final a = mondayOf(w), b = addDays(a, 6);
  return '${a.day} ${monthShort[a.month - 1]} – ${b.day} ${monthShort[b.month - 1]}';
}

enum EvTipo { ejercicio, comida, sesion }

const tipoLabel = {EvTipo.ejercicio: 'Ejercicio', EvTipo.comida: 'Comida', EvTipo.sesion: 'Sesión con coach'};

class Ev {
  final String id, titulo, hora, detalle;
  final EvTipo tipo;
  final ExCfg? cfg;
  Ev(this.id, this.tipo, this.titulo, this.hora, this.detalle, {this.cfg});
}

List<Ev> baseEvents(DateTime d, bool paid, Coach? coach) {
  final w = weekdayIdx(d);
  final k = '${d.year}-${d.month}-${d.day}';
  final out = <Ev>[];
  if (w == 0 || w == 2 || w == 4) {
    out.add(Ev('ex$k', EvTipo.ejercicio, ['Fuerza · tren inferior', 'Fuerza · tren superior', 'Full body'][w ~/ 2], '07:30', 'Rutina de 45 min'));
  }
  if (w == 6 && d.day % 2 == 0) out.add(Ev('ex2$k', EvTipo.ejercicio, 'Cardio suave', '10:00', '30 min al aire libre'));
  if (w == 1 || w == 3) out.add(Ev('co$k', EvTipo.comida, 'Almuerzo planificado', '13:30', 'Bowl de pollo y arroz'));
  if (w == 6) out.add(Ev('co2$k', EvTipo.comida, 'Meal prep semanal', '11:00', 'Preparar las comidas de la semana'));
  if (paid && coach != null && (w == 1 || w == 3)) {
    out.add(Ev('se$k', EvTipo.sesion, 'Sesión con ${coach.nombre}', '18:00', coach.lugarCorto));
  }
  return out;
}

const horas = ['07:00', '09:00', '13:00', '18:00', '20:00'];

// ───────────────────────── Misc ─────────────────────────
class Msg {
  final bool user;
  final String text, time;
  Msg(this.user, this.text, this.time);
}

List<Msg> initialMsgs() => [
      Msg(false, '¡Hola! Ya tengo tu paquete. El lunes empezamos con fuerza de tren inferior.', '09:12'),
      Msg(true, 'Perfecto. ¿Necesito llevar algo en especial?', '09:20'),
      Msg(false, 'Ropa cómoda, agua y una toalla. Llega 10 minutos antes para calentar.', '09:24'),
    ];

const coachNotes = [
  ('4 nov', 'Buena técnica en la sentadilla. La próxima semana subimos 2 kg en el bloque principal.'),
  ('2 nov', 'Prioriza dormir entre 7 y 8 horas los días de fuerza.'),
  ('30 oct', 'Agrega 10 minutos de movilidad de cadera antes de cada sesión.'),
];

double clampD(double v, double a, double b) => math.max(a, math.min(b, v));
