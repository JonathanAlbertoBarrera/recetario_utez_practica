import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _busqueda = TextEditingController();

  @override
  void dispose() {
    _busqueda.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListenableBuilder(
            listenable: widget.vm,
            builder: (context, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('busqueda'),
                  controller: _busqueda,
                  decoration: const InputDecoration(
                    labelText: 'Buscar una receta',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (texto) => widget.vm.buscar(texto),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('buscar'),
                  onPressed: widget.vm.cargando
                      ? null
                      : () => widget.vm.buscar(_busqueda.text),
                  child: const Text('Buscar recetas'),
                ),
                const SizedBox(height: 16),
                Expanded(child: _contenido()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contenido() => switch (widget.vm.estado) {
    RecetasInicial() => const Center(
      child: Text(
        'Escribe una receta o déjalo vacío y toca Buscar recetas.',
        textAlign: TextAlign.center,
      ),
    ),
    RecetasCargando() => const Center(child: CircularProgressIndicator()),
    RecetasVacias(:final busqueda) => Center(
      child: Text(
        busqueda.isEmpty
            ? 'No hay recetas disponibles.'
            : 'No encontramos recetas para "$busqueda".',
        textAlign: TextAlign.center,
      ),
    ),
    RecetasFallidas(:final mensaje) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(mensaje, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => widget.vm.reintentar(),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    ),
    RecetasListas(:final recetas, :final total) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mostrando ${recetas.length} de $total recetas · Rápidas: ${widget.vm.rapidas}',
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            itemCount: recetas.length,
            itemBuilder: (context, indice) => TarjetaReceta(receta: recetas[indice]),
          ),
        ),
      ],
    ),
  };
}
