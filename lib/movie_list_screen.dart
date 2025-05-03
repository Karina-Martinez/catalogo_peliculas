import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String apiKey = '67284f919e5a50692425479d0363bcf4';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<dynamic> _movies = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchPopularMovies();
  }

  Future<void> _fetchPopularMovies() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final Uri url = Uri.parse(
        'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=es-MX');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _movies = data['results'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
          'Error al cargar las películas: Código de estado ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas Populares'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : ListView.builder(
        itemCount: _movies.length,
        itemBuilder: (context, index) {
          final movie = _movies[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: SizedBox(
                width: 50,
                height: 75,
                child: movie['poster_path'] != null
                    ? Image.network(
                  'https://image.tmdb.org/t/p/w92${movie['poster_path']}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image_not_supported);
                  },
                )
                    : const Icon(Icons.image_not_supported),
              ),
              title: Text(movie['title']),
              subtitle: Text(
                  'Calificación: ${movie['vote_average'].toStringAsFixed(1)}'),
              onTap: () {
                print('Película seleccionada: ${movie['title']}');
              },
            ),
          );
        },
      ),
    );
  }
}