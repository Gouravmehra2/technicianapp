import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/privacy_policy_screen/privacy_policy_controller.dart';

class PrivacyPolicyScreen extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: AppColor.brownAccentPrimary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Privacy Policy',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              children: [
                // ── Hero title ─────────────────────────────────────────────
                _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '1APP Privacy Policy',
                        style: AppTextStyle.headlineLargeBold.copyWith(
                          color: AppColor.blackShade1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'This Privacy Notice ("Notice") outlines how 1App and its affiliates, referred to as "we," collect, use, and disclose information about customers and visitors of our websites, advertisements, and software or services.',
                        style: AppTextStyle.bodyMediumRegular.copyWith(
                          color: AppColor.coolGrayText,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BlockQuote(
                        text:
                            '"The terms \'1App\', \'we\', \'us\', and \'our\' include both the company and its affiliates. These entities collectively own and operate https://www.technicianapp.com/ and provide a range of software and services now or in the future."',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Dynamic sections ───────────────────────────────────────
                ...controller.sections.map(
                  (section) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon + title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppColor.brownAccentPrimary
                                      .withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  section.icon,
                                  size: 22,
                                  color: AppColor.brownAccentPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  section.title,
                                  style:
                                      AppTextStyle.headlineSmallSemiBold
                                          .copyWith(
                                    color: AppColor.blackShade1,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // Intro paragraph
                          if (section.intro.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              section.intro,
                              style: AppTextStyle.bodyMediumRegular.copyWith(
                                color: AppColor.coolGrayText,
                                height: 1.6,
                              ),
                            ),
                          ],

                          // Block quotes
                          if (section.blockQuotes.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            ...section.blockQuotes.map(
                              (q) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _BlockQuote(text: q),
                              ),
                            ),
                          ],

                          // Sub-sections
                          if (section.subSections.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ...section.subSections.map(
                              (sub) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sub.title,
                                      style: AppTextStyle.titleSmallSemiBold
                                          .copyWith(
                                        color: AppColor.brownAccentPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      sub.body,
                                      style:
                                          AppTextStyle.bodyMediumRegular
                                              .copyWith(
                                        color: AppColor.coolGrayText,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          // Link
                          if (section.linkText != null) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                section.linkText!,
                                style: AppTextStyle.bodyMediumMedium.copyWith(
                                  color: AppColor.brownAccentPrimary,
                                  decoration: TextDecoration.underline,
                                  decorationColor:
                                      AppColor.brownAccentPrimary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Footer note ────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'As a customer or user of our Software and Services, including installation of TVs, smart home devices, audio components, etc., you agree to this Notice by using our Software and Services.',
                    style: AppTextStyle.bodySmallRegular.copyWith(
                      color: AppColor.coolGrayText,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // ── Accept button ──────────────────────────────────────────────
          // Container(
          //   color: const Color(0xffF6F6F6),
          //   padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          //   child: CommonButton(
          //     label: 'Accept Terms',
          //     onTap: () => Get.back(),
          //     backgroundColor: AppColor.brownAccentPrimary,
          //     height: 52,
          //   ),
          // ),
        ],
      ),
    );
  }
}

// ── Reusable card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColor.lightGreyColor,
        ),
      ),
      child: child,
    );
  }
}

// ── Block quote ───────────────────────────────────────────────────────────────

class _BlockQuote extends StatelessWidget {
  final String text;

  const _BlockQuote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColor.neutral1,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            color: AppColor.brownAccentPrimary.withValues(alpha: 0.40),
            width: 3,
          ),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyle.bodySmallRegular.copyWith(
          color: AppColor.coolGrayText,
          fontStyle: FontStyle.italic,
          height: 1.6,
        ),
      ),
    );
  }
}
