/// Centralized string resources for the Pax Payment app
/// Use these instead of hardcoded strings throughout the project
class PaxPaymentStrings {
  PaxPaymentStrings._();

  // ============ APP GENERAL ============
  static const String appName = 'Pax Payment';
  static const String paxPayment = 'PAX PAYMENT';
  static const String loading = 'Loading...';
  static const String pleaseWait = 'Please wait...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String ok = 'OK';
  static const String yes = 'Yes';
  static const String no = 'No';
  static const String save = 'Save';
  static const String clearOrder = 'Clear Order';
  static const String exit = 'Exit';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String back = 'BACK';
  static const String next = 'Next';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String retry = 'Retry';
  static const String submit = 'Submit';
  static const String search = 'Search';
  static const String guest = 'Guest';

  // ============ AUTH / LOGIN ============
  static const String login = 'LOGIN';
  static const String logIn = 'Login';
  static const String loginIn = 'Login In';
  static const String logout = 'Logout';
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String createAccount = 'Create Account';
  static const String alreadyHaveAccount = 'Already a User? ';
  static const String dontHaveAccount = 'New to Pax Payment? ';
  static const String forgotPassword = 'Forgot Password?';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String username = 'Username';
  static const String enterEmail = 'Enter your email';
  static const String enterPassword = 'Enter your password';
  static const String enterUsername = 'Enter your username';
  static const String invalidEmail = 'Invalid email address';
  static const String invalidPassword =
      'Password must be at least 6 characters';
  static const String passwordMismatch = 'Passwords do not match';
  static const String loginSuccess = 'Login successful';
  static const String loginFailed = 'Login failed';
  static const String signupSuccess = 'Account created successfully';
  static const String signupFailed = 'Failed to create account';
  static const String welcomeBack = 'Welcome Back!';
  static const String createYourAccount = 'Create your account';
  static const String or = 'or';
  static const String phoneNumber = 'Phone Number';
  static const String enterPhoneNumber = 'Enter phone number';
  static const String phoneNumberRequired = 'Phone number is required';
  static const String invalidPhoneNumber = 'Please enter a valid phone number';

  // ============ PIN SCREEN ============
  static const String passcode = 'Passcode';
  static const String selectUsername = 'Select Username';
  static const String selectEmployee = 'Select Employee';
  static const String pleaseSelectEmployee = 'Please select employee';
  static const String youAreNotClockedIn = 'You are not clocked in';
  static const String clockIn = 'Clock in';
  static const String clockOut = 'Clock out';
  static const String clockedIn = 'Clocked In';
  static const String clockedOut = 'Clocked Out';
  static const String clockInSuccess = 'Clocked In Successfully';
  static const String clockOutSuccess = 'Clocked Out Successfully';
  static const String confirmClockOut = 'Confirm Clock Out';
  static const String confirmClockOutMessage =
      'Are you sure you want to clock out?';
  static const String noEmployeesAvailable = 'No employees available';

  // ============ NAVIGATION OPTIONS ============
  static const String admin = 'Admin';
  static const String ordering = 'Ordering';
  static const String manageRegister = 'Manage Register';
  static const String registerNotOpen = 'Register not open';
  static const String technicalSupport = 'Technical Support';

  // ============ ORDERING SCREEN ============
  static const String menu = 'Menu';
  static const String tabsAndTables = 'Tabs & Tables';
  static const String orders = 'Orders';
  static const String options = 'POS OPTIONS';
  static const String holdOrder = 'HOLD ORDER';
  static const String addServiceStage = 'ADD SERVICE STAGE';
  static const String pay = 'PAY';
  static const String order = 'ORDER';
  static const String product = 'Product';
  static const String qty = 'Qty';
  static const String each = 'Each';
  static const String total = 'Total';
  static const String customer = 'Customer:';
  static const String tableNumber = 'Table Number:';
  static const String tab = 'Tab:';
  static const String limit = 'Limit:';
  static const String date = 'Date:';
  static const String items = 'Items';
  static const String deals = 'Deals';
  static const String totalDiscount = 'Total Discount';
  static const String subTotal = 'SubTotal';
  static const String tax = 'Tax';
  static const String serviceCharges = 'Service Charges';
  static const String paidItems = 'paid items';
  static const String cartIsEmpty = 'Cart is Empty.Start taking Orders.';
  static const String testMode = 'TEST MODE';
  static const String orderingStaffFallback = 'Staff';
  static const String orderingViewOrder = 'View Order';
  static const String orderingNoItemsInOrder = 'No items in order';
  static const String orderingItemSingular = 'item';
  static const String orderingItemPlural = 'items';
  static const String orderingNewItems = 'New Items';
  static const String ordersViewAndManage = 'View and manage orders';

  // ============ ORDER OPTIONS ============
  static const String optionAdd = 'Add';
  static const String optionPrint = 'Print';
  static const String optionDiscount = 'Discount';
  static const String optionNotes = 'Notes';
  static const String optionSeparate = 'Separate';
  static const String optionCancel = 'Cancel Item';
  static const String optionSplit = 'Split';
  static const String optionEdit = 'Edit';
  static const String optionRetrieve = 'Retrieve';
  static const String optionRecall = 'Recall';
  static const String optionManualDiscount = 'Manual Discount';
  static const String optionAddMisc = 'Add Misc';
  static const String optionVoidOrder = 'Void Order';

  // ============ OPTION MESSAGES ============
  static const String noItemsToPrint = 'No items to print';
  static const String addItemsBeforeDiscount =
      'Please add items to the order before applying discounts';
  static const String noItemsToSeparate = 'No items to separate';
  static const String noItemsToCancel = 'No items to cancel';
  static const String noItemsToSplit = 'No items to split';
  static const String noItemsToEdit = 'No items to edit';
  static const String addItemsBeforeManualDiscount =
      'Please add items to the order before applying manual discounts';
  static const String noOrderToVoid = 'No order to void';
  static const String comingSoon = 'coming soon';
  static const String optionNotImplemented = 'Option not implemented yet';
  static const String holdOrderSuccess = 'Order held successfully';
  static const String holdOrderFailed = 'Failed to hold order';
  static const String noItemsToHold = 'No items to hold';
  static const String noOrdersToRetrieve = 'No orders to retrieve';
  static const String ordersDialogTitle = 'Orders';
  static const String noOrdersFound = 'No orders found';
  static const String orderSubmitted = 'Order submitted successfully';
  static const String orderSubmitFailed = 'Failed to submit order';
  static const String orderVoided = 'Order voided';
  static const String orderVoidFailed = 'Failed to void order';
  static const String confirmVoidOrder =
      'Are you sure you want to void this order?';
  static const String voidOrderTitle = 'Void Order';
  static const String selectItemFirst = 'Please select an item first';
  static const String discountApplied = 'Discount applied';
  static const String noteAdded = 'Note saved';
  static const String itemSeparated = 'Item separated';
  static const String itemCancelled = 'Item removed';
  static const String confirmCancelItem = 'Remove this item from the order?';
  static const String cancelItemTitle = 'Cancel Item';
  static const String recallOrders = 'Completed Orders';
  static const String noCompletedOrders = 'No completed orders found';
  static const String printerNotConfigured = 'Printer not configured';
  static const String qtyCannotSeparate =
      'Item quantity must be greater than 1 to separate';
  static const String editItemTitle = 'Edit Item';
  static const String splitNotAvailable = 'Split payment - coming soon';

  // ============ ORDERS HUB DIALOG ============
  static const String ordersHubTitle = 'Orders';
  static const String ordersHubAll = 'All';
  static const String ordersHubPaid = 'Paid';
  static const String ordersHubUnpaid = 'UnPaid';
  static const String ordersHubVoid = 'Void';
  static const String ordersHubOpen = 'Open';
  static const String ordersHubTakeout = 'Takeout';
  static const String ordersHubDinein = 'Dinein';
  static const String ordersHubSearchHint = 'Search by ID or status';
  static const String ordersHubFrom = 'From';
  static const String ordersHubTo = 'To';
  static const String ordersHubColumnId = 'ID';
  static const String ordersHubColumnTime = 'Time';
  static const String ordersHubColumnType = 'Type';
  static const String ordersHubColumnTotal = 'Total';
  static const String ordersHubColumnStatus = 'Status';
  static const String ordersHubColumnServedBy = 'ServedBy';
  static const String ordersHubColumnAction = 'Action';
  static const String ordersHubOpenBtn = 'Open';
  static const String ordersHubPrintBtn = 'Print';

  // ============ MENU SECTION ============
  static const String allCategories = 'All Categories';
  static const String categories = 'Categories';
  static const String noProductsAvailable = 'No products available';
  static const String noCategoriesAvailable = 'No categories available';

  // ============ STORE / BUSINESS ============
  static const String storeCode = 'Store Code';
  static const String storeName = 'Store Name';
  static const String businessName = 'Business Name';
  static const String createStore = 'Create Store';
  static const String selectStore = 'Select Store';
  static const String enterStoreCode = 'Enter store code';
  static const String enterStoreName = 'Enter store name';
  static const String storeCreatedSuccess = 'Store created successfully';
  static const String storeCreatedFailed = 'Failed to create store';

  // ============ DATA RESTORE ============
  static const String restoreData = 'Restore Data';
  static const String restoringData = 'Restoring data...';
  static const String dataRestoredSuccess = 'Data restored successfully';
  static const String dataRestoreFailed = 'Failed to restore data';
  static const String noDataToRestore = 'No data to restore';
  static const String restoreComplete = 'Restore Complete';

  // ============ DIALOG ============
  static const String dialogConfirmTitle = 'Confirm';
  static const String dialogErrorTitle = 'Error';
  static const String dialogSuccessTitle = 'Success';
  static const String dialogWarningTitle = 'Warning';

  // ============ TECHNICAL SUPPORT ============
  static const String supportTel = 'Tel:';
  static const String supportPhoneNumber = '02036331498';
  static const String supportPhoneUK = '+44 121 387 0007';
  static const String supportPhoneUSA = '+1 917 764 4101';
  static const String supportPhoneROI = '+353 01 685 9016';
  static const String supportEmail = 'Email:';
  static const String supportEmailAddress = 'support@paxpayment.co.uk';
  static const String supportHours = 'Mon-Fri : 9am - 5pm';
  static const String supportCallUs = 'Call Us';
  static const String supportEmailUs = 'Email Us';

  // ============ VALIDATION MESSAGES ============
  static const String fieldRequired = 'This field is required';
  static const String invalidInput = 'Invalid input';
  static const String pleaseEnterValue = 'Please enter a value';
  static const String minLengthError = 'Minimum length is';
  static const String maxLengthError = 'Maximum length is';

  // ============ NETWORK ============
  static const String noInternet = 'No internet connection';
  static const String connectionTimeout = 'Connection timeout';
  static const String serverError = 'Server error';
  static const String unknownError = 'An unknown error occurred';
  static const String tryAgain = 'Please try again';

  // ============ CURRENCY ============
  static const String currencySymbol = '£';
  static const String zeroAmount = '0.00';

  // ============ DATE FORMATS ============
  static const String dateFormatDisplay = 'dd-MM-yyyy';
  static const String dateFormatApi = 'yyyy-MM-dd';
  static const String timeFormat12 = 'hh:mm a';
  static const String timeFormat24 = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';

  // ============ ASSETS ============
  static const String logo = 'assets/images/logo_paxpayment.png';
  static const String clockInBackground = 'assets/images/clockin_bg.webp';
  static const String wineGlass = 'assets/images/wine-glass.png';

  // ============ PAYMENT SCREEN ============
  static const String notPaid = 'NOT PAID';
  static const String cash = 'CASH';
  static const String cardReader = 'CARD READER';
  static const String tapToPay = 'TAP TO PAY';
  static const String giftCertificate = 'GIFT CERTIFICATE';
  static const String balanceDue = 'Balance Due';
  static const String tip = 'Tip';
  static const String tipCustom = 'Custom';
  static const String changeDue = 'Change Due';
  static const String paymentComplete = 'Payment Complete';
  static const String addPayment = 'Add Payment';
  static const String paymentBack = 'BACK';
  static const String amountPaid = 'Amount Paid';
  static const String invoiceNumber = 'Invoice number';
  static const String clerk = 'Clerk';
  static const String time = 'Time';
  static const String totalTendered = 'Total Tendered';
  static const String payCancel = 'CANCEL';
  static const String tenderType = 'Tender Type';
  static const String removeTender = 'REMOVE TENDER';
  static const String tenderAmount = 'Tender amount';
  static const String goBack = 'Go Back';
  static const String customTip = 'Custom\nTip';
}

typedef XeposStrings = PaxPaymentStrings;
