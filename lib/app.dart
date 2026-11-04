import 'package:flutter/material.dart';

import 'datos/recetas_repositorio.dart';
import 'presentacion/recetas_pagina.dart';
import 'presentacion/recetas_view_model.dart';

class AppRecetario extends StatefulWidget {
  const AppRecetario({super.key, required this.repositorio});

  final RecetasRepositorio repositorio;

  @override
  State<AppRecetario> createState() => _AppRecetarioState();
}

class _AppRecetarioState extends State<AppRecetario> {
  late final RecetasViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RecetasViewModel(widget.repositorio);
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetario UTEZ',
      debugShowCheckedModeBanner: false,
      home: RecetasPagina(vm: _vm),
    );
  }
}
