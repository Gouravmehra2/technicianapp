import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:technicianapp/constant/common_widgets/app_snackbar.dart';
import 'package:technicianapp/core/api_repo/api_repo.dart';
import 'package:technicianapp/core/models/chat_detail_model.dart';
import 'package:technicianapp/core/services/socket_service.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/charges_model.dart';
import 'package:technicianapp/presentation/screens/counter_offer_screen/model/counter_offer_model.dart';
import 'package:technicianapp/presentation/screens/technician_home_screen/model/new_jobs_model.dart'
    hide Conversation;

// ─────────────────────────────────────────────────────────────────────────────
// CounterOfferController
//
// Arguments expected (passed via Get.toNamed arguments):
//   { 'job': Jobs }
//
// The Jobs object may contain:
//   - job.sId          → jobId  (always present)
//   - job.assignedRequest → requestId (present when a request already exists)
//
// Flow:
//   onInit:
//     • Extract jobId from job.sId
//     • Extract requestId from job.assignedRequest (if it is a String or Map
//       with '_id' key)
//     • If requestId is present → _loadConversation() directly
//     • If requestId is absent  → show the blank form; first sendCounterOffer()
//       will call requestJobApi and capture the new requestId
// ─────────────────────────────────────────────────────────────────────────────

enum ChargeType { fixedPrice, additionalCharges }

class CounterOfferController extends GetxController {
  final ApiRepo _apiRepo = Get.find<ApiRepo>();

  late Jobs job;

  // ── IDs ───────────────────────────────────────────────────────────────────
  String _jobId = ''; // job._id  (never changes)
  String? _requestId; // request._id (set after first offer or from args)

  // ── Controllers & scroll ──────────────────────────────────────────────────
  final TextEditingController messageController = TextEditingController();
  final TextEditingController counterAmountCtrl = TextEditingController();
  final TextEditingController proposalCtrl = TextEditingController();
  final ScrollController scrollController = ScrollController();

  // ── State ─────────────────────────────────────────────────────────────────
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool showCounterForm = true.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final Rxn<InvoiceModel> invoice = Rxn<InvoiceModel>();
  final RxBool isJobAccepted = false.obs;

  // ── Charge type toggle (radio) ────────────────────────────────────────────
  final Rx<ChargeType> chargeType = ChargeType.fixedPrice.obs;

  // ── Allowance rows (used only for additionalCharges mode) ─────────────────
  final allowances = <Allowance>[
    Allowance('Travel Fee'),
    Allowance('Spare Parts'),
    Allowance('Extra Labor'),
    Allowance('Other'),
  ];

  ChatDetailModel? _chatDetail;

  // ─────────────────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    job = (args is Map ? args['job'] : args) as Jobs;

    // jobId — always the Jobs document _id
    _jobId = job.sId ?? '';

    // requestId — may come from assignedRequest (String _id or Map { _id: … })
    final raw = job.assignedRequest;
    if (raw is String && raw.isNotEmpty) {
      _requestId = raw;
    }

    // Opening coordinator message
    messages.add(
      ChatMessage(
        isUser: false,
        type: MsgType.text,
        text:
            'Hi, please make a counter offer with the fixed price you want '
            'for this job. You can also add optional additional charges.',
        time: _now(),
      ),
    );

    if (_requestId != null && _requestId!.isNotEmpty) {
      _loadConversation();
    }

