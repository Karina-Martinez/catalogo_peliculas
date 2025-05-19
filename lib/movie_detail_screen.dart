import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = '67284f919e5a50692425479d0363bcf4';

class MovieDetailScreen extends StatefulWidget {
  final Map<String, dynamic> movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  String _director = 'No disponible';
  List<String> _genres = ['No disponible'];
  bool _isLoadingDetails = true;
  String _detailsError = '';

  @override
  void initState() {
    super.initState();

    final isFromApi = widget.movie.containsKey('id');

    if (isFromApi) {
      _fetchMovieDetails();
    } else {
      // Datos desde Firestore
      setState(() {
        _isLoadingDetails = false;
        _director = widget.movie['director'] ?? 'No disponible';
        _genres = [widget.movie['genre'] ?? 'No disponible'];
      });
    }
  }

  Future<void> _fetchMovieDetails() async {
    setState(() {
      _isLoadingDetails = true;
      _detailsError = '';
    });

    final int movieId = widget.movie['id'];
    final Uri detailsUrl = Uri.parse(
      'https://api.themoviedb.org/3/movie/$movieId?api_key=$apiKey&language=es-MX&append_to_response=credits',
    );

    try {
      final response = await http.get(detailsUrl);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> crew = data['credits']['crew'];
        final List<dynamic> genresData = data['genres'];

        final directorList = crew.where((person) => person['job'] == 'Director').toList();
        setState(() {
          _director = directorList.isNotEmpty ? directorList.first['name'] : 'No disponible';
          _genres = genresData.map<String>((genre) => genre['name'] as String).toList();
          _isLoadingDetails = false;
        });
      } else {
        setState(() {
          _detailsError = 'Error al cargar los detalles: Código ${response.statusCode}';
          _isLoadingDetails = false;
        });
      }
    } catch (e) {
      setState(() {
        _detailsError = 'Error de conexión: $e';
        _isLoadingDetails = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isFromApi = widget.movie.containsKey('id');
    final String? imageUrl = isFromApi
        ? (widget.movie['poster_path'] != null
        ? 'https://image.tmdb.org/t/p/w500${widget.movie['poster_path']}'
        : null)
        : widget.movie['imageUrl'];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie['title'] ?? 'Detalles de la Película'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen de la película
            if (imageUrl != null && imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Icon(Icons.image_not_supported, size: 60),
                  );
                },
              )
            else
              const SizedBox(
                height: 300,
                width: double.infinity,
                child: Icon(Icons.image_not_supported, size: 60),
              ),
            const SizedBox(height: 20),

            // Título
            Text(
              widget.movie['title'] ?? 'Título no disponible',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Año
            Text(
              'Año: ${widget.movie['release_date']?.substring(0, 4) ?? widget.movie['year'] ?? 'No disponible'}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Director y género(s)
            _isLoadingDetails
                ? const CircularProgressIndicator()
                : _detailsError.isNotEmpty
                ? Text(_detailsError, style: const TextStyle(color: Colors.red))
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎬 Director: $_director',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  '📚 Género(s): ${_genres.join(', ')}',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Sinopsis
            const Text(
              'Sinopsis:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.movie['overview'] ?? widget.movie['synopsis'] ?? 'Sinopsis no disponible',
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 20),

            // Calificación
            if (isFromApi)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calificación:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${widget.movie['vote_average']?.toStringAsFixed(1) ?? 'N/A'} / 10',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}