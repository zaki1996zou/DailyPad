import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:flutter/material.dart';

/// In-app privacy policy (required for App Store; do not link to a third-party placeholder).
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const String _lastUpdated = 'May 29, 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'Last updated: $_lastUpdated',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.secondaryTextColor(context),
                ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _PolicySection(
            title: 'Overview',
            body:
                '${AppStrings.appName} is an offline productivity app. Your notes and tasks are stored '
                'locally on your iPhone. We do not operate servers, accounts, or cloud sync for your content.',
          ),
          const _PolicySection(
            title: 'Data We Collect',
            body:
                'We do not collect personal data, usage analytics, advertising identifiers, or location data. '
                'We do not sell or share your information with third parties.',
          ),
          const _PolicySection(
            title: 'Data Stored on Your Device',
            body:
                'All notes, tasks, categories, favorites, pinned notes, completion status, and app preferences '
                '(such as dark mode) are saved on your device using local storage. You can delete all notes and '
                'tasks at any time from Settings → Delete All Data.',
          ),
          const _PolicySection(
            title: 'Internet & Third Parties',
            body:
                'The app works without an internet connection. If you choose Contact Support, your email app may '
                'send a message to our support address — that communication is handled by your device and email '
                'provider, not by ${AppStrings.appName}.',
          ),
          const _PolicySection(
            title: 'Children',
            body:
                '${AppStrings.appName} is not directed at children under 13. We do not knowingly collect information from children.',
          ),
          const _PolicySection(
            title: 'Changes',
            body:
                'We may update this policy. Continued use of the app after changes means you accept the updated policy.',
          ),
          const _PolicySection(
            title: 'Contact',
            body:
                'Questions about privacy? Email ${AppStrings.supportEmail}.',
          ),
        ],
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.secondaryTextColor(context),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
