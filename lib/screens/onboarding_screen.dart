import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:verimask/l10n/app_localizations.dart';

/// Onboarding screen shown on first app launch.
///
/// Presents 3 swipeable pages explaining VeriMask's core features.
/// Saves completion flag to SharedPreferences and navigates to EnrollScreen.
///
/// Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.7, 1.8
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  static const _totalPages = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/enroll');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  _buildPage(
                    key: const Key('onboarding_page_0'),
                    icon: Icons.face,
                    title: l10n.onboardingStep1Title,
                    body: l10n.onboardingStep1Body,
                    theme: theme,
                    welcome: l10n.onboardingWelcome,
                    description: l10n.onboardingDescription,
                  ),
                  _buildPage(
                    key: const Key('onboarding_page_1'),
                    icon: Icons.camera_alt,
                    title: l10n.onboardingStep2Title,
                    body: l10n.onboardingStep2Body,
                    theme: theme,
                  ),
                  _buildPage(
                    key: const Key('onboarding_page_2'),
                    icon: Icons.share,
                    title: l10n.onboardingStep3Title,
                    body: l10n.onboardingStep3Body,
                    theme: theme,
                  ),
                ],
              ),
            ),
            _buildDotsIndicator(theme),
            const SizedBox(height: 24),
            _buildControls(l10n, theme),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required Key key,
    required IconData icon,
    required String title,
    required String body,
    required ThemeData theme,
    String? welcome,
    String? description,
  }) {
    return Padding(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (welcome != null) ...[
            Text(
              welcome,
              style: theme.textTheme.headlineLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],
          if (description != null) ...[
            Text(
              description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
          Icon(
            icon,
            size: 80,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(ThemeData theme) {
    return Row(
      key: const Key('onboarding_dots'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final isActive = index == _currentPage;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 12 : 8,
          height: isActive ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.colorScheme.primary : Colors.white24,
          ),
        );
      }),
    );
  }

  Widget _buildControls(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('onboarding_next_button'),
              onPressed: _nextPage,
              child: Text(
                _currentPage == _totalPages - 1
                    ? l10n.onboardingGetStarted
                    : l10n.onboardingNext,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            key: const Key('onboarding_skip_button'),
            onPressed: _completeOnboarding,
            child: Text(l10n.onboardingSkip),
          ),
        ],
      ),
    );
  }
}
