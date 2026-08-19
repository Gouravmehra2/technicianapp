import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/app_shimmer.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/charges_model.dart';
import 'counter_offer_controller.dart';

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
          style: AppTextStyle.titleLargeBold
              .copyWith(color: AppColor.blackShade1),
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
                    1 + msgCount + (invoiceVisible ? 1 : 0) + (showForm ? 1 : 0);

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
                        child: msg.type == MsgType.technicianOffer
                            ? _TechnicianOfferBubble(msg: msg)
                            : msg.type == MsgType.adminOffer
                                ? _AdminOfferBubble(msg: msg, c: c)
                                : _TextBubble(msg: msg),
                      );
                    }

                    // ── Invoice card ──────────────────────────────────────────
                    if (invoiceVisible && i == msgCount + 1) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
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
            Obx(() => c.isSending.value
                ? const LinearProgressIndicator(
                    color: AppColor.brownAccentPrimary,
                    backgroundColor: Color(0xFFF5EDD8),
                  )
                : const SizedBox.shrink()),

            // ── Input bar ────────────────────────────────────────────────────
            _InputBar(c: c),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8D5B0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: false,
            tilePadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            onExpansionChanged: (val) => setState(() => _expanded = val),
            title: Row(
              children: [
                const Icon(Icons.receipt_long_outlined,
                    color: AppColor.brownAccentPrimary, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Job Details',
                  style: AppTextStyle.titleSmallSemiBold
                      .copyWith(color: AppColor.brownAccentPrimary),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.brownAccentPrimary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'New Request',
                    style: AppTextStyle.labelSmallMedium
                        .copyWith(color: AppColor.brownAccentPrimary),
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppColor.brownAccentPrimary, size: 20),
                ),
              ],
            ),
            children: [
              Text(
                widget.c.job.title,
                style: AppTextStyle.titleMediumSemiBold
                    .copyWith(color: AppColor.blackShade1),
              ),
              const SizedBox(height: 2),
              Text(
                'Req #892-A',
                style: AppTextStyle.bodySmallRegular
                    .copyWith(color: AppColor.brownAccentPrimary),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 14, color: AppColor.coolGrayText),
                  const SizedBox(width: 4),
                  Text(
                    'Northside, Austin, TX',
                    style: AppTextStyle.bodySmallRegular
                        .copyWith(color: AppColor.coolGrayText),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(
                        color: AppColor.brownAccentPrimary, width: 3),
                  ),
                ),
                child: Text(
                  '"Looking to get an 85-inch Samsung mounted on a brick fireplace. Need all cables concealed. I do not have a bracket yet."',
                  style: AppTextStyle.bodySmallRegular
                      .copyWith(color: AppColor.coolGrayText, height: 1.5),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFFEEEEEE), height: 1),
              const SizedBox(height: 10),
              _InfoRow(
                  icon: Icons.access_time_outlined,
                  label: 'Requested Time',
                  value: 'Today, 2:00 PM'),
              const SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.build_outlined,
                  label: 'Service Type',
                  value: 'TV Installation'),
              const SizedBox(height: 8),
              _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Customer',
                  value: 'Michael T.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColor.coolGrayText),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTextStyle.bodySmallRegular
                    .copyWith(color: AppColor.coolGrayText)),
            Text(value,
                style: AppTextStyle.bodySmallMedium
                    .copyWith(color: AppColor.blackShade1)),
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
    final isUser = msg.isUser;
    if (!isUser) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar('C'),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
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
                        color: AppColor.coolGrayText, fontSize: 11),
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
                          color: AppColor.coolGrayText, fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.done_all,
                        size: 13, color: AppColor.brownAccentPrimary),
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
// Shows fixed counter amount. Additional charges and proposal are optional.
// ─────────────────────────────────────────────────────────────────────────────
class _TechnicianOfferBubble extends StatelessWidget {
  final ChatMessage msg;
  const _TechnicianOfferBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final hasAllowances =
        msg.allowances != null && msg.allowances!.isNotEmpty;
    final hasProposal =
        msg.proposal != null && msg.proposal!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Label — outside, above the card, right-aligned
          Text(
            'YOUR COUNTER OFFER',
            style: AppTextStyle.labelMediumSemiBold.copyWith(
              color: AppColor.blackShade1,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Brown card
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                decoration: BoxDecoration(
                  color: AppColor.brownAccentPrimary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Counter Amount (fixed price) ──────────────────────────
                    Text(
                      'Counter Amount',
                      style: AppTextStyle.bodySmallMedium
                          .copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
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
                                color: AppColor.brownAccentPrimary),
                          ),
                          Text(
                            msg.counterAmount ?? '0.00',
                            style: AppTextStyle.titleLargeBold
                                .copyWith(color: AppColor.blackShade1),
                          ),
                        ],
                      ),
                    ),

                    // ── Additional Allowances (only if any were added) ─────────
                    if (hasAllowances) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Text(
                            'Additional Allowances',
                            style: AppTextStyle.bodySmallMedium
                                .copyWith(color: Colors.white70),
                          ),
                          const Spacer(),
                          Text(
                            'Optional',
                            style: AppTextStyle.labelSmallRegular
                                .copyWith(color: Colors.white54),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...msg.allowances!.map((a) => _AllowanceRowStatic(
                            label: a.label,
                            checked: a.checked.value,
                            amount: a.amountCtrl.text,
                          )),
                    ],

                    // ── Proposal (only if filled) ──────────────────────────────
                    if (hasProposal) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Your Proposal',
                        style: AppTextStyle.bodySmallMedium
                            .copyWith(color: Colors.white70),
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
                              color: AppColor.blackShade1, height: 1.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // "G" avatar — bottom-right overlapping the card
              Positioned(
                bottom: -10,
                right: -6,
                child: _Avatar('G'),
              ),
            ],
          ),

          // Time + double tick
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                msg.time,
                style: AppTextStyle.bodySmallRegular
                    .copyWith(color: AppColor.coolGrayText, fontSize: 11),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.done_all,
                  size: 14, color: AppColor.brownAccentPrimary),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// Static read-only allowance row used inside the sent bubble
