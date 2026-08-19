import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/charges_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/dashboard_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart';

// ─── Message types ────────────────────────────────────────────────────────────
enum MsgType { text, technicianOffer, adminOffer }

// ─── Allowance (for the form + bubble snapshots) ──────────────────────────────
class Allowance {
  final String label;
  final RxBool checked;
  final TextEditingController amountCtrl;

  Allowance(this.label, {bool checked = false, String amount = ''})
      : checked = RxBool(checked),
        amountCtrl = TextEditingController(text: amount);

  void dispose() => amountCtrl.dispose();
}

// ─── Chat message ─────────────────────────────────────────────────────────────
class ChatMessage {
  final bool isUser; // true = technician
  final MsgType type;
  final String text;
  final String time;

  // technicianOffer fields
  final String? counterAmount;
  final List<Allowance>? allowances;
  final String? proposal;

  // adminOffer fields
  final String? offerAmount;
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
    this.actionTaken,
    this.chargeItem,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
class CounterOfferController extends GetxController {
  final ApiRepo _apiRepo = Get.find<ApiRepo>();

  late NewJob job;
  Requests? _initialRequest; // from dashboard data

  // ── Controllers & scroll ──────────────────────────────────────────────────
  final TextEditingController messageController = TextEditingController();
  final TextEditingController counterAmountCtrl = TextEditingController();
  final TextEditingController proposalCtrl = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ── State ─────────────────────────────────────────────────────────────────
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool showCounterForm = true.obs;
  final RxBool showAdditionalCharges = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final Rxn<InvoiceModel> invoice = Rxn<InvoiceModel>();

  String? _requestId;

  // ── Allowance rows ────────────────────────────────────────────────────────
  final allowances = <Allowance>[
    Allowance('Travel Fee'),
    Allowance('Spare Parts'),
    Allowance('Extra Labor'),
    Allowance('Other'),
  ];

  static const _backendLabels = ['Gas', 'Toll', 'Travel', 'Spare Parts', 'Extra Labor', 'Other'];

