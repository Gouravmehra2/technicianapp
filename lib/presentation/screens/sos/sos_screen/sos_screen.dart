import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';
import 'package:technicianapp/constant/app_text_style/app_text_style.dart';
import 'package:technicianapp/constant/common_widgets/common_button.dart';
import 'package:technicianapp/constant/common_widgets/my_scaffold.dart';
import 'package:technicianapp/presentation/screens/sos/sos_screen/sos_controller.dart';

class SosScreen extends GetView<SosController> {
  const SosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xffF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.chevron_left, color: Colors.black, size: 24),
          ),
        ),
        title: Text(
          'Emergency Assistance',
          style: AppTextStyle.titleLargeBold.copyWith(color: Colors.black),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
        children: [
          // ── SOS Button ─────────────────────────────────────────────────
          Center(child: _SosButton()),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Tap & Hold for 3 Seconds',
              style: AppTextStyle.titleLargeBold.copyWith(
                color: AppColor.brownAccentPrimary,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'TO PREVENT ACCIDENTAL TRIGGERS',
              style: AppTextStyle.bodySmallMedium.copyWith(
                color: AppColor.blackShade1,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Emergency Services Card ────────────────────────────────────
          _ServiceCard(
            title: 'Emergency Services',
            subtitle: 'Contact local police, ambulance, or fire services.',
            icon: Icons.local_police_outlined,
            iconColor: Colors.red,
            actions: [
              _ActionButton(
                label: 'Call Emergency Services',
                icon: Icons.phone_outlined,
                onTap: controller.callEmergencyServices,
                isDark: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── 1App Safety Team Card ──────────────────────────────────────
          _ServiceCard(
            title: '1App Safety Team',
            subtitle: '24/7 priority assistance for marketplace safety.',
            icon: Icons.verified_user_outlined,
            iconColor: AppColor.brownAccentPrimary,
            actions: [
              _ActionButton(
                label: 'Call Safety Team',
                icon: Icons.phone_outlined,
                onTap: controller.callSafetyTeam,
                isDark: true,
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Live Chat',
                icon: Icons.chat_bubble_outline,
                onTap: controller.openLiveChat,
                isDark: false,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Share Live Location Card ───────────────────────────────────
          _ServiceCard(
            title: 'Share Live Location',
            subtitle: 'Update contacts and safety team on your movement.',
            icon: Icons.my_location_outlined,
            iconColor: AppColor.brownAccentPrimary,
            actions: [
              CommonButton(
                label: 'Share Location',
                onTap: controller.shareLocation,
                backgroundColor: AppColor.brownAccentPrimary,
                foregroundColor: Colors.white,
                height: 52,
                boxShadow: const [],
                leadingIcon: const Icon(Icons.location_on_outlined, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Currently Assigned Technician ──────────────────────────────
          Text('Currently Assigned Technician', style: AppTextStyle.titleLargeBold),
          const SizedBox(height: 12),
          _TechnicianCard(controller: controller),
          const SizedBox(height: 24),

          // ── Emergency Contacts ─────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Emergency Contacts', style: AppTextStyle.titleLargeBold),
              GestureDetector(
                onTap: controller.addEmergencyContact,
                child: Text(
                  '+ Add',
                  style: AppTextStyle.bodyMediumMedium.copyWith(
                    color: AppColor.brownAccentPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.emergencyContacts.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (_, i) {
                final c = controller.emergencyContacts[i];
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(c.imageUrl),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.name,
                      style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF0F0F0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '"When SOS is triggered, location and booking details are shared automatically with these contacts."',
              style: AppTextStyle.bodySmallRegular.copyWith(
                color: AppColor.coolGrayText,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Quick Actions ──────────────────────────────────────────────
          Text('Quick Actions', style: AppTextStyle.titleLargeBold),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _QuickActionTile(
                icon: Icons.block,
                label: 'Report\nMisconduct',
                iconColor: Colors.red,
                onTap: controller.reportMisconduct,
              ),
              _QuickActionTile(
                icon: Icons.camera_alt_outlined,
                label: 'Upload Evidence',
                iconColor: AppColor.brownAccentPrimary,
                onTap: controller.uploadEvidence,
              ),
              _QuickActionTile(
                icon: Icons.my_location,
                label: 'Share Location',
                iconColor: Colors.blue,
                onTap: controller.shareLocation,
              ),
              _QuickActionTile(
                icon: Icons.call_missed_outgoing,
                label: 'Request Call Back',
                iconColor: AppColor.greenColor,
                onTap: controller.requestCallBack,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── SOS pulse button ──────────────────────────────────────────────────────────

class _SosButton extends StatefulWidget {
  @override
  State<_SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<_SosButton> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) => Transform.scale(scale: _pulse.value, child: child),
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xffF5B8B8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xffCC3333),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ring 1
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                ),
                // ring 2
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_outlined, color: Color(0xffF5B8B8), size: 44),
                    const SizedBox(height: 4),
                    Text(
                      'EMERGENCY SOS',
                      style: AppTextStyle.labelMediumSemiBold.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Service card ──────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<Widget> actions;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyle.titleLargeBold),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyle.bodyMediumRegular.copyWith(color: AppColor.coolGrayText),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: iconColor, size: 24),
            ],
          ),
          const SizedBox(height: 14),
          ...actions,
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      label: label,
      onTap: onTap,
      backgroundColor: isDark ? AppColor.blackColor : const Color(0xffF0F0F0),
      foregroundColor: isDark ? Colors.white : AppColor.blackShade1,
      height: 52,
      boxShadow: const [],
      leadingIcon: Icon(icon, color: isDark ? Colors.white : AppColor.blackShade1, size: 18),
    );
  }
}

// ── Technician card ───────────────────────────────────────────────────────────

class _TechnicianCard extends StatelessWidget {
  final SosController controller;

  const _TechnicianCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.lightGreyColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: const NetworkImage(
                      'https://randomuser.me/api/portraits/men/32.jpg',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColor.greenColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Gourav Dev', style: AppTextStyle.titleMediumSemiBold),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColor.brownAccentPrimary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'EXPERT',
                            style: AppTextStyle.labelSmallMedium.copyWith(
                              color: AppColor.brownAccentPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Booking ID: #A12345',
                      style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.directions_car_outlined, size: 14, color: AppColor.coolGrayText),
                        const SizedBox(width: 4),
                        Text(
                          'White Tesla Model 3 • ABC-123',
                          style: AppTextStyle.bodySmallRegular.copyWith(color: AppColor.coolGrayText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  label: 'Call',
                  onTap: controller.callTechnician,
                  backgroundColor: AppColor.blackColor,
                  foregroundColor: Colors.white,
                  height: 46,
                  boxShadow: const [],
                  leadingIcon: const Icon(Icons.phone_outlined, color: Colors.white, size: 16),
                  leadingSpacing: 6,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CommonButton(
                  label: 'Message',
                  onTap: controller.messageTechnician,
                  backgroundColor: const Color(0xffF0F0F0),
                  foregroundColor: AppColor.blackShade1,
                  height: 46,
                  boxShadow: const [],
                  leadingIcon: const Icon(Icons.chat_bubble_outline, color: AppColor.blackShade1, size: 16),
                  leadingSpacing: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick action tile ─────────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColor.lightGreyColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyle.bodySmallMedium.copyWith(color: AppColor.blackShade1),
            ),
          ],
        ),
      ),
    );
  }
}
