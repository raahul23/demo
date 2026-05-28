import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static const _defaultEnv = 'dev';

  static String get current {
    const fromDefine = String.fromEnvironment('ENV');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    return kReleaseMode ? 'prod' : _defaultEnv;
  }

  static String get baseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return 'https://api.goapp.com';
    }
    return dotenv.get('API_BASE_URL', fallback: 'https://api.goapp.com');
  }

  static String get googlePlacesApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.get('GOOGLE_MAPS_API_KEY', fallback: '');
  }

  static String get googleGeocodingApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.get('GOOGLE_MAPS_API_KEY', fallback: googlePlacesApiKey);
  }

  static String get googleDirectionsApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.get('GOOGLE_MAPS_API_KEY', fallback: googlePlacesApiKey);
  }

  static String get googleDistanceMatrixApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.get('GOOGLE_MAPS_API_KEY', fallback: googlePlacesApiKey);
  }

  static String get googleRoutesApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.get('GOOGLE_MAPS_API_KEY', fallback: googlePlacesApiKey);
  }

  static String get googleRoutesMatrixApiKey {
    const fromDefine = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }
    if (!dotenv.isInitialized) {
      return '';
    }
    return dotenv.get('GOOGLE_MAPS_API_KEY', fallback: googlePlacesApiKey);
  }

  static bool get mockApi {
    const fromDefine = String.fromEnvironment('MOCK_API');
    if (fromDefine.isNotEmpty) {
      final value = fromDefine.toLowerCase();
      return value == 'true' || value == '1' || value == 'yes';
    }
    if (!dotenv.isInitialized) {
      return false;
    }
    final value = dotenv.get('MOCK_API', fallback: 'false').toLowerCase();
    return value == 'true' || value == '1' || value == 'yes';
  }

  static Future<void> load() async {
    final envFile = 'assets/env/${Env.current}.env';
    await dotenv.load(fileName: envFile);
  }
}
