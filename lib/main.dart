import 'package:flutter/material.dart';

void main() {
  runApp(const MovieCatalogApp());
}

class MovieCatalogApp extends StatelessWidget {
  const MovieCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catálogo de Películas',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Imagen de fondo
          Image.network(
            'https://img.freepik.com/free-photo/gradient-iphone-wallpaper-oil-bubble-water-background_53876-176849.jpg?semt=ais_hybrid&w=740',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Contenido superpuesto
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  '¡Bienvenido al Catálogo de Películas!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Catálogo de Películas',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    // Navegar a la lista de películas
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MovieListScreen()),
                    );
                  },
                  child: const Text('Explorar Películas'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Películas'),
      ),
      body: const Center(
        child: Text('Aquí irá la lista de películas'),
      ),
    );
  }
}