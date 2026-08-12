import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicySubSection {
  final String title;
  final String body;

  const PrivacyPolicySubSection({required this.title, required this.body});
}

class PrivacyPolicySection {
  final IconData icon;
  final String title;
  final String intro;
  final List<PrivacyPolicySubSection> subSections;
  final List<String> blockQuotes;
  final String? linkText;
  final String? linkUrl;

  const PrivacyPolicySection({
    required this.icon,
    required this.title,
    required this.intro,
    this.subSections = const [],
    this.blockQuotes = const [],
    this.linkText,
    this.linkUrl,
  });
}

class PrivacyPolicyController extends GetxController {
  final List<PrivacyPolicySection> sections = const [
    PrivacyPolicySection(
      icon: Icons.person_outline_rounded,
      title: 'Personal Information\nWe Collect',
      intro: '',
      subSections: [
        PrivacyPolicySubSection(
          title: 'Account information',
          body:
              'In addition to your name, service or shipping address, billing address, e-mail address, telephone number, bank account number, credit card number, and other account information, we collect and maintain regular business records containing information about you that might constitute personal information. Aside from billing and order history, we may collect and maintain other details about your account.',
        ),
        PrivacyPolicySubSection(
          title: 'Purchase & Order Information',
          body:
              'Our Products and Services collect certain information relating to the products and/or services you purchase when you use them. In this Purchase and Order Information, you will find information about the products and/or services you purchased, their prices, and quantities, as well as delivery methods and details, as well as the installation dates and location.',
        ),
      ],
    ),
    PrivacyPolicySection(
      icon: Icons.cookie_outlined,
      title: 'Cookies & Other\nTechnologies',
      intro:
          'Our Products and Services may be provided through a variety of platforms, including Internet websites operated by us, our affiliates, and/or other companies. This includes information collected during your time on these sites, such as browsing activity, IP address, and items added to your Cart but not purchased.',
      blockQuotes: [
        'In order to better understand user behavior and gather statistics about website and platform usage, we and our partners may use technologies like cookies, web beacons, tags, and others on these platforms and in electronic communications. These tools may also collect data such as demographic information, browser type, device type, Internet Service Provider, referring/exit pages, platform type, date/time stamp, number of clicks, and similar information.',
        'Please note that you can still access our Services even if you disable certain cookies; however, you may not be recognized automatically upon returning.',
      ],
    ),
    PrivacyPolicySection(
      icon: Icons.bar_chart_rounded,
      title: 'Google Analytics',
      intro:
          'We make use of Google Analytics and Signals, which enhances current features (such as advertising reports, remarketing, cross-device reports, and reports on interests and demographics) by offering collective and anonymous data about you. This is only available if you have enabled personalized ads in your Google Account.',
      linkText: 'Google Privacy Policy ↗',
      linkUrl: 'https://policies.google.com/privacy',
    ),
    PrivacyPolicySection(
      icon: Icons.child_care_rounded,
      title: "Children's information",
      intro:
          'We are committed to protecting children\'s privacy. We do not intentionally direct the Services to children under eighteen, nor do we knowingly collect any personal information from them. In the event that we learn that a child under eighteen has provided personal information through the Services, we will take reasonable steps to remove that information.',
    ),
    PrivacyPolicySection(
      icon: Icons.history_rounded,
      title: 'Data Retention',
      intro:
          'We retain personal information about you for a period of time that is necessary to provide our Services, to meet legal or tax requirements, to prevent fraud, and for other business purposes. If we de-identify information, we will maintain and use it in de-identified form.',
    ),
  ];
}
