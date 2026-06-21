import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../data/voice_lines.dart';

class VoiceLinesPage extends StatefulWidget {
  const VoiceLinesPage({super.key});

  @override
  State<VoiceLinesPage> createState() => _VoiceLinesPageState();
}

class _VoiceLinesPageState extends State<VoiceLinesPage> {
  final FlutterTts _tts = FlutterTts();

  String? _speakingKey;
  bool _isSpeaking = false;

  List<String> _availableLanguages = const [];

  @override
  void initState() {
    super.initState();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    try {
      final languages = await _tts.getLanguages;

      if (languages is List) {
        _availableLanguages =
            languages.map((language) => language.toString()).toList();
      }
    } catch (_) {
      _availableLanguages = const [];
    }

    _tts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _speakingKey = null;
        _isSpeaking = false;
      });
    });

    _tts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        _speakingKey = null;
        _isSpeaking = false;
      });
    });

    _tts.setErrorHandler((message) {
      if (!mounted) return;
      setState(() {
        _speakingKey = null;
        _isSpeaking = false;
      });
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  bool _isIrish(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ga';
  }

  bool _languageAvailable(String code) {
    return _availableLanguages.any(
      (language) => language.toLowerCase() == code.toLowerCase(),
    );
  }

  String _bestTtsLanguageForCurrentLocale(BuildContext context) {
    final wantsIrish = _isIrish(context);

    if (wantsIrish && _languageAvailable('ga-IE')) {
      return 'ga-IE';
    }

    if (_languageAvailable('en-IE')) {
      return 'en-IE';
    }

    if (_languageAvailable('en-GB')) {
      return 'en-GB';
    }

    if (_languageAvailable('en-US')) {
      return 'en-US';
    }

    return wantsIrish ? 'ga-IE' : 'en-IE';
  }

  bool _willUseIrishVoice(BuildContext context) {
    return _isIrish(context) && _languageAvailable('ga-IE');
  }

  String _text({
    required BuildContext context,
    required String en,
    required String ga,
  }) {
    return _isIrish(context) ? ga : en;
  }

  Future<void> _speakLine(VoiceLine line) async {
    final useIrishPhrase = _isIrish(context);
    final text = useIrishPhrase ? line.spokenGA : line.spokenEN;
    final languageCode = _bestTtsLanguageForCurrentLocale(context);

    if (_isSpeaking) {
      await _tts.stop();
      if (!mounted) return;
    }

    setState(() {
      _speakingKey = line.key;
      _isSpeaking = true;
    });

    try {
      await _tts.setLanguage(languageCode);
      await _tts.speak(text);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _speakingKey = null;
        _isSpeaking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _text(
              context: context,
              en: 'Could not speak this phrase on this device.',
              ga: 'Níorbh fhéidir an frása seo a rá ar an ngléas seo.',
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _stopSpeaking() async {
    await _tts.stop();

    if (!mounted) return;

    setState(() {
      _speakingKey = null;
      _isSpeaking = false;
    });
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7E57C2),
            Color(0xFF26A69A),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E57C2).withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.record_voice_over_rounded,
              color: Colors.white,
              size: 44,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    context: context,
                    en: 'Voice Lines',
                    ga: 'Línte Gutha',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _text(
                    context: context,
                    en: 'Tap a button to say what you need',
                    ga: 'Tapáil cnaipe chun an rud atá uait a rá',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceFallbackNotice(BuildContext context) {
    if (!_isIrish(context)) return const SizedBox.shrink();
    if (_willUseIrishVoice(context)) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFFB300).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_rounded,
            color: Color(0xFFFF8F00),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Níor aimsíodh guth Gaeilge ar an ngléas seo. Úsáidfear guth Béarla mar chúltaca.',
              style: TextStyle(
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNowSpeakingCard(BuildContext context) {
    final currentLine = _speakingKey == null
        ? null
        : voiceLines.where((line) => line.key == _speakingKey).firstOrNull;

    if (currentLine == null) {
      return const SizedBox.shrink();
    }

    final label = _isIrish(context)
        ? currentLine.spokenGA
        : currentLine.spokenEN;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      constraints: const BoxConstraints(maxWidth: 760),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: currentLine.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: currentLine.color.withValues(alpha: 0.32),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: currentLine.color.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: currentLine.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              currentLine.icon,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text(
                    context: context,
                    en: 'Speaking now',
                    ga: 'Á rá anois',
                  ),
                  style: TextStyle(
                    color: currentLine.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            onPressed: _stopSpeaking,
            icon: const Icon(Icons.stop_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceLineCard(BuildContext context, VoiceLine line) {
    final isSpeakingThis = _speakingKey == line.key && _isSpeaking;
    final label = _isIrish(context) ? line.labelGA : line.labelEN;
    final spoken = _isIrish(context) ? line.spokenGA : line.spokenEN;

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () => _speakLine(line),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSpeakingThis
              ? line.color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSpeakingThis
                ? line.color
                : line.color.withValues(alpha: 0.18),
            width: isSpeakingThis ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: line.color.withValues(
                alpha: isSpeakingThis ? 0.20 : 0.08,
              ),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: line.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                line.icon,
                color: line.color,
                size: 42,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: line.color,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: Text(
                  spoken,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                color: line.color,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isSpeakingThis
                        ? Icons.volume_up_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isSpeakingThis
                        ? _text(
                            context: context,
                            en: 'Speaking',
                            ga: 'Á rá',
                          )
                        : _text(
                            context: context,
                            en: 'Say it',
                            ga: 'Abair é',
                          ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
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

  Widget _buildVoiceGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 270,
        mainAxisExtent: 270,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: voiceLines.length,
      itemBuilder: (context, index) {
        return _buildVoiceLineCard(context, voiceLines[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _text(
            context: context,
            en: 'Voice Lines',
            ga: 'Línte Gutha',
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7F2FF),
              Color(0xFFF3FFF5),
              Color(0xFFFFF8E8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                _buildVoiceFallbackNotice(context),
                _buildNowSpeakingCard(context),
                _buildVoiceGrid(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}