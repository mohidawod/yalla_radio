import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';




void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class RadioStation {
  final String name;
  final String url;
  bool isFavorite;

  RadioStation({
    required this.name,
    required this.url,
    this.isFavorite = false,
  });
}

class RadioController {
  AudioPlayer? _player; // 👈 تغيير إلى nullable
  String? currentStationUrl;
  bool isPlaying = false;
  bool _isBusy = false;
  double _volume = 1.0;

  Future<void> play(String url) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      // إذا كان هناك مشغل موجود، نوقفه ونحذفه
      if (_player != null) {
        await _player!.stop();
        await _player!.dispose();
        _player = null;
      }

      // إنشاء مشغل جديد
      _player = AudioPlayer();

      // تعيين مستوى الصوت
      await _player!.setVolume(_volume);

      // تشغيل المحطة الجديدة
      await _player!.play(UrlSource(url));

      currentStationUrl = url;
      isPlaying = true;
    } catch (e) {
      debugPrint('Error while playing: $e');
      await stop();
    } finally {
      _isBusy = false;
    }
  }

  Future<void> stop() async {
    if (_player != null) {
      await _player!.stop();
      await _player!.dispose();
      _player = null;
    }
    currentStationUrl = null;
    isPlaying = false;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_player != null) {
      await _player!.setVolume(_volume);
    }
  }

  double get volume => _volume;

  Future<void> dispose() async {
    await stop();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RadioController _radioController = RadioController();
  late List<RadioStation> _stations;
  bool _isDarkMode = false;
  bool _isLoading = false;
  int _currentIndex = 0;
  double _currentVolume = 1.0;
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await _initSharedPreferences();
    _loadStations();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = _prefs.getBool('darkMode') ?? false;
    });
  }

  void _loadStations() {
    final List<RadioStation> stations = [
      RadioStation(
        name: 'Monte Carlo Doualiya',
        url:
            'https://montecarlodoualiya128k.ice.infomaniak.ch/mc-doualiya.mp3 ',
      ),
      RadioStation(
        name: 'BBC English',
        url: 'http://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
      ),
      RadioStation(
        name: 'Radio Asharq',
        url:
            'https://l3.itworkscdn.net/asharqradioalive/asharqradioa/icecast.audio ',
      ),
      RadioStation(
        name: 'إذاعة القرآن الكريم',
        url: 'https://qurango.net/radio/mishary_alafasi ',
      ),
      RadioStation(
        name: 'Radio Dabangasudan',
        url: 'https://stream.dabangasudan.org ',
      ),
      RadioStation(
        name: 'Nogoum fm',
        url: 'https://audio.nrpstream.com/listen/nogoumfm/radio.mp3 ',
      ),
      RadioStation(
        name: 'Al araby',
        url:
            'https://l3.itworkscdn.net/alarabyradiolive/alarabyradio_audio/icecast.audio ',
      ),
    ];
    
    final List<String>? savedFavorites = _prefs.getStringList('favorites');

    if (savedFavorites != null) {
      for (var station in stations) {
        if (savedFavorites.contains(station.name)) {
          station.isFavorite = true;
        }
      }
    }

    setState(() {
      _stations = stations;
    });
  }

  Future<void> _saveFavorites() async {
    final List<String> favoriteNames =
        _stations.where((s) => s.isFavorite).map((s) => s.name).toList();
    await _prefs.setStringList('favorites', favoriteNames);
  }

  void _toggleDarkMode() async {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await _prefs.setBool('darkMode', _isDarkMode);
  }

  void _toggleFavorite(RadioStation station) {
    setState(() {
      station.isFavorite = !station.isFavorite;
    });
    _saveFavorites();
  }

  Future<void> _playStation(RadioStation station) async {
    setState(() => _isLoading = true);
    try {
      await _radioController.stop(); // 👈 إجبار إيقاف أي تشغيل قديم
      await _radioController.play(station.url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل تشغيل المحطة: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _stopPlaying() async {
    setState(() => _isLoading = true);
    try {
      await _radioController.stop();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeVolume(double newVolume) async {
    setState(() {
      _currentVolume = newVolume;
    });
    await _radioController.setVolume(newVolume);
  }

  @override
  void dispose() {
    _radioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          _isDarkMode
              ? ThemeData.dark().copyWith(
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
                  bodyMedium: TextStyle(fontSize: 16, color: Colors.white),
                ),
                appBarTheme: const AppBarTheme(
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
              : ThemeData.light().copyWith(
                textTheme: const TextTheme(
                  bodyLarge: TextStyle(fontSize: 18),
                  bodyMedium: TextStyle(fontSize: 16),
                ),
                appBarTheme: const AppBarTheme(
                  titleTextStyle: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('تطبيق الراديو'),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder:
                        (context) => Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('تحكم في الصوت'),
                              Slider(
                                value: _currentVolume,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                label: '${(_currentVolume * 100).round()}%',
                                onChanged: _changeVolume,
                              ),
                            ],
                          ),
                        ),
                  );
                },
              ),
              IconButton(
                icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleDarkMode,
              ),
              if (_radioController.isPlaying)
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: _stopPlaying,
                ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCurrentScreen(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'المفضلة',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.info),
                label: 'عن التطبيق',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return _buildFavoritesScreen();
      case 2:
        return _buildAboutScreen();
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'المحطات الإذاعية',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
              children:
                  _stations.map((station) {
                    final isCurrent =
                        _radioController.currentStationUrl == station.url;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap:
                            () =>
                                isCurrent && _radioController.isPlaying
                                    ? _stopPlaying()
                                    : _playStation(station),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.radio,
                                size: 40,
                                color: isCurrent ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                station.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      station.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          station.isFavorite
                                              ? Colors.red
                                              : null,
                                    ),
                                    onPressed: () => _toggleFavorite(station),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      isCurrent && _radioController.isPlaying
                                          ? Icons.stop
                                          : Icons.play_arrow,
                                      color: isCurrent ? Colors.blue : null,
                                    ),
                                    onPressed:
                                        () =>
                                            isCurrent &&
                                                    _radioController.isPlaying
                                                ? _stopPlaying()
                                                : _playStation(station),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesScreen() {
    final favorites = _stations.where((s) => s.isFavorite).toList();
    return favorites.isEmpty
        ? const Center(
          child: Text(
            'لا توجد محطات مفضلة بعد',
            style: TextStyle(fontSize: 18),
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final station = favorites[index];
            final isCurrent = _radioController.currentStationUrl == station.url;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(
                  Icons.radio,
                  color: isCurrent ? Colors.blue : null,
                ),
                title: Text(station.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () => _toggleFavorite(station),
                    ),
                    IconButton(
                      icon: Icon(
                        isCurrent && _radioController.isPlaying
                            ? Icons.stop
                            : Icons.play_arrow,
                      ),
                      onPressed:
                          () =>
                              isCurrent && _radioController.isPlaying
                                  ? _stopPlaying()
                                  : _playStation(station),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }

  Widget _buildAboutScreen() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.radio, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'تطبيق الراديو',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('الإصدار 1.0.0'),
            SizedBox(height: 20),
            Text('App Developer: Mohammed Dawood'),
            Text('mohidawod@gmail.com'),
          ],
        ),
      ),
    );
  }
}
