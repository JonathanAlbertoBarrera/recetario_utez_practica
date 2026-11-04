import 'package:flutter/material.dart';

import '../dominio/receta.dart';

class TarjetaReceta extends StatelessWidget {
  const TarjetaReceta({super.key, required this.receta});

  final Receta receta;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(receta.nombre, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('${receta.cocina} · ${receta.dificultad.etiqueta}'),
            const SizedBox(height: 8),
            Text('Tiempo: ${receta.tiempoTotal} min · Porciones: ${receta.porciones}'),
            Text('Calificación: ${receta.calificacion.toStringAsFixed(1)}'),
            if (receta.esRapida) const Chip(label: Text('Rápida')),
          ],
        ),
      ),
    );
  }
}
