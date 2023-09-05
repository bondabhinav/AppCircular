import 'package:flexischool/providers/loader_provider.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

void setupLocator() {
  getIt.registerSingleton<LoaderProvider>(LoaderProvider());
}
