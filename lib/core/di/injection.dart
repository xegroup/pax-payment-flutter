import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_flags.dart';
import '../database/local_storage.dart';
import '../network/api_client.dart';
import '../security/secure_storage_service.dart';
import '../services/storage_service.dart';

final GetIt sl = GetIt.instance;

Future<void> setupDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  if (!sl.isRegistered<SharedPreferences>()) {
    sl.registerSingleton<SharedPreferences>(prefs);
  }
  if (!sl.isRegistered<SecureStorageService>()) {
    sl.registerLazySingleton<SecureStorageService>(
      () => isRunningTests
          ? SecureStorageService.memory()
          : SecureStorageService(),
    );
  }
  if (!sl.isRegistered<StorageService>()) {
    sl.registerLazySingleton<StorageService>(() => StorageService(sl()));
  }
  if (!sl.isRegistered<LocalStorage>()) {
    sl.registerLazySingleton<LocalStorage>(
      () => LocalStorage(sl(), sl()),
    );
  }
  if (!sl.isRegistered<ApiClient>()) {
    sl.registerLazySingleton<ApiClient>(ApiClient.new);
  }
}
