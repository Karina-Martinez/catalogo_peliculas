import 'package:flutter/material.dart';
import 'movie_list_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'welcome_screen.dart';
import 'admin_screen.dart';
import 'movie_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/catalog': (context) => const MovieListScreen(),
        '/admin': (context) => const AdminScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/movie_detail') {
          final movie = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          );
        }
        return null;
      },
    );
  }
}