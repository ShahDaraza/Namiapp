// ===================================================================
// ServiceHub Flutter — Backend API Bridge Service
// Zenith Intercontinental LLC
// -------------------------------------------------------------------
// Connects the Flutter app to the Node.js/Express backend at
// http://localhost:4000 with Firebase Auth token in headers.
//
// Routes to:
//   POST /api/payments/complete-job — complete a job & process payment
//   GET  /api/payments/wallet/:providerId — wallet summary & ledger
//   POST /api/payments/top-up — top up wallet via JazzCash/Easypaisa
// ===================================================================

import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Response wrapper for all API calls.
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] as bool? ?? false,
      data: json['data'],
      error: json['error'] as String?,
    );
  }
}

/// Core API Service — handles auth headers, requests, error mapping.
class ApiService {
  // In production, use the deployed backend URL.
  // For local dev with Flutter on desktop/emulator:
  //   Android emulator → 10.0.2.2
  //   iOS simulator    → localhost
  //   Windows/macOS    → localhost
  static const String _baseUrl = 'http://localhost:4000';

  /// Shared headers including Firebase Auth bearer token.
  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken != null) {
        headers['Authorization'] = 'Bearer $idToken';
      }
    } catch (e) {
      debugPrint('[ApiService] Failed to get Firebase token: $e');
    }

    // In dev mode without Firebase, use mock auth header
    if (_isDevMode()) {
      headers['Authorization'] = 'Bearer dev-mock-token';
    }

    return headers;
  }

  static bool _isDevMode() => kDebugMode;

  // ────────────────────────────────────────────────────────────
  // PAYMENT API
  // ────────────────────────────────────────────────────────────

  /// POST /api/payments/complete-job
  ///
  /// Completes a booking and processes payment.
  /// [bookingId] — the booking/job ID
  /// [paymentMethod] — "CASH", "MOBILE_WALLET", or "CREDIT_CARD"
  /// [walletProvider] — required for MOBILE_WALLET: "JAZZCASH", "EASYPAISA", "NAYAPAY"
  static Future<ApiResponse> completeJob({
    required String bookingId,
    required String paymentMethod,
    String? walletProvider,
  }) async {
    try {
      final body = {
        'bookingId': bookingId,
        'paymentMethod': paymentMethod,
        if (walletProvider != null) 'walletProvider': walletProvider,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payments/complete-job'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      return ApiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      debugPrint('[ApiService] completeJob error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// GET /api/payments/wallet/:providerId
  ///
  /// Retrieves wallet summary including:
  /// - walletBalance, totalEarnings, totalCommission
  /// - recentTransactions (ledger log)
  /// - pendingTopUps
  static Future<ApiResponse> getWallet({required String providerId}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/payments/wallet/$providerId'),
        headers: await _headers(),
      );

      return ApiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      debugPrint('[ApiService] getWallet error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  /// POST /api/payments/top-up
  ///
  /// Initiates a wallet top-up via local mobile wallet.
  /// [providerId] — the provider's ID
  /// [amount] — amount to add (e.g. 500 PKR)
  /// [localWalletProvider] — "JAZZCASH", "EASYPAISA", "NAYAPAY"
  static Future<ApiResponse> initiateTopUp({
    required String providerId,
    required double amount,
    required String localWalletProvider,
  }) async {
    try {
      final body = {
        'providerId': providerId,
        'amount': amount,
        'localWalletProvider': localWalletProvider,
      };

      final response = await http.post(
        Uri.parse('$_baseUrl/api/payments/top-up'),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      return ApiResponse.fromJson(jsonDecode(response.body));
    } catch (e) {
      debugPrint('[ApiService] initiateTopUp error: $e');
      return ApiResponse(success: false, error: e.toString());
    }
  }

  // ────────────────────────────────────────────────────────────
  // MOCK / FALLBACK METHODS (for demo without backend)
  // ────────────────────────────────────────────────────────────

  /// Simulates completing a cash job locally (no backend needed).
  /// Returns estimated commission and wallet impact.
  static Map<String, dynamic> mockCompleteCashJob({
    required double finalCost,
  }) {
    const commissionRate = 0.15;
    final commissionFee = (finalCost * commissionRate * 100).round() / 100;
    final netAmount = finalCost - commissionFee;

    return {
      'paymentMethod': 'CASH',
      'grossAmount': finalCost,
      'commissionFee': commissionFee,
      'netAmount': netAmount,
      'walletImpact': -commissionFee, // wallet debited by commission
      'description':
          'Cash job: PKR $finalCost completed. 15% commission (PKR $commissionFee) will be deducted from wallet.',
    };
  }

  /// Simulates completing a digital payment job locally.
  static Map<String, dynamic> mockCompleteDigitalJob({
    required double finalCost,
    required String method,
  }) {
    const commissionRate = 0.15;
    final commissionFee = (finalCost * commissionRate * 100).round() / 100;
    final netAmount = finalCost - commissionFee;

    return {
      'paymentMethod': method,
      'grossAmount': finalCost,
      'commissionFee': commissionFee,
      'netAmount': netAmount,
      'walletImpact': netAmount, // wallet credited by net
      'gatewayRef': 'MOCK-${DateTime.now().millisecondsSinceEpoch}',
      'description':
          'Digital payment: PKR $finalCost via $method. Net PKR $netAmount credited to wallet.',
    };
  }
}

/// Model matching the backend's wallet summary response.
class WalletSummary {
  final String id;
  final String name;
  final double walletBalance;
  final double totalEarnings;
  final double totalCommission;
  final bool walletLocked;
  final bool isActive;
  final String currency;
  final List<LedgerEntry> recentTransactions;
  final List<PendingTopUp> pendingTopUps;

  WalletSummary({
    required this.id,
    required this.name,
    required this.walletBalance,
    required this.totalEarnings,
    required this.totalCommission,
    required this.walletLocked,
    required this.isActive,
    required this.currency,
    required this.recentTransactions,
    required this.pendingTopUps,
  });

  factory WalletSummary.fromJson(Map<String, dynamic> json) {
    return WalletSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      walletBalance: (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      totalCommission: (json['totalCommission'] as num?)?.toDouble() ?? 0.0,
      walletLocked: json['walletLocked'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'PKR',
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => LedgerEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pendingTopUps: (json['pendingTopUps'] as List<dynamic>?)
              ?.map((e) => PendingTopUp.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LedgerEntry {
  final String id;
  final String type;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String description;
  final DateTime createdAt;

  LedgerEntry({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.description,
    required this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble() ?? 0.0,
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PendingTopUp {
  final String id;
  final double amount;
  final double fee;
  final String status;
  final String? provider;
  final DateTime createdAt;

  PendingTopUp({
    required this.id,
    required this.amount,
    required this.fee,
    required this.status,
    this.provider,
    required this.createdAt,
  });

  factory PendingTopUp.fromJson(Map<String, dynamic> json) {
    return PendingTopUp(
      id: json['id'] as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String,
      provider: json['provider'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}