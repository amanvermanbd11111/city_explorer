import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/places/places_bloc.dart';
import '../../blocs/places/places_event.dart';
import '../../blocs/places/places_state.dart';
import '../../blocs/theme/theme_bloc.dart';
import '../../blocs/theme/theme_event.dart';
import '../../blocs/theme/theme_state.dart';
import '../../blocs/locale/locale_bloc.dart';
import '../../blocs/locale/locale_event.dart';
import '../../blocs/locale/locale_state.dart';
import '../auth/guest_login_screen.dart';
import '../places/places_search_screen.dart';
import '../favorites/favorites_screen.dart';
import '../../widgets/search_bar_widget.dart';
import '../../../core/localization/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PlacesBloc>().add(LoadLastSearchedCityEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const GuestLoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.appTitle ?? 'City Explorer'),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              bool isDarkMode = false;
              if (themeState is ThemeLoaded) {
                isDarkMode = themeState.isDarkMode;
              }
              
              return IconButton(
                onPressed: () {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
                icon: Icon(
                  isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
              );
            },
          ),
          BlocBuilder<LocaleBloc, LocaleState>(
            builder: (context, localeState) {
              String currentLanguage = 'EN';
              if (localeState is LocaleLoaded) {
                currentLanguage = localeState.locale.languageCode == 'hi' ? 'HI' : 'EN';
              }
              
              return TextButton(
                onPressed: () {
                  final newLocale = currentLanguage == 'EN' ? Locale('hi') : Locale('en');
                  context.read<LocaleBloc>().add(ChangeLocaleEvent(newLocale));
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  minimumSize: Size(40, 40),
                  padding: EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  currentLanguage,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      state.user.username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog(context);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(state.user.username),
                        ],
                      ),
                    ),
                    PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                );
              }
              return SizedBox.shrink();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is AuthAuthenticated) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              radius: 30,
                              child: Icon(
                                Icons.person,
                                color: Colors.blue,
                                size: 30,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)?.welcome ?? 'Welcome back,',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    state.user.username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
              const SizedBox(height: 24),
              SearchBarWidget(
                onSearch: (query) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlacesSearchScreen(initialQuery: query),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)?.quickActions ?? 'Quick Actions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.search,
                      title: AppLocalizations.of(context)?.searchPlaces ?? 'Search Places',
                      subtitle: AppLocalizations.of(context)?.findInterestingPlaces ?? 'Find interesting places in any city',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacesSearchScreen(),
                          ),
                        );
                      },
                    ),
                    BlocBuilder<PlacesBloc, PlacesState>(
                      builder: (context, state) {
                        return _buildActionCard(
                          context,
                          icon: Icons.history,
                          title: AppLocalizations.of(context)?.lastSearch ?? 'Last Search',
                          subtitle: state is LastSearchedCityLoaded && state.cityName != null
                              ? state.cityName!
                              : AppLocalizations.of(context)?.noRecentSearches ?? 'No recent searches',
                          color: Colors.orange,
                          onTap: state is LastSearchedCityLoaded && state.cityName != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PlacesSearchScreen(
                                        initialQuery: state.cityName!,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.favorite,
                      title: AppLocalizations.of(context)?.favorites ?? 'Favorites',
                      subtitle: AppLocalizations.of(context)?.yourSavedPlaces ?? 'Your saved places',
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoritesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.chat,
                      title: AppLocalizations.of(context)?.cityChat ?? 'City Chat',
                      subtitle: AppLocalizations.of(context)?.chatWithOtherExplorers ?? 'Chat with other explorers',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlacesSearchScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)?.logout ?? 'Logout'),
          content: Text(AppLocalizations.of(context)?.logoutConfirmation ?? 'Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context)?.cancel ?? 'Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutEvent());
              },
              child: Text(AppLocalizations.of(context)?.logout ?? 'Logout'),
            ),
          ],
        );
      },
    );
  }
}