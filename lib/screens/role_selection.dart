// lib/screens/role_selection.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;

import 'package:kokodayo/simple_provider.dart';

import '../app_state.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with SingleTickerProviderStateMixin {
  String selectedRole = '';
  bool notificationPermissionGranted = false;
  bool doNotDisturbOverrideGranted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get canProceed {
    if (Platform.isAndroid) {
      return selectedRole.isNotEmpty &&
          notificationPermissionGranted &&
          doNotDisturbOverrideGranted;
    } else {
      return selectedRole.isNotEmpty && notificationPermissionGranted;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRoleSelectionTitle(),
                        const SizedBox(height: 32),
                        _buildRoleOptions(),
                        const SizedBox(height: 40),
                        _buildPermissionSection(),
                        const SizedBox(height: 40),
                        _buildStartButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.phone_android,
              size: 32,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              '迷子スマホ探索',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelectionTitle() {
    return const Text(
      'この端末の役割を選んでください',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2D3748),
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRoleOptions() {
    return Row(
      children: [
        Expanded(
          child: _buildRoleCard('parent', '親（探す側）', Icons.search, Colors.green),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildRoleCard(
              'child', '子（鳴らされる側）', Icons.volume_up, Colors.orange),
        ),
      ],
    );
  }

  Widget _buildRoleCard(String role, String title, IconData icon, Color color) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Radio<String>(
              value: role,
              groupValue: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
                HapticFeedback.lightImpact();
              },
              activeColor: color,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : const Color(0xFF4A5568),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection() {
    return Column(
      children: [
        _buildPermissionCard(
          title: '通知を許可する',
          subtitle: 'アプリからの通知を受け取るために必要です',
          isRequired: true,
          isGranted: notificationPermissionGranted,
          onTap: () {
            setState(() {
              notificationPermissionGranted = !notificationPermissionGranted;
            });
            HapticFeedback.lightImpact();
            _requestNotificationPermission();
          },
        ),
        if (Platform.isAndroid) ...[
          const SizedBox(height: 16),
          _buildPermissionCard(
            title: 'おやすみモード上書き',
            subtitle: 'おやすみモード中でも音を鳴らせるようにします',
            isRequired: true,
            isGranted: doNotDisturbOverrideGranted,
            onTap: () {
              setState(() {
                doNotDisturbOverrideGranted = !doNotDisturbOverrideGranted;
              });
              HapticFeedback.lightImpact();
              _requestDoNotDisturbOverride();
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required bool isRequired,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted ? Colors.green.shade300 : Colors.red.shade300,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isGranted
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isGranted ? Icons.check_circle : Icons.error,
                color: isGranted ? Colors.green : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '必須',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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

  Widget _buildStartButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: ElevatedButton(
        onPressed: canProceed ? _onStartPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          canProceed ? const Color(0xFF4C51BF) : Colors.grey.shade300,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canProceed ? 8 : 0,
          shadowColor: const Color(0xFF4C51BF).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (canProceed) ...[
              const Icon(Icons.rocket_launch, size: 24),
              const SizedBox(width: 8),
            ],
            const Text(
              'はじめる',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _requestNotificationPermission() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          notificationPermissionGranted = true;
        });
      }
    });
  }

  void _requestDoNotDisturbOverride() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          doNotDisturbOverrideGranted = true;
        });
      }
    });
  }

  
  void _onStartPressed() {
    HapticFeedback.mediumImpact();
    final state = context.read<AppState>();
    state.setRole(selectedRole);
    final route = selectedRole == 'parent' ? '/parentCode' : '/childPair';
    Navigator.pushReplacementNamed(context, route);
  }

}
