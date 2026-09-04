import 'package:flutter/material.dart';

enum AppLanguage {
  uz('uz', "O'zbekcha", '🇺🇿'),
  ru('ru', 'Русский', '🇷🇺'),
  en('en', 'English', '🇬🇧');

  final String code;
  final String label;
  final String flag;

  const AppLanguage(this.code, this.label, this.flag);

  static AppLanguage fromCode(String code) {
    return AppLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => AppLanguage.uz,
    );
  }
}

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('uz'));
  }

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      // General
      'app_name': 'Archa',
      'cancel': 'Cancel',
      'confirm': 'Confirm',
      'save': 'Save',
      'close': 'Close',
      'start': 'Start',
      'km_h': 'km/h',
      'mph': 'mph',
      'meters': 'm',
      'km': 'km',
      'minutes': 'min',

      // Nav Tabs
      'tab_home': 'Map',
      'tab_routes': 'Routes',
      'tab_categories': 'Objects',
      'tab_add': 'Add',
      'tab_ai': 'AI Chat',
      'tab_reports': 'Reports',
      'tab_profile': 'Profile',

      // Onboarding
      'onboarding_title_1': 'Smart Radar Warning',
      'onboarding_desc_1': 'Real-time alerts for speed cameras, police radars, and mobile traps with distance countdowns.',
      'onboarding_title_2': 'AI Driving Assistant',
      'onboarding_desc_2': 'Personalized route predictions, hazard forecasts, and smart driving safety insights.',
      'onboarding_title_3': 'Community Powered',
      'onboarding_desc_3': 'Join thousands of drivers reporting police patrols, roadworks, and traffic jams in real time.',
      'permissions_title': 'Allow Permissions',
      'permissions_desc': 'Enable essential permissions for real-time navigation and voice assistance.',
      'perm_location': 'Precise Location (Required for Speed & Camera proximity)',
      'perm_mic': 'Microphone (For voice assistant chat)',
      'perm_notifications': 'Push Notifications (Hazard & Radar updates)',
      'get_started': 'Get Started',
      'choose_language': 'Choose Language',

      // Home Map
      'speed_limit': 'Limit',
      'current_speed': 'Current Speed',
      'radar_ahead': 'Radar Ahead',
      'report_hazard': 'Report',
      'search': 'Search',
      'search_destination': 'Where to? (e.g. Tashkent City, Chilonzor)',
      'stationary_camera': 'Multi Radar',
      'mobile_patrol': 'Police Patrol (GAY)',
      'speed_trap': 'Section Speed Control',
      'red_light_camera': 'Red Light Camera',
      'traffic_jam': 'Traffic Jam',
      'accident': 'Car Accident',
      'roadwork': 'Road Works',
      'pothole': 'Road Hazard / Pothole',
      'simulate_drive': 'Simulate Drive',
      'stop_sim': 'Stop Simulator',
      'drive_mode': 'Drive HUD',
      'voice_alert_test': 'Test Voice Alert',
      'map_layers': 'Map Style Layer',
      'map_styles': 'Map type',
      'map_type': 'Map type',
      'map_details': 'Map details',
      'osm_standard': 'Default',
      'osm_dark': 'Dark',
      'satellite': 'Satellite',
      'traffic': 'Traffic',

      // Route Planning
      'plan_route': 'Plan Route',
      'fastest_route': 'Fastest Route',
      'safest_route': 'Safest Route (Low Radars)',
      'eta': 'ETA',
      'distance': 'Distance',
      'radars_on_route': 'Radars on route',
      'safety_score': 'Safety Index',
      'start_navigation': 'Start Navigation',
      'origin': 'Current Location',
      'destination': 'Destination',

      // Navigation
      'navigation_active': 'Navigation Active',
      'speed_warning': 'Slow Down! Speed Camera in',
      'reroute_suggested': 'Faster & safer route found!',
      'reroute_reason': 'Police radar detected ahead. Avoid delay?',
      'accept_reroute': 'Accept Re-route',
      'dismiss': 'Dismiss',
      'turn_left': 'Turn Left',
      'turn_right': 'Turn Right',
      'straight': 'Continue Straight',
      'destination_reached': 'You have arrived at your destination!',

      // AI Agent
      'ai_agent_title': 'Radar AI Copilot',
      'ai_greeting': 'Hello! I am your AI Driving Copilot. Ask me about road conditions, safest routes, or your weekly driving score.',
      'prompt_1': 'What awaits me on the road today?',
      'prompt_2': 'Best route to Chilonzor?',
      'prompt_3': 'How was my driving this week?',
      'prompt_4': 'Where are the most active radar traps?',
      'type_a_message': 'Ask AI assistant or tap mic...',
      'listening': 'Listening... Speak now',
      'weekly_insights': 'Weekly Driving Insights',
      'risk_prediction': 'AI Route Risk Forecast',

      // Reports
      'reports_title': 'Road Hazard Reports',
      'quick_report': 'Quick Report Hazard',
      'select_hazard_desc': 'Select hazard type at your current location',
      'report_sent': 'Report submitted! +10 Karma points earned.',
      'live_community_feed': 'Live Community Feed',
      'my_reports': 'My Reports History',
      'no_reports_yet': 'No reports in this tab yet.',
      'verified_by': 'Verified by',
      'drivers': 'drivers',

      // Profile & Stats
      'driver_score': 'Driver Safety Score',
      'safe_driver_master': 'Elite Safe Driver',
      'speeding_events': 'Speed Violations',
      'distance_driven': 'Distance Driven',
      'clean_trips': 'Clean Trips',
      'points_earned': 'Karma Points',
      'leaderboard': 'City Leaderboard',
      'achievements': 'Badges & Achievements',
      'rank': 'Rank',
      'top_safest_drivers': 'Top 5% safest drivers in Tashkent city. Zero speeding alerts this week!',

      // Settings
      'settings_title': 'Settings',
      'language': 'Language',
      'units': 'Units of Measurement',
      'alert_distance': 'Voice Alert Distance',
      'voice_alerts': 'Voice Alerts (TTS)',
      'sound_chimes': 'Audio Chimes',
      'dark_mode': 'Theme Mode',
      'api_configuration': 'REST API Developer Settings',
      'backend_mode': 'Service Mode (Mock / REST)',
      'base_url': 'API Base URL',
    },
    'ru': {
      // General
      'app_name': 'Archa',
      'cancel': 'Отмена',
      'confirm': 'Подтвердить',
      'save': 'Сохранить',
      'close': 'Закрыть',
      'start': 'Старт',
      'km_h': 'км/ч',
      'mph': 'миль/ч',
      'meters': 'м',
      'km': 'км',
      'minutes': 'мин',

      // Nav Tabs
      'tab_home': 'Карта',
      'tab_routes': 'Маршруты',
      'tab_categories': 'Объекты',
      'tab_add': 'Добавить',
      'tab_ai': 'AI Чат',
      'tab_reports': 'Отчеты',
      'tab_profile': 'Профиль',

      // Onboarding
      'onboarding_title_1': 'Умный Антирадар',
      'onboarding_desc_1': 'Мгновенные оповещения о стационарных камерах, патрулях ДПС и мобильных засадах с таймером расстояния.',
      'onboarding_title_2': 'ИИ Ассистент Водителя',
      'onboarding_desc_2': 'Персональные прогнозы дорожной обстановки, оценка рисков и рекомендации по безопасности вождения.',
      'onboarding_title_3': 'Сообщество Водителей',
      'onboarding_desc_3': 'Присоединяйтесь к водителям, предупреждающим о радарах, пробках и ДТП в реальном времени.',
      'permissions_title': 'Разрешения',
      'permissions_desc': 'Предоставьте доступ для навигации в реальном времени и голосового ассистента.',
      'perm_location': 'Геолокация (для спидометра и приближения к радарам)',
      'perm_mic': 'Микрофон (для голосового общения с ИИ)',
      'perm_notifications': 'Уведомления (о камерах и предупреждениях)',
      'get_started': 'Начать',
      'choose_language': 'Выберите язык',

      // Home Map
      'speed_limit': 'Ограничение',
      'current_speed': 'Скорость',
      'radar_ahead': 'Впереди камера',
      'report_hazard': 'Сообщить',
      'search': 'Поиск',
      'search_destination': 'Куда едем? (напр. Ташкент Сити, Чиланзар)',
      'stationary_camera': 'Мультирадар',
      'mobile_patrol': 'Патруль ДПС (ГАИ)',
      'speed_trap': 'Контроль средней скорости',
      'red_light_camera': 'Камера на светофоре',
      'traffic_jam': 'Пробка',
      'accident': 'ДТП / Авария',
      'roadwork': 'Дорожные работы',
      'pothole': 'Опасная яма / Дефект дороги',
      'simulate_drive': 'Симуляция поездки',
      'stop_sim': 'Остановить симуляцию',
      'drive_mode': 'Режим Вождения',
      'voice_alert_test': 'Тест Голоса',
      'map_layers': 'Слой карты',
      'map_styles': 'Тип карты',
      'map_type': 'Тип карты',
      'map_details': 'Подробности',
      'osm_standard': 'По умолчанию',
      'osm_dark': 'Тёмная',
      'satellite': 'Спутник',
      'traffic': 'Пробки',

      // Route Planning
      'plan_route': 'Построить Маршрут',
      'fastest_route': 'Самый Быстрый',
      'safest_route': 'Безопасный (Меньше камер)',
      'eta': 'Время прибытия',
      'distance': 'Дистанция',
      'radars_on_route': 'Камер на пути',
      'safety_score': 'Индекс безопасности',
      'start_navigation': 'Начать поездку',
      'origin': 'Текущее местоположение',
      'destination': 'Пункт назначения',

      // Navigation
      'navigation_active': 'Навигация активна',
      'speed_warning': 'Снизьте скорость! Камера через',
      'reroute_suggested': 'Найден более быстрый и безопасный путь!',
      'reroute_reason': 'Впереди обнаружен пост ДПС. Объехать?',
      'accept_reroute': 'Применить объезд',
      'dismiss': 'Пропустить',
      'turn_left': 'Поверните налево',
      'turn_right': 'Поверните направо',
      'straight': 'Двигайтесь прямо',
      'destination_reached': 'Вы прибыли в пункт назначения!',

      // AI Agent
      'ai_agent_title': 'ИИ Ассистент Radar AI',
      'ai_greeting': 'Здравствуйте! Я ваш автопилот-ассистент. Спросите о ситуации на дороге, лучшем маршруте или статистике вождения.',
      'prompt_1': 'Что меня ждет на дорогах сегодня?',
      'prompt_2': 'Как лучше доехать до Чиланзара?',
      'prompt_3': 'Какой у меня рейтинг вождения за неделю?',
      'prompt_4': 'Где сейчас больше всего камер и постов?',
      'type_a_message': 'Спросите у ИИ или нажмите микрофон...',
      'listening': 'Слушаю вас... Говорите',
      'weekly_insights': 'Итоги недели и безопасность',
      'risk_prediction': 'ИИ Прогноз рисков маршрута',

      // Reports
      'reports_title': 'События на дороге',
      'quick_report': 'Сообщить о событии',
      'select_hazard_desc': 'Выберите тип дорожного события',
      'report_sent': 'Спасибо! Отчет отправлен (+10 очков кармы).',
      'live_community_feed': 'Лента сообщества',
      'my_reports': 'Мои отчеты',
      'no_reports_yet': 'Здесь пока нет отчетов.',
      'verified_by': 'Подтверждено',
      'drivers': 'водителями',

      // Profile & Stats
      'driver_score': 'Рейтинг Безопасности',
      'safe_driver_master': 'Мастер Безопасного Вождения',
      'speeding_events': 'Превышений скорости',
      'distance_driven': 'Пройдено км',
      'clean_trips': 'Чистых поездок',
      'points_earned': 'Очков кармы',
      'leaderboard': 'Таблица Лидеров',
      'achievements': 'Достижения и Награды',
      'rank': 'Место',
      'top_safest_drivers': 'Входит в топ-5% самых аккуратных водителей Ташкента! 0 превышений за неделю.',

      // Settings
      'settings_title': 'Настройки',
      'language': 'Язык интерфейса',
      'units': 'Единицы измерения',
      'alert_distance': 'Дистанция предупреждения',
      'voice_alerts': 'Голосовые подсказки',
      'sound_chimes': 'Звуковые сигналы',
      'dark_mode': 'Тема оформления',
      'api_configuration': 'REST API настройки разработчика',
      'backend_mode': 'Режим данных (Mock / REST API)',
      'base_url': 'URL сервера API',
    },
    'uz': {
      // General
      'app_name': 'Archa',
      'cancel': 'Bekor qilish',
      'confirm': 'Tasdiqlash',
      'save': 'Saqlash',
      'close': 'Yopish',
      'start': 'Boshlash',
      'km_h': 'km/soat',
      'mph': 'milya/soat',
      'meters': 'm',
      'km': 'km',
      'minutes': 'daq',

      // Nav Tabs
      'tab_home': 'Karta',
      'tab_routes': 'Yo\'nalishlar',
      'tab_categories': 'Obyektlar',
      'tab_add': 'Qo\'shish',
      'tab_ai': 'AI Chat',
      'tab_reports': 'Xabarlar',
      'tab_profile': 'Profil',

      // Onboarding
      'onboarding_title_1': 'Aqlli Antiradar',
      'onboarding_desc_1': 'Statsionar kameralar, YPX patrul va mobil radarlar haqida masofa hisoblagichi bilan real vaqtda ogohlantirish.',
      'onboarding_desc_2': 'Sun\'iy intellekt orqali xavfsiz yo\'llar, xavf zonalari tahlili va haydash bo\'yicha tavsiyalar.',
      'onboarding_title_2': 'AI Haydovchi Yordamchisi',
      'onboarding_title_3': 'Haydovchilar Hamjamiyati',
      'onboarding_desc_3': 'Yo\'ldagi radarlar, tirbandlik va YTX haqida darhol xabar beruvchi minglab haydovchilarga qo\'shiling.',
      'permissions_title': 'Ruxsatnomalar',
      'permissions_desc': 'Haqiqiy vaqtdagi navigatsiya va ovozli yordamchi uchun ruxsat bering.',
      'perm_location': 'Geolokatsiya (Tezlik va radarlarni aniqlash uchun)',
      'perm_mic': 'Mikrofon (Ovozli AI yordamchi uchun)',
      'perm_notifications': 'Bildirishnomalar (Kameralar va xavflar haqida)',
      'get_started': 'Boshlash',
      'choose_language': 'Tilni tanlang',

      // Home Map
      'speed_limit': 'Cheklov',
      'current_speed': 'Tezlik',
      'radar_ahead': 'Oldinda Radar',
      'report_hazard': 'Xabar berish',
      'search': 'Qidirish',
      'search_destination': 'Qayerga boramiz? (masalan, Tashkent City, Chilonzor)',
      'stationary_camera': 'Multiradar',
      'mobile_patrol': 'YPX Patruli (GAY)',
      'speed_trap': 'O\'rtacha tezlik nazorati',
      'red_light_camera': 'Svetofor kamerasi',
      'traffic_jam': 'Tirbandlik',
      'accident': 'Yo\'l-transport hodisasi',
      'roadwork': 'Yo\'l ta\'miri',
      'pothole': 'Chuqur / Yo\'l xavfi',
      'simulate_drive': 'Sinov haydash rejimi',
      'stop_sim': 'Sinovni to\'xtatish',
      'drive_mode': 'Haydash Ekrani',
      'voice_alert_test': 'Ovozni sinash',
      'map_layers': 'Xarita qatlami',
      'map_styles': 'Xarita turi',
      'map_type': 'Xarita turi',
      'map_details': 'Qo\'shimcha ma\'lumotlar',
      'osm_standard': 'Standart',
      'osm_dark': 'Tungi',
      'satellite': 'Yo\'ldosh',
      'traffic': 'Tirbandlik',

      // Route Planning
      'plan_route': 'Yo\'nalish Tuzish',
      'fastest_route': 'Eng Tez Yo\'l',
      'safest_route': 'Xavfsiz Yo\'l (Kameralar kam)',
      'eta': 'Yetib borish vaqti',
      'distance': 'Masofa',
      'radars_on_route': 'Yo\'ldagi kameralar',
      'safety_score': 'Xavfsizlik indeksi',
      'start_navigation': 'Harakatni boshlash',
      'origin': 'Hozirgi joylashuv',
      'destination': 'Manzil',

      // Navigation
      'navigation_active': 'Navigatsiya yoqilgan',
      'speed_warning': 'Tezlikni pasaytiring! Kamera yaqinlashmoqda:',
      'reroute_suggested': 'Tezroq va xavfsizroq yangi yo\'l topildi!',
      'reroute_reason': 'Oldinda YPX radari aniqlandi. Aylanib o\'tilsinmi?',
      'accept_reroute': 'Aylanib o\'tish',
      'dismiss': 'Qoldirish',
      'turn_left': 'Chapga buriling',
      'turn_right': 'O\'ngga buriling',
      'straight': 'To\'g\'riga davom eting',
      'destination_reached': 'Manzilga yetib keldingiz!',

      // AI Agent
      'ai_agent_title': 'Radar AI Yordamchisi',
      'ai_greeting': 'Assalomu alaykum! Men sizning aqlli hamrohingizman. Yo\'ldagi holat, xavfsiz marshrut yoki haftalik reytingingiz haqida so\'rang.',
      'prompt_1': 'Bugun yo\'llarda nima kutmoqda?',
      'prompt_2': 'Chilonzorga eng yaxshi yo\'l qaysi?',
      'prompt_3': 'Bu haftadagi haydash ballim qanday?',
      'prompt_4': 'Eng ko\'p radarlar qaysi ko\'chalarda?',
      'type_a_message': 'AI yordamchiga yozing yoki mikrofonga gapiring...',
      'listening': 'Eshitmoqdaman... Gapiring',
      'weekly_insights': 'Haftalik Tahlil & Xavfsizlik',
      'risk_prediction': 'AI Yo\'l Xavfi Bashorati',

      // Reports
      'reports_title': 'Yo\'l Xabarlari',
      'quick_report': 'Xavf haqida xabar berish',
      'select_hazard_desc': 'Hozirgi joylashuvingizdagi xavf turini tanlang',
      'report_sent': 'Xabaringiz yuborildi! +10 karma ball berildi.',
      'live_community_feed': 'Jonli xabarlar tasmasi',
      'my_reports': 'Yuborilgan xabarlarim',
      'no_reports_yet': 'Ushbu bo\'limda hali xabarlar yo\'q.',
      'verified_by': 'Tasdiqladi:',
      'drivers': 'haydovchi',

      // Profile & Stats
      'driver_score': 'Haydovchi Xavfsizlik Balli',
      'safe_driver_master': 'Mohir Xavfsiz Haydovchi',
      'speeding_events': 'Tezlik oshirishlar',
      'distance_driven': 'Bosib o\'tilgan masofa',
      'clean_trips': 'Qoidabuzarliksiz safarlar',
      'points_earned': 'Karma ballari',
      'leaderboard': 'Peshqadamlar Jadvali',
      'achievements': 'Yutuqlar & Nishonlar',
      'rank': 'O\'rin',
      'top_safest_drivers': 'Toshkent bo\'yicha eng xavfsiz 5% haydovchilar safida! Bu hafta 0 ta tezlik oshirish.',

      // Settings
      'settings_title': 'Sozlamalar',
      'language': 'Ilova tili',
      'units': 'O\'lchov birligi',
      'alert_distance': 'Ogohlantirish masofasi',
      'voice_alerts': 'Ovozli ogohlantirish (TTS)',
      'sound_chimes': 'Tovush signallari',
      'dark_mode': 'Mavzu (Qorong\'i / Yorug\')',
      'api_configuration': 'REST API Dasturchi sozlamalari',
      'backend_mode': 'Ma\'lumotlar manbasi (Mock / REST)',
      'base_url': 'API Server manzili',
    }
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String tr(String key) => translate(key);
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
