import 'package:flutter/material.dart';
import 'package:technicianapp/constant/app_color/app_color.dart';

class EmptyApiState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRefresh;
  final bool compact;

  const EmptyApiState({
    super.key,
    this.title = 'No New Jobs Found',
    this.message =
        'Stay on this screen. We’ll notify you\nas soon as a new job is available.',
    this.onRefresh,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact();
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Illustration(size: 116),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF242424),
                  ),
                ),
                const SizedBox(height: 18),
                _Message(message: message),
                if (onRefresh != null) ...[
                  const SizedBox(height: 18),
                  _RefreshButton(onRefresh: onRefresh!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompact() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Illustration(size: 76),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF242424),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message.replaceAll('\n', ' '),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColor.coolGrayText,
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Now'),
              style: TextButton.styleFrom(
                foregroundColor: AppColor.brownAccentPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  final double size;

  const _Illustration({this.size = 220});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF2E1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.business_center_rounded,
        size: size * 0.48,
        color: Color(0xFF9A5C25),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final String message;

  const _Message({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF7),
        border: Border.all(color: const Color(0xFFF3DCC4), width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: Color(0xFF895B2C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  final VoidCallback onRefresh;

  const _RefreshButton({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRefresh,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB07A2C),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 11),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: const Text(
          'Refresh Now',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
