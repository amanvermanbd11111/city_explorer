import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/http_client.dart';
import 'data/datasources/local/hive_service.dart';
import 'data/datasources/remote/nominatim_api_service.dart';
import 'data/datasources/remote/weather_api_service.dart';
import 'data/datasources/remote/websocket_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/chat_repository_impl.dart';
import 'data/repositories/places_repository_impl.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'domain/usecases/get_weather.dart';
import 'domain/usecases/login_guest.dart';
import 'domain/usecases/search_places.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/places/places_bloc.dart';
import 'presentation/blocs/weather/weather_bloc.dart';
import 'presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(CityExplorerApp());
}

class CityExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => HiveService()),
        RepositoryProvider(create: (_) => HttpClient()),
        RepositoryProvider<NominatimApiService>(
          create: (context) => NominatimApiServiceImpl(
            httpClient: context.read<HttpClient>(),
          ),
        ),
        RepositoryProvider<WeatherApiService>(
          create: (context) => WeatherApiServiceImpl(
            httpClient: context.read<HttpClient>(),
          ),
        ),
        RepositoryProvider<WebSocketService>(
          create: (_) => WebSocketServiceImpl(),
        ),
        RepositoryProvider(
          create: (context) => AuthRepositoryImpl(
            hiveService: context.read<HiveService>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => PlacesRepositoryImpl(
            apiService: context.read<NominatimApiService>(),
            hiveService: context.read<HiveService>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => WeatherRepositoryImpl(
            apiService: context.read<WeatherApiService>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => ChatRepositoryImpl(
            webSocketService: context.read<WebSocketService>(),
            hiveService: context.read<HiveService>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryImpl>(),
              loginGuest: LoginGuest(context.read<AuthRepositoryImpl>()),
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider(
            create: (context) => PlacesBloc(
              placesRepository: context.read<PlacesRepositoryImpl>(),
              searchPlaces: SearchPlaces(context.read<PlacesRepositoryImpl>()),
            ),
          ),
          BlocProvider(
            create: (context) => WeatherBloc(
              getWeather: GetWeather(context.read<WeatherRepositoryImpl>()),
            ),
          ),
          BlocProvider(
            create: (context) => ChatBloc(
              chatRepository: context.read<ChatRepositoryImpl>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'City Explorer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}