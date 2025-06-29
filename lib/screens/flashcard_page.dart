import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:confetti/confetti.dart';
import 'package:flip_card/flip_card.dart';

class EnhancedFlashcardPage extends StatefulWidget {
  final List<Map<String, dynamic>> vocabularies;
  final String language;
  final String category;
  final bool isApiMode;

  const EnhancedFlashcardPage({
    super.key,
    required this.vocabularies,
    required this.language,
    required this.category,
    required this.isApiMode,
  });

  @override
  _EnhancedFlashcardPageState createState() => _EnhancedFlashcardPageState();
}

class _EnhancedFlashcardPageState extends State<EnhancedFlashcardPage>
    with TickerProviderStateMixin {
  late List<Map<String, dynamic>> vocabList;
  int currentIndex = 0;
  bool isLoading = false;
  int correctCount = 0;
  int sessionCount = 0; // Track session count instead of total attempts
  bool _isFlipped = false;
  static const int maxSessions = 10; // Maximum 10 sessions

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _progressController;
  late AnimationController _bounceController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _bounceAnimation;

  late ConfettiController _confettiController;
  late GlobalKey<FlipCardState> _flipCardKey;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    vocabList = List.from(widget.vocabularies);
    _flipCardKey = GlobalKey<FlipCardState>();

    // Initialize animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );

    // Start initial animations
    _slideController.forward();
    _scaleController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _progressController.dispose();
    _bounceController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _animateToNextCard() async {
    // Haptic feedback
    HapticFeedback.lightImpact();

    // Reset flip state
    setState(() {
      _isFlipped = false;
    });

    // Animate out current card
    await _slideController.reverse();
    await _scaleController.reverse();

    // Update state - go to next card or shuffle if at end
    setState(() {
      if (currentIndex < vocabList.length - 1) {
        currentIndex++;
      } else {
        // Reset to beginning and shuffle if needed
        currentIndex = 0;
        vocabList.shuffle();
      }
    });

    // Animate in new card
    _slideController.forward();
    _scaleController.forward();

    // Update progress
    _progressController.reset();
    _progressController.forward();
  }

  Future<void> _markAsMastered(Map<String, dynamic> vocab) async {
    if (user == null) return;

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Bounce animation
    _bounceController.forward().then((_) {
      _bounceController.reset();
    });

    try {
      if (widget.isApiMode) {
        final querySnapshot = await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .where('word', isEqualTo: vocab['word'])
            .where('category', isEqualTo: widget.category)
            .where('source', isEqualTo: 'api')
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(user!.uid)
              .collection('vocabularies')
              .doc(querySnapshot.docs.first.id)
              .update({
                'isMastered': true,
                'masteredAt': FieldValue.serverTimestamp(),
              });
        }
      } else if (vocab['id'] != null) {
        await _firestore
            .collection('users')
            .doc(user!.uid)
            .collection('vocabularies')
            .doc(vocab['id'])
            .update({
              'isMastered': true,
              'masteredAt': FieldValue.serverTimestamp(),
            });
      }

      setState(() {
        correctCount++;
        sessionCount++;
      });

      _confettiController.play();
      _showSnackBar('🎉 Kosakata berhasil dikuasai!', Colors.green);

      // Check if we've completed 10 sessions
      if (sessionCount >= maxSessions) {
        await Future.delayed(const Duration(milliseconds: 1500));
        _showCompletionDialog();
      } else {
        await _animateToNextCard();
      }
    } catch (e) {
      _showSnackBar('❌ Error menandai sebagai dikuasai', Colors.red);
    }
  }

  void _nextCard() async {
    HapticFeedback.selectionClick();

    setState(() {
      sessionCount++;
    });

    // Check if we've completed 10 sessions
    if (sessionCount >= maxSessions) {
      _showCompletionDialog();
    } else {
      await _animateToNextCard();
    }
  }

  void _flipCard() {
    HapticFeedback.selectionClick();
    _flipCardKey.currentState?.toggleCard();
    setState(() {
      _isFlipped = !_isFlipped;
    });

    // Rotate animation for visual feedback
    _rotateController.forward().then((_) {
      _rotateController.reverse();
    });
  }

  void _showCompletionDialog() {
    HapticFeedback.heavyImpact();
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.celebration, size: 80, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  '🎉 Fantastis!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Anda telah menyelesaikan ${maxSessions} sesi pembelajaran!\nKosakata dikuasai: $correctCount kata',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF00BCD4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Kembali',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Beranda',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF00BCD4)),
        ),
      );
    }

    if (vocabList.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCompletionDialog();
      });
      return const SizedBox.shrink();
    }

    final currentVocab = vocabList[currentIndex];
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final cardHeight = cardWidth * 1.1;
    
    // Calculate progress based on sessions (each session = 10%)
    final progress = sessionCount / maxSessions;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00BCD4), Color(0xFF4CAF50)],
            ),
          ),
        ),
        title: Text(
          'Flashcard - ${widget.category.toUpperCase()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${sessionCount + 1} / $maxSessions',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Enhanced Progress Bar
              Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📚 Kata ${sessionCount + 1} dari $maxSessions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00BCD4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: progress * _progressAnimation.value,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00BCD4),
                          ),
                          minHeight: 10,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dikuasai: $correctCount kata',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Enhanced Flashcard
              Expanded(
                child: Center(
                  child: GestureDetector(
                    onTap: _flipCard,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([
                        _slideAnimation,
                        _scaleAnimation,
                        _rotateAnimation,
                        _bounceAnimation,
                      ]),
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value * _bounceAnimation.value,
                          child: Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Container(
                                width: cardWidth,
                                height: cardHeight,
                                child: FlipCard(
                                  key: _flipCardKey,
                                  direction: FlipDirection.HORIZONTAL,
                                  speed: 600,
                                  onFlip: () {
                                    setState(() {
                                      _isFlipped = !_isFlipped;
                                    });
                                  },
                                  front: _buildCardFront(
                                    currentVocab,
                                    cardWidth,
                                    cardHeight,
                                  ),
                                  back: _buildCardBack(
                                    currentVocab,
                                    cardWidth,
                                    cardHeight,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Enhanced Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Flip instruction
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.touch_app,
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isFlipped
                                ? 'Ketuk untuk lihat kata'
                                : 'Ketuk untuk lihat terjemahan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildEnhancedActionButton(
                            icon: Icons.skip_next_outlined,
                            label: 'Lewati',
                            color: Colors.orange,
                            onTap: _nextCard,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildEnhancedActionButton(
                            icon: Icons.check_circle_outline,
                            label: 'Kuasai',
                            color: const Color(0xFF4CAF50),
                            onTap: () => _markAsMastered(currentVocab),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.red,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardFront(
    Map<String, dynamic> vocab,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFF8F9FA)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00BCD4).withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Word
                Text(
                  vocab['word'] ?? '',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD4),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Phonetic
                if (vocab['phonetic']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vocab['phonetic'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Instruction
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.touch_app,
                        size: 18,
                        color: Colors.blue.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Ketuk untuk melihat terjemahan',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(
    Map<String, dynamic> vocab,
    double width,
    double height,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4CAF50), Color(0xFF00BCD4)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Translation
                Text(
                  vocab['translation'] ?? '',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  '(Bahasa Indonesia)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),

                // Example
                if (vocab['example']?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.format_quote,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Contoh:',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vocab['example'],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveToPersonalVocabulary(Map<String, dynamic> vocab) async {
    if (user == null) return;

    HapticFeedback.lightImpact();

    try {
      await _firestore
          .collection('users')
          .doc(user!.uid)
          .collection('vocabularies')
          .add({
            'word': vocab['word'],
            'translation': vocab['translation'],
            'phonetic': vocab['phonetic'] ?? '',
            'partOfSpeech': vocab['partOfSpeech'] ?? '',
            'example': vocab['example'] ?? '',
            'language': widget.language,
            'category': widget.category,
            'source': 'personal',
            'isMastered': false,
            'fromApi': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
      _showSnackBar('📝 Kosakata berhasil disimpan!', const Color(0xFF00BCD4));
    } catch (e) {
      _showSnackBar('❌ Error menyimpan kosakata', Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              message.contains('❌')
                  ? Icons.error_outline
                  : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
