import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/charges_model.dart';

// ─── Message types ────────────────────────────────────────────────────────────
enum MsgType {
  text,           // plain text from admin or technician
  technicianOffer, // technician's counter-offer card (brown, right)
  adminOffer,     // admin's revised offer card with Accept/Counter buttons (left)
  accepted,       // final accepted confirmation — shows agreed amount (left)
}

// ─── Allowance (for the form + bubble snapshots) ──────────────────────────────
class Allowance {
  final String label;
  final RxBool checked;
  final TextEditingController amountCtrl;
  final TextEditingController otherLabelCtrl;

  Allowance(this.label, {bool checked = false, String amount = ''})
      : checked = RxBool(checked),
        amountCtrl = TextEditingController(text: amount),
        otherLabelCtrl = TextEditingController();

  void dispose() {
    amountCtrl.dispose();
    otherLabelCtrl.dispose();
  }

  String getDisplayLabel() {
    if (label == 'Other' && otherLabelCtrl.text.trim().isNotEmpty) {
      return otherLabelCtrl.text.trim();
    }
    return label;
  }
}

// ─── Chat message ─────────────────────────────────────────────────────────────
class ChatMessage {
  final bool isUser; // true = technician (right side)
  final MsgType type;
  final String text;
  final String time;

  // technicianOffer fields
  final String? counterAmount;
  final List<Allowance>? allowances;
  final String? proposal;

  // adminOffer fields
  final String? offerAmount;

  // accepted fields — the amount the admin agreed to (tech's winning counter)
  final String? acceptedAmount;

  /// null = pending action, true = accepted, false = countered
  final RxnBool? actionTaken;

  // for the charges-respond flow (optional)
  final ChargeItem? chargeItem;

  ChatMessage({
    required this.isUser,
    required this.type,
    required this.text,
    required this.time,
    this.counterAmount,
    this.allowances,
    this.proposal,
    this.offerAmount,
    this.acceptedAmount,
    this.actionTaken,
    this.chargeItem,
  });
}
