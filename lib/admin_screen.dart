import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _yearController = TextEditingController();
  final _directorController = TextEditingController();
  final _genreController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _imageController = TextEditingController();

  Future<void> _addMovie() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('movies').add({
          'title': _titleController.text.trim(),
          'year': _yearController.text.trim(),
          'director': _directorController.text.trim(),
          'genre': _genreController.text.trim(),
          'synopsis': _synopsisController.text.trim(),
          'imageUrl': _imageController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Película agregada con éxito')),
        );
        _clearForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar la película: $e')),
        );
      }
    }
  }

  void _clearForm() {
    _titleController.clear();
    _yearController.clear();
    _directorController.clear();
    _genreController.clear();
    _synopsisController.clear();
    _imageController.clear();
  }

  Future<void> _deleteMovie(String movieId) async {
    try {
      await FirebaseFirestore.instance.collection('movies').doc(movieId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Película eliminada con éxito')),
      );
      setState(() {}); // Activar un rebuild para actualizar la lista
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar la película: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Películas'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Agregar Nueva Película',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Título'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el título';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Año'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el año';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Por favor, ingresa un año válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _directorController,
                    decoration: const InputDecoration(labelText: 'Director'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el director';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _genreController,
                    decoration: const InputDecoration(labelText: 'Género'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el género';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _synopsisController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Sinopsis'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa la sinopsis';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _imageController,
                    decoration: const InputDecoration(labelText: 'URL de la Imagen'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa la URL de la imagen';
                      }
                      if (!Uri.parse(value).isAbsolute) {
                        return 'Por favor, ingresa una URL válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _addMovie,
                    child: const Text('Agregar Película'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Listado de Películas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('movies').snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Algo salió mal: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay películas en el catálogo.'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final movie = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 75,
                          child: movie['imageUrl'] != null
                              ? Image.network(
                            movie['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.image_not_supported);
                            },
                          )
                              : const Icon(Icons.image_not_supported),
                        ),
                        title: Text(movie['title'] ?? 'Título no disponible'),
                        subtitle: Text('Año: ${movie['year'] ?? 'N/A'}, Género: ${movie['genre'] ?? 'N/A'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _deleteMovie(doc.id);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}