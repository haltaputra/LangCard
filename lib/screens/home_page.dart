import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'learning_page.dart';

// Widget Top-Level
class WelcomeSection extends StatelessWidget {
  final String userName;

  const WelcomeSection({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4A90E2), Color(0xFF63B3ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF4A90E2).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.2),
            radius: 25,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2);
  }
}

class StatsCards extends StatelessWidget {
  final int totalVocab;
  final int masteredVocab;
  final bool isTablet;

  const StatsCards({
    required this.totalVocab,
    required this.masteredVocab,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Kosakata Saya',
            value: totalVocab,
            colors: [Color(0xFF4A90E2), Color(0xFF63B3ED)],
            icon: Icons.book,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Dikuasai',
            value: masteredVocab,
            colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
            icon: Icons.check_circle,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 700.ms).scaleXY(begin: 0.9);
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int value;
  final List<Color> colors;
  final IconData icon;

  const StatCard({
    required this.title,
    required this.value,
    required this.colors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$value',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onAddVocab;
  final VoidCallback onStartLearning;

  const ActionButtons({
    required this.isTablet,
    required this.onAddVocab,
    required this.onStartLearning,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Aksi Cepat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.add,
                label: 'Tambah\nKosakata',
                isPrimary: true,
                onTap: onAddVocab,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: ActionButton(
                icon: Icons.play_arrow,
                label: 'Mulai\nBelajar',
                isPrimary: false,
                onTap: onStartLearning,
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 800.ms).scaleXY(begin: 0.95);
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;
  final bool isWide;

  const ActionButton({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: isWide ? 16 : 20,
            horizontal: isWide ? 24 : 0,
          ),
          decoration: BoxDecoration(
            color: isPrimary ? Color(0xFF4A90E2) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isPrimary ? null : Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: isPrimary
                    ? Color(0xFF4A90E2).withOpacity(0.3)
                    : Colors.grey.shade100,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? Colors.white.withOpacity(0.2)
                            : Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        icon,
                        color: isPrimary ? Colors.white : Color(0xFF4A90E2),
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      label.replaceAll('\n', ' '),
                      style: TextStyle(
                        color: isPrimary ? Colors.white : Color(0xFF4A90E2),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? Colors.white.withOpacity(0.2)
                            : Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        icon,
                        color: isPrimary ? Colors.white : Color(0xFF4A90E2),
                        size: 28,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : Color(0xFF4A90E2),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class VocabularySection extends StatelessWidget {
  final List<QueryDocumentSnapshot> vocabs;
  final bool isLoading;
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final Function(String, String, String) onDeleteVocab;
  final Function(Map<String, dynamic>) onShowDetails;
  final String filter;
  final User? user;
  final VoidCallback onDeleteAll;

  const VocabularySection({
    required this.vocabs,
    required this.isLoading,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onDeleteVocab,
    required this.onShowDetails,
    required this.filter,
    required this.user,
    required this.onDeleteAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.list_alt,
                      color: Color(0xFF4A90E2),
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Kosakata Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (vocabs.isNotEmpty)
                Row(
                  children: [
                    GestureDetector(
                      onTap: onDeleteAll,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red.shade400,
                          size: 20,
                        ),
                      ).animate().scale(duration: 300.ms),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: onToggleExpand,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ).animate().rotate(
                            duration: 300.ms,
                            begin: 0,
                            end: isExpanded ? 0.5 : 0,
                          ),
                    ),
                  ],
                ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getFilterBadgeColor(filter).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _getFilterLabel(filter),
              style: TextStyle(
                fontSize: 12,
                color: _getFilterBadgeColor(filter),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: isExpanded ? null : 300,
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF4A90E2),
                      ),
                    ),
                  )
                : vocabs.isEmpty
                    ? EmptyState(filter: filter)
                    : VocabList(
                        vocabs: vocabs,
                        onDeleteVocab: onDeleteVocab,
                        onShowDetails: onShowDetails,
                        user: user,
                      ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.3);
  }

  Color _getFilterBadgeColor(String filter) {
    switch (filter) {
      case 'personal':
        return Color(0xFFE67E22); // Orange
      case 'mastered':
        return Color(0xFF2ECC71); // Green
      case 'all':
        return Color(0xFF9B59B6); // Purple
      default:
        return Color(0xFF4A90E2);
    }
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'personal':
        return 'Kosakata Ditambahkan';
      case 'mastered':
        return 'Kosakata Dikuasai';
      case 'all':
        return 'Semua Kosakata';
      default:
        return 'Kosakata Ditambahkan';
    }
  }
}

class EmptyState extends StatelessWidget {
  final String filter;

  const EmptyState({this.filter = 'personal'});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (filter) {
      case 'personal':
        message = 'Belum ada kosakata yang ditambahkan';
        icon = Icons.add_circle_outline;
        break;
      case 'mastered':
        message = 'Belum ada kosakata yang dikuasai';
        icon = Icons.school_outlined;
        break;
      case 'all':
        message = 'Belum ada kosakata yang ditambahkan atau dikuasai';
        icon = Icons.book_outlined;
        break;
      default:
        message = 'Belum ada kosakata yang ditambahkan';
        icon = Icons.add_circle_outline;
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: Colors.grey.shade400),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            filter == 'mastered'
                ? 'Pelajari kosakata untuk menguasainya!'
                : 'Tambahkan kosakata pertama Anda!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}

class VocabList extends StatelessWidget {
  final List<QueryDocumentSnapshot> vocabs;
  final Function(String, String, String) onDeleteVocab;
  final Function(Map<String, dynamic>) onShowDetails;
  final User? user;

  const VocabList({
    required this.vocabs,
    required this.onDeleteVocab,
    required this.onShowDetails,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: vocabs.length > 3
          ? BouncingScrollPhysics()
          : NeverScrollableScrollPhysics(),
      itemCount: vocabs.length,
      itemBuilder: (context, index) {
        final vocab = vocabs[index];
        final data = vocab.data() as Map<String, dynamic>? ?? {};

        return Container(
          margin: EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            elevation: 0,
            child: InkWell(
              onTap: () => onShowDetails({...data, 'id': vocab.id}),
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: data['isMastered'] == true
                            ? Colors.green.withOpacity(0.1)
                            : data['source'] == 'personal'
                                ? Color(0xFFE67E22).withOpacity(0.1)
                                : Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        data['isMastered'] == true
                            ? Icons.check_circle
                            : data['source'] == 'personal'
                                ? Icons.add_circle_outline
                                : Icons.book,
                        color: data['isMastered'] == true
                            ? Colors.green
                            : data['source'] == 'personal'
                                ? Color(0xFFE67E22)
                                : Color(0xFF4A90E2),
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['word'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            data['translation'] ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (data['category'] != null &&
                                  (data['category'] as String).isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4A90E2).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    data['category'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF4A90E2),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (data['source'] == 'personal')
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFE67E22).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Ditambahkan',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFFE67E22),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              if (data['isMastered'] == true)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Dikuasai',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      onPressed: () => onDeleteVocab(
                        vocab.id,
                        data['category'] ?? '',
                        data['language'] ?? 'en',
                      ),
                      icon: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.red.shade400,
                          size: 16,
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ).animate().fadeIn(duration: 200.ms * (index + 1)).scaleXY(begin: 0.95);
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = "Nama Pengguna";
  int _totalVocab = 0;
  int _masteredVocab = 0;
  List<QueryDocumentSnapshot> _vocabs = [];
  bool _isLoading = true;
  bool _isExpanded = false;
  String _vocabFilter = 'personal';

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadUserData();
    _loadVocabs();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {});
        }
      });
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (user == null || !mounted) return;
    try {
      final userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (mounted) {
        setState(() {
          _userName = userDoc.exists
              ? (userDoc.data()?['name'] as String?) ?? user!.displayName ?? 'Nama Pengguna'
              : user!.displayName ?? 'Nama Pengguna';
          if (!userDoc.exists) {
            _firestore.collection('users').doc(user!.uid).set({
              'name': user!.displayName ?? 'Nama Pengguna',
              'email': user!.email ?? '',
              'createdAt': FieldValue.serverTimestamp(),
              'lastActive': FieldValue.serverTimestamp(),
              'points': 0,
            });
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memuat data pengguna: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadVocabs() async {
    if (user == null || !mounted) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      setState(() => _isLoading = true);

      Query<Map<String, dynamic>> baseQuery = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('vocabularies')
          .orderBy('createdAt', descending: true);

      switch (_vocabFilter) {
        case 'personal':
          baseQuery = baseQuery.where('source', isEqualTo: 'personal');
          break;
        case 'mastered':
          baseQuery = baseQuery.where('isMastered', isEqualTo: true);
          break;
        case 'all':
          // Mengambil semua kosakata yang ditambahkan dan dikuasai
          final personalSnapshot = await baseQuery
              .where('source', isEqualTo: 'personal')
              .get();
          final masteredSnapshot = await baseQuery
              .where('isMastered', isEqualTo: true)
              .get();
          final allDocs = <QueryDocumentSnapshot>{...personalSnapshot.docs, ...masteredSnapshot.docs};
          if (mounted) {
            setState(() {
              _vocabs = allDocs.toList()
                ..sort((a, b) {
                  final bCreatedAt = b.data() as Map<String, dynamic>?;
                  final aCreatedAt = a.data() as Map<String, dynamic>?;
                  final bTimestamp = bCreatedAt?['createdAt'] as Timestamp?;
                  final aTimestamp = aCreatedAt?['createdAt'] as Timestamp?;
                  return (bTimestamp ?? Timestamp(0, 0))
                      .compareTo(aTimestamp ?? Timestamp(0, 0));
                });
            });
          }
          break;
        default:
          baseQuery = baseQuery.where('source', isEqualTo: 'personal');
          break;
      }

      if (_vocabFilter != 'all') {
        final vocabSnapshot = await baseQuery.get();
        final masteredSnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .where('isMastered', isEqualTo: true)
            .get();
        final personalSnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .where('source', isEqualTo: 'personal')
            .get();

        if (mounted) {
          setState(() {
            _vocabs = vocabSnapshot.docs;
            _totalVocab = personalSnapshot.size;
            _masteredVocab = masteredSnapshot.size;
            _isLoading = false;
          });
        }
      } else {
        final masteredSnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .where('isMastered', isEqualTo: true)
            .get();
        final personalSnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .where('source', isEqualTo: 'personal')
            .get();

        if (mounted) {
          setState(() {
            _totalVocab = personalSnapshot.size;
            _masteredVocab = masteredSnapshot.size;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        print("Error loading vocabularies: $e");
        String errorMessage = 'Gagal memuat kosa kata: $e';
        if (e.toString().contains('FAILED_PRECONDITION')) {
          errorMessage =
              'Gagal memuat kosa kata: Indeks Firestore belum dibuat. Silakan hubungi admin atau coba lagi nanti.';
        }
        _showSnackBar(errorMessage);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateCategoryCount(
    String category,
    String language,
    bool isAdd,
  ) async {
    if (user == null || category.isEmpty || !mounted) return;
    try {
      final categoryRef = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('categories')
          .doc('${language}_$category');
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(categoryRef);
        if (snapshot.exists) {
          transaction.update(categoryRef, {
            'count': FieldValue.increment(isAdd ? 1 : -1),
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        } else if (isAdd) {
          transaction.set(categoryRef, {
            'name': category,
            'language': language,
            'count': 1,
            'lastUpdated': FieldValue.serverTimestamp(),
          });
        }
      });
    } catch (e) {
      if (mounted) _showSnackBar('Gagal memperbarui kategori: $e');
    }
  }

  Future<void> _deleteAllVocabularies() async {
    if (user == null || !mounted) return;

    bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Konfirmasi'),
            content: Text(
              _vocabFilter == 'personal'
                  ? 'Apakah Anda yakin ingin menghapus semua kosakata yang ditambahkan?'
                  : _vocabFilter == 'mastered'
                      ? 'Apakah Anda yakin ingin menghapus semua kosakata yang dikuasai?'
                      : 'Apakah Anda yakin ingin menghapus semua kosakata yang ditambahkan dan dikuasai?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      setState(() => _isLoading = true);

      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('vocabularies');

      switch (_vocabFilter) {
        case 'personal':
          query = query.where('source', isEqualTo: 'personal');
          break;
        case 'mastered':
          query = query.where('isMastered', isEqualTo: true);
          break;
        case 'all':
          query = query.where('source', isEqualTo: 'personal').where('isMastered', isEqualTo: true);
          break;
        default:
          query = query.where('source', isEqualTo: 'personal');
          break;
      }

      final snapshot = await query.get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (_vocabFilter == 'mastered') {
          await _firestore
              .collection('users')
              .doc(user!.uid)
              .collection('vocabularies')
              .doc(doc.id)
              .update({
                'isMastered': false,
                'masteredAt': null,
              });
        } else {
          await _firestore
              .collection('users')
              .doc(user!.uid)
              .collection('vocabularies')
              .doc(doc.id)
              .delete();
          if (data['category'] != null && data['language'] != null) {
            await _updateCategoryCount(
              data['category'],
              data['language'],
              false,
            );
          }
        }
      }

      if (mounted) {
        await _loadVocabs();
        _showSnackBar(
          _vocabFilter == 'personal'
              ? 'Semua kosakata yang ditambahkan berhasil dihapus!'
              : _vocabFilter == 'mastered'
                  ? 'Semua kosakata yang dikuasai berhasil dihapus!'
                  : 'Semua kosakata yang ditambahkan dan dikuasai berhasil dihapus!',
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error menghapus kosakata: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(body: Center(child: Text('Pengguna tidak login')));
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFF4A90E2).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.dashboard, color: Color(0xFF4A90E2), size: 24),
            ),
            SizedBox(width: 12),
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.menu, color: Colors.black54, size: 22),
            ),
            onPressed: _showFilterMenu,
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF4A90E2)))
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 32 : 20,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WelcomeSection(userName: _userName),
                        SizedBox(height: 24),
                        StatsCards(
                          totalVocab: _totalVocab,
                          masteredVocab: _masteredVocab,
                          isTablet: isTablet,
                        ),
                        SizedBox(height: 24),
                        ActionButtons(
                          isTablet: isTablet,
                          onAddVocab: _showAddVocabDialog,
                          onStartLearning: _startLearning,
                        ),
                        SizedBox(height: 24),
                        VocabularySection(
                          vocabs: _vocabs,
                          isLoading: _isLoading,
                          isExpanded: _isExpanded,
                          onToggleExpand: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          onDeleteVocab: _deleteVocab,
                          onShowDetails: _showVocabDetails,
                          filter: _vocabFilter,
                          user: user,
                          onDeleteAll: _deleteAllVocabularies,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Color(0xFF4A90E2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          elevation: 4,
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

  Future<void> _showAddVocabDialog() async {
    if (user == null || !mounted) return;
    final wordController = TextEditingController();
    final translationController = TextEditingController();
    final categoryController = TextEditingController();
    String selectedLanguage = 'en';

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.add, color: Color(0xFF4A90E2), size: 24),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tambah Kosakata Baru',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 24),
              TextField(
                controller: wordController,
                decoration: InputDecoration(
                  labelText: 'Kata/Kosakata',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4A90E2)),
                  ),
                  prefixIcon: Icon(Icons.text_fields, color: Color(0xFF4A90E2)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: translationController,
                decoration: InputDecoration(
                  labelText: 'Terjemahan (Bahasa Indonesia)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4A90E2)),
                  ),
                  prefixIcon: Icon(Icons.translate, color: Color(0xFF4A90E2)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: InputDecoration(
                  labelText: 'Kategori (Opsional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4A90E2)),
                  ),
                  prefixIcon: Icon(Icons.category, color: Color(0xFF4A90E2)),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedLanguage,
                decoration: InputDecoration(
                  labelText: 'Bahasa Asal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Color(0xFF4A90E2)),
                  ),
                  prefixIcon: Icon(Icons.language, color: Color(0xFF4A90E2)),
                ),
                items: [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'fr', child: Text('French')),
                  DropdownMenuItem(value: 'es', child: Text('Spanish')),
                  DropdownMenuItem(value: 'de', child: Text('German')),
                  DropdownMenuItem(value: 'it', child: Text('Italian')),
                  DropdownMenuItem(value: 'ja', child: Text('Japanese')),
                  DropdownMenuItem(value: 'ko', child: Text('Korean')),
                  DropdownMenuItem(value: 'zh', child: Text('Chinese')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedLanguage = value;
                  }
                },
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (wordController.text.trim().isNotEmpty &&
                            translationController.text.trim().isNotEmpty) {
                          try {
                            final category = categoryController.text.trim();
                            await _firestore
                                .collection('users')
                                .doc(user!.uid)
                                .collection('vocabularies')
                                .add({
                                  'word': wordController.text.trim(),
                                  'translation': translationController.text.trim(),
                                  'category': category,
                                  'language': selectedLanguage,
                                  'translationLanguage': 'id',
                                  'source': 'personal',
                                  'isMastered': false,
                                  'phonetic': '',
                                  'partOfSpeech': '',
                                  'example': '',
                                  'createdAt': FieldValue.serverTimestamp(),
                                  'learningProgress': 0,
                                });
                            await _updateCategoryCount(
                              category,
                              selectedLanguage,
                              true,
                            );
                            if (mounted) {
                              await _loadVocabs();
                              Navigator.pop(context);
                              _showSnackBar('Kosakata berhasil ditambahkan!');
                            }
                          } catch (e) {
                            if (mounted)
                              _showSnackBar('Gagal menambahkan kosakata: $e');
                          }
                        } else {
                          if (mounted)
                            _showSnackBar('Kata dan terjemahan wajib diisi!');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Simpan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteVocab(
    String docId,
    String category,
    String language,
  ) async {
    if (user == null || !mounted) return;
    try {
      final docRef = _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('vocabularies')
          .doc(docId);
      final doc = await docRef.get();
      if (doc.exists && doc.data()!['isMastered'] == true) {
        await docRef.update({
          'isMastered': false,
          'masteredAt': null,
        });
      } else {
        await docRef.delete();
        await _updateCategoryCount(category, language, false);
      }
      if (mounted) {
        await _loadVocabs();
        _showSnackBar('Kosakata berhasil dihapus');
      }
    } catch (e) {
      if (mounted) _showSnackBar('Gagal menghapus kosakata: $e');
    }
  }

  void _showFilterMenu() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'Menu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _buildFilterOption(
              icon: Icons.book,
              title: 'Kosakata Saya',
              description: 'Tampilkan kosakata yang ditambahkan',
              isSelected: _vocabFilter == 'personal',
              color: Color(0xFFE67E22),
              onTap: () {
                if (mounted) {
                  setState(() => _vocabFilter = 'personal');
                  _loadVocabs();
                  Navigator.pop(context);
                }
              },
            ),
            Divider(height: 32),
            _buildFilterOption(
              icon: Icons.check_circle,
              title: 'Dikuasai',
              description: 'Tampilkan kosakata yang dikuasai',
              isSelected: _vocabFilter == 'mastered',
              color: Color(0xFF2ECC71),
              onTap: () {
                if (mounted) {
                  setState(() => _vocabFilter = 'mastered');
                  _loadVocabs();
                  Navigator.pop(context);
                }
              },
            ),
            Divider(height: 32),
            _buildFilterOption(
              icon: Icons.view_list,
              title: 'Semua Kosakata',
              description: 'Tampilkan semua kosakata yang ditambahkan dan dikuasai',
              isSelected: _vocabFilter == 'all',
              color: Color(0xFF9B59B6),
              onTap: () {
                if (mounted) {
                  setState(() => _vocabFilter = 'all');
                  _loadVocabs();
                  Navigator.pop(context);
                }
              },
            ),
            Divider(height: 32),
            _buildFilterOption(
              icon: Icons.logout,
              title: 'Keluar',
              description: 'Keluar dari aplikasi',
              isSelected: false,
              color: Colors.red,
              onTap: () {
                if (mounted) {
                  Navigator.pop(context);
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required IconData icon,
    required String title,
    required String description,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  void _showVocabDetails(Map<String, dynamic> data) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: data['isMastered'] == true
                          ? Colors.green.withOpacity(0.1)
                          : data['source'] == 'personal'
                              ? Color(0xFFE67E22).withOpacity(0.1)
                              : Color(0xFF4A90E2).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      data['isMastered'] == true
                          ? Icons.check_circle
                          : data['source'] == 'personal'
                              ? Icons.add_circle_outline
                              : Icons.book,
                      color: data['isMastered'] == true
                          ? Colors.green
                          : data['source'] == 'personal'
                              ? Color(0xFFE67E22)
                              : Color(0xFF4A90E2),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Detail Kosakata',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Text(
                      data['word'] ?? '',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: data['isMastered'] == true
                            ? Colors.green
                            : data['source'] == 'personal'
                                ? Color(0xFFE67E22)
                                : Color(0xFF4A90E2),
                      ),
                    ),
                    SizedBox(height: 8),
                    if (data['phonetic'] != null &&
                        (data['phonetic'] as String).isNotEmpty)
                      Text(
                        data['phonetic'],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    SizedBox(height: 16),
                    Text(
                      data['translation'] ?? '',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              if (data['example'] != null &&
                  (data['example'] as String).isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Contoh:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        data['example'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (data['category'] != null &&
                      (data['category'] as String).isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF4A90E2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Kategori: ${data['category']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (data['source'] == 'personal')
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFE67E22).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Ditambahkan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFE67E22),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  if (data['isMastered'] == true)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Dikuasai',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  if (!data['isMastered'] && data['id'] != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await _firestore
                                .collection('users')
                                .doc(user!.uid)
                                .collection('vocabularies')
                                .doc(data['id'])
                                .update({
                                  'isMastered': true,
                                  'masteredAt': FieldValue.serverTimestamp(),
                                });
                            Navigator.pop(context);
                            _loadVocabs();
                            _showSnackBar('Kosakata berhasil dikuasai!');
                          } catch (e) {
                            _showSnackBar('Gagal mengubah status: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Tandai Dikuasai'),
                      ),
                    ),
                  if (!data['isMastered'] && data['id'] != null)
                    SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A90E2),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Tutup',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startLearning() {
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LearningPage()),
      );
    }
  }
}