import 'package:flutter/material.dart';
import '../core_data.dart';
import '../state.dart';
import '../ui.dart';

/// Resumen compacto de la valoración (para tarjetas y perfiles).
Widget ratingSummary(String coachId, {double size = 14}) {
  final r = app.ratingOf(coachId);
  final n = app.reviewsOf(coachId).length;
  if (r == null) return Text('Sin reseñas todavía', style: ts(12, c: slate));
  return Row(mainAxisSize: MainAxisSize.min, children: [
    Stars(r, size: size),
    const SizedBox(width: 6),
    Text('${r.toStringAsFixed(1)} · $n ${n == 1 ? 'reseña' : 'reseñas'}', style: ts(12, c: slate, w: FontWeight.w500)),
  ]);
}

class ResenaCard extends StatelessWidget {
  final Review r;
  const ResenaCard(this.r, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: box(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(r.autor, style: ts(14, w: FontWeight.w600))),
            Text(r.fecha, style: ts(11, c: slate)),
          ]),
          const SizedBox(height: 4),
          Stars(r.estrellas.toDouble(), size: 15),
          if (r.texto.isNotEmpty) ...[const SizedBox(height: 6), Text(r.texto, style: ts(14, h: 1.4))],
        ]),
      );
}

// ───────────────────────── Reseñas del entrenador ─────────────────────────
class ResenasScreen extends StatelessWidget {
  final String coachId;
  const ResenasScreen({super.key, required this.coachId});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: app,
        builder: (context, _) {
          final c = coachById(coachId);
          final list = app.reviewsOf(coachId);
          final mine = app.myReview(coachId);
          Widget? bottom;
          if (app.canReview(coachId)) {
            bottom = SizedBox(width: double.infinity, child: Btn(mine == null ? 'Escribir reseña' : 'Editar mi reseña', () => showSheet(context, (_) => _ResenaSheet(coachId: coachId)), bg: lime, fg: navy, icon: Icons.rate_review_outlined));
          } else if (app.me != null) {
            bottom = Text('Podrás dejar una reseña después de conversar con ${c.nombre.split(' ').first}.', style: ts(12, c: slate), textAlign: TextAlign.center);
          }
          return SubScreen(
            title: 'Reseñas',
            subtitle: c.nombre,
            bottom: bottom,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: box(bg: navy, bd: null),
                child: Row(children: [
                  Text(app.ratingOf(coachId)?.toStringAsFixed(1) ?? '—', style: ts(36, w: FontWeight.w700, c: white)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Stars(app.ratingOf(coachId) ?? 0, size: 20),
                      const SizedBox(height: 4),
                      Text('${list.length} ${list.length == 1 ? 'reseña' : 'reseñas'}', style: ts(13, c: soft)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: 16),
              if (list.isEmpty) Text('Aún no hay reseñas.', style: ts(14, c: slate)),
              for (final r in list) ResenaCard(r),
            ]),
          );
        },
      );
}

class _ResenaSheet extends StatefulWidget {
  final String coachId;
  const _ResenaSheet({required this.coachId});
  @override
  State<_ResenaSheet> createState() => _ResenaSheetState();
}

class _ResenaSheetState extends State<_ResenaSheet> {
  late int estrellas = app.myReview(widget.coachId)?.estrellas ?? 0;
  late final texto = TextEditingController(text: app.myReview(widget.coachId)?.texto ?? '');

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          sheetHandle(),
          Text('Tu reseña de ${coachById(widget.coachId).nombre}', style: ts(18, w: FontWeight.w600)),
          label('Valoración'),
          Row(children: [
            for (var i = 1; i <= 5; i++)
              GestureDetector(
                onTap: () => setState(() => estrellas = i),
                child: Padding(padding: const EdgeInsets.only(right: 6), child: Icon(i <= estrellas ? Icons.star : Icons.star_border, size: 36, color: const Color(0xFFF59E0B))),
              ),
          ]),
          label('Comentario (opcional)'),
          field(texto, '¿Cómo fue trabajar con este entrenador?', maxLen: 160),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: Btn('Publicar reseña', estrellas == 0
                ? null
                : () {
                    app.addReview(widget.coachId, estrellas, texto.text);
                    Navigator.pop(context);
                    toast(context, 'Reseña publicada');
                  }, bg: lime, fg: navy),
          ),
        ]),
      );
}
