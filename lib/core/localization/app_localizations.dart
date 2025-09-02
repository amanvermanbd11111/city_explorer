import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // App Title
  String get appTitle => locale.languageCode == 'hi' ? 'सिटी एक्सप्लोरर' : 'City Explorer';

  // Home Screen
  String get welcome => locale.languageCode == 'hi' ? 'वापसी पर स्वागत,' : 'Welcome back,';
  String get searchPlaces => locale.languageCode == 'hi' ? 'स्थान खोजें' : 'Search Places';
  String get quickActions => locale.languageCode == 'hi' ? 'त्वरित क्रियाएं' : 'Quick Actions';
  String get findInterestingPlaces => locale.languageCode == 'hi' ? 'किसी भी शहर में दिलचस्प जगहें खोजें' : 'Find interesting places in any city';
  String get lastSearch => locale.languageCode == 'hi' ? 'अंतिम खोज' : 'Last Search';
  String get noRecentSearches => locale.languageCode == 'hi' ? 'कोई हाल की खोज नहीं' : 'No recent searches';
  String get favorites => locale.languageCode == 'hi' ? 'पसंदीदा' : 'Favorites';
  String get yourSavedPlaces => locale.languageCode == 'hi' ? 'आपके सहेजे गए स्थान' : 'Your saved places';
  String get cityChat => locale.languageCode == 'hi' ? 'सिटी चैट' : 'City Chat';
  String get chatWithOtherExplorers => locale.languageCode == 'hi' ? 'अन्य खोजकर्ताओं के साथ चैट करें' : 'Chat with other explorers';

  // Search Screen
  String get searchForCity => locale.languageCode == 'hi' ? 'शहर खोजें' : 'Search for a city';
  String get enterCityName => locale.languageCode == 'hi' ? 'दिलचस्प जगहों को खोजने के लिए शहर का नाम दर्ज करें' : 'Enter a city name to find interesting places';
  String get searchingPlaces => locale.languageCode == 'hi' ? 'स्थान खोजे जा रहे हैं...' : 'Searching for places...';
  String foundPlaces(int count, String query) => locale.languageCode == 'hi' ? '"$query" में $count स्थान मिले' : 'Found $count places in "$query"';
  String get mapView => locale.languageCode == 'hi' ? 'मानचित्र दृश्य' : 'Map View';
  String get noPlacesFound => locale.languageCode == 'hi' ? 'कोई स्थान नहीं मिला' : 'No places found';
  String noPlacesFoundFor(String query) => locale.languageCode == 'hi' ? '"$query" के लिए कोई स्थान नहीं मिला' : 'No places found for "$query"';
  String get tryAgain => locale.languageCode == 'hi' ? 'फिर से कोशिश करें' : 'Try Again';

  // Details Screen
  String get placeDetails => locale.languageCode == 'hi' ? 'स्थान विवरण' : 'Place Details';
  String get details => locale.languageCode == 'hi' ? 'विवरण' : 'Details';
  String get weatherInformation => locale.languageCode == 'hi' ? 'मौसम की जानकारी' : 'Weather Information';
  String get loadingWeather => locale.languageCode == 'hi' ? 'मौसम डेटा लोड हो रहा है...' : 'Loading weather data...';
  String get temperature => locale.languageCode == 'hi' ? 'तापमान' : 'Temperature';
  String get humidity => locale.languageCode == 'hi' ? 'नमी' : 'Humidity';
  String get failedToLoadWeather => locale.languageCode == 'hi' ? 'मौसम लोड करने में विफल' : 'Failed to load weather';
  String get joinCityChat => locale.languageCode == 'hi' ? 'सिटी चैट में शामिल हों' : 'Join City Chat';
  String get refreshWeather => locale.languageCode == 'hi' ? 'मौसम रिफ्रेश करें' : 'Refresh Weather';

  // Favorites
  String get noFavoritesYet => locale.languageCode == 'hi' ? 'अभी तक कोई पसंदीदा नहीं' : 'No Favorites Yet';
  String get startExploring => locale.languageCode == 'hi' ? 'स्थानों की खोज शुरू करें और उन्हें अपने पसंदीदा में जोड़ने के लिए दिल आइकन पर टैप करें' : 'Start exploring places and tap the heart icon to add them to your favorites';
  String favoritePlaces(int count) => locale.languageCode == 'hi' ? '$count पसंदीदा स्थान' : '$count favorite place${count == 1 ? '' : 's'}';
  String get addedToFavorites => locale.languageCode == 'hi' ? 'पसंदीदा में जोड़ा गया' : 'Added to favorites';
  String get removedFromFavorites => locale.languageCode == 'hi' ? 'पसंदीदा से हटाया गया' : 'Removed from favorites';
  String get loadingFavorites => locale.languageCode == 'hi' ? 'पसंदीदा लोड हो रहे हैं...' : 'Loading favorites...';

  // Common
  String get error => locale.languageCode == 'hi' ? 'त्रुटि' : 'Error';
  String get retry => locale.languageCode == 'hi' ? 'पुनः प्रयास' : 'Retry';
  String get cancel => locale.languageCode == 'hi' ? 'रद्द करें' : 'Cancel';
  String get viewDetails => locale.languageCode == 'hi' ? 'विवरण देखें' : 'View Details';
  String get logout => locale.languageCode == 'hi' ? 'लॉगआउट' : 'Logout';
  String get logoutConfirmation => locale.languageCode == 'hi' ? 'क्या आप वाकई लॉगआउट करना चाहते हैं?' : 'Are you sure you want to logout?';

  // Theme
  String get switchToLightMode => locale.languageCode == 'hi' ? 'लाइट मोड पर स्विच करें' : 'Switch to Light Mode';
  String get switchToDarkMode => locale.languageCode == 'hi' ? 'डार्क मोड पर स्विच करें' : 'Switch to Dark Mode';

  // Map
  String get noPlacesToShow => locale.languageCode == 'hi' ? 'मानचित्र पर दिखाने के लिए कोई स्थान नहीं' : 'No places to show on map';
  String get searchPlacesToSeeMap => locale.languageCode == 'hi' ? 'उन्हें मानचित्र पर देखने के लिए स्थानों की खोज करें' : 'Search for places to see them on the map';
  String placesIn(String query) => locale.languageCode == 'hi' ? '"$query" में स्थान' : 'Places in "$query"';
  String get placesMap => locale.languageCode == 'hi' ? 'स्थान मानचित्र' : 'Places Map';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}