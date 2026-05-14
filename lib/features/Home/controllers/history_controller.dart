import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gateway_mobile/utils/constants/api_constants.dart';
import 'package:gateway_mobile/utils/http/http_client.dart';

class HistoryController extends GetxController {
  static HistoryController get instance => Get.find();

  final deviceStorage = GetStorage();
  
  final transactions = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final error = Rx<String?>(null);
  
  final searchController = TextEditingController();
  final statusFilter = 'all'.obs;
  final currentPage = 1.obs;
  final hasNextPage = false.obs;
  
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    loadTransactions();
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchDebounce?.cancel();
    super.onClose();
  }

  void onSearchChanged(String value) {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      loadTransactions(refresh: true);
    });
  }

  void setStatusFilter(String status) {
    statusFilter.value = status;
    loadTransactions(refresh: true);
  }

  Future<void> loadTransactions({bool refresh = false, bool more = false}) async {
    if (refresh) {
      currentPage.value = 1;
      isRefreshing.value = true;
    } else if (more) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    
    error.value = null;

    try {
      final token = deviceStorage.read("token") ?? "";
      
      final queryParams = {
        "page": currentPage.value.toString(),
      };
      
      if (statusFilter.value != 'all') {
        queryParams["status"] = statusFilter.value;
      }
      
      if (searchController.text.trim().isNotEmpty) {
        queryParams["reference"] = searchController.text.trim();
        queryParams["customer"] = searchController.text.trim();
      }

      // Construct URL with query params
      String url = APIConstants.merchantTransactions;
      if (queryParams.isNotEmpty) {
        url += "?" + queryParams.entries.map((e) => "${e.key}=${e.value}").join("&");
      }

      final res = await APPHttpHelper.get(url, token);

      if (res['status'] == 'success' || res['data'] != null) {
        final data = res['data'] ?? res;
        final List<dynamic> rows = data['transactions'] ?? [];
        final meta = data['meta'];

        if (refresh || !more) {
          transactions.assignAll(rows.cast<Map<String, dynamic>>());
        } else {
          transactions.addAll(rows.cast<Map<String, dynamic>>());
        }

        currentPage.value = meta['current_page'] ?? currentPage.value;
        hasNextPage.value = (meta['current_page'] ?? 0) < (meta['last_page'] ?? 0);
      } else {
        error.value = res['message'] ?? "Unable to load transactions.";
      }
    } catch (e) {
      error.value = "Unable to load transactions.";
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (!isLoadingMore.value && hasNextPage.value) {
      currentPage.value++;
      await loadTransactions(more: true);
    }
  }
}
