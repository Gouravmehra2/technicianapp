import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';
import 'job_detail_controller.dart';

// ─── Shared text sizes ────────────────────────────────────────────────────────

const _kLabelSize = 12.0;
const _kValueSize = 14.0;
const _kHeadingSize = 13.0;

// ─── Screen ───────────────────────────────────────────────────────────────────

class JobDetailScreen extends GetView<JobDetailController> {
  JobDetailScreen({super.key});

  @override
  final controller = Get.put(JobDetailController());

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.chevron_left, color: Colors.black, size: 30),
        ),
        title: const Text(
          'Job Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.callSupport,
            icon: const Icon(Icons.support_agent, color: Colors.black87),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColor.brownAccentPrimary,
            ),
          );
        }

        final job = controller.job;
        if (job == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColor.coolGrayText,
                ),
                const SizedBox(height: 14),
                Text(
                  'Job details not available.',
                  style: AppTextStyle.bodyMediumRegular.copyWith(
                    color: AppColor.coolGrayText,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: controller.fetchJobDetail,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: AppColor.brownAccentPrimary,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                child: Column(
                  children: [
                    _JobInfoCard(job: job),
                    const SizedBox(height: 16),
                    _ScheduleCard(job: job, controller: controller),

                    if (job.workType != null) ...[
                      const SizedBox(height: 16),
                      _WorkTypeCard(job: job),
                      const SizedBox(height: 16),
                    ],
                    if ((job.description ?? '').isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _DescriptionCard(job: job),
                    ],
                    if ((job.requirements ?? []).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _RequirementsCard(job: job),
                    ],
                    if ((job.preferredSkills ?? []).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SkillsCard(job: job),
                    ],
                    // Completed: show all tasks with their completion data
                    if ((_isCompleted(job.status) || _isCheckout(job.status)) &&
                        (job.tasks ?? []).isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _CompletedTasksSection(job: job),
                    ],
                    // Checkout: payment pending banner
                    if (_isCheckout(job.status)) ...[
                      const SizedBox(height: 16),
                      const _CheckoutBanner(),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _BottomActions(controller: controller),
          ],
        );
      }),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

/// Bold uppercase section heading inside a card.
class _CardHeading extends StatelessWidget {
  final String title;

  const _CardHeading(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w800,
        fontSize: _kHeadingSize,
        color: AppColor.brownAccentPrimary,
        letterSpacing: 1.0,
      ),
    );
  }
}

/// One label + value row with a leading icon.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColor.brownAccentPrimary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                fontSize: _kLabelSize,
                color: AppColor.coolGrayText,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: _kValueSize,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// White rounded card wrapper with subtle shadow.
class _DetailCard extends StatelessWidget {
  final Widget child;

  const _DetailCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─── Job Info Card ────────────────────────────────────────────────────────────

class _JobInfoCard extends StatelessWidget {
  final Jobs job;

  const _JobInfoCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.work_outline_rounded,
                  color: AppColor.brownAccentPrimary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title ?? 'Untitled Job',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        color: Color(0xFF1A1A1A),
                        height: 1.2,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((job.status ?? '').isNotEmpty)
                              _StatusChip(status: job.status!),
                            if ((job.sId ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              _SmallChip(label: 'ID: ${job.sId}'),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          if ((job.serviceType?.name ?? '').isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.miscellaneous_services_outlined,
                  size: 15,
                  color: AppColor.brownAccentPrimary,
                ),
                const SizedBox(width: 6),
                Text(
                  job.serviceType!.name!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: _kValueSize,
                    color: Color(0xFF444444),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
          ],
          _DestinationCard(job: job),
          // if ((job.serviceType?.name ?? '').isNotEmpty ||
          //     address.isNotEmpty) ...[
          //   const SizedBox(height: 12),
          //   Divider(height: 1, color: Colors.grey.shade100),
          //   const SizedBox(height: 12),
          // ],
          // if ((job.serviceType?.name ?? '').isNotEmpty) ...[
          //   Row(
          //     children: [
          //       const Icon(
          //         Icons.miscellaneous_services_outlined,
          //         size: 15,
          //         color: AppColor.brownAccentPrimary,
          //       ),
          //       const SizedBox(width: 6),
          //       Text(
          //         job.serviceType!.name!,
          //         style: const TextStyle(
          //           fontFamily: 'Inter',
          //           fontWeight: FontWeight.w600,
          //           fontSize: _kValueSize,
          //           color: Color(0xFF444444),
          //         ),
          //       ),
          //     ],
          //   ),
          //   const SizedBox(height: 6),
          // ],
          // if (address.isNotEmpty)
          //   Row(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       const Icon(
          //         Icons.place_outlined,
          //         size: 15,
          //         color: AppColor.coolGrayText,
          //       ),
          //       const SizedBox(width: 6),
          //       Expanded(
          //         child: Text(
          //           address,
          //           style: const TextStyle(
          //             fontFamily: 'Inter',
          //             fontWeight: FontWeight.w500,
          //             fontSize: _kLabelSize + 1,
          //             color: AppColor.coolGrayText,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          if (job.pay != null) ...[
            const SizedBox(height: 10),
            _PayCard(job: job),
          ],
        ],
      ),
    );
  }
}

// ─── Schedule Card (ETA + Duration + Distance + Amount) ───────────────────────

class _ScheduleCard extends StatelessWidget {
  final Jobs job;
  final JobDetailController controller;

  const _ScheduleCard({required this.job, required this.controller});

  /// Formats a time range from jobDate.from → jobDate.to.
  /// Falls back to scheduledDate / serviceDate if jobDate is absent.
  String _buildTimeRange(JobDetailController ctrl) {
    final from = job.jobDate?.from ?? '';
    final to = job.jobDate?.to ?? '';

    if (from.isNotEmpty && to.isNotEmpty) {
      return '${ctrl.formatDateTime(from)} – ${ctrl.formatDateTime(to)}';
    }
    if (from.isNotEmpty) return ctrl.formatDateTime(from);

    // fallback to scheduledDate / serviceDate
    final fallback = job.scheduledDate ?? job.serviceDate ?? '';
    return fallback.isNotEmpty ? ctrl.formatDateTime(fallback) : '';
  }

  /// Duration: prefer estimatedTime, then jobDurationMinutes, then jobDate range hours.
  String _buildDuration(JobDetailController ctrl) {
    if ((job.estimatedTime ?? '').isNotEmpty) return '${job.estimatedTime} hrs';
    if (job.jobDurationMinutes != null) return '${job.jobDurationMinutes} min';
    if ((job.pay?.approxHours ?? '').isNotEmpty) {
      return '${job.pay!.approxHours} hrs (approx)';
    }
    // derive from jobDate window
    final from = job.jobDate?.from ?? '';
    final to = job.jobDate?.to ?? '';
    if (from.isNotEmpty && to.isNotEmpty) {
      try {
        final diff = DateTime.parse(
          to,
        ).difference(DateTime.parse(from)).inMinutes;
        if (diff >= 60) {
          final h = diff ~/ 60;
          final m = diff % 60;
          return m > 0 ? '${h}h ${m}m' : '${h}h';
        }
        if (diff > 0) return '${diff}m';
      } catch (_) {}
    }
    return '';
  }

