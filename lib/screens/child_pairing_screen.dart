import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kokodayo/simple_provider.dart';

import '../app_state.dart';
import '../models/device.dart';

/// Child device pairing flow.
class ChildPairingScreen extends StatefulWidget {
  const ChildPairingScreen({super.key});

  @override
  State<ChildPairingScreen> createState() => _ChildPairingScreenState();
}

class _ChildPairingScreenState extends State<ChildPairingScreen>
    with TickerProviderStateMixin {
  // Code input state
  final List<String> _codeDigits = ['', '', '', '', '', ''];
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  String _errorMessage = '';
  bool _isVerifying = false;

  // Nickname state
  bool _showNicknameScreen = false;
  final TextEditingController _nicknameController =
      TextEditingController(text: '娘のスマホ');

  // Animations
  late AnimationController _slideController;
  late AnimationController _shakeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  String get _enteredCode => _codeDigits.join('');
  bool get _isCodeComplete =>
      _enteredCode.length == 6 && !_enteredCode.contains('');

  @override
  void initState() {
    super.initState();

    _slideController =
        AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _shakeController =
        AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _slideAnimation = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeInOut));
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn));
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    for (final controller in _controllers) {
      controller.dispose();
    }
    _nicknameController.dispose();
    _slideController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body:
          _showNicknameScreen ? _buildNicknameScreen() : _buildCodeInputScreen(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF4C51BF),
            size: 20,
          ),
        ),
        onPressed: () {
          if (_showNicknameScreen) {
            setState(() => _showNicknameScreen = false);
          } else {
            Navigator.pop(context);
          }
        },
      ),
      title: Text(
        _showNicknameScreen ? 'ニックネーム設定' : 'ペアリング',
        style: const TextStyle(
          color: Color(0xFF2D3748),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCodeInputScreen() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildInstructionSection(),
          const SizedBox(height: 40),
          _buildCodeInputSection(),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildErrorMessage(),
          ],
          const Spacer(),
          _buildNextButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInstructionSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.pink.shade50, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.smartphone, size: 28, color: Colors.pink),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '親の画面に表示された\n6桁コードを入力してください',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeInputSection() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value * 10 * (_errorMessage.isNotEmpty ? 1 : 0), 0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (i) => _buildCodeInput(i)),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    6,
                    (i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _codeDigits[i].isNotEmpty
                            ? Colors.green.shade400
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCodeInput(int index) {
    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: _codeDigits[index].isNotEmpty
            ? Colors.blue.shade50
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _codeDigits[index].isNotEmpty
              ? Colors.blue.shade300
              : Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFF2D3748),
        ),
        decoration: const InputDecoration(border: InputBorder.none, counterText: ''),
        onChanged: (value) => _onCodeChanged(value, index),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: _isCodeComplete && !_isVerifying ? _verifyCode : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _isCodeComplete ? const Color(0xFF4C51BF) : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: _isCodeComplete ? 8 : 0,
          shadowColor: const Color(0xFF4C51BF).withOpacity(0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isVerifying) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              const Text('確認中...'),
            ] else ...[
              const Icon(Icons.arrow_forward, size: 20),
              const SizedBox(width: 8),
              const Text(
                '次へ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNicknameScreen() {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildSuccessSection(),
            const SizedBox(height: 40),
            _buildNicknameInputSection(),
            const Spacer(),
            _buildCompleteButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.celebration, size: 28, color: Colors.green),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'ペアリング成功！\n最後にニックネームを設定しましょう',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNicknameInputSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'この端末の名前',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nicknameController,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D3748),
            ),
            decoration: InputDecoration(
              hintText: 'ニックネームを入力',
              hintStyle:
                  TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.blue.shade300, width: 2),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: const Icon(Icons.edit, color: Colors.grey, size: 20),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(
                '※親端末の一覧に表示されます',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCompleteButton() {
    final canComplete = _nicknameController.text.trim().isNotEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canComplete ? _completePairing : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canComplete ? Colors.green.shade400 : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: canComplete ? 8 : 0,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, size: 24),
            SizedBox(width: 8),
            Text(
              '完了',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _onCodeChanged(String value, int index) {
    setState(() {
      _errorMessage = '';
      _codeDigits[index] = value;
    });

    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    HapticFeedback.lightImpact();
  }

  Future<void> _verifyCode() async {
    setState(() {
      _isVerifying = true;
      _errorMessage = '';
    });
    HapticFeedback.mediumImpact();

    final state = context.read<AppState>();

    await Future.delayed(const Duration(seconds: 1));

    if (state.verifyCode(_enteredCode)) {
      setState(() {
        _isVerifying = false;
        _showNicknameScreen = true;
      });
      _slideController.forward();
      HapticFeedback.heavyImpact();
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'コードが無効または期限切れです';
        for (var i = 0; i < 6; i++) {
          _codeDigits[i] = '';
          _controllers[i].clear();
        }
      });
      _shakeController.forward().then((_) => _shakeController.reset());
      _focusNodes[0].requestFocus();
      HapticFeedback.heavyImpact();
    }
  }

  void _completePairing() {
    HapticFeedback.heavyImpact();
    final state = context.read<AppState>();

    state.addDevice(
      Device(
        name: _nicknameController.text.trim().isEmpty
            ? '未設定'
            : _nicknameController.text.trim(),
        lastSeen: DateTime.now(),
      ),
    );
    Navigator.pushReplacementNamed(context, '/childAlarm');
  }
}

