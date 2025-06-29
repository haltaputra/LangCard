import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'flashcard_page.dart';

class LearningPage extends StatefulWidget {
  @override
  _LearningPageState createState() => _LearningPageState();
}

class _LearningPageState extends State<LearningPage>
    with SingleTickerProviderStateMixin {
  String selectedLanguage = 'en'; // Only English
  String selectedCategory = 'Hewan'; // Default category
  String learningMode = 'api'; // 'api' or 'personal'

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  bool isLoading = false;
  List<String> personalCategories = []; // Dynamic categories for personal mode
  bool isLoadingCategories = false;

  // Track shown words per category to avoid repetition
  Map<String, Set<String>> shownWordsPerCategory = {};

  late AnimationController _animationController;

  // Categories for API mode - added 'Acak' (Random) category
  final List<String> manualCategories = [
    'Acak', // New random category
    'Hewan',
    'Makanan',
    'Teknologi',
    'Perjalanan',
    'Alam',
    'Olahraga',
    'Musik',
    'Pekerjaan',
    'Pendidikan',
    'Kesehatan',
  ];

  // Fixed category-specific word lists to ensure relevance
  final Map<String, List<String>> categoryWords = {
    'Hewan': [
      'dog',
      'cat',
      'elephant',
      'tiger',
      'bird',
      'lion',
      'monkey',
      'giraffe',
      'zebra',
      'bear',
      'wolf',
      'fox',
      'deer',
      'rabbit',
      'snake',
      'turtle',
      'fish',
      'shark',
      'dolphin',
      'whale',
      'penguin',
      'eagle',
      'owl',
      'frog',
    ],
    'Makanan': [
      'pizza',
      'sushi',
      'pasta',
      'rice',
      'bread',
      'burger',
      'sandwich',
      'salad',
      'soup',
      'steak',
      'chicken',
      'fish',
      'vegetable',
      'fruit',
      'dessert',
      'cake',
      'cookie',
      'chocolate',
      'ice cream',
      'coffee',
      'tea',
      'juice',
      'water',
      'milk',
    ],
    'Teknologi': [
      'computer',
      'phone',
      'internet',
      'software',
      'app',
      'laptop',
      'tablet',
      'camera',
      'robot',
      'drone',
      'server',
      'network',
      'website',
      'program',
      'algorithm',
      'data',
      'cloud',
      'keyboard',
      'mouse',
      'monitor',
      'printer',
      'speaker',
      'microphone',
      'headphone',
    ],
    'Perjalanan': [
      'plane',
      'hotel',
      'passport',
      'tour',
      'destination',
      'airport',
      'train',
      'bus',
      'taxi',
      'luggage',
      'backpack',
      'map',
      'compass',
      'beach',
      'mountain',
      'forest',
      'city',
      'country',
      'ticket',
      'reservation',
      'vacation',
      'journey',
      'adventure',
      'guide',
    ],
    'Alam': [
      'mountain',
      'river',
      'forest',
      'ocean',
      'tree',
      'flower',
      'grass',
      'sky',
      'cloud',
      'rain',
      'snow',
      'wind',
      'sun',
      'moon',
      'star',
      'planet',
      'earth',
      'volcano',
      'desert',
      'island',
      'beach',
      'lake',
      'waterfall',
      'canyon',
    ],
    'Olahraga': [
      'football',
      'basketball',
      'tennis',
      'swimming',
      'baseball',
      'volleyball',
      'golf',
      'rugby',
      'cricket',
      'hockey',
      'boxing',
      'wrestling',
      'karate',
      'judo',
      'cycling',
      'running',
      'marathon',
      'gymnastics',
      'skiing',
      'snowboarding',
      'surfing',
      'skating',
      'climbing',
      'yoga',
    ],
    'Musik': [
      'guitar',
      'piano',
      'drum',
      'singing',
      'song',
      'concert',
      'band',
      'orchestra',
      'violin',
      'flute',
      'trumpet',
      'saxophone',
      'bass',
      'rhythm',
      'melody',
      'harmony',
      'lyrics',
      'album',
      'artist',
      'composer',
      'conductor',
      'audience',
      'stage',
      'performance',
    ],
    'Pekerjaan': [
      'teacher',
      'doctor',
      'engineer',
      'programmer',
      'chef',
      'artist',
      'writer',
      'musician',
      'lawyer',
      'nurse',
      'scientist',
      'driver',
      'pilot',
      'farmer',
      'designer',
      'manager',
      'accountant',
      'journalist',
      'photographer',
      'architect',
      'mechanic',
      'electrician',
      'plumber',
      'carpenter',
    ],
    'Pendidikan': [
      'school',
      'university',
      'student',
      'teacher',
      'book',
      'library',
      'classroom',
      'homework',
      'exam',
      'test',
      'grade',
      'subject',
      'mathematics',
      'science',
      'history',
      'geography',
      'language',
      'literature',
      'research',
      'study',
      'lecture',
      'diploma',
      'degree',
      'education',
    ],
    'Kesehatan': [
      'hospital',
      'doctor',
      'nurse',
      'medicine',
      'patient',
      'health',
      'disease',
      'treatment',
      'symptom',
      'diagnosis',
      'therapy',
      'surgery',
      'vaccine',
      'vitamin',
      'exercise',
      'diet',
      'nutrition',
      'wellness',
      'fitness',
      'recovery',
      'checkup',
      'prescription',
      'pharmacy',
      'ambulance',
    ],
  };

  // Comprehensive English to Indonesian translations for all category words
  final Map<String, String> wordTranslations = {
    // Hewan (Animals)
    'dog': 'anjing',
    'cat': 'kucing',
    'elephant': 'gajah',
    'tiger': 'harimau',
    'bird': 'burung',
    'lion': 'singa',
    'monkey': 'monyet',
    'giraffe': 'jerapah',
    'zebra': 'zebra',
    'bear': 'beruang',
    'wolf': 'serigala',
    'fox': 'rubah',
    'deer': 'rusa',
    'rabbit': 'kelinci',
    'snake': 'ular',
    'turtle': 'kura-kura',
    'fish': 'ikan',
    'shark': 'hiu',
    'dolphin': 'lumba-lumba',
    'whale': 'paus',
    'penguin': 'penguin',
    'eagle': 'elang',
    'owl': 'burung hantu',
    'frog': 'katak',

    // Makanan (Food)
    'pizza': 'pizza',
    'sushi': 'sushi',
    'pasta': 'pasta',
    'rice': 'nasi',
    'bread': 'roti',
    'burger': 'burger',
    'sandwich': 'sandwich',
    'salad': 'salad',
    'soup': 'sup',
    'steak': 'steak',
    'chicken': 'ayam',
    'vegetable': 'sayuran',
    'fruit': 'buah',
    'dessert': 'makanan penutup',
    'cake': 'kue',
    'cookie': 'kue kering',
    'chocolate': 'cokelat',
    'ice cream': 'es krim',
    'coffee': 'kopi',
    'tea': 'teh',
    'juice': 'jus',
    'water': 'air',
    'milk': 'susu',

    // Teknologi (Technology)
    'computer': 'komputer',
    'phone': 'telepon',
    'internet': 'internet',
    'software': 'perangkat lunak',
    'app': 'aplikasi',
    'laptop': 'laptop',
    'tablet': 'tablet',
    'camera': 'kamera',
    'robot': 'robot',
    'drone': 'drone',
    'server': 'server',
    'network': 'jaringan',
    'website': 'situs web',
    'program': 'program',
    'algorithm': 'algoritma',
    'data': 'data',
    'cloud': 'awan',
    'keyboard': 'keyboard',
    'mouse': 'mouse',
    'monitor': 'monitor',
    'printer': 'printer',
    'speaker': 'speaker',
    'microphone': 'mikrofon',
    'headphone': 'headphone',

    // Perjalanan (Travel)
    'plane': 'pesawat',
    'hotel': 'hotel',
    'passport': 'paspor',
    'tour': 'tur',
    'destination': 'tujuan',
    'airport': 'bandara',
    'train': 'kereta',
    'bus': 'bus',
    'taxi': 'taksi',
    'luggage': 'koper',
    'backpack': 'ransel',
    'map': 'peta',
    'compass': 'kompas',
    'beach': 'pantai',
    'mountain': 'gunung',
    'forest': 'hutan',
    'city': 'kota',
    'country': 'negara',
    'ticket': 'tiket',
    'reservation': 'reservasi',
    'vacation': 'liburan',
    'journey': 'perjalanan',
    'adventure': 'petualangan',
    'guide': 'pemandu',

    // Alam (Nature)
    'river': 'sungai',
    'ocean': 'lautan',
    'tree': 'pohon',
    'flower': 'bunga',
    'grass': 'rumput',
    'sky': 'langit',
    'cloud': 'awan',
    'rain': 'hujan',
    'snow': 'salju',
    'wind': 'angin',
    'sun': 'matahari',
    'moon': 'bulan',
    'star': 'bintang',
    'planet': 'planet',
    'earth': 'bumi',
    'volcano': 'gunung berapi',
    'desert': 'gurun',
    'island': 'pulau',
    'lake': 'danau',
    'waterfall': 'air terjun',
    'canyon': 'ngarai',

    // Olahraga (Sports)
    'football': 'sepak bola',
    'basketball': 'bola basket',
    'tennis': 'tenis',
    'swimming': 'berenang',
    'baseball': 'bisbol',
    'volleyball': 'bola voli',
    'golf': 'golf',
    'rugby': 'rugby',
    'cricket': 'kriket',
    'hockey': 'hoki',
    'boxing': 'tinju',
    'wrestling': 'gulat',
    'karate': 'karate',
    'judo': 'judo',
    'cycling': 'bersepeda',
    'running': 'berlari',
    'marathon': 'maraton',
    'gymnastics': 'senam',
    'skiing': 'ski',
    'snowboarding': 'snowboarding',
    'surfing': 'selancar',
    'skating': 'seluncur',
    'climbing': 'panjat',
    'yoga': 'yoga',

    // Musik (Music)
    'guitar': 'gitar',
    'piano': 'piano',
    'drum': 'drum',
    'singing': 'bernyanyi',
    'song': 'lagu',
    'concert': 'konser',
    'band': 'band',
    'orchestra': 'orkestra',
    'violin': 'biola',
    'flute': 'seruling',
    'trumpet': 'terompet',
    'saxophone': 'saksofon',
    'bass': 'bass',
    'rhythm': 'ritme',
    'melody': 'melodi',
    'harmony': 'harmoni',
    'lyrics': 'lirik',
    'album': 'album',
    'artist': 'artis',
    'composer': 'komposer',
    'conductor': 'konduktor',
    'audience': 'penonton',
    'stage': 'panggung',
    'performance': 'pertunjukan',

    // Pekerjaan (Jobs)
    'teacher': 'guru',
    'doctor': 'dokter',
    'engineer': 'insinyur',
    'programmer': 'programmer',
    'chef': 'koki',
    'artist': 'seniman',
    'writer': 'penulis',
    'musician': 'musisi',
    'lawyer': 'pengacara',
    'nurse': 'perawat',
    'scientist': 'ilmuwan',
    'driver': 'pengemudi',
    'pilot': 'pilot',
    'farmer': 'petani',
    'designer': 'desainer',
    'manager': 'manajer',
    'accountant': 'akuntan',
    'journalist': 'jurnalis',
    'photographer': 'fotografer',
    'architect': 'arsitek',
    'mechanic': 'mekanik',
    'electrician': 'tukang listrik',
    'plumber': 'tukang ledeng',
    'carpenter': 'tukang kayu',

    // Pendidikan (Education)
    'school': 'sekolah',
    'university': 'universitas',
    'student': 'siswa',
    'book': 'buku',
    'library': 'perpustakaan',
    'classroom': 'ruang kelas',
    'homework': 'pekerjaan rumah',
    'exam': 'ujian',
    'test': 'tes',
    'grade': 'nilai',
    'subject': 'mata pelajaran',
    'mathematics': 'matematika',
    'science': 'ilmu pengetahuan',
    'history': 'sejarah',
    'geography': 'geografi',
    'language': 'bahasa',
    'literature': 'sastra',
    'research': 'penelitian',
    'study': 'belajar',
    'lecture': 'kuliah',
    'diploma': 'diploma',
    'degree': 'gelar',
    'education': 'pendidikan',

    // Kesehatan (Health)
    'hospital': 'rumah sakit',
    'medicine': 'obat',
    'patient': 'pasien',
    'health': 'kesehatan',
    'disease': 'penyakit',
    'treatment': 'pengobatan',
    'symptom': 'gejala',
    'diagnosis': 'diagnosis',
    'therapy': 'terapi',
    'surgery': 'operasi',
    'vaccine': 'vaksin',
    'vitamin': 'vitamin',
    'exercise': 'olahraga',
    'diet': 'diet',
    'nutrition': 'nutrisi',
    'wellness': 'kesejahteraan',
    'fitness': 'kebugaran',
    'recovery': 'pemulihan',
    'checkup': 'pemeriksaan',
    'prescription': 'resep',
    'pharmacy': 'apotek',
    'ambulance': 'ambulans',

    // Common words that might appear in random selection
    'time': 'waktu',
    'day': 'hari',
    'night': 'malam',
    'year': 'tahun',
    'month': 'bulan',
    'week': 'minggu',
    'hour': 'jam',
    'minute': 'menit',
    'second': 'detik',
    'home': 'rumah',
    'work': 'kerja',
    'play': 'bermain',
    'eat': 'makan',
    'drink': 'minum',
    'sleep': 'tidur',
    'walk': 'jalan',
    'run': 'lari',
    'talk': 'bicara',
    'listen': 'mendengarkan',
    'read': 'membaca',
    'write': 'menulis',
    'watch': 'menonton',
    'see': 'melihat',
    'hear': 'mendengar',
    'feel': 'merasa',
    'think': 'berpikir',
    'know': 'tahu',
    'learn': 'belajar',
    'understand': 'mengerti',
    'remember': 'ingat',
    'forget': 'lupa',
    'love': 'cinta',
    'hate': 'benci',
    'happy': 'senang',
    'sad': 'sedih',
    'angry': 'marah',
    'afraid': 'takut',
    'big': 'besar',
    'small': 'kecil',
    'long': 'panjang',
    'short': 'pendek',
    'tall': 'tinggi',
    'low': 'rendah',
    'high': 'tinggi',
    'hot': 'panas',
    'cold': 'dingin',
    'warm': 'hangat',
    'cool': 'sejuk',
    'new': 'baru',
    'old': 'lama',
    'young': 'muda',
    'good': 'baik',
    'bad': 'buruk',
    'right': 'benar',
    'wrong': 'salah',
    'true': 'benar',
    'false': 'salah',
    'easy': 'mudah',
    'hard': 'sulit',
    'simple': 'sederhana',
    'complex': 'kompleks',
    'fast': 'cepat',
    'slow': 'lambat',
    'early': 'awal',
    'late': 'terlambat',
    'open': 'buka',
    'close': 'tutup',
    'start': 'mulai',
    'end': 'selesai',
    'begin': 'mulai',
    'finish': 'selesai',
    'stop': 'berhenti',
    'continue': 'lanjutkan',
    'help': 'bantuan',
    'friend': 'teman',
    'family': 'keluarga',
    'parent': 'orang tua',
    'child': 'anak',
    'baby': 'bayi',
    'man': 'pria',
    'woman': 'wanita',
    'boy': 'anak laki-laki',
    'girl': 'anak perempuan',
    'person': 'orang',
    'people': 'orang-orang',
    'world': 'dunia',
    'country': 'negara',
    'city': 'kota',
    'street': 'jalan',
    'house': 'rumah',
    'building': 'gedung',
    'room': 'ruangan',
    'door': 'pintu',
    'window': 'jendela',
    'wall': 'dinding',
    'floor': 'lantai',
    'ceiling': 'langit-langit',
    'roof': 'atap',
    'table': 'meja',
    'chair': 'kursi',
    'bed': 'tempat tidur',
    'desk': 'meja',
    'car': 'mobil',
    'bicycle': 'sepeda',
    'boat': 'perahu',
    'ship': 'kapal',
    'road': 'jalan',
    'path': 'jalur',
    'bridge': 'jembatan',
    'sea': 'laut',
    'land': 'tanah',
    'ground': 'tanah',
    'field': 'lapangan',
    'garden': 'kebun',
    'park': 'taman',
    'jungle': 'hutan rimba',
    'hill': 'bukit',
    'valley': 'lembah',
    'cave': 'gua',
    'coast': 'pantai',
    'shore': 'tepi pantai',
    'storm': 'badai',
    'thunder': 'guntur',
    'lightning': 'petir',
    'rainbow': 'pelangi',
    'light': 'cahaya',
    'dark': 'gelap',
    'morning': 'pagi',
    'afternoon': 'siang',
    'evening': 'sore',
    'today': 'hari ini',
    'tomorrow': 'besok',
    'yesterday': 'kemarin',
    'watch': 'jam tangan',
    'clock': 'jam',
    'calendar': 'kalender',
    'date': 'tanggal',
    'birthday': 'ulang tahun',
    'holiday': 'liburan',
    'weekend': 'akhir pekan',
    'money': 'uang',
    'coin': 'koin',
    'bill': 'tagihan',
    'bank': 'bank',
    'store': 'toko',
    'shop': 'toko',
    'market': 'pasar',
    'mall': 'mal',
    'restaurant': 'restoran',
    'cafe': 'kafe',
    'bar': 'bar',
    'station': 'stasiun',
    'ship': 'kapal',
    'bag': 'tas',
    'clothes': 'pakaian',
    'shirt': 'kemeja',
    'pants': 'celana',
    'dress': 'gaun',
    'shoe': 'sepatu',
    'hat': 'topi',
    'coat': 'mantel',
    'jacket': 'jaket',
    'sock': 'kaus kaki',
    'glove': 'sarung tangan',
    'scarf': 'syal',
    'umbrella': 'payung',
    'glasses': 'kacamata',
    'jewelry': 'perhiasan',
    'ring': 'cincin',
    'necklace': 'kalung',
    'bracelet': 'gelang',
    'earring': 'anting',
    'food': 'makanan',
    'meal': 'makanan',
    'breakfast': 'sarapan',
    'lunch': 'makan siang',
    'dinner': 'makan malam',
    'snack': 'camilan',
    'meat': 'daging',
    'bread': 'roti',
    'hamburger': 'hamburger',
    'candy': 'permen',
    'beer': 'bir',
    'wine': 'anggur',
    'salt': 'garam',
    'pepper': 'merica',
    'sugar': 'gula',
    'oil': 'minyak',
    'butter': 'mentega',
    'cheese': 'keju',
    'egg': 'telur',
    'apple': 'apel',
    'banana': 'pisang',
    'orange': 'jeruk',
    'grape': 'anggur',
    'strawberry': 'stroberi',
    'lemon': 'lemon',
    'potato': 'kentang',
    'tomato': 'tomat',
    'carrot': 'wortel',
    'onion': 'bawang',
    'garlic': 'bawang putih',
    'beef': 'daging sapi',
    'pork': 'daging babi',
    'lamb': 'daging domba',
    'sausage': 'sosis',
    'bacon': 'daging asap',
    'shrimp': 'udang',
    'crab': 'kepiting',
    'lobster': 'lobster',
    'oyster': 'tiram',
    'clam': 'kerang',
    'mussel': 'kerang',
    'squid': 'cumi-cumi',
    'octopus': 'gurita',
  };

  // API endpoints
  static const String dictionaryApiUrl =
      'https://api.dictionaryapi.dev/api/v2/entries/';
  static const String randomWordApiUrl =
    'https://random-word-api.herokuapp.com/word?number=10&lang=en';

  @override
  void initState() {
    super.initState();
    _loadPersonalCategories(); // Load personal categories on initialization
    _loadShownWords(); // Load previously shown words
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Load previously shown words from Firestore
  Future<void> _loadShownWords() async {
    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('learning_data')
          .doc('shown_words')
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          shownWordsPerCategory = {};
          data.forEach((category, words) {
            if (words is List) {
              shownWordsPerCategory[category] = Set<String>.from(words);
            }
          });
        }
      }
    } catch (e) {
      print('Error loading shown words: $e');
    }
  }

  // Save shown words to Firestore
  Future<void> _saveShownWords(String category, List<String> newWords) async {
    if (user == null) return;

    try {
      // Add new words to the tracking set
      if (!shownWordsPerCategory.containsKey(category)) {
        shownWordsPerCategory[category] = {};
      }
      shownWordsPerCategory[category]!.addAll(newWords);

      // Convert sets to lists for Firestore
      Map<String, List<String>> dataToSave = {};
      shownWordsPerCategory.forEach((key, value) {
        dataToSave[key] = value.toList();
      });

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('learning_data')
          .doc('shown_words')
          .set(dataToSave);
    } catch (e) {
      print('Error saving shown words: $e');
    }
  }

  // Method to load categories from user's vocabulary collection
  Future<void> _loadPersonalCategories() async {
    if (user == null) return;

    setState(() => isLoadingCategories = true);

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('vocabularies')
          .where('language', isEqualTo: selectedLanguage)
          .where('source', isEqualTo: 'personal')
          .get();

      Set<String> categories = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['category'] != null &&
            data['category'].toString().isNotEmpty) {
          categories.add(data['category'].toString());
        }
      }

      setState(() {
        personalCategories = categories.toList()..sort();
        // Reset selectedCategory if not in personal categories
        if (learningMode == 'personal' &&
            personalCategories.isNotEmpty &&
            !personalCategories.contains(selectedCategory)) {
          selectedCategory = personalCategories.first;
        }
      });
    } catch (e) {
      print('Error loading personal categories: $e');
      setState(() => personalCategories = []);
    } finally {
      setState(() => isLoadingCategories = false);
    }
  }

  // Fetch random words from API
  Future<List<String>> _fetchRandomWords() async {
  try {
    final response = await http.get(Uri.parse(randomWordApiUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      if (data.isNotEmpty) {
        Set<String> uniqueWords = data.cast<String>().toSet();
        while (uniqueWords.length < 10 && uniqueWords.length < wordTranslations.length) {
          uniqueWords.addAll(_getRandomWordsFromAllCategories().take(10 - uniqueWords.length));
        }
        return uniqueWords.take(10).toList();
      }
    }
    return _getRandomWordsFromAllCategories();
  } catch (e) {
    print('Error fetching random words: $e');
    return _getRandomWordsFromAllCategories();
  }
}

  // Get random words from all categories as fallback
  List<String> _getRandomWordsFromAllCategories() {
  List<String> allWords = [];
  categoryWords.forEach((_, words) => allWords.addAll(words));
  Set<String> shownWords = shownWordsPerCategory['Acak'] ?? {};
  List<String> availableWords = allWords.where((word) => !shownWords.contains(word)).toList();
  if (availableWords.length < 10) {
    shownWordsPerCategory['Acak'] = {};
    availableWords = List.from(allWords);
  }
  availableWords.shuffle();
  return availableWords.take(10).toList();
}

  // More reliable translation method using multiple approaches
  Future<String> _translateWordToIndonesian(String word) async {
    // 1. First check our dictionary for translation
    String? translation = wordTranslations[word.toLowerCase()];
    if (translation != null && translation.isNotEmpty) {
      return translation;
    }

    // 2. Try using our expanded dictionary with common words
    for (var entry in wordTranslations.entries) {
      if (word.toLowerCase() == entry.key.toLowerCase()) {
        return entry.value;
      }
    }

    // 3. Try using a simple rule-based translation for common word patterns
    String simplifiedTranslation = _applySimpleTranslationRules(word);
    if (simplifiedTranslation != word) {
      return simplifiedTranslation;
    }

    // 4. Last resort - use the original word if all else fails
    return word;
  }

  // Apply simple translation rules for common English word patterns
  String _applySimpleTranslationRules(String word) {
    // This is a very simplified approach and won't work for many words
    // but can help with some common patterns when APIs fail

    String lowerWord = word.toLowerCase();

    // Common suffixes
    if (lowerWord.endsWith('tion')) {
      return lowerWord.substring(0, lowerWord.length - 4) + 'si';
    }
    if (lowerWord.endsWith('sion')) {
      return lowerWord.substring(0, lowerWord.length - 4) + 'si';
    }
    if (lowerWord.endsWith('ment')) {
      return lowerWord.substring(0, lowerWord.length - 4) + 'men';
    }
    if (lowerWord.endsWith('ity')) {
      return lowerWord.substring(0, lowerWord.length - 3) + 'itas';
    }
    if (lowerWord.endsWith('ness')) {
      return 'ke' + lowerWord.substring(0, lowerWord.length - 4) + 'an';
    }

    // No pattern matched
    return word;
  }

  // Batch translate multiple words at once for efficiency
  Future<Map<String, String>> _batchTranslateWords(List<String> words) async {
    Map<String, String> translations = {};

    // First check our dictionary for all words
    for (String word in words) {
      String? translation = wordTranslations[word.toLowerCase()];
      if (translation != null && translation.isNotEmpty) {
        translations[word] = translation;
      }
    }

    // For words not found in dictionary, try to translate them
    List<String> wordsToTranslate = words
        .where((word) => !translations.containsKey(word))
        .toList();

    if (wordsToTranslate.isEmpty) {
      return translations; // All words were found in dictionary
    }

    // Try to translate remaining words individually
    for (String word in wordsToTranslate) {
      String translation = await _translateWordToIndonesian(word);
      translations[word] = translation;
    }

    return translations;
  }

  // Start API learning mode with category-specific words
  Future<void> _startAPILearning() async {
    if (selectedCategory.isEmpty) {
      _showSnackBar('Pilih kategori terlebih dahulu');
      return;
    }

    setState(() => isLoading = true);

    try {
      List<String> sampleWords = selectedCategory == 'Acak'
    ? await _fetchRandomWords()
    : await _fetchCategoryWords(selectedCategory);

      if (sampleWords.isEmpty) {
        _showSnackBar(
          'Tidak dapat menemukan kata untuk kategori ini. Coba lagi.',
        );
        setState(() => isLoading = false);
        return;
      }

      List<Map<String, dynamic>> vocabularies = [];

      // Save the new words to the shown words list
      await _saveShownWords(selectedCategory, sampleWords);

      // Pre-translate all words in batch for efficiency
      Map<String, String> translations = await _batchTranslateWords(
        sampleWords,
      );

      for (String word in sampleWords) {
        // Use pre-translated word if available
        String translation =
            translations[word] ?? await _translateWordToIndonesian(word);

        final url = Uri.parse('$dictionaryApiUrl$selectedLanguage/$word');
        final response = await http.get(url);

        String phonetic = '';
        String partOfSpeech = '';
        String example = '';

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data is List && data.isNotEmpty) {
            final entry = data[0];
            if (entry['meanings']?.isNotEmpty ?? false) {
              final meaning = entry['meanings'][0];
              if (meaning['definitions']?.isNotEmpty ?? false) {
                final def = meaning['definitions'][0];
                example = def['example'] ?? '';
              }
              partOfSpeech = meaning['partOfSpeech'] ?? '';
            }
            phonetic =
                entry['phonetic'] ??
                (entry['phonetics']?.firstWhere(
                      (p) => p['text'] != null,
                      orElse: () => {},
                    )['text'] ??
                    '');
          }
        }

        final vocabDoc = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .add({
              'word': word,
              'translation': translation,
              'phonetic': phonetic,
              'partOfSpeech': partOfSpeech,
              'example': example,
              'language': selectedLanguage,
              'category': selectedCategory,
              'source': 'api',
              'isMastered': false,
              'createdAt': FieldValue.serverTimestamp(),
            });

        vocabularies.add({
          'id': vocabDoc.id,
          'word': word,
          'translation': translation,
          'phonetic': phonetic,
          'partOfSpeech': partOfSpeech,
          'example': example,
          'language': selectedLanguage,
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnhancedFlashcardPage(
            vocabularies: vocabularies,
            language: selectedLanguage,
            category: selectedCategory,
            isApiMode: true,
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Get words for a specific category, ensuring they match the category
  Future<List<String>> _fetchCategoryWords(String category) async {
  List<String> allWords = categoryWords[category] ?? [];
  Set<String> shown = shownWordsPerCategory[category] ?? {};
  List<String> notShownYet = allWords.where((word) => !shown.contains(word)).toList();
  if (notShownYet.length >= 10) {
    notShownYet.shuffle();
    return notShownYet.take(10).toList();
  }
  if (notShownYet.length < 10) {
    if (shown.length >= allWords.length) {
      shownWordsPerCategory[category] = {};
      allWords.shuffle();
      return allWords.take(10).toList();
    } else {
      List<String> result = List.from(notShownYet);
      List<String> shownList = shown.toList()..shuffle();
      result.addAll(shownList.take(10 - notShownYet.length));
      return result;
    }
  }
  allWords.shuffle();
  return allWords.take(10).toList();
}

  Future<void> _startPersonalLearning() async {
    if (selectedCategory.isEmpty) {
      _showSnackBar('Pilih kategori terlebih dahulu');
      return;
    }

    setState(() => isLoading = true);

    try {
      // Get all non-mastered vocabulary for this category
      final snapshot = await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('vocabularies')
          .where('language', isEqualTo: selectedLanguage)
          .where('category', isEqualTo: selectedCategory)
          .where('source', isEqualTo: 'personal')
          .where('isMastered', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        _showSnackBar('Tidak ada kosakata personal untuk kategori ini');
        setState(() => isLoading = false);
        return;
      }

      // Convert to list and shuffle to get random order
      List<QueryDocumentSnapshot> allDocs = snapshot.docs.toList();
      allDocs.shuffle();

      // Take up to 10 random items
      List<QueryDocumentSnapshot> selectedDocs = allDocs.length > 10 ? allDocs.sublist(0, 10) : allDocs;

      List<Map<String, dynamic>> vocabularies = selectedDocs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'word': data['word'],
          'translation': data['translation'],
          'phonetic': data['phonetic'] ?? '',
          'partOfSpeech': data['partOfSpeech'] ?? '',
          'example': data['example'] ?? '',
          'language': data['language'],
          'category': data['category'],
          'source': data['source'],
          'isMastered': data['isMastered'],
        };
      }).toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EnhancedFlashcardPage(
            vocabularies: vocabularies,
            language: selectedLanguage,
            category: selectedCategory,
            isApiMode: false,
          ),
        ),
      );
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mulai Belajar',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Mode Pembelajaran',
              child: Row(
                children: [
                  Expanded(
                    child: _buildModeCard(
                      title: 'Kosakata Baru',
                      subtitle: 'Otomatis dari API',
                      icon: Icons.public,
                      isSelected: learningMode == 'api',
                      onTap: () {
                        setState(() {
                          learningMode = 'api';
                          selectedCategory =
                              'Acak'; // Default to random category
                        });
                        _animationController.forward(from: 0.0);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModeCard(
                      title: 'Kosakata Saya',
                      subtitle: 'Yang sudah ditambahkan',
                      icon: Icons.library_books,
                      isSelected: learningMode == 'personal',
                      onTap: () {
                        setState(() {
                          learningMode = 'personal';
                        });
                        _loadPersonalCategories(); // Reload personal categories
                        _animationController.forward(from: 0.0);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Bahasa',
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'English',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Pilih Kategori',
              child: learningMode == 'api'
                  ? _buildCategoryDropdown()
                  : _buildPersonalCategoryDropdown(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (learningMode == 'api') {
                          _startAPILearning();
                        } else {
                          if (personalCategories.isEmpty) {
                            _showSnackBar(
                              'Belum ada kosakata personal yang ditambahkan',
                            );
                            return;
                          }
                          _startPersonalLearning();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Mulai Belajar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  title == 'Mode Pembelajaran'
                      ? Icons.school
                      : title == 'Bahasa'
                      ? Icons.language
                      : Icons.category,
                  color: const Color(0xFF4A90E2),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4A90E2).withOpacity(0.1)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A90E2).withOpacity(0.2)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: isSelected
                    ? const Color(0xFF4A90E2)
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF4A90E2) : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFF4A90E2).withOpacity(0.8)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: manualCategories.contains(selectedCategory)
            ? selectedCategory
            : null,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: 'Pilih kategori',
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A90E2)),
        items: manualCategories.map((category) {
          IconData categoryIcon;
          switch (category) {
            case 'Acak':
              categoryIcon = Icons.shuffle;
              break;
            case 'Hewan':
              categoryIcon = Icons.pets;
              break;
            case 'Makanan':
              categoryIcon = Icons.restaurant;
              break;
            case 'Teknologi':
              categoryIcon = Icons.computer;
              break;
            case 'Perjalanan':
              categoryIcon = Icons.flight;
              break;
            case 'Alam':
              categoryIcon = Icons.eco;
              break;
            case 'Olahraga':
              categoryIcon = Icons.sports_soccer;
              break;
            case 'Musik':
              categoryIcon = Icons.music_note;
              break;
            case 'Pekerjaan':
              categoryIcon = Icons.work;
              break;
            case 'Pendidikan':
              categoryIcon = Icons.school;
              break;
            case 'Kesehatan':
              categoryIcon = Icons.health_and_safety;
              break;
            default:
              categoryIcon = Icons.category;
          }

          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 16,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(category),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
          });
        },
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
    );
  }

  Widget _buildPersonalCategoryDropdown() {
    if (isLoadingCategories) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
            ),
          ),
        ),
      );
    }

    if (personalCategories.isEmpty) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey.shade500, size: 20),
            const SizedBox(width: 12),
            const Text(
              'Belum ada kategori kosakata personal',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonFormField<String>(
        value: personalCategories.contains(selectedCategory)
            ? selectedCategory
            : personalCategories.first,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintText: 'Pilih kategori',
          hintStyle: TextStyle(color: Colors.grey.shade500),
        ),
        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF4A90E2)),
        items: personalCategories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.bookmark,
                    size: 16,
                    color: const Color(0xFF4A90E2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(category),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
          });
        },
        dropdownColor: Colors.white,
        style: const TextStyle(color: Colors.black87, fontSize: 16),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF4A90E2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
