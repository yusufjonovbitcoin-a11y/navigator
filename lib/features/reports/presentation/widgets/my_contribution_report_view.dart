import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/reports/presentation/widgets/report_item_card.dart';

class MyContributionReportView extends ConsumerWidget {
  final bool isDark;
  final VoidCallback onAddReport;

  const MyContributionReportView({
    super.key,
    required this.isDark,
    required this.onAddReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karma = ref.watch(userKarmaProvider);
    final reportsAsync = ref.watch(reportListProvider);

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);
    final cardBg = isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white;
    final cardBorder = isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
      children: [
        // 1. User Level & Reputation Header Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                  : [const Color(0xFF0F172A), const Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFF9500).withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9500).withOpacity(0.15),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Gold Badge Avatar
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD60A), Color(0xFFFF9500)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF9500).withOpacity(0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(CupertinoIcons.shield_lefthalf_fill, color: Colors.black, size: 28),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Level 5 Marshal',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF9500).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF9500),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Oltin Yo\'l Qo\'riqchisi (Eng yuqori ishonch)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(CupertinoIcons.star_fill, color: Color(0xFFFFD60A), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              '$karma Karma ball',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFFFD60A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• TOP 3% haydovchi',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.checkmark_seal_fill, color: Color(0xFF34C759), size: 18),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Siz qo\'shgan har qanday radar va YPX posti tekshiruvsiz xaritada darhol butun jamoaga ko\'rinadi!',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Colors.white70,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. Community Impact Numbers
        Text(
          'Jamoatga Qo\'shgan Hissangiz',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildImpactBox(
                title: 'Yuborilgan',
                value: '12 ta',
                subtitle: '11 ta tasdiqlangan',
                color: const Color(0xFF007AFF),
                cardBg: cardBg,
                cardBorder: cardBorder,
                textColor: textColor,
                subtextColor: subtextColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildImpactBox(
                title: 'Aniqlik',
                value: '91.6%',
                subtitle: 'Reyting a\'lo',
                color: const Color(0xFF34C759),
                cardBg: cardBg,
                cardBorder: cardBorder,
                textColor: textColor,
                subtextColor: subtextColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildImpactBox(
                title: 'Ogohlantirildi',
                value: '2.8k+',
                subtitle: 'nafar haydovchi',
                color: const Color(0xFFFF9500),
                cardBg: cardBg,
                cardBorder: cardBorder,
                textColor: textColor,
                subtextColor: subtextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 3. Badges Earned Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Qo\'lga Kiritilgan Unvonlar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: textColor),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBadgePill('🦅', 'Burgut Ko\'z', 'Kameralar ustasi', const Color(0xFF007AFF)),
                  _buildBadgePill('🛡️', 'Qo\'riqchi', 'YPX aniqlovchi', const Color(0xFF34C759)),
                  _buildBadgePill('💎', 'Afsona', '1500+ Karma', const Color(0xFFFF9500)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 4. My Reports List Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mening Xabarlarim Tarixi',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textColor),
            ),
            TextButton.icon(
              onPressed: onAddReport,
              icon: const Icon(CupertinoIcons.plus, size: 14),
              label: const Text('Yangi xabar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 5. User Reports List
        reportsAsync.when(
          data: (reports) {
            final myReports = reports.take(4).toList();

            if (myReports.isEmpty) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: cardBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.doc_text, size: 40, color: subtextColor.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text('Hozircha xabarlar yo\'q', style: TextStyle(color: subtextColor, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final report = myReports[idx];
                return ReportItemCard(
                  report: report,
                  onUpvote: () => ref.read(reportListProvider.notifier).upvote(report.id),
                  onDownvote: () => ref.read(reportListProvider.notifier).downvote(report.id),
                );
              },
            );
          },
          loading: () => const Center(child: CupertinoActivityIndicator()),
          error: (e, _) => Text('Error: $e', style: TextStyle(color: subtextColor)),
        ),
      ],
    );
  }

  Widget _buildImpactBox({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10.5, color: subtextColor)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 9.5, color: subtextColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgePill(String emoji, String title, String desc, Color color) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          desc,
          style: const TextStyle(fontSize: 9.5, color: Colors.grey),
        ),
      ],
    );
  }
}
