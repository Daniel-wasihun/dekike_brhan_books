import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SchoolAboutScreen extends StatelessWidget {
  const SchoolAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ስለ እኛ',
          style: AppTheme.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: AppColors.textDark,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: AppColors.background,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.church_rounded,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'በኢትዮጵያ ኦርቶዶክስ ተዋህዶ ቤተ ክርስቲያን በሸገር ከተማ ኩራጂዳ ክፍለ ከተማ መንበረ ብርሃን ቅ/ሥላሴ ቤተ ክርስቲያን ደቂቀ ብርሃን ሰ/ት/ቤት የማስተማሪያ መጻህፍት',
                    textAlign: TextAlign.center,
                    style: AppTheme.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.divider, thickness: 1.5),
                  const SizedBox(height: 24),
                  Text(
                    'ይህ መተግበሪያ የሰንበት ትምህርት ቤት ተማሪዎች መንፈሳዊ ትምህርቶቻቸውን በቀላሉ እንዲያገኙ እና እንዲያነቡ ታስቦ የተዘጋጀ ነው።',
                    textAlign: TextAlign.center,
                    style: AppTheme.outfit(
                      fontSize: 15,
                      color: AppColors.textMedium,
                      height: 1.5,
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
}