    _listenToSocket();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // ── Load conversation ─────────────────────────────────────────────────────
  Future<void> _loadConversation() async {
    if (_requestId == null || _requestId!.isEmpty) return;

    try {
      isLoading.value = true;

      _chatDetail = await _apiRepo.getConversationApi(job.sId.toString());
      final requestDetail = _chatDetail?.data?.request;
      final reqStatus = requestDetail?.status ?? '';
      final finalAmount = requestDetail?.counterOffer ?? 0;

      if (finalAmount > 0) {}
      isJobAccepted.value = reqStatus == 'accepted';

      // Rebuild — keep only the opening coordinator message
      messages.removeRange(1, messages.length);
      showCounterForm.value = !isJobAccepted.value;

      if (_chatDetail?.success == true &&
          _chatDetail?.data?.conversation != null) {
        _buildFromConversation(
          entries: _chatDetail?.data?.conversation ?? [],
          reqStatus: reqStatus,
          finalAmount: finalAmount,
        );
      } else if (requestDetail?.sId != null) {
        _handleStatusOnly(reqStatus, finalAmount, requestDetail?.createdAt);
      }

      messages.refresh();
      _scrollToBottom();
    } catch (e) {
      debugPrint('[CounterOffer] _loadConversation error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Build chat from conversation entries ──────────────────────────────────
  void _buildFromConversation({
    required List<Conversation> entries,
    required String reqStatus,
    required int finalAmount,
  }) {
    bool acceptedBubbleAdded = false;

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final isTech = entry.sender == 'technician';
      final time = _formatApiTime(entry.createdAt);
      final text = (entry.message ?? '').trim();
      final entryAmt = entry.counterOffer ?? 0;
      final entryCounterFrom = entry.counterOfferFrom ?? '';
      final isLastEntry = i == entries.length - 1;

      if (isTech) {
        if (entryAmt > 0) {
          messages.add(
            ChatMessage(
              isUser: true,
              type: MsgType.technicianOffer,
              text: '',
              time: time,
              counterAmount: entryAmt.toString(),
            ),
          );
          showCounterForm.value = false;
        } else if (text.isNotEmpty) {
          messages.add(
            ChatMessage(
              isUser: true,
              type: MsgType.text,
              text: text,
              time: time,
            ),
          );
        }
      } else {
        final isAdminCounter = entryCounterFrom == 'admin' && entryAmt > 0;
        final textLower = text.toLowerCase();
        final isAcceptanceMsg =
            textLower.contains('accept') ||
            (isLastEntry && reqStatus == 'accepted');
        final isRejectionMsg =
            textLower.contains('reject') ||
            textLower.contains('declin') ||
            (isLastEntry && reqStatus == 'rejected');

        if (isAdminCounter) {
          messages.add(
            ChatMessage(
              isUser: false,
              type: MsgType.adminOffer,
              text: text.isNotEmpty
                  ? text
                  : "Here is the admin's revised offer.",
              time: time,
              offerAmount: '₹$entryAmt',
              actionTaken: isLastEntry && reqStatus != 'accepted'
                  ? RxnBool(null)
                  : RxnBool(reqStatus == 'accepted' ? true : false),
            ),
          );
          showCounterForm.value = false;
        } else if (isAcceptanceMsg && !acceptedBubbleAdded) {
          final amount = finalAmount > 0 ? finalAmount : entryAmt;
          _addAcceptedBubble(amount, time);
          acceptedBubbleAdded = true;
          showCounterForm.value = false;
        } else if (isRejectionMsg) {
          messages.add(
            ChatMessage(
              isUser: false,
              type: MsgType.text,
              text: text.isNotEmpty
                  ? text
                  : '✗ Your offer was declined. Please send a new counter offer.',
              time: time,
            ),
          );
          if (isLastEntry) {
            _resetForm();
            showCounterForm.value = true;
          }
        } else {
          messages.add(
            ChatMessage(
              isUser: false,
              type: MsgType.text,
              text: text.isNotEmpty ? text : 'Your offer is under review.',
              time: time,
            ),
          );
        }
      }
    }

    if (reqStatus == 'accepted' && !acceptedBubbleAdded) {
      _addAcceptedBubble(finalAmount, _now());
      showCounterForm.value = false;
    }
  }

  // ── Handle status-only response ───────────────────────────────────────────
  void _handleStatusOnly(String reqStatus, int finalAmount, String? createdAt) {
    final time = _formatApiTime(createdAt);
    switch (reqStatus) {
      case 'accepted':
        _addAcceptedBubble(finalAmount, time);
        showCounterForm.value = false;
      case 'rejected':
        messages.add(
          ChatMessage(
            isUser: false,
            type: MsgType.text,
            text: '✗ Your offer was declined. Please send a new counter offer.',
            time: time,
          ),
        );
        _resetForm();
        showCounterForm.value = true;
      case 'pending':
      case 'counter-offer':
      case 'countered':
        if (finalAmount > 0) {
          messages.add(
            ChatMessage(
              isUser: true,
              type: MsgType.technicianOffer,
              text: '',
              time: time,
              counterAmount: finalAmount.toString(),
            ),
          );
          showCounterForm.value = false;
        }
    }
  }

  // ── Accepted bubble ───────────────────────────────────────────────────────
  void _addAcceptedBubble(int amount, String time) {
    messages.add(
      ChatMessage(
        isUser: false,
        type: MsgType.accepted,
        text: 'Your counter offer has been accepted. The job is now confirmed.',
        time: time,
        acceptedAmount: amount > 0 ? amount.toString() : null,
      ),
    );
  }

  // ── Socket ────────────────────────────────────────────────────────────────
  void _listenToSocket() {
    final socket = SocketService.instance;
    socket.reconnectIfNeeded();

    if (_requestId != null && _requestId!.isNotEmpty) {
      socket.joinRequestRoom(_requestId!);
    }

    socket.on('request:message', (_) => _loadConversation());
    socket.on('request:updated', (_) => _loadConversation());
    socket.on('request:status', (_) => _loadConversation());
    socket.on('job:updated', (_) => _loadConversation());
    socket.on('charge:reviewed', (_) => _loadConversation());
    socket.on('charge:responded', (_) => _loadConversation());
    socket.on('invoice:generated', (_) => _loadConversation());
    socket.on('invoice:paid', (_) => _loadConversation());
  }

  // ── Plain text message ────────────────────────────────────────────────────
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    if (_requestId == null || _requestId!.isEmpty) {
      AppSnackbar.error(
        'Please send a counter offer first before messaging.',
        title: 'Info',
      );
      return;
    }

    final optimistic = ChatMessage(
      isUser: true,
      type: MsgType.text,
      text: text,
      time: _now(),
    );
    messages.add(optimistic);
    messageController.clear();
    _scrollToBottom();

    try {
      isSending.value = true;
      final response = await _apiRepo.sendMessageApi(
        requestId: _requestId!,
        message: text,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        messages.remove(optimistic);
        messageController.text = text;
        AppSnackbar.error(
          body['message'] as String? ?? 'Failed to send message',
          title: 'Error',
        );
        return;
      }
      await _loadConversation();
    } catch (e) {
      messages.remove(optimistic);
      messageController.text = text;
      AppSnackbar.error(
        'Failed to send message. Check your connection.',
        title: 'Error',
      );
    } finally {
      isSending.value = false;
    }
  }

  // ── Send counter offer ────────────────────────────────────────────────────
  Future<void> sendCounterOffer() async {
    final isFixed = chargeType.value == ChargeType.fixedPrice;

    // ── Validate ──────────────────────────────────────────────────────────
    if (isFixed) {
      final amountStr = counterAmountCtrl.text.trim();
      if (amountStr.isEmpty) {
        AppSnackbar.error(
          'Please enter your counter amount.',
          title: 'Validation',
        );
        return;
      }
      final parsed = double.tryParse(
        amountStr.replaceAll('\$', '').replaceAll('₹', '').replaceAll(',', ''),
      );
      if (parsed == null || parsed <= 0) {
        AppSnackbar.error(
          'Enter a valid counter amount greater than 0.',
          title: 'Validation',
        );
        return;
      }
    } else {
      // Additional charges mode — at least one row must be checked with amount
      final hasAny = allowances.any(
        (a) =>
            a.checked.value &&
            a.amountCtrl.text.trim().isNotEmpty &&
            (double.tryParse(
                      a.amountCtrl.text
                          .trim()
                          .replaceAll('\$', '')
                          .replaceAll(',', ''),
                    ) ??
                    0) >
                0,
      );
      if (!hasAny) {
        AppSnackbar.error(
          'Please add at least one additional charge.',
          title: 'Validation',
        );
        return;
      }
    }

    try {
      isSending.value = true;

      if (isFixed) {
        final fixedPrice = double.parse(
          counterAmountCtrl.text
              .trim()
              .replaceAll('\$', '')
              .replaceAll('₹', '')
              .replaceAll(',', ''),
        );

        if (_requestId == null || _requestId!.isEmpty) {
          // First offer — create the request
          await _requestJobWithFixedPrice(fixedPrice: fixedPrice).then((value) {
            _requestId = value['data']['request']['_id'];
          });
        } else {
          // Re-counter — submit charges to existing request
          await _submitChargesToExistingRequest(
            charges: [
              {
                'label': 'Fixed Price',
                'description': 'Counter offer fixed price',
                'amount': fixedPrice,
                'isFixedPrice': true,
              },
            ],
            counterAmount: fixedPrice.toStringAsFixed(2),
          );
        }
      } else {
        // Additional charges mode
        final List<Map<String, dynamic>> chargesPayload = [];
        for (final a in allowances) {
          if (!a.checked.value) continue;
          final amt =
              double.tryParse(
                a.amountCtrl.text
                    .trim()
                    .replaceAll('\$', '')
                    .replaceAll('₹', '')
                    .replaceAll(',', ''),
              ) ??
              0;
          if (amt <= 0) {
            AppSnackbar.error(
              'Enter a valid amount for "${a.label}".',
              title: 'Validation',
            );
            return;
          }
          chargesPayload.add({
            'label': _toBackendLabel(a),
            'description': a.label == 'Other'
                ? a.otherLabelCtrl.text.trim()
                : '',
            'amount': amt,
          });
        }

        if (_requestId == null || _requestId!.isEmpty) {
          // No request yet — create one first (with no fixed price, only charges)
          await _requestJobWithChargesOnly(chargesPayload: chargesPayload);
        } else {
          await _submitChargesToExistingRequest(
            charges: chargesPayload,
            counterAmount: null,
          );
        }
      }
    } finally {
      isSending.value = false;
    }
  }

  // ── Case A1: First offer — fixed price ────────────────────────────────────
  Future _requestJobWithFixedPrice({required double fixedPrice}) async {
    try {
      final response = await _apiRepo.requestJobApi(
        jobId: _jobId,
        note: proposalCtrl.text.trim().isEmpty
            ? null
            : proposalCtrl.text.trim(),
        fixedPrice: fixedPrice.round(),
        charges: null,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        AppSnackbar.error(
          body['message'] as String? ?? 'Failed to request job',
          title: 'Error',
        );
        return;
      }
      _captureRequestId(body);
      _addOfferBubble(fixedPrice.toStringAsFixed(2), isFixed: true);
      AppSnackbar.success(
        body['message'] as String? ?? 'Counter offer sent!',
        title: 'Success',
      );
      await _loadConversation();
      return response.data;
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  // ── Case A2: First offer — additional charges only ────────────────────────
  Future<void> _requestJobWithChargesOnly({
    required List<Map<String, dynamic>> chargesPayload,
  }) async {
    try {
      final response = await _apiRepo.requestJobApi(
        jobId: _jobId,
        note: proposalCtrl.text.trim().isEmpty
            ? null
            : proposalCtrl.text.trim(),
        fixedPrice: null,
        charges: chargesPayload,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        AppSnackbar.error(
          body['message'] as String? ?? 'Failed to request job',
          title: 'Error',
        );
        return;
      }

      _captureRequestId(body);
      _addOfferBubble(null, isFixed: false);
      AppSnackbar.success(
        body['message'] as String? ?? 'Counter offer sent!',
        title: 'Success',
      );
      await _loadConversation();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  // ── Case B: Re-counter on an existing request ─────────────────────────────
  Future<void> _submitChargesToExistingRequest({
    required List<Map<String, dynamic>> charges,
    required String? counterAmount,
  }) async {
    try {
      final response = await _apiRepo.submitChargesApi(
        requestId: _chatDetail?.data?.request?.sId ?? _requestId!,
        charges: charges,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] != true) {
        AppSnackbar.error(
          body['message'] as String? ?? 'Failed to submit counter offer',
          title: 'Error',
        );
        return;
      }

      _addOfferBubble(counterAmount, isFixed: counterAmount != null);
      AppSnackbar.success(
        body['message'] as String? ?? 'Counter offer sent!',
        title: 'Success',
      );
      await _loadConversation();
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    }
  }

  // ── Capture requestId from response body ──────────────────────────────────
  void _captureRequestId(Map<String, dynamic> body) {
    final nested = body['data'] as Map<String, dynamic>?;
    final requestMap = nested?['request'] as Map<String, dynamic>?;
    final newId = requestMap?['_id'] as String? ?? nested?['_id'] as String?;
    if (newId != null && newId.isNotEmpty) {
      _requestId = newId;
      SocketService.instance.joinRequestRoom(_requestId!);
    }
  }

  // ── Optimistic offer bubble ───────────────────────────────────────────────
  void _addOfferBubble(String? counterAmount, {required bool isFixed}) {
    final snapshot = !isFixed
        ? allowances
              .where(
                (a) => a.checked.value && a.amountCtrl.text.trim().isNotEmpty,
              )
              .map(
                (a) => Allowance(
                  a.label,
                  checked: true,
                  amount: a.amountCtrl.text,
                ),
              )
              .toList()
        : <Allowance>[];
    final proposal = proposalCtrl.text.trim();

    messages.add(
      ChatMessage(
        isUser: true,
        type: MsgType.technicianOffer,
        text: '',
        time: _now(),
        counterAmount: counterAmount,
        allowances: snapshot.isEmpty ? null : snapshot,
        proposal: proposal.isEmpty ? null : proposal,
      ),
    );

    showCounterForm.value = false;
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
      final response = await _apiRepo.respondToChargeApi(
        chargeId: chargeId,
        action: 'accept',
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        AppSnackbar.success('Offer accepted!', title: 'Success');
        await _loadConversation();
      } else {
        AppSnackbar.error(
          body['message'] as String? ?? 'Failed',
          title: 'Error',
        );
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
      final response = await _apiRepo.respondToChargeApi(
        chargeId: chargeId,
        action: 'reject',
      );
      final body = response.data as Map<String, dynamic>;
      if (body['success'] == true) {
        AppSnackbar.success(
          'You can now submit a new counter offer.',
          title: 'Info',
        );
        await _loadConversation();
      } else {
        AppSnackbar.error(
          body['message'] as String? ?? 'Failed',
          title: 'Error',
        );
      }
    } catch (e) {
      AppSnackbar.error(e.toString(), title: 'Error');
    } finally {
      isSending.value = false;
      _scrollToBottom();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _toBackendLabel(Allowance a) {
    if (a.label == 'Other') {
      return a.otherLabelCtrl.text.trim().isEmpty
          ? 'Other'
          : a.otherLabelCtrl.text.trim();
    }
    if (a.label == 'Travel Fee') return 'Travel';
    return a.label;
  }

  void _resetForm() {
    counterAmountCtrl.clear();
    proposalCtrl.clear();
    chargeType.value = ChargeType.fixedPrice;
    for (final a in allowances) {
      a.checked.value = false;
      a.amountCtrl.clear();
      a.otherLabelCtrl.clear();
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
    SocketService.instance.off('request:message');
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
