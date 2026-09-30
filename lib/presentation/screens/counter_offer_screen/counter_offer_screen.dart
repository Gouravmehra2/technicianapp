import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/app_shimmer.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/charges_model.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/counter_offer_model.dart';
import 'counter_offer_controller.dart';
// ChargeType enum is defined in counter_offer_controller.dart

class CounterOfferScreen extends StatelessWidget {
  const CounterOfferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CounterOfferController());

    return MyScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColor.blackShade1),
        title: Text(
          'Counter Offer',
          style: AppTextStyle.titleLargeBold.copyWith(
            color: AppColor.blackShade1,
          ),
        ),
      ),
      body: Obx(() {
        if (c.isLoading.value && c.messages.length <= 1) {
          return const SingleChildScrollView(
            padding: EdgeInsets.only(top: 12, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: AppShimmer(
                    child: ShimmerBox(
                      width: double.infinity,
                      height: 60,
                      radius: 14,
                    ),
                  ),
                ),
                CounterOfferChatShimmer(),
              ],
            ),
          );
        }
        return Column(
          children: [
            // ── Scrollable chat area ─────────────────────────────────────────
            Expanded(
              child: Obx(() {
                final showForm = c.showCounterForm.value;
                final msgCount = c.messages.length;
                final invoiceVisible = c.invoice.value != null;
                final totalItems =
                    1 +
                    msgCount +
                    (invoiceVisible ? 1 : 0) +
                    (showForm ? 1 : 0);

                return ListView.builder(
                  controller: c.scrollController,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: totalItems,
                  itemBuilder: (_, i) {
                    // ── Job details header ────────────────────────────────────
                    if (i == 0) return _JobDetailsCard(c: c);
                    // ── Chat messages ─────────────────────────────────────────
                    if (i <= msgCount) {
                      final msg = c.messages[i - 1];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: switch (msg.type) {
                          MsgType.technicianOffer => _TechnicianOfferBubble(
                            msg: msg,
                          ),
                          MsgType.adminOffer => _AdminOfferBubble(
                            msg: msg,
                            c: c,
                          ),
                          MsgType.accepted => _AcceptedOfferBubble(msg: msg),
                          MsgType.text => _TextBubble(msg: msg),
                        },
                      );
                    }

                    // ── Invoice card ──────────────────────────────────────────
                    if (invoiceVisible && i == msgCount + 1) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: _InvoiceCard(invoice: c.invoice.value!),
                      );
                    }

                    // ── Counter offer form ────────────────────────────────────
                    if (showForm) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _CounterOfferFormSection(c: c),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              }),
            ),

            // ── Sending indicator ────────────────────────────────────────────
            Obx(
              () => c.isSending.value
                  ? const LinearProgressIndicator(
                      color: AppColor.brownAccentPrimary,
                      backgroundColor: Color(0xFFF5EDD8),
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Input bar — hidden once job is accepted ───────────────────
            // c.job.requestId == null ? const SizedBox.shrink() : _InputBar(c: c),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Job Details Card
// ─────────────────────────────────────────────────────────────────────────────
class _JobDetailsCard extends StatefulWidget {
  final CounterOfferController c;

  const _JobDetailsCard({required this.c});

  @override
  State<_JobDetailsCard> createState() => _JobDetailsCardState();
}

class _JobDetailsCardState extends State<_JobDetailsCard> {
  bool _expanded = false;

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
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
      final now = DateTime.now();
      final isToday =
          dt.year == now.year && dt.month == now.month && dt.day == now.day;
      if (isToday) {
        final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
        final m = dt.minute.toString().padLeft(2, '0');
        return 'Today, $h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
      }
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          final status = widget.c.requestStatus.value;
          if (status == null) return const SizedBox.shrink();
          final request = status.request;
          final statusLabel = request.status.replaceAll('-', ' ').capitalize!;
          final chargeLabel = request.chargesStatus
              .replaceAll('-', ' ')
              .capitalize!;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF9F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE8D5B0)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusPill(label: statusLabel, icon: Icons.sync_rounded),
                _StatusPill(
                  label: 'Charges: $chargeLabel',
                  icon: Icons.receipt_long_outlined,
                ),
                if (request.agreedTotal != null)
                  _StatusPill(
                    label:
                        'Total: \$${request.agreedTotal!.toStringAsFixed(2)}',
                    icon: Icons.attach_money_rounded,
                  ),
              ],
            ),
          );
        }),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE8D5B0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                onExpansionChanged: (val) => setState(() => _expanded = val),
                title: Row(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      color: AppColor.brownAccentPrimary,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Job Details',
                      style: AppTextStyle.titleSmallSemiBold.copyWith(
                        color: AppColor.brownAccentPrimary,
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.c.job.budget != null && widget.c.job.budget! > 0)
                      Text(
                        '\$${widget.c.job.budget!.toStringAsFixed(0)}',
                        style: AppTextStyle.labelSmallMedium.copyWith(
                          color: AppColor.brownAccentPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColor.brownAccentPrimary,
                        size: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                children: [
                  Text(
                    widget.c.job.title ?? '',
                    style: AppTextStyle.titleMediumSemiBold.copyWith(
                      color: AppColor.blackShade1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (widget.c.job.sId != null && widget.c.job.sId!.isNotEmpty)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'JOB ID: ',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.blackColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '${widget.c.job.sId}',
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.brownAccentPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (widget.c.job.location != null &&
                      widget.c.job.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: AppColor.coolGrayText,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.c.job.location!,
                            style: AppTextStyle.bodySmallRegular.copyWith(
                              color: AppColor.coolGrayText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (widget.c.job.description != null &&
                      widget.c.job.description!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColor.brownAccentPrimary,
                            width: 3,
                          ),
                        ),
                      ),
                      child: _DescriptionContent(
                        description: widget.c.job.description!,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFEEEEEE), height: 1),
                  const SizedBox(height: 10),
                  if (widget.c.job.scheduledDate != null &&
                      widget.c.job.scheduledDate!.isNotEmpty)
                    InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Scheduled Date',
                      value: _formatDate(widget.c.job.scheduledDate),
                    )
                  else if (widget.c.job.serviceDate != null &&
                      widget.c.job.serviceDate!.isNotEmpty)
                    InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Service Date',
                      value: _formatDate(widget.c.job.serviceDate),
                    )
                  else if (widget.c.job.createdAt != null &&
                      widget.c.job.createdAt!.isNotEmpty)
                    InfoRow(
                      icon: Icons.access_time_outlined,
                      label: 'Posted On',
                      value: _formatDate(widget.c.job.createdAt),
                    ),
                  if (widget.c.job.serviceType != null &&
                      widget.c.job.serviceType?.name != null) ...[
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.build_outlined,
                      label: 'Service Type',
                      value: widget.c.job.serviceType?.name ?? '',
                    ),
                  ],
                  if (widget.c.job.budget != null &&
                      widget.c.job.budget! > 0) ...[
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.attach_money_outlined,
                      label: 'Budget',
                      value: '\$${widget.c.job.budget!.toStringAsFixed(2)}',
                    ),
                  ],
                  if (widget.c.job.estimatedTime != null &&
                      widget.c.job.estimatedTime!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Estimated Time',
                      value: widget.c.job.estimatedTime!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;

  const _StatusPill({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8D5B0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColor.brownAccentPrimary),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTextStyle.labelSmallMedium.copyWith(
              color: AppColor.brownAccentPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Description — HTML viewer with Read More / Show Less
// ─────────────────────────────────────────────────────────────────────────────
class _DescriptionContent extends StatefulWidget {
  final String description;

  const _DescriptionContent({required this.description});

  @override
  State<_DescriptionContent> createState() => _DescriptionContentState();
}

class _DescriptionContentState extends State<_DescriptionContent> {
  bool _expanded = false;

  bool _isHtml(String s) => s.contains('<') && s.contains('>');

  @override
  Widget build(BuildContext context) {
    final isHtml = _isHtml(widget.description);

    if (isHtml) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 280),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 120),
              child: ClipRect(child: _htmlWidget()),
            ),
            secondChild: _htmlWidget(),
          ),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _expanded ? '  Show less' : '  Read more',
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: AppColor.brownAccentPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Plain text — use ReadMoreText
    return ReadMoreText(
      widget.description,
      trimMode: TrimMode.Line,
      trimLines: 4,
      colorClickableText: AppColor.brownAccentPrimary,
      trimCollapsedText: '  Read more',
      trimExpandedText: '  Show less',
      style: AppTextStyle.bodySmallRegular.copyWith(
        color: AppColor.coolGrayText,
        height: 1.5,
      ),
      moreStyle: AppTextStyle.bodySmallMedium.copyWith(
        color: AppColor.brownAccentPrimary,
        fontWeight: FontWeight.w700,
      ),
      lessStyle: AppTextStyle.bodySmallMedium.copyWith(
        color: AppColor.brownAccentPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _htmlWidget() {
    return Html(
      data: widget.description,
      style: {
        'body': Style(
          fontFamily: 'Inter',
          fontSize: FontSize(13),
          color: AppColor.coolGrayText,
          lineHeight: LineHeight(1.55),
          margin: Margins.zero,
          padding: HtmlPaddings.zero,
        ),
        'p': Style(margin: Margins.only(bottom: 6)),
        'li': Style(fontSize: FontSize(13), color: AppColor.coolGrayText),
        'strong': Style(
          fontWeight: FontWeight.w700,
          color: AppColor.blackShade1,
        ),
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row — label + value with icon, used inside Job Details
// ─────────────────────────────────────────────────────────────────────────────
class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: AppColor.coolGrayText),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyle.bodySmallRegular.copyWith(
                color: AppColor.coolGrayText,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              value,
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: AppColor.blackShade1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Plain text bubble — admin (left) or technician (right)
// ─────────────────────────────────────────────────────────────────────────────
class _TextBubble extends StatelessWidget {
  final ChatMessage msg;

  const _TextBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    if (!msg.isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Avatar('C'),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                      border: Border.all(color: AppColor.lightGreyColor),
                    ),
                    child: Text(
                      msg.text,
                      style: AppTextStyle.bodyMediumRegular.copyWith(
                        color: AppColor.blackShade1,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg.time,
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Technician text message — right-aligned brown bubble
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColor.brownAccentPrimary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: AppTextStyle.bodyMediumRegular.copyWith(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg.time,
                      style: AppTextStyle.bodySmallRegular.copyWith(
                        color: AppColor.coolGrayText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.done_all,
                      size: 13,
                      color: AppColor.brownAccentPrimary,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Technician Counter Offer Bubble — read-only sent state
// ─────────────────────────────────────────────────────────────────────────────
class _TechnicianOfferBubble extends StatelessWidget {
  final ChatMessage msg;

  const _TechnicianOfferBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final hasAllowances = msg.allowances != null && msg.allowances!.isNotEmpty;
    final hasProposal = msg.proposal != null && msg.proposal!.trim().isNotEmpty;
    final isFixed = msg.counterAmount != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'YOUR COUNTER OFFER',
            style: AppTextStyle.labelMediumSemiBold.copyWith(
              color: AppColor.blackShade1,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isFixed) ...[
                      // ── Fixed price amount ──────────────────────────────────
                      Text(
                        'Counter Amount',
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$ ',
                              style: AppTextStyle.titleMediumSemiBold.copyWith(
                                color: AppColor.brownAccentPrimary,
                              ),
                            ),
                            Text(
                              msg.counterAmount!,
                              style: AppTextStyle.titleLargeBold.copyWith(
                                color: AppColor.blackShade1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (hasAllowances) ...[
                      // ── Additional charges list ─────────────────────────────
                      Text(
                        'Additional Charges',
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...msg.allowances!.map(
                        (a) => _AllowanceRowStatic(
                          label: a.getDisplayLabel(),
                          checked: a.checked.value,
                          amount: a.amountCtrl.text,
                        ),
                      ),
                    ],

                    // ── Proposal ──────────────────────────────────────────────
                    if (hasProposal) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Your Proposal',
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          msg.proposal!,
                          style: AppTextStyle.bodySmallRegular.copyWith(
                            color: AppColor.blackShade1,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Avatar — bottom-right overlapping the card
              const Positioned(bottom: -10, right: -6, child: _Avatar('G')),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                msg.time,
                style: AppTextStyle.bodySmallRegular.copyWith(
                  color: AppColor.coolGrayText,
                  fontSize: 11,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.done_all,
                size: 14,
                color: AppColor.brownAccentPrimary,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Static read-only allowance row — used inside the sent bubble
// ─────────────────────────────────────────────────────────────────────────────
class _AllowanceRowStatic extends StatelessWidget {
  final String label;
  final bool checked;
  final String amount;

  const _AllowanceRowStatic({
    required this.label,
    required this.checked,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: checked ? AppColor.brownAccentPrimary : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: checked
                    ? AppColor.brownAccentPrimary
                    : AppColor.coolGrayText,
              ),
            ),
            child: checked
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: AppColor.blackShade1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.lightGreyColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$ ',
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                  ),
                ),
                Text(
                  amount.isEmpty ? '0.00' : amount,
                  style: AppTextStyle.bodySmallMedium.copyWith(
                    color: amount.isEmpty
                        ? AppColor.coolGrayText
                        : AppColor.blackShade1,
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

// ─────────────────────────────────────────────────────────────────────────────
// Accepted Offer Bubble — shown when admin accepts the technician's counter offer
// Displays the agreed amount in a green confirmation card (left / admin side)
// ─────────────────────────────────────────────────────────────────────────────
class _AcceptedOfferBubble extends StatelessWidget {
  final ChatMessage msg;

  const _AcceptedOfferBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _Avatar('C'),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: const Color(0xFFB7EFCC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header row ──────────────────────────────────────────
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF16a34a),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Job Accepted!',
                            style: AppTextStyle.titleSmallSemiBold.copyWith(
                              color: const Color(0xFF16a34a),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ── Final agreed amount — always shown ──────────────────
                      Text(
                        'Final Agreed Price',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFB7EFCC)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '₹',
                              style: AppTextStyle.titleMediumSemiBold.copyWith(
                                color: const Color(0xFF16a34a),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              msg.acceptedAmount ?? '—',
                              style: AppTextStyle.titleLargeBold.copyWith(
                                color: AppColor.blackShade1,
                                fontSize: 26,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Confirmed',
                                style: AppTextStyle.labelSmallMedium.copyWith(
                                  color: const Color(0xFF16a34a),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── Confirmation text ───────────────────────────────────
                      Text(
                        msg.text.isNotEmpty
                            ? msg.text
                            : 'Your counter offer has been accepted. The job is now confirmed.',
                        style: AppTextStyle.bodySmallRegular.copyWith(
                          color: AppColor.coolGrayText,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.time,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    fontSize: 11,
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

// ─────────────────────────────────────────────────────────────────────────────
// Admin Revised Offer Bubble
// ─────────────────────────────────────────────────────────────────────────────
class _AdminOfferBubble extends StatelessWidget {
  final ChatMessage msg;
  final CounterOfferController c;

  const _AdminOfferBubble({required this.msg, required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _Avatar('C'),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: AppColor.lightGreyColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.text,
                        style: AppTextStyle.bodyMediumRegular.copyWith(
                          color: AppColor.blackShade1,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.offerAmount ?? '',
                        style: AppTextStyle.titleLargeBold.copyWith(
                          color: AppColor.brownAccentPrimary,
                        ),
                      ),
                      if (msg.chargeItem != null &&
                          msg.chargeItem!.counterHistory.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Negotiation history',
                          style: AppTextStyle.bodySmallMedium.copyWith(
                            color: AppColor.coolGrayText,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ...msg.chargeItem!.counterHistory.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Text(
                                  'Round ${entry.round}',
                                  style: AppTextStyle.labelSmallMedium.copyWith(
                                    color: AppColor.coolGrayText,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${entry.actor == 'technician' ? 'You' : 'Admin'} ${entry.action}',
                                    style: AppTextStyle.bodySmallRegular
                                        .copyWith(color: AppColor.blackShade1),
                                  ),
                                ),
                                Text(
                                  '\$${entry.amount.toStringAsFixed(2)}',
                                  style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.blackShade1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      Obx(() {
                        final taken = msg.actionTaken?.value;
                        final charge = msg.chargeItem;

                        if (charge != null && charge.status == 'rejected') {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: _OfferStatus(
                              label: 'Charge Rejected',
                              color: const Color(0xFFB42318),
                              background: const Color(0xFFFFE4E8),
                              icon: Icons.cancel_outlined,
                            ),
                          );
                        }

                        if (taken == true) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: _OfferStatus(
                              label: 'Offer Accepted',
                              color: Color(0xFF16a34a),
                              background: Color(0xFFDCFCE7),
                              icon: Icons.check_circle_outline,
                            ),
                          );
                        }

                        if (taken == false) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: _OfferStatus(
                              label: 'Waiting for admin',
                              color: AppColor.brownAccentPrimary,
                              background: Color(0xFFF5EDD8),
                              icon: Icons.hourglass_empty_rounded,
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton(
                                onPressed: c.isSending.value
                                    ? null
                                    : c.rejectFixedOffer,
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFB42318),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Reject'),
                              ),
                              const SizedBox(width: 2),
                              OutlinedButton(
                                onPressed: c.isSending.value
                                    ? null
                                    : () => c.counterAdminOffer(msg),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColor.brownAccentPrimary,
                                  side: const BorderSide(
                                    color: AppColor.brownAccentPrimary,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Counter',
                                  style: AppTextStyle.buttonSmall.copyWith(
                                    color: AppColor.brownAccentPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: c.isSending.value
                                    ? null
                                    : () => c.acceptOffer(msg),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.brownAccentPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Accept',
                                  style: AppTextStyle.buttonSmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  msg.time,
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.coolGrayText,
                    fontSize: 11,
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

class _OfferStatus extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  final IconData icon;

  const _OfferStatus({
    required this.label,
    required this.color,
    required this.background,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyle.bodySmallMedium.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Counter Offer Form Section
// ─────────────────────────────────────────────────────────────────────────────
class _CounterOfferFormSection extends StatelessWidget {
  final CounterOfferController c;

  const _CounterOfferFormSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR COUNTER OFFER',
          style: AppTextStyle.labelMediumSemiBold.copyWith(
            color: AppColor.blackShade1,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColor.brownAccentPrimary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fixed Price',
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              _WhiteField(
                controller: c.counterAmountCtrl,
                prefix: '\$ ',
                hint: 'Enter your fixed price',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                large: true,
                readOnly: false,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Text(
                    'Additional Charges',
                    style: AppTextStyle.bodySmallMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Optional',
                    style: AppTextStyle.labelSmallRegular.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Add travel, parts, or extra labor to your offer.',
                style: AppTextStyle.labelSmallRegular.copyWith(
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 10),
              ...c.allowances.map((a) => _EditableAllowanceRow(allowance: a)),

              const SizedBox(height: 14),

              // ── Your Proposal (shared) ──────────────────────────────────
              Text(
                'Your Proposal (optional)',
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: c.proposalCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Describe your proposal... (optional)',
                    hintStyle: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: AppTextStyle.bodySmallRegular.copyWith(
                    color: AppColor.blackShade1,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // ── Send button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: c.isSending.value
                        ? null
                        : () => c.sendCounterOffer(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      disabledBackgroundColor: Colors.white70,
                    ),
                    child: c.isSending.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColor.brownAccentPrimary,
                            ),
                          )
                        : Text(
                            'Send Counter Offer',
                            style: AppTextStyle.buttonMedium.copyWith(
                              color: AppColor.brownAccentPrimary,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editable allowance row with "Other" text field
// ─────────────────────────────────────────────────────────────────────────────
class _EditableAllowanceRow extends StatelessWidget {
  final Allowance allowance;

  const _EditableAllowanceRow({required this.allowance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // ── Checkbox ───────────────────────────────────────────────────────
          Obx(
            () => GestureDetector(
              onTap: () {
                allowance.checked.value = !allowance.checked.value;
                if (!allowance.checked.value) {
                  allowance.amountCtrl.clear();
                }
              },
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: allowance.checked.value
                      ? AppColor.brownAccentPrimary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: allowance.checked.value
                        ? AppColor.brownAccentPrimary
                        : AppColor.coolGrayText,
                  ),
                ),
                child: allowance.checked.value
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // ── Label with "Other" special handling ───────────────────────────
          Expanded(
            child: allowance.label == 'Other'
                ? Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        border: allowance.checked.value
                            ? Border.all(color: AppColor.lightGreyColor)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: allowance.otherLabelCtrl,
                        enabled: allowance.checked.value,
                        style: AppTextStyle.bodySmallMedium.copyWith(
                          color: allowance.checked.value
                              ? AppColor.blackShade1
                              : AppColor.coolGrayText.withOpacity(0.3),
                        ),
                        decoration: InputDecoration(
                          hintText: allowance.checked.value
                              ? 'Enter custom label...'
                              : 'Other (click checkbox to edit)',
                          hintStyle: AppTextStyle.bodySmallMedium.copyWith(
                            color: allowance.checked.value
                                ? AppColor.coolGrayText
                                : AppColor.coolGrayText.withOpacity(0.3),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                        ),
                      ),
                    ),
                  )
                : Text(
                    allowance.label,
                    style: AppTextStyle.bodySmallMedium.copyWith(
                      color: AppColor.blackShade1,
                    ),
                  ),
          ),

          const SizedBox(width: 8),

          // ── Amount field ──────────────────────────────────────────────────
          SizedBox(
            width: 85,
            child: Obx(
              () => TextField(
                controller: allowance.amountCtrl,
                enabled: allowance.checked.value,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: AppTextStyle.bodySmallRegular.copyWith(
                    color: allowance.checked.value
                        ? AppColor.coolGrayText
                        : AppColor.coolGrayText.withOpacity(0.3),
                  ),
                  hintText: '0.00',
                  hintStyle: AppTextStyle.bodySmallRegular.copyWith(
                    color: allowance.checked.value
                        ? AppColor.coolGrayText
                        : AppColor.coolGrayText.withOpacity(0.3),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColor.lightGreyColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColor.lightGreyColor,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColor.brownAccentPrimary,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: AppColor.lightGreyColor.withOpacity(0.5),
                    ),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                ),
                style: AppTextStyle.bodySmallMedium.copyWith(
                  color: allowance.checked.value
                      ? AppColor.blackShade1
                      : AppColor.coolGrayText.withOpacity(0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// White text field — used inside the counter offer form
// ─────────────────────────────────────────────────────────────────────────────
class _WhiteField extends StatelessWidget {
  final TextEditingController controller;
  final String? prefix;
  final String hint;
  final TextInputType keyboardType;
  final bool large;
  final bool readOnly;

  const _WhiteField({
    required this.controller,
    this.prefix,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.large = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: readOnly ? Border.all(color: AppColor.lightGreyColor) : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        enabled: !readOnly,
        decoration: InputDecoration(
          prefixText: readOnly ? null : prefix,
          prefixStyle:
              (large
                      ? AppTextStyle.titleMediumSemiBold
                      : AppTextStyle.bodyMediumRegular)
                  .copyWith(
                    color: readOnly
                        ? AppColor.coolGrayText
                        : AppColor.brownAccentPrimary,
                  ),
          hintText: hint,
          hintStyle:
              (large
                      ? AppTextStyle.titleLargeBold
                      : AppTextStyle.bodyMediumRegular)
                  .copyWith(color: AppColor.coolGrayText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
        style:
            (large
                    ? AppTextStyle.titleLargeBold
                    : AppTextStyle.bodyMediumRegular)
                .copyWith(
                  color: readOnly
                      ? AppColor.coolGrayText
                      : AppColor.blackShade1,
                ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input bar — pinned at bottom
// ─────────────────────────────────────────────────────────────────────────────
class _InputBar extends StatelessWidget {
  final CounterOfferController c;

  const _InputBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: c.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyle.bodyMediumRegular.copyWith(
                  color: AppColor.coolGrayText,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => c.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: c.sendMessage,
            child: Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: AppColor.brownAccentPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Avatar circle
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String label;

  const _Avatar(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColor.brownAccentPrimary,
        border: Border.all(color: Colors.white),
      ),
      child: Text(
        label,
        style: AppTextStyle.labelSmallMedium.copyWith(
          color: Colors.white,
          fontSize: 9,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invoice Card
// ─────────────────────────────────────────────────────────────────────────────
class _InvoiceCard extends StatelessWidget {
  final InvoiceModel invoice;

  const _InvoiceCard({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isPaid = invoice.status == 'paid';
    final isFinalised = invoice.status == 'finalised';

    final statusColor = isPaid
        ? const Color(0xFF16a34a)
        : isFinalised
        ? const Color(0xFF2563eb)
        : AppColor.coolGrayText;

    final statusBg = isPaid
        ? const Color(0x1F16a34a)
        : isFinalised
        ? const Color(0x1A2563eb)
        : const Color(0xFFF3F4F6);

    final statusLabel = isPaid
        ? '💰 Paid'
        : isFinalised
        ? '✓ Finalised'
        : 'Draft';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFF0E8DC)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFDF9F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(bottom: BorderSide(color: Color(0xFFF0E8DC))),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_outlined,
                  size: 18,
                  color: AppColor.brownAccentPrimary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🧾 ${invoice.invoiceNumber}',
                    style: AppTextStyle.titleSmallSemiBold.copyWith(
                      color: AppColor.blackShade1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyle.labelSmallMedium.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Line items
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: Column(
              children: [
                _InvoiceRow(
                  label: 'Fixed Job Charge',
                  amount: invoice.fixedJobCharge,
                  bold: false,
                ),
                ...invoice.additionalCharges.map(
                  (item) => _InvoiceRow(
                    label: item.label,
                    sublabel: item.description,
                    amount: item.agreedAmount,
                    bold: false,
                  ),
                ),
                const Divider(color: Color(0xFFF0E8DC), height: 16),
                _InvoiceRow(
                  label: 'Total',
                  amount: invoice.totalAmount,
                  bold: true,
                ),
              ],
            ),
          ),

          // Footer
          if (isPaid || isFinalised)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 12),
              child: Text(
                isPaid
                    ? '✓ Payment received — check your wallet'
                    : '⏳ Invoice finalised — awaiting admin payment',
                style: AppTextStyle.bodySmallRegular.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox(height: 12),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invoice row — label + optional sublabel + amount
// ─────────────────────────────────────────────────────────────────────────────
class _InvoiceRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final double amount;
  final bool bold;

  const _InvoiceRow({
    required this.label,
    this.sublabel,
    required this.amount,
    required this.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: bold
                      ? AppTextStyle.titleSmallSemiBold.copyWith(
                          color: AppColor.blackShade1,
                        )
                      : AppTextStyle.bodySmallMedium.copyWith(
                          color: AppColor.blackShade1,
                        ),
                ),
                if (sublabel != null && sublabel!.isNotEmpty)
                  Text(
                    sublabel!,
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: bold
                ? AppTextStyle.titleSmallSemiBold.copyWith(
                    color: AppColor.brownAccentPrimary,
                  )
                : AppTextStyle.bodySmallMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
          ),
        ],
      ),
    );
  }
}
