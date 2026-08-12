import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingSafetyStep {
  final int number;
  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
  final String tip;

  const BookingSafetyStep({
    required this.number,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.tip,
  });
}

class BookingSafetyController extends GetxController {
  final List<BookingSafetyStep> steps = const [
    BookingSafetyStep(
      number: 1,
      icon: Icons.person_outline_rounded,
      title: 'Verify Professional Arrival',
      subtitle: 'Start Service with OTP',
      body:
          'Before work begins, verify the professional assigned to your booking and share the OTP only after they arrive at your location.',
      tip: 'This helps ensure the right professional is attending your service.',
    ),
    BookingSafetyStep(
      number: 2,
      icon: Icons.receipt_long_outlined,
      title: 'Review & Approve Estimate',
      subtitle: 'Check Pricing Before Work Starts',
      body:
          'Review the service estimate and any additional work recommendations carefully. Approve only the charges you agree with.',
      tip: 'All approved estimates remain recorded for your reference.',
    ),
    BookingSafetyStep(
      number: 3,
      icon: Icons.phone_android_outlined,
      title: 'Track Service Updates',
      subtitle: 'Stay Informed Throughout the Job',
      body:
          'Monitor booking progress, service status, and important updates directly within the app.',
      tip: 'Real-time tracking keeps everything transparent and documented.',
    ),
    BookingSafetyStep(
      number: 4,
      icon: Icons.credit_card_outlined,
      title: 'Complete Secure Payment',
      subtitle: 'Pay After Service Completion',
      body:
          'Make payments only after the service has been completed and reviewed.',
      tip:
          'Secure payments help maintain accurate records and enable faster support if required.',
    ),
    BookingSafetyStep(
      number: 5,
      icon: Icons.star_border_rounded,
      title: 'Rate & Share Feedback',
      subtitle: 'Help Us Maintain Quality',
      body:
          'Rate your service experience and provide feedback once the job is completed.',
      tip:
          'Your reviews help us improve service quality and recognize top-performing professionals.',
    ),
  ];

  final List<String> safetyReportItems = const [
    'Unprofessional behavior',
    'Unapproved additional charges',
    'Incorrect professional assignment',
    'Safety concerns during service',
    'Any issue not reflected in the booking',
  ];

  void onReportIssue() {
    // TODO: navigate to report issue
  }

  void onContactSupport() {
    // TODO: navigate to support
  }
}
