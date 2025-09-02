import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/place.dart';
import '../../blocs/weather/weather_bloc.dart';
import '../../blocs/weather/weather_event.dart';
import '../../blocs/weather/weather_state.dart';
import '../../blocs/favorites/favorites_bloc.dart';
import '../../blocs/favorites/favorites_event.dart';
import '../../blocs/favorites/favorites_state.dart';
import '../chat/chat_screen.dart';

class PlaceDetailScreen extends StatefulWidget {
  final Place place;

  const PlaceDetailScreen({Key? key, required this.place}) : super(key: key);

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WeatherBloc>().add(
          GetWeatherEvent(widget.place.lat, widget.place.lon),
        );
    
    // Check favorite status
    final favoritesBloc = context.read<FavoritesBloc>();
    final placeId = favoritesBloc.favoritesRepository.generatePlaceId(widget.place);
    favoritesBloc.add(CheckFavoriteStatusEvent(placeId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Place Details'),
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final placeId = context.read<FavoritesBloc>().favoritesRepository.generatePlaceId(widget.place);
              bool isFavorite = false;
              
              if (state is FavoritesLoaded) {
                isFavorite = state.favoriteStatus[placeId] ?? false;
              }
              
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(ToggleFavoriteEvent(widget.place));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isFavorite ? 'Removed from favorites' : 'Added to favorites'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.chat),
            onPressed: () {
              final cityName = widget.place.city ?? 
                             widget.place.displayName.split(',').first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(cityName: cityName),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPlaceHeader(),
            _buildPlaceDetails(),
            _buildWeatherCard(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }


  Widget _buildPlaceHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue, Colors.blue.shade700],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.place.displayName.split(',').first,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.place.formattedAddress,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceDetails() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Display Name', widget.place.displayName),
              if (widget.place.addressType != null)
                _buildDetailRow('Type', widget.place.addressType!),
              if (widget.place.city != null)
                _buildDetailRow('City', widget.place.city!),
              if (widget.place.state != null)
                _buildDetailRow('State', widget.place.state!),
              if (widget.place.country != null)
                _buildDetailRow('Country', widget.place.country!),
              if (widget.place.postcode != null)
                _buildDetailRow('Postal Code', widget.place.postcode!),
              _buildDetailRow('Coordinates', 
                '${widget.place.lat.toStringAsFixed(6)}, ${widget.place.lon.toStringAsFixed(6)}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.cloud, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    'Weather Information',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              BlocBuilder<WeatherBloc, WeatherState>(
                builder: (context, state) {
                  if (state is WeatherLoading) {
                    return Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 8),
                          Text('Loading weather data...'),
                        ],
                      ),
                    );
                  } else if (state is WeatherLoaded) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildWeatherItem(
                              'Temperature',
                              state.weather.temperatureCelsius,
                              Icons.thermostat,
                              Colors.orange,
                            ),
                            _buildWeatherItem(
                              'Humidity',
                              state.weather.humidityPercent,
                              Icons.water_drop,
                              Colors.blue,
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Text(
                                state.weather.main,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                state.weather.description.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (state is WeatherError) {
                    return Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red.shade400,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Failed to load weather',
                          style: TextStyle(color: Colors.red.shade600),
                        ),
                        SizedBox(height: 4),
                        Text(
                          state.message,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<WeatherBloc>().add(
                                  GetWeatherEvent(widget.place.lat, widget.place.lon),
                                );
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    );
                  }
                  return SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                final cityName = widget.place.city ?? 
                               widget.place.displayName.split(',').first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(cityName: cityName),
                  ),
                );
              },
              icon: Icon(Icons.chat),
              label: Text('Join City Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<WeatherBloc>().add(
                      GetWeatherEvent(widget.place.lat, widget.place.lon),
                    );
              },
              icon: Icon(Icons.refresh),
              label: Text('Refresh Weather'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}