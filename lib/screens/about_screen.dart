import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/constants.dart';
import '../widgets/powered_by_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    AppThemeScope.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About JAMB CBT', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          children: [
            const SizedBox(height: 12.0),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 72.0,
                    height: 72.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    AppConstants.appName,
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: TextStyle(fontSize: 13.0, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),
            
            const Text(
              'App Purpose',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'JAMB CBT is a computer-based test training platform built for candidates preparing for the Nigerian Unified Tertiary Matriculation Examination (UTME). It covers 10 core subjects with 200 original, syllabus-aligned questions each, complete offline support, timed exam simulations, and performance analytics over time.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.0, height: 1.45),
            ),
            const SizedBox(height: 24.0),

            const Text(
              'Key Features',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            _buildFeatureBullet('Offline Practice Mode', 'Review questions with instant answer explanations.'),
            _buildFeatureBullet('Mock Exam Timer', 'Simulate the real UTME timing to build speed and accuracy.'),
            _buildFeatureBullet('JAMB-Aligned Exams', 'Timed exams match the real UTME format: 60 questions for Use of English, 40 for other subjects.'),
            _buildFeatureBullet('200-Question Banks', 'Each subject has 200 original syllabus-aligned questions, drawn randomly every attempt.'),
            _buildFeatureBullet('Gamification Engine', 'Earn coins, accumulate XP, and achieve streak milestones.'),
            const SizedBox(height: 24.0),

            const Text(
              'About the Questions',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Every question is original, written to match the official JAMB UTME syllabus and exam style, and organised by subject and topic so you can focus your revision where it matters most.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.0, height: 1.45),
            ),
            const SizedBox(height: 24.0),

            const Text(
              'Support & Feedback',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Encountered a bug or have questions/suggestions? Please reach out to us:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.0, height: 1.4),
            ),
            const SizedBox(height: 8.0),
            Text(
              AppConstants.contactEmail,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent, fontSize: 14.0),
            ),
            
            const PoweredByFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u2022 ', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 16.0)),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontFamily: 'Nunito', fontSize: 13.0, color: AppColors.textSecondary),
                children: [
                  TextSpan(text: '$title: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  TextSpan(text: desc),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