  String _buildAmount() {
    final pay = job.pay;
    if (pay == null) {
      final v = job.finalPrice != null && (job.finalPrice ?? 0) > 0
          ? job.finalPrice
          : job.budget;
      return v != null ? '\$$v' : '';
    }

    switch ((pay.type ?? '').toLowerCase()) {
      case 'hourly':
        final rate = pay.hourlyRate ?? 0;
        final approx = double.tryParse(pay.approxHours ?? '') ?? 0;
        final max = pay.maxHours ?? 0;
        final hours = approx > 0 ? approx : max.toDouble();
        if (hours > 0 && rate > 0) {
          return 'Est. \$${(rate * hours).toStringAsFixed(0)}';
        }
        if (rate > 0) return '\$$rate/hr';
        return '';

      case 'perdevice':
      case 'per_device':
      case 'per-device':
        final rate = pay.perDeviceRate ?? 0;
        final devices = pay.maxDevices ?? 0;
        if (devices > 0 && rate > 0) return 'Est. \$${rate * devices}';
        if (rate > 0) return '\$$rate/device';
        return '';

      case 'blended':
        final fixed = pay.blendedFixedAmount ?? 0;
        final addlRate = pay.blendedHourlyRate ?? 0;
        final maxAddl = pay.blendedMaxAddlHours ?? 0;
        if (addlRate > 0 && maxAddl > 0) {
          return 'Est. \$${fixed + addlRate * maxAddl}';
        }
        return '\$$fixed';

      case 'fixed':
      default:
        final amount = pay.fixedAmount ?? 0;
        if (amount > 0) return '\$$amount';
        final fallback = job.finalPrice != null && (job.finalPrice ?? 0) > 0
            ? job.finalPrice
            : job.budget;
        return fallback != null ? '\$$fallback' : '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = _buildTimeRange(controller);
    final duration = _buildDuration(controller);
    final amount = _buildAmount();

    return Obx(() {
      final distance = controller.distanceKm.value;
      return _DetailCard(
        child: Column(
          children: [
            // ── Row 1: Schedule window + Duration ──
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.calendar_month_outlined,
                    label: 'Schedule',
                    value: timeRange,
                  ),
                ),
                _VertDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.timer_outlined,
                    label: 'Duration',
                    value: duration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Divider(height: 1, color: Colors.grey.shade100),
            const SizedBox(height: 4),
            // ── Row 2: Distance + Amount ──
            Row(
              children: [
                Expanded(
                  child: _StatCell(
                    icon: Icons.location_on_outlined,
                    label: 'Distance',
                    value: distance,
                  ),
                ),
                _VertDivider(),
                Expanded(
                  child: _StatCell(
                    icon: Icons.payments_outlined,
                    label: 'Est. Pay',
                    value: amount,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 56, color: Colors.grey.shade100);
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColor.brownAccentPrimary),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: _kLabelSize,
              color: AppColor.coolGrayText,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Destination Card ─────────────────────────────────────────────────────────

class _DestinationCard extends StatelessWidget {
  final Jobs job;

  const _DestinationCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final fullAddress = [
      job.location,
      job.city,
      job.state,
      job.zipCode,
    ].where((s) => (s ?? '').isNotEmpty).join(', ');

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('DESTINATION'),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullAddress.isNotEmpty ? fullAddress : 'No location',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: _kValueSize,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(width: 5),
              // GestureDetector(
              //   onTap: hasCoords
              //       ? () => MapLaunchHelper.navigateTo(
              //     lat: job.coordinates!.lat!,
              //     lng: job.coordinates!.lng!,
              //   )
              //       : null,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 16,
              //       vertical: 10,
              //     ),
              //     decoration: BoxDecoration(
              //       color: hasCoords
              //           ? AppColor.brownAccentPrimary
              //           : Colors.grey.shade200,
              //       borderRadius: BorderRadius.circular(22),
              //     ),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.min,
              //       children: [
              //         Icon(
              //           Icons.navigation_outlined,
              //           size: 15,
              //           color: hasCoords ? Colors.white : AppColor.coolGrayText,
              //         ),
              //         const SizedBox(width: 5),
              //         Text(
              //           'Navigate',
              //           style: TextStyle(
              //             fontFamily: 'Inter',
              //             fontWeight: FontWeight.w700,
              //             fontSize: 13,
              //             color: hasCoords
              //                 ? Colors.white
              //                 : AppColor.coolGrayText,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Description Card (HTML + Read More) ─────────────────────────────────────

class _DescriptionCard extends StatefulWidget {
  final Jobs job;

  const _DescriptionCard({required this.job});

  @override
  State<_DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<_DescriptionCard> {
  bool _looksLikeHtml(String s) => s.contains('<') && s.contains('>');

  @override
  Widget build(BuildContext context) {
    final raw = widget.job.description ?? '';
    final isHtml = _looksLikeHtml(raw);

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('DESCRIPTION'),
          const SizedBox(height: 10),
          if (isHtml)
            _HtmlDescription(html: raw)
          else
            ReadMoreText(
              raw,
              trimMode: TrimMode.Line,
              trimLines: 4,
              colorClickableText: AppColor.brownAccentPrimary,
              trimCollapsedText: '  Read more',
              trimExpandedText: '  Show less',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
                fontSize: _kValueSize,
                color: Color(0xFF333333),
                height: 1.65,
              ),
              moreStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: _kValueSize,
                color: AppColor.brownAccentPrimary,
              ),
              lessStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: _kValueSize,
                color: AppColor.brownAccentPrimary,
              ),
            ),
        ],
      ),
    );
  }
}

class _HtmlDescription extends StatefulWidget {
  final String html;

  const _HtmlDescription({required this.html});

  @override
  State<_HtmlDescription> createState() => _HtmlDescriptionState();
}

class _HtmlDescriptionState extends State<_HtmlDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 120),
            child: ClipRect(child: _htmlWidget()),
          ),
          secondChild: _htmlWidget(),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              _expanded ? '  Show less' : '  Read more',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
                fontSize: _kValueSize,
                color: AppColor.brownAccentPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _htmlWidget() {
    return Html(
      data: widget.html,
      style: {
        'body': Style(
          fontFamily: 'Inter',
          fontSize: FontSize(_kValueSize),
          color: const Color(0xFF333333),
          lineHeight: LineHeight(1.65),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'p': Style(margin: Margins.only(bottom: 6)),
        'li': Style(
          fontSize: FontSize(_kValueSize),
          color: const Color(0xFF333333),
        ),
      },
    );
  }
}

// ─── Requirements Card ────────────────────────────────────────────────────────

class _RequirementsCard extends StatelessWidget {
  final Jobs job;

  const _RequirementsCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('REQUIREMENTS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (job.requirements ?? [])
                .map((r) => _TagChip(label: r))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Preferred Skills Card ────────────────────────────────────────────────────

class _SkillsCard extends StatelessWidget {
  final Jobs job;

  const _SkillsCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('PREFERRED SKILLS'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (job.preferredSkills ?? [])
                .map((s) => _TagChip(label: s))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Pay Card ─────────────────────────────────────────────────────────────────

class _PayCard extends StatelessWidget {
  final Jobs job;

  const _PayCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final pay = job.pay!;
    final type = (pay.type ?? '').toLowerCase();

    // Build rows based on pay type
    final rows = <_InfoRow>[];

    if (type.isNotEmpty) {
      rows.add(
        _InfoRow(
          icon: Icons.category_outlined,
          label: 'Pay Type',
          value: _formatPayType(pay.type!),
        ),
      );
    }

    if (type == 'fixed' || type.isEmpty) {
      if (pay.fixedAmount != null) {
        rows.add(
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Fixed Amount',
            value: '\$${pay.fixedAmount}',
          ),
        );
      }
      if ((pay.approxHours ?? '').isNotEmpty) {
        rows.add(
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Approx Hours',
            value: '${pay.approxHours} hrs',
          ),
        );
      }
    } else if (type == 'hourly') {
      if (pay.hourlyRate != null) {
        rows.add(
          _InfoRow(
            icon: Icons.access_time,
            label: 'Hourly Rate',
            value: '\$${pay.hourlyRate}/hr',
          ),
        );
      }
      if (pay.maxHours != null) {
        rows.add(
          _InfoRow(
            icon: Icons.hourglass_top_outlined,
            label: 'Maximum Hours',
            value: '${pay.maxHours} hrs',
          ),
        );
      }
      if ((pay.approxHours ?? '').isNotEmpty) {
        rows.add(
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Approx Hours',
            value: '${pay.approxHours} hrs',
          ),
        );
      }
    } else if (type == 'per_device' ||
        type == 'perdevice' ||
        type == 'per device') {
      if (pay.perDeviceRate != null) {
        rows.add(
          _InfoRow(
            icon: Icons.devices_outlined,
            label: 'Per Device Rate',
            value: '\$${pay.perDeviceRate}',
          ),
        );
      }
      if ((pay.approxHours ?? '').isNotEmpty) {
        rows.add(
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Approx Hours',
            value: '${pay.approxHours} hrs',
          ),
        );
      }
    } else if (type == 'blended') {
      if (pay.blendedFixedAmount != null) {
        rows.add(
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Blended Fixed',
            value: '\$${pay.blendedFixedAmount}',
          ),
        );
      }
      if (pay.blendedFixedHours != null) {
        rows.add(
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Blended Fixed Hrs',
            value: '${pay.blendedFixedHours} hrs',
          ),
        );
      }
      if (pay.blendedHourlyRate != null) {
        rows.add(
          _InfoRow(
            icon: Icons.paid_outlined,
            label: 'Blended Hourly',
            value: '\$${pay.blendedHourlyRate}/hr',
          ),
        );
      }
      if (pay.blendedMaxAddlHours != null) {
        rows.add(
          _InfoRow(
            icon: Icons.more_time,
            label: 'Max Addl Hours',
            value: '${pay.blendedMaxAddlHours} hrs',
          ),
        );
      }
      if ((pay.approxHours ?? '').isNotEmpty) {
        rows.add(
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Approx Hours',
            value: '${pay.approxHours} hrs',
          ),
        );
      }
    } else {
      // Unknown type — show all non-null fields
      if (pay.fixedAmount != null) {
        rows.add(
          _InfoRow(
            icon: Icons.attach_money,
            label: 'Fixed Amount',
            value: '\$${pay.fixedAmount}',
          ),
        );
      }
      if (pay.hourlyRate != null) {
        rows.add(
          _InfoRow(
            icon: Icons.access_time,
            label: 'Hourly Rate',
            value: '\$${pay.hourlyRate}/hr',
          ),
        );
      }
      if (pay.maxHours != null) {
        rows.add(
          _InfoRow(
            icon: Icons.hourglass_top_outlined,
            label: 'Max Hours',
            value: '${pay.maxHours} hrs',
          ),
        );
      }
      if ((pay.approxHours ?? '').isNotEmpty) {
        rows.add(
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Approx Hours',
            value: '${pay.approxHours} hrs',
          ),
        );
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CardHeading('PAY DETAILS'),
              const Spacer(),
              if (type.isNotEmpty) _PayTypeBadge(type: pay.type!),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  String _formatPayType(String t) {
    switch (t.toLowerCase()) {
      case 'fixed':
        return 'Fixed Price';
      case 'hourly':
        return 'Hourly Rate';
      case 'per_device':
      case 'perdevice':
      case 'per device':
        return 'Per Device';
      case 'blended':
        return 'Blended';
      default:
        return t;
    }
  }
}

