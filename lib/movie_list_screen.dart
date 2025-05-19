import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

const String apiKey = '67284f919e5a50692425479d0363bcf4';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  List<Map<String, dynamic>> _apiMovies = [];
  String _error = '';
  bool _isApiLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPopularMovies();
  }

  Future<void> _fetchPopularMovies() async {
    setState(() {
      _isApiLoading = true;
      _error = '';
    });

    final Uri url = Uri.parse(
      'https://api.themoviedb.org/3/movie/popular?api_key=$apiKey&language=es-MX',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = List<Map<String, dynamic>>.from(data['results']);

        // Transforma cada película de la API a un formato uniforme
        final transformedMovies = results.map((apiMovie) {
          return {
            'title': apiMovie['title'] ?? 'Título no disponible',
            'year': (apiMovie['release_date'] ?? '').split('-').first,
            'director': 'Desconocido',
            'genre': 'No disponible',
            'synopsis': apiMovie['overview'] ?? 'Sin sinopsis',
            'imageUrl': apiMovie['poster_path'] != null
                ? 'https://image.tmdb.org/t/p/w92${apiMovie['poster_path']}'
                : '',
            'fromApi': true,
          };
        }).toList();

        setState(() {
          _apiMovies = transformedMovies;
          _isApiLoading = false;
        });
      } else {
        setState(() {
          _error = 'Error al cargar las películas: Código ${response.statusCode}';
          _isApiLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error de conexión: $e';
        _isApiLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Películas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/admin');
            },
          ),
        ],
      ),
      body: _isApiLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('movies').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final firestoreMovies = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          final combinedMovies = [...firestoreMovies, ..._apiMovies];

          return ListView.builder(
            itemCount: combinedMovies.length,
            itemBuilder: (context, index) {
              final movie = combinedMovies[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8.0),
                  leading: SizedBox(
                    width: 50,
                    height: 75,
                    child: movie['imageUrl'] != null && movie['imageUrl'] != ''
                        ? Image.network(
                      movie['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported);
                      },
                    )
                        : const Icon(Icons.image_not_supported),
                  ),
                  title: Text(movie['title']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Año: ${movie['year'] ?? 'N/A'}'),
                      Text('Director: ${movie['director'] ?? 'Desconocido'}'),
                      Text('Género: ${movie['genre'] ?? 'N/A'}'),
                      const SizedBox(height: 4),
                      Text(
                        movie['synopsis'] ?? 'Sin sinopsis',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/movie_detail',
                      arguments: movie,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