class _AllowanceRowStatic extends StatelessWidget {
  final String label;
  final bool checked;
  final String amount;
  const _AllowanceRowStatic(
      {required this.label, required this.checked, required this.amount});

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
              color: checked
                  ? AppColor.brownAccentPrimary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                  color: checked
                      ? AppColor.brownAccentPrimary
                      : AppColor.coolGrayText),
            ),
            child: checked
                ? const Icon(Icons.check, size: 12, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: AppTextStyle.bodySmallMedium
                    .copyWith(color: AppColor.blackShade1)),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: AppColor.lightGreyColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$ ',
                    style: AppTextStyle.bodySmallRegular
                        .copyWith(color: AppColor.coolGrayText)),
                Text(
                  amount.isEmpty ? '0.00' : amount,
                  style: AppTextStyle.bodySmallMedium.copyWith(
                      color: amount.isEmpty
                          ? AppColor.coolGrayText
                          : AppColor.blackShade1),
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
          _Avatar('C'),
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
                            color: AppColor.blackShade1, height: 1.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        msg.offerAmount ?? '',
                        style: AppTextStyle.titleLargeBold
                            .copyWith(color: AppColor.brownAccentPrimary),
                      ),
                      Obx(() {
                        final taken = msg.actionTaken?.value;

                        if (taken == true) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColor.lightGreen1Color,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '✓ Offer Accepted',
                                style: AppTextStyle.bodySmallMedium
                                    .copyWith(color: AppColor.green2Color),
                              ),
                            ),
                          );
                        }

                        if (taken == false) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5EDD8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Counter Offer Sent',
                                style: AppTextStyle.bodySmallMedium.copyWith(
                                    color: AppColor.brownAccentPrimary),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton(
                                onPressed: () => c.counterAdminOffer(msg),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor:
                                      AppColor.brownAccentPrimary,
                                  side: const BorderSide(
                                      color: AppColor.brownAccentPrimary),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Counter',
                                  style: AppTextStyle.buttonSmall.copyWith(
                                      color: AppColor.brownAccentPrimary),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => c.acceptOffer(msg),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColor.brownAccentPrimary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Accept',
                                  style: AppTextStyle.buttonSmall
                                      .copyWith(color: Colors.white),
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
                  style: AppTextStyle.bodySmallRegular
                      .copyWith(color: AppColor.coolGrayText, fontSize: 11),
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
// Counter Offer Form Section
// Fixed counter amount field + optional additional charges (toggled) + proposal
// ─────────────────────────────────────────────────────────────────────────────
class _CounterOfferFormSection extends StatelessWidget {
  final CounterOfferController c;
  const _CounterOfferFormSection({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "YOUR COUNTER OFFER" label — above the brown card
        Text(
          'YOUR COUNTER OFFER',
          style: AppTextStyle.labelMediumSemiBold.copyWith(
            color: AppColor.blackShade1,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),

        // Brown card form
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
              // ── Counter Amount (fixed, always visible) ────────────────────
              Text(
                'Counter Amount',
                style: AppTextStyle.bodySmallMedium
                    .copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              _WhiteField(
                controller: c.counterAmountCtrl,
                prefix: '\$ ',
                hint: '350.00',
                keyboardType: TextInputType.number,
                large: true,
              ),
              const SizedBox(height: 14),

              // ── Additional Charges toggle row ─────────────────────────────
              GestureDetector(
                onTap: c.toggleAdditionalCharges,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'Additional Charges',
                      style: AppTextStyle.bodySmallMedium
                          .copyWith(color: Colors.white70),
                    ),
                    const Spacer(),
                    Obx(() => AnimatedRotation(
                          turns:
                              c.showAdditionalCharges.value ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        )),
                  ],
                ),
              ),

              // ── Additional charges rows (collapsible) ─────────────────────
              Obx(() => c.showAdditionalCharges.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Column(
                        children: c.allowances
                            .map((a) => _EditableAllowanceRow(allowance: a))
                            .toList(),
                      ),
                    )
                  : const SizedBox.shrink()),

              const SizedBox(height: 14),

              // ── Your Proposal (optional) ──────────────────────────────────
              Text(
                'Your Proposal',
                style: AppTextStyle.bodySmallMedium
                    .copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 2),
              Text(
                'Optional',
                style: AppTextStyle.labelSmallRegular
                    .copyWith(color: Colors.white54),
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
                    hintStyle: AppTextStyle.bodySmallRegular
                        .copyWith(color: AppColor.coolGrayText),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                  style: AppTextStyle.bodySmallRegular
                      .copyWith(color: AppColor.blackShade1, height: 1.6),
                ),
              ),
              const SizedBox(height: 14),

              // ── Send button ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed:
                          c.isSending.value ? null : c.sendCounterOffer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
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
                                  color: AppColor.brownAccentPrimary),
                            ),
                    )),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editable allowance row
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
          Obx(() => GestureDetector(
                onTap: () =>
                    allowance.checked.value = !allowance.checked.value,
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
                            : AppColor.coolGrayText),
                  ),
                  child: allowance.checked.value
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              )),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              allowance.label,
              style: AppTextStyle.bodySmallMedium
                  .copyWith(color: AppColor.blackShade1),
            ),
          ),
          SizedBox(
            width: 85,
            child: TextField(
              controller: allowance.amountCtrl,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: AppTextStyle.bodySmallRegular
                    .copyWith(color: AppColor.coolGrayText),
                hintText: '0.00',
                hintStyle: AppTextStyle.bodySmallRegular
                    .copyWith(color: AppColor.coolGrayText),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColor.lightGreyColor)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: AppColor.lightGreyColor)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: AppColor.brownAccentPrimary)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              ),
              style: AppTextStyle.bodySmallMedium
                  .copyWith(color: AppColor.blackShade1),
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
  const _WhiteField({
    required this.controller,
    this.prefix,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixText: prefix,
          prefixStyle: (large
                  ? AppTextStyle.titleMediumSemiBold
                  : AppTextStyle.bodyMediumRegular)
              .copyWith(color: AppColor.brownAccentPrimary),
          hintText: hint,
          hintStyle: (large
                  ? AppTextStyle.titleLargeBold
                  : AppTextStyle.bodyMediumRegular)
              .copyWith(color: AppColor.coolGrayText),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
        style: (large
                ? AppTextStyle.titleLargeBold
                : AppTextStyle.bodyMediumRegular)
            .copyWith(color: AppColor.blackShade1),
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
                hintStyle: AppTextStyle.bodyMediumRegular
                    .copyWith(color: AppColor.coolGrayText),
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
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 18),
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
    return CircleAvatar(
      radius: 14,
      backgroundColor: AppColor.brownAccentPrimary,
      child: Text(
        label,
        style: AppTextStyle.labelSmallMedium
            .copyWith(color: Colors.white, fontSize: 9),
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

    final statusLabel =
        isPaid ? '💰 Paid' : isFinalised ? '✓ Finalised' : 'Draft';

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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFDF9F5),
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
              border: Border(
                bottom: BorderSide(color: Color(0xFFF0E8DC)),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.receipt_outlined,
                    size: 18, color: AppColor.brownAccentPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🧾 ${invoice.invoiceNumber}',
                    style: AppTextStyle.titleSmallSemiBold
                        .copyWith(color: AppColor.blackShade1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: AppTextStyle.labelSmallMedium
                        .copyWith(color: statusColor),
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
                      ? AppTextStyle.titleSmallSemiBold
                          .copyWith(color: AppColor.blackShade1)
                      : AppTextStyle.bodySmallMedium
                          .copyWith(color: AppColor.blackShade1),
                ),
                if (sublabel != null && sublabel!.isNotEmpty)
                  Text(
                    sublabel!,
                    style: AppTextStyle.bodySmallRegular
                        .copyWith(color: AppColor.coolGrayText),
                  ),
              ],
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: bold
                ? AppTextStyle.titleSmallSemiBold
                    .copyWith(color: AppColor.brownAccentPrimary)
                : AppTextStyle.bodySmallMedium
                    .copyWith(color: AppColor.brownAccentPrimary),
          ),
        ],
      ),
    );
  }
}