  String _toBackendLabel(String ui) {
    if (ui == 'Travel Fee') return 'Travel';
    return _backendLabels.contains(ui) ? ui : 'Other';
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();

    // Arguments: either legacy NewJob or the new Map with job + request
    final args = Get.arguments;
    if (args is Map) {
      job = args['job'] as NewJob;
      _initialRequest = args['request'] as Requests?;
    } else {
      job = args as NewJob;
    }

    _requestId = job.requestId;

    // Seed the opening coordinator message
    messages.add(ChatMessage(
      isUser: false,
      type: MsgType.text,
      text: 'Hi, please make a counter offer with the fixed price you want '
          'for this job. You can also add optional additional charges.',
      time: _now(),
    ));

    // Populate from the conversation snapshot passed by the home screen
    if (_initialRequest != null) {
      _buildFromRequest(_initialRequest!);
    }

    _listenToSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // ── Build chat bubbles from a Requests object ─────────────────────────────
  //
  // The dashboard `requests[].conversation[]` contains entries like:
  //   { sender: 'technician', message: '...', counterOffer: 400, createdAt: '...' }
  //   { sender: 'admin',      message: 'Request accepted.',       createdAt: '...' }
  //
  // `request.status`           → 'pending' | 'accepted' | 'rejected' | 'countered'
  // `request.counterOffer`     → latest counter amount on the request
  // `request.counterOfferFrom` → who sent the last counter ('technician'|'admin')
  // ─────────────────────────────────────────────────────────────────────────────
  void _buildFromRequest(Requests req) {
    final convo = req.conversation ?? [];
    if (convo.isEmpty) return;

    for (final entry in convo) {
      final isTech = entry.sender == 'technician';
      final time = _formatApiTime(entry.createdAt);
      final text = entry.message ?? '';
      final entryAmt = entry.counterOffer ?? 0; // now properly typed

      if (isTech && entryAmt > 0) {
        // Technician counter offer bubble — amount is what the tech sent
        messages.add(ChatMessage(
          isUser: true,
          type: MsgType.technicianOffer,
          text: '',
          time: time,
          counterAmount: entryAmt.toString(),
          proposal: req.note?.isNotEmpty == true ? req.note : null,
        ));
        showCounterForm.value = false;
      } else if (!isTech) {
        final isAccepted = req.status == 'accepted' ||
            text.toLowerCase().contains('accepted');
        final isRejected = req.status == 'rejected' ||
            text.toLowerCase().contains('rejected');

        // Admin sent a revised counter-offer amount in this entry
        final adminAmt = (entry.counterOfferFrom == 'admin' &&
                entryAmt > 0)
            ? entryAmt
            : null;

        if (adminAmt != null && !isAccepted && !isRejected) {
          messages.add(ChatMessage(
            isUser: false,
            type: MsgType.adminOffer,
            text: text.isNotEmpty
                ? text
                : 'Here is the admin\'s revised offer.',
            time: time,
            offerAmount: '\$$adminAmt',
            actionTaken: RxnBool(null),
          ));
        } else {
          // Plain status / acceptance / rejection message
          messages.add(ChatMessage(
            isUser: false,
            type: MsgType.text,
            text: _adminStatusText(req.status, text),
            time: time,
          ));
          if (isAccepted) showCounterForm.value = false;
          // If rejected, let the tech send a new counter offer
          if (isRejected) showCounterForm.value = true;
        }
      }
    }

    messages.refresh();
  }

  String _adminStatusText(String? status, String raw) {
    if (status == 'accepted') return '✓ Your counter offer has been accepted!';
    if (status == 'rejected') return '✗ Your offer was declined. You may send a new counter offer.';
    return raw.isNotEmpty ? raw : 'Your offer is under review.';
  }

  // ── Socket ────────────────────────────────────────────────────────────────
  void _listenToSocket() {
    final socket = SocketService.instance;
    socket.reconnectIfNeeded();

    // Join request room for scoped events
    if (_requestId != null && _requestId!.isNotEmpty) {
      socket.joinRequestRoom(_requestId!);
    }

    // Reload from dashboard whenever the request or job updates
    socket.on('request:updated', (_) => _reloadFromDashboard());
    socket.on('request:status',  (_) => _reloadFromDashboard());
    socket.on('job:updated',     (_) => _reloadFromDashboard());

    // Charges/invoice events (for the extended charges flow)
    socket.on('charge:reviewed',   (_) => _reloadFromDashboard());
    socket.on('charge:responded',  (_) => _reloadFromDashboard());
    socket.on('invoice:generated', (_) => _reloadFromDashboard());
    socket.on('invoice:paid',      (_) => _reloadFromDashboard());
  }

  /// Re-fetches the dashboard and rebuilds the conversation from the matching request.
  Future<void> _reloadFromDashboard() async {
    try {
      isLoading.value = true;
      final dashboard = await _apiRepo.getTechnicianDashboardApi();
      if (dashboard.success != true) return;

      final req = dashboard.data?.requests?.firstWhereOrNull(
        (r) => r.sId == _requestId || (r.job?.sId ?? '') == job.id,
      );
      if (req == null) return;

      _initialRequest = req;

      // Reset: keep only the opening coordinator message (index 0)
      messages.removeRange(1, messages.length);
      showCounterForm.value = true;

      _buildFromRequest(req);
      _scrollToBottom();
    } catch (e) {
      debugPrint('[CounterOffer] _reloadFromDashboard error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _joinRequestRoomIfNeeded() {
    if (_requestId == null || _requestId!.isEmpty) return;
    SocketService.instance.joinRequestRoom(_requestId!);
  }

  // ── Plain text message ────────────────────────────────────────────────────
  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    messages.add(ChatMessage(
      isUser: true,
      type: MsgType.text,
      text: text,
      time: _now(),
    ));
    messageController.clear();
    _scrollToBottom();
  }

  // ── Toggle additional charges ─────────────────────────────────────────────
  void toggleAdditionalCharges() =>
      showAdditionalCharges.value = !showAdditionalCharges.value;

  // ── Send counter offer ────────────────────────────────────────────────────
  Future<void> sendCounterOffer() async {
    final amountStr = counterAmountCtrl.text.trim();
    if (amountStr.isEmpty) {
      AppSnackbar.error('Please enter a counter amount.', title: 'Validation');
      return;
    }
    final fixedPrice = double.tryParse(amountStr);
    if (fixedPrice == null || fixedPrice <= 0) {
      AppSnackbar.error('Enter a valid counter amount.', title: 'Validation');
      return;
    }

    // Build charges from checked + visible rows only
    final List<Map<String, dynamic>> chargesPayload = [];
    if (showAdditionalCharges.value) {
      for (final a in allowances) {
        if (!a.checked.value) continue;
        final amt = double.tryParse(a.amountCtrl.text.trim()) ?? 0;
        if (amt <= 0) {
          AppSnackbar.error('Enter a valid amount for "${a.label}".', title: 'Validation');
          return;
        }
        chargesPayload.add({
          'label': _toBackendLabel(a.label),
          'description': proposalCtrl.text.trim(),
          'amount': amt,
        });
      }
    }

    try {
      isSending.value = true;
      if (_requestId == null) {
        await _requestJobWithCharges(fixedPrice: fixedPrice, chargesPayload: chargesPayload);
      } else {
        await _submitChargesToExistingRequest(fixedPrice: fixedPrice, chargesPayload: chargesPayload);
      }
    } finally {
      isSending.value = false;
    }
  }

  // ── Case A: new request ───────────────────────────────────────────────────
  Future<void> _requestJobWithCharges({
    required double fixedPrice,
    required List<Map<String, dynamic>> chargesPayload,
  }) async {
    try {
      final response = await _apiRepo.requestJobApi(
        jobId: job.id,
        note: proposalCtrl.text.trim().isEmpty ? null : proposalCtrl.text.trim(),
        fixedPrice: fixedPrice,
        charges: chargesPayload.isEmpty ? null : chargesPayload,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        AppSnackbar.error(body['message'] as String? ?? 'Failed to request job', title: 'Error');
        return;
      }

      // Capture requestId
      final nested = body['data'] as Map<String, dynamic>?;
      final requestMap = nested?['request'] as Map<String, dynamic>?;
      final newId = requestMap?['_id'] as String? ?? nested?['_id'] as String?;
      if (newId != null && newId.isNotEmpty) {
        _requestId = newId;
        _joinRequestRoomIfNeeded();
      }

      // Use the exact amount the technician typed — never the charges sum
      _addOfferBubble(fixedPrice.toStringAsFixed(2));
      AppSnackbar.success(body['message'] as String? ?? 'Counter offer sent!', title: 'Success');

      // Reload to sync server state
      await _reloadFromDashboard();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  // ── Case B: add charges to existing request ───────────────────────────────
  Future<void> _submitChargesToExistingRequest({
    required double fixedPrice,
    required List<Map<String, dynamic>> chargesPayload,
  }) async {
    if (chargesPayload.isEmpty) {
      // No additional charges — just resend the fixed price as a new counter offer
      // by treating it as a plain re-request (or show info)
      _addOfferBubble(fixedPrice.toStringAsFixed(2));
      AppSnackbar.success('Counter offer updated!', title: 'Success');
      await _reloadFromDashboard();
      return;
    }

    try {
      final response = await _apiRepo.submitChargesApi(
        requestId: _requestId!,
        charges: chargesPayload,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        AppSnackbar.error(body['message'] as String? ?? 'Failed to submit charges', title: 'Error');
        return;
      }
      // Always show the fixed counter price in the bubble, not the charges sum
      _addOfferBubble(fixedPrice.toStringAsFixed(2));
      AppSnackbar.success(body['message'] as String? ?? 'Counter offer sent!', title: 'Success');
      await _reloadFromDashboard();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  /// Appends the read-only technician offer bubble.
  void _addOfferBubble(String counterAmount) {
    final snapshot = showAdditionalCharges.value
        ? allowances
            .where((a) => a.checked.value && a.amountCtrl.text.trim().isNotEmpty)
            .map((a) => Allowance(a.label, checked: true, amount: a.amountCtrl.text))
            .toList()
        : <Allowance>[];
    final proposal = proposalCtrl.text.trim();

    messages.add(ChatMessage(
      isUser: true,
      type: MsgType.technicianOffer,
      text: '',
      time: _now(),
      counterAmount: counterAmount, // ← always the fixed price, never the charges sum
      allowances: snapshot.isEmpty ? null : snapshot,
      proposal: proposal.isEmpty ? null : proposal,
    ));

    showCounterForm.value = false;
    showAdditionalCharges.value = false;
    _scrollToBottom();
  }

  // ── Accept admin counter-offer ────────────────────────────────────────────
  Future<void> acceptOffer(ChatMessage msg) async {
    final chargeId = msg.chargeItem?.id;
    if (chargeId == null || chargeId.isEmpty) {
      msg.actionTaken?.value = true;
      showCounterForm.value = false;
      messages.refresh();
      _scrollToBottom();
      return;
    }
    try {
      isSending.value = true;
      final response = await _apiRepo.respondToChargeApi(chargeId: chargeId, action: 'accept');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        msg.actionTaken?.value = true;
        messages.refresh();
        AppSnackbar.success('Offer accepted!', title: 'Success');
        await _reloadFromDashboard();
      } else {
        AppSnackbar.error(body['message'] as String? ?? 'Failed', title: 'Error');
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isSending.value = false;
      _scrollToBottom();
    }
  }

  // ── Counter admin's counter-offer ─────────────────────────────────────────
  Future<void> counterAdminOffer(ChatMessage msg) async {
    final chargeId = msg.chargeItem?.id;
    if (chargeId == null || chargeId.isEmpty) {
      msg.actionTaken?.value = false;
      messages.refresh();
      _resetForm();
      showCounterForm.value = true;
      _scrollToBottom();
      return;
    }
    try {
      isSending.value = true;
      final response = await _apiRepo.respondToChargeApi(chargeId: chargeId, action: 'reject');
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        msg.actionTaken?.value = false;
        messages.refresh();
        _resetForm();
        showCounterForm.value = true;
        AppSnackbar.success('You can now submit a new counter offer.', title: 'Info');
        await _reloadFromDashboard();
      } else {
        AppSnackbar.error(body['message'] as String? ?? 'Failed', title: 'Error');
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isSending.value = false;
      _scrollToBottom();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _resetForm() {
    counterAmountCtrl.clear();
    proposalCtrl.clear();
    showAdditionalCharges.value = false;
    for (final a in allowances) {
      a.checked.value = false;
      a.amountCtrl.clear();
    }
  }

  String _now() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour < 12 ? 'AM' : 'PM'}';
  }

  String _formatApiTime(String? iso) {
    if (iso == null || iso.isEmpty) return _now();
    try {
      final dt = DateTime.parse(iso).toLocal();
      final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m ${dt.hour < 12 ? 'AM' : 'PM'}';
    } catch (_) {
      return _now();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    if (_requestId != null && _requestId!.isNotEmpty) {
      SocketService.instance.leaveRequestRoom(_requestId!);
    }
    SocketService.instance.off('request:updated');
    SocketService.instance.off('request:status');
    SocketService.instance.off('job:updated');
    SocketService.instance.off('charge:reviewed');
    SocketService.instance.off('charge:responded');
    SocketService.instance.off('invoice:generated');
    SocketService.instance.off('invoice:paid');

    messageController.dispose();
    counterAmountCtrl.dispose();
    proposalCtrl.dispose();
    scrollController.dispose();
    for (final a in allowances) {
      a.dispose();
    }
    super.onClose();
  }
}
