import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

/// A convenience wrapper around the [Shimmer] package.
///
/// Usage:
/// ```dart
/// AppShimmer(child: _SomePlaceholderWidget())
/// ```
class AppShimmer extends StatelessWidget {
  final Widget child;

  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFEEEEEE),
      highlightColor: const Color(0xFFF5F5F5),
      child: child,
    );
  }
}

/// A rounded rectangle placeholder used as a generic shimmer block.
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// Shimmer placeholder that mimics the EarningsCard.
class EarningsCardShimmer extends StatelessWidget {
  const EarningsCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            const ShimmerBox(width: 44, height: 44, radius: 22),
            const SizedBox(width: 12),
            const ShimmerBox(width: 120, height: 18),
            const SizedBox(width: 8),
            const ShimmerBox(width: 60, height: 18),
            const Spacer(),
            const ShimmerBox(width: 24, height: 24, radius: 12),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder that mimics the OverviewCard grid.
class OverviewCardShimmer extends StatelessWidget {
  const OverviewCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.brownAccentPrimary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 90, height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const ShimmerBox(width: 60, height: 14),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3,
              padding: EdgeInsets.zero,
              children: List.generate(4, (_) => _OverviewStatShimmerTile()),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewStatShimmerTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ShimmerBox(width: 36, height: 36, radius: 10),
          SizedBox(height: 8),
          ShimmerBox(width: 40, height: 22),
          SizedBox(height: 4),
          ShimmerBox(width: 70, height: 14),
        ],
      ),
    );
  }
}

/// Shimmer placeholder for a single schedule job card.
class ScheduleJobCardShimmer extends StatelessWidget {
  const ScheduleJobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerBox(width: 80, height: 24),
                      SizedBox(height: 6),
                      ShimmerBox(width: 100, height: 14),
                    ],
                  ),
                ),
                const ShimmerBox(width: 90, height: 28, radius: 20),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: double.infinity, height: 18),
            const SizedBox(height: 6),
            const ShimmerBox(width: 180, height: 14),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: ShimmerBox(width: double.infinity, height: 40, radius: 20)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(width: double.infinity, height: 40, radius: 20)),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: double.infinity, height: 42, radius: 30),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a single new-job card (horizontal scroll).
class NewJobCardShimmer extends StatelessWidget {
  const NewJobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.78,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                ShimmerBox(width: 44, height: 44, radius: 10),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(width: double.infinity, height: 20)),
                SizedBox(width: 10),
                ShimmerBox(width: 44, height: 22, radius: 12),
              ],
            ),
            const SizedBox(height: 10),
            const ShimmerBox(width: 160, height: 14),
            const SizedBox(height: 6),
            const ShimmerBox(width: 200, height: 14),
            const SizedBox(height: 6),
            const ShimmerBox(width: 120, height: 14),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(child: ShimmerBox(width: double.infinity, height: 38, radius: 20)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(width: double.infinity, height: 38, radius: 20)),
              ],
            ),
            const SizedBox(height: 8),
            const ShimmerBox(width: double.infinity, height: 40, radius: 30),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for the Job screen recommended card.
class RecommendedJobCardShimmer extends StatelessWidget {
  const RecommendedJobCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 46, height: 46, radius: 23),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(width: 50, height: 18, radius: 20),
                      SizedBox(height: 6),
                      ShimmerBox(width: 160, height: 22),
                    ],
                  ),
                ),
                ShimmerBox(width: 22, height: 22, radius: 11),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                ShimmerBox(width: 80, height: 26, radius: 20),
                SizedBox(width: 8),
                ShimmerBox(width: 80, height: 26, radius: 20),
                SizedBox(width: 8),
                ShimmerBox(width: 100, height: 26, radius: 20),
              ],
            ),
            const SizedBox(height: 12),
            const ShimmerBox(width: double.infinity, height: 16),
            const SizedBox(height: 14),
            Row(
              children: const [
                Expanded(child: ShimmerBox(width: double.infinity, height: 44, radius: 30)),
                SizedBox(width: 12),
                Expanded(child: ShimmerBox(width: double.infinity, height: 44, radius: 30)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer placeholder for a single job list card (Job screen).
class JobListCardShimmer extends StatelessWidget {
  const JobListCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                ShimmerBox(width: 44, height: 44, radius: 12),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(width: double.infinity, height: 20)),
                SizedBox(width: 10),
                ShimmerBox(width: 60, height: 22, radius: 20),
              ],
            ),
            const SizedBox(height: 8),
            const ShimmerBox(width: 200, height: 14),
            const SizedBox(height: 6),
            const ShimmerBox(width: 220, height: 14),
            const SizedBox(height: 6),
            const ShimmerBox(width: 100, height: 14),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(child: ShimmerBox(width: double.infinity, height: 38, radius: 20)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(width: double.infinity, height: 38, radius: 20)),
              ],
            ),
            const SizedBox(height: 8),
            const ShimmerBox(width: double.infinity, height: 42, radius: 30),
          ],
        ),
      ),
    );
  }
}

/// Shimmer for the counter-offer chat (shows a few message bubble placeholders).
class CounterOfferChatShimmer extends StatelessWidget {
  const CounterOfferChatShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Left bubble (admin)
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28, radius: 14),
                const SizedBox(width: 10),
                const Flexible(child: ShimmerBox(width: 220, height: 60, radius: 16)),
              ],
            ),
            const SizedBox(height: 16),
            // Right bubble (technician)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Flexible(child: ShimmerBox(width: 200, height: 44, radius: 16)),
              ],
            ),
            const SizedBox(height: 16),
            // Large offer card placeholder
            const ShimmerBox(width: double.infinity, height: 200, radius: 16),
            const SizedBox(height: 16),
            // Admin offer bubble
            Row(
              children: [
                const ShimmerBox(width: 28, height: 28, radius: 14),
                const SizedBox(width: 10),
                const Flexible(child: ShimmerBox(width: 240, height: 80, radius: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
