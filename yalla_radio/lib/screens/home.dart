import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
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
  final AudioPlayer player = AudioPlayer();
  String? currentStationUrl;
  bool isPlaying = false;

  Future<void> play(String url) async {
    await player.stop();
    await player.play(UrlSource(url));
    currentStationUrl = url;
    isPlaying = true;
  }

  Future<void> stop() async {
    await player.stop();
    currentStationUrl = null;
    isPlaying = false;
  }

  void dispose() {
    player.dispose();
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RadioController _radioController = RadioController();
  final List<RadioStation> _stations = [
    RadioStation(
      name: 'Monte Carlo Doualiya',
      url: 'https://montecarlodoualiya128k.ice.infomaniak.ch/mc-doualiya.mp3',
    ),
    RadioStation(name: 'راديو 2', url: 'https://stream2.url'),
    RadioStation(name: 'راديو نجوم FM', url: 'https://stream.nogomfm.com/live'),
    RadioStation(
      name: 'إذاعة القرآن الكريم',
      url: 'https://qurango.net/radio.mp3',
    ),
    RadioStation(name: 'راديو سوا', url: 'https://stream.sawa.com/sawa'),
    RadioStation(name: 'ميجا إف إم', url: 'https://stream.mega-fm.net/live'),
    RadioStation(name: 'راديو هلا', url: 'https://stream.halafm.com/live'),
  ];

  bool _isDarkMode = false;
  int _currentIndex = 0;

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _toggleFavorite(RadioStation station) {
    setState(() {
      station.isFavorite = !station.isFavorite;
    });
  }

  Future<void> _playStation(RadioStation station) async {
    await _radioController.play(station.url);
    setState(() {});
  }

  Future<void> _stopPlaying() async {
    await _radioController.stop();
    setState(() {});
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
      theme: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('تطبيق الراديو'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleDarkMode,
            ),
            if (_radioController.isPlaying)
              IconButton(icon: const Icon(Icons.stop), onPressed: _stopPlaying),
          ],
        ),
        body: _buildCurrentScreen(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
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
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light);
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primarySwatch: Colors.blueGrey,
      brightness: Brightness.dark,
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
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          const Text(
            'المحطات الإذاعية',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _stations.length,
              itemBuilder: (context, index) {
                final station = _stations[index];
                final isCurrent =
                    _radioController.currentStationUrl == station.url;

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color:
                      isCurrent
                          ? (_isDarkMode
                              ? Colors.blueGrey[800]
                              : Colors.blue[100])
                          : null,
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
                            color:
                                isCurrent
                                    ? Colors.blueAccent
                                    : (_isDarkMode
                                        ? Colors.white70
                                        : Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            station.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _isDarkMode ? Colors.white : Colors.black,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                                  color: station.isFavorite ? Colors.red : null,
                                ),
                                onPressed: () => _toggleFavorite(station),
                              ),
                              IconButton(
                                icon: Icon(
                                  isCurrent && _radioController.isPlaying
                                      ? Icons.stop
                                      : Icons.play_arrow,
                                  color: isCurrent ? Colors.blueAccent : null,
                                ),
                                onPressed:
                                    () =>
                                        isCurrent && _radioController.isPlaying
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
              },
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
        : Padding(
          padding: const EdgeInsets.all(12.0),
          child: ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final station = favorites[index];
              final isCurrent =
                  _radioController.currentStationUrl == station.url;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                elevation: 2,
                child: ListTile(
                  leading: Icon(
                    Icons.radio,
                    color: isCurrent ? Colors.blueAccent : null,
                  ),
                  title: Text(station.name),
                  subtitle: Text(station.url),
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
          ),
        );
  }

  Widget _buildAboutScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.radio,
              size: 80,
              color: _isDarkMode ? Colors.blueGrey : Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'تطبيق الراديو',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('الإصدار 1.0.0'),
            const SizedBox(height: 20),
            const Text('المطور: محمد داود'),
          ],
        ),
      ),
    );
  }
}
