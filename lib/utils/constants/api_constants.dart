class APIConstants {
  //static const String baseUrl = 'https://uat.insourceerp.com';
  // static const String baseUrl = 'https://uat-pos.mygeepay.com';
  static const String baseUrl = 'https://gateway.mygeepay.com/api/v1/mobile';
  // static const String trackUrl = 'http://192.168.0.136:8050/v1';
  static const String trackUrl = "https://pos-tracker.geepay.tech/v1";

  static const String loginendpoint = "auth/login";
  static const String dashboardendpoint = "merchant/dashboard";
  static const String transactionhistoryendpoint = "api/my-transactions";
  static const String transactionStatusendpoint = "api/get-transaction-status";
  static const String modesendpoint = "/api/payment-modes";
  static const String userdetailsendpoint = "api/user-details";
  static const String channelsendpoint = "/api/payment/modes/";
  static const String requesttopay = "api/payment/process";
  static const String payBill = "api/bill-payments/purchase";
  static const String transactiondetails = "api/transactions";
  static const String getBillCustomerName =
      "api/bill-payments/get-bill-customer";
  static const String purchasePackage = "api/bill-payments/purchase-voucher";
  static const String requestToPayPackages = "api/request-to-pay/";

  static const String deviceregistrationendpoint = "pos/register";

  static const String pinglocationendpoint = "location/register";
  static const String checkupdateendpoint = "app/update";
  //static const String mnostatusendpoint = "mno/status";
  static const String heartbeatendpoint = "pos/device/heartbeat";
  static const String transactiontimeoutendpoint = "portal/mmp/settimeout";
  static const String transactionstatusendpoint = "portal/mmp/txn/status";
  static const String narrationendpoint = "portal/mmp/narration";
  static const String transactiondetailsendpoint = "portal/mmp/txn/details/";

  static const String terminaltypesendpoint = "terminal-types/get";

  // Merchant Endpoints
  static const String merchantCollect = "merchant/collect";
  static const String merchantNameLookup = "merchant/name-lookup/";
  static const String merchantCollectStatus = "merchant/collect/status/";
  static const String merchantDisburse = "merchant/disburse";
  static const String merchantDisburseStatus = "merchant/disburse/status/";
  static const String merchantBalanceDisbursement = "merchant/balance/disbursement";
  static const String merchantTransactions = "merchant/transactions";
  static const String merchantTransactionDetails = "merchant/transactions/";
}
