import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/network/http_client.dart';
import 'data/datasources/local/hive_service.dart';
import 'data/datasources/remote/nominatim_api_service.dart';
import 'data/datasources/remote/weather_api_service.dart';
import 'data/datasources/remote/websocket_service.dart';
import 'data/datasources/remote/firebase_chat_service.dart';
import 'data/datasources/remote/firebase_auth_service.dart';
import 'data/datasources/local/favorites_service.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/firebase_chat_repository_impl.dart';
import 'data/repositories/places_repository_impl.dart';
import 'data/repositories/weather_repository_impl.dart';
import 'data/repositories/favorites_repository_impl.dart';
import 'domain/usecases/get_weather.dart';
import 'domain/usecases/login_guest.dart';
import 'domain/usecases/search_places.dart';
import 'domain/usecases/get_favorites.dart';
import 'domain/usecases/toggle_favorite.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/chat/chat_bloc.dart';
import 'presentation/blocs/places/places_bloc.dart';
import 'presentation/blocs/weather/weather_bloc.dart';
import 'presentation/blocs/favorites/favorites_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_event.dart';
import 'presentation/blocs/theme/theme_state.dart';
import 'presentation/blocs/locale/locale_bloc.dart';
import 'presentation/blocs/locale/locale_event.dart';
import 'presentation/blocs/locale/locale_state.dart';
import 'core/localization/app_localizations.dart';
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
          create: (context) => WebSocketServiceImpl(
            hiveService: context.read<HiveService>(),
          ),
        ),
        RepositoryProvider<FirebaseAuthService>(
          create: (context) => FirebaseAuthService(),
        ),
        RepositoryProvider<FirebaseChatService>(
          create: (context) => FirebaseChatServiceImpl(
            authService: context.read<FirebaseAuthService>(),
          ),
        ),
        RepositoryProvider(
          create: (context) => AuthRepositoryImpl(
            hiveService: context.read<HiveService>(),
            firebaseAuthService: context.read<FirebaseAuthService>(),
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
          create: (context) => FirebaseChatRepositoryImpl(
            firebaseChatService: context.read<FirebaseChatService>(),
            hiveService: context.read<HiveService>(),
          ),
        ),
        RepositoryProvider<FavoritesService>(
          create: (context) => FavoritesServiceImpl(),
        ),
        RepositoryProvider(
          create: (context) => FavoritesRepositoryImpl(
            favoritesService: context.read<FavoritesService>(),
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
              chatRepository: context.read<FirebaseChatRepositoryImpl>(),
            ),
          ),
          BlocProvider(
            create: (context) => FavoritesBloc(
              favoritesRepository: context.read<FavoritesRepositoryImpl>(),
              getFavorites: GetFavorites(context.read<FavoritesRepositoryImpl>()),
              toggleFavorite: ToggleFavorite(context.read<FavoritesRepositoryImpl>()),
            ),
          ),
          BlocProvider(
            create: (context) => ThemeBloc()..add(LoadThemeEvent()),
          ),
          BlocProvider(
            create: (context) => LocaleBloc()..add(LoadLocaleEvent()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            ThemeData currentTheme = ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            );
            
            if (themeState is ThemeLoaded) {
              currentTheme = themeState.themeData;
            }
            
            return BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, localeState) {
                Locale currentLocale = Locale('en');
                if (localeState is LocaleLoaded) {
                  currentLocale = localeState.locale;
                }
                
                return MaterialApp(
                  title: 'City Explorer',
                  theme: currentTheme,
                  locale: currentLocale,
                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en', ''), // English
                    Locale('hi', ''), // Hindi
                  ],
                  home: const SplashScreen(),
                  debugShowCheckedModeBanner: false,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