class _PayTypeBadge extends StatelessWidget {
  final String type;

  const _PayTypeBadge({required this.type});

  Color get _bg {
    switch (type.toLowerCase()) {
      case 'fixed':
        return const Color(0xFFE8F5E9);
      case 'hourly':
        return const Color(0xFFE3F2FD);
      case 'blended':
        return const Color(0xFFF3E5F5);
      default:
        return const Color(0xFFFFF3E0);
    }
  }

  Color get _fg {
    switch (type.toLowerCase()) {
      case 'fixed':
        return Colors.green.shade700;
      case 'hourly':
        return Colors.blue.shade700;
      case 'blended':
        return Colors.purple.shade700;
      default:
        return AppColor.brownAccentPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: _fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Work Type Card ───────────────────────────────────────────────────────────

class _WorkTypeCard extends StatelessWidget {
  final Jobs job;

  const _WorkTypeCard({required this.job});

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('WORK TYPE'),
          const SizedBox(height: 12),
          if ((job.workType?.name ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.build_outlined,
              label: 'Type',
              value: job.workType!.name!,
            ),
          if ((job.workType?.subType?.name ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.subdirectory_arrow_right,
              label: 'Sub-Type',
              value: job.workType!.subType!.name!,
            ),
          if ((job.additionalWorkType?.name ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.add_circle_outline,
              label: 'Additional',
              value: job.additionalWorkType!.name!,
            ),
          if ((job.additionalWorkType?.subType?.name ?? '').isNotEmpty)
            _InfoRow(
              icon: Icons.subdirectory_arrow_right,
              label: 'Addl Sub-Type',
              value: job.additionalWorkType!.subType!.name!,
            ),
        ],
      ),
    );
  }
}

// ─── Assigned Technician Card ─────────────────────────────────────────────────

class _AssignedTechnicianCard extends StatelessWidget {
  final Jobs job;

  const _AssignedTechnicianCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final tech = job.assignedTechnician!;
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('ASSIGNED TECHNICIAN'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: AppColor.brownAccentPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((tech.name ?? '').isNotEmpty)
                      Text(
                        tech.name!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: _kValueSize + 1,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    if ((tech.email ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tech.email!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: _kLabelSize + 1,
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                    if ((tech.phone ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tech.phone!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500,
                          fontSize: _kLabelSize + 1,
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Tasks Card ───────────────────────────────────────────────────────────────

class _TasksCard extends StatelessWidget {
  final Jobs job;

  const _TasksCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final tasks = job.tasks ?? [];
    final doneCount = tasks.where((t) => t.isDone == true).length;

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CardHeading('TASKS'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: doneCount == tasks.length
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$doneCount / ${tasks.length} done',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: doneCount == tasks.length
                        ? Colors.green.shade700
                        : AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tasks.isEmpty ? 0 : doneCount / tasks.length,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: AlwaysStoppedAnimation<Color>(
                doneCount == tasks.length
                    ? Colors.green.shade500
                    : AppColor.brownAccentPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...tasks.map((t) => _TaskRow(task: t)),
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Tasks task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final done = task.isDone ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 22,
            color: done ? Colors.green.shade600 : Colors.grey.shade300,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? '',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: done ? FontWeight.w500 : FontWeight.w600,
                    fontSize: _kValueSize,
                    color: done
                        ? AppColor.coolGrayText
                        : const Color(0xFF1A1A1A),
                    decoration: done ? TextDecoration.lineThrough : null,
                    decorationColor: AppColor.coolGrayText,
                  ),
                ),
                if ((task.group ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    task.group!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                      color: AppColor.coolGrayText,
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
}

// ─── Reschedule History Card ──────────────────────────────────────────────────

class _RescheduleHistoryCard extends StatelessWidget {
  final Jobs job;

  const _RescheduleHistoryCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final history = job.rescheduleHistory ?? [];
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeading('RESCHEDULE HISTORY'),
          const SizedBox(height: 12),
          ...history.asMap().entries.map((e) {
            final h = e.value;
            final isLast = e.key == history.length - 1;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((h.reason ?? '').isNotEmpty) ...[
                  Text(
                    h.reason!,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: _kValueSize,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    _DateBox(label: 'Previous', value: h.previousDate ?? '—'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(
                        Icons.east_outlined,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    _DateBox(label: 'Rescheduled', value: h.newDate ?? '—'),
                  ],
                ),
                if (!isLast) ...[
                  const SizedBox(height: 10),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;

  const _DateBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 10,
            color: AppColor.coolGrayText,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }
}

// ─── Chip helpers ─────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8D5B0)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          fontSize: _kLabelSize + 1,
          color: AppColor.brownAccentPrimary,
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String label;

  const _SmallChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
          fontSize: 11,
          color: AppColor.coolGrayText,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  ({Color bg, Color fg}) get _colors {
    switch (status.toLowerCase()) {
      case 'active':
        return (bg: const Color(0xFFE8F5E9), fg: Color(0xFF2E7D32));
      case 'ontheway':
        return (bg: const Color(0xFFE3F2FD), fg: const Color(0xFF1565C0));
      case 'completed':
        return (bg: const Color(0xFFE3F2FD), fg: Color(0xFF1565C0));
      case 'checkout':
        return (bg: const Color(0xFFE8F5E9), fg: Color(0xFF2E7D32));
      case 'cancelled':
        return (bg: const Color(0xFFFFEBEE), fg: Color(0xFFC62828));
      case 'pending':
      case 'open':
        return (bg: const Color(0xFFFFFDE7), fg: Color(0xFFF57F17));
      default:
        return (bg: const Color(0xFFFFF3E0), fg: AppColor.brownAccentPrimary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _isPending(status) ? 'PENDING' : status.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          fontSize: 11,
          color: c.fg,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ─── Status helpers ───────────────────────────────────────────────────────────

bool _isCompleted(String? status) =>
    (status ?? '').toLowerCase() == 'completed';

bool _isCheckout(String? status) => (status ?? '').toLowerCase() == 'checkout';

bool _isPending(String? status) {
  final normalized = (status ?? '').toLowerCase();
  return normalized == 'pending' || normalized == 'open';
}

// ─── Bottom Actions ───────────────────────────────────────────────────────────

class _BottomActions extends StatelessWidget {
  final JobDetailController controller;

  const _BottomActions({required this.controller});

  @override
  Widget build(BuildContext context) {
    final status = controller.job?.status;

    // Completed: read-only — no action
    if (_isCompleted(status)) return const SizedBox.shrink();

    // Pending: the job cannot be started until an admin assigns it.
    if (_isPending(status)) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFFD54F)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFFF57F17),
                size: 22,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Admin has not assigned this job yet. You cannot start the job until it is assigned.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF7A4F01),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Checkout: payment pending info bar
    if (_isCheckout(status)) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFA5D6A7)),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF2E7D32),
                size: 22,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Job is complete. Payment will be processed in 3–5 business days.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1B5E20),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: controller.isRequestedByMe
                  ? controller.startJob
                  : controller.onRequestJob,
              child: Container(
                width: Get.width,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: AppColor.brownAccentPrimary,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.brownAccentPrimary.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  controller.isRequestedByMe ? 'Start Job' : 'Request Job',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          if (!controller.isRequestedByMe) ...[
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: controller.quoteOwnPrice,
                child: Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColor.brownAccentPrimary,
                      width: 1.5,
                    ),
                  ),
                  child: const Text(
                    'Counter Offer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColor.brownAccentPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Completed Job Tasks Section ──────────────────────────────────────────────

class _CompletedTasksSection extends StatelessWidget {
  final Jobs job;

  const _CompletedTasksSection({required this.job});

  @override
  Widget build(BuildContext context) {
    final tasks = job.tasks ?? [];
    if (tasks.isEmpty) return const SizedBox.shrink();

    final doneCount = tasks.where((t) => t.isDone == true).length;

    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CardHeading('COMPLETED TASKS'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$doneCount / ${tasks.length} done',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tasks.isEmpty ? 0 : doneCount / tasks.length,
              minHeight: 5,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...tasks.map((t) => _CompletedTaskTile(task: t)).toList(),
        ],
      ),
    );
  }
}

class _CompletedTaskTile extends StatelessWidget {
  final Tasks task;

  const _CompletedTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    final done = task.isDone == true;
    final hasCoords = task.technicianLat != null && task.technicianLng != null;
    final hasNote = (task.completionNote ?? '').trim().isNotEmpty;
    final hasImage = (task.completionImage ?? '').trim().isNotEmpty;
    final hasSig = (task.signature ?? '').trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: done ? const Color(0xFFF0FFF4) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? const Color(0xFFA5D6A7) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 20,
                color: done ? const Color(0xFF4CAF50) : Colors.grey.shade400,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title ?? '',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        fontSize: _kValueSize,
                        color: done
                            ? const Color(0xFF1A1A1A)
                            : AppColor.coolGrayText,
                      ),
                    ),
                    if ((task.group ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        task.group!,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColor.coolGrayText,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (done) ...[
            // Coordinates where task was completed
            if (hasCoords) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppColor.brownAccentPrimary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_fmt(task.technicianLat)}, ${_fmt(task.technicianLng)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: Color(0xFF444444),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Evidence captured while the technician completed this task.
            if (hasNote || hasImage || hasSig) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (hasNote)
                    _RequirementBadge(
                      icon: Icons.notes_outlined,
                      label: 'Additional note',
                    ),
                  if (hasImage)
                    _RequirementBadge(
                      icon: Icons.image_outlined,
                      label: 'Image uploaded',
                    ),
                  if (hasSig)
                    _RequirementBadge(
                      icon: Icons.draw_outlined,
                      label: 'Signature uploaded',
                    ),
                ],
              ),
            ],

            if (hasNote) ...[
              const SizedBox(height: 10),
              _EvidenceBlock(
                icon: Icons.notes_outlined,
                title: 'Additional note',
                child: Text(
                  task.completionNote!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    height: 1.45,
                    color: Color(0xFF333333),
                  ),
                ),
              ),
            ],

            if (hasImage) ...[
              const SizedBox(height: 10),
              _EvidenceBlock(
                icon: Icons.image_outlined,
                title: 'Technician image',
                child: _UploadedImage(url: task.completionImage!),
              ),
            ],

            if (hasSig) ...[
              const SizedBox(height: 10),
              _EvidenceBlock(
                icon: Icons.draw_outlined,
                title: 'Customer signature',
                child: _UploadedImage(url: task.signature!),
              ),
            ],

            // Completion timestamp
            if (task.checkedAt != null) ...[
              const SizedBox(height: 6),
              Text(
                'Completed: ${_formatCheckedAt(task.checkedAt.toString())}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: AppColor.coolGrayText,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _fmt(dynamic v) {
    if (v == null) return '—';
    try {
      return double.parse(v.toString()).toStringAsFixed(5);
    } catch (_) {
      return v.toString();
    }
  }

  String _formatCheckedAt(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${months[dt.month - 1]} ${dt.day}, $h:$m $period';
    } catch (_) {
      return raw;
    }
  }
}

class _EvidenceBlock extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _EvidenceBlock({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColor.brownAccentPrimary),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: Color(0xFF444444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _UploadedImage extends StatelessWidget {
  final String url;

  const _UploadedImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        url,
        width: double.infinity,
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Text(
            'Uploaded file is unavailable.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColor.coolGrayText,
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _RequirementBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE8D5B0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColor.brownAccentPrimary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColor.brownAccentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Checkout Banner ──────────────────────────────────────────────────────────

class _CheckoutBanner extends StatelessWidget {
  const _CheckoutBanner();

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_outlined,
              color: Color(0xFF2E7D32),
              size: 30,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Job Completed',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Great work! Your payment is being processed and will be deposited within 3–5 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: AppColor.coolGrayText,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE8D5B0)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColor.brownAccentPrimary,
                ),
                SizedBox(width: 8),
                Text(
                  'Payment in 3–5 business days',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
