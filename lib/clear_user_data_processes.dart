//Cancel background tasks
import 'package:get_it/get_it.dart';
import 'package:workmanager/workmanager.dart';

import 'api/token_refresher.dart';

class ClearUserDataProcess{
clearJobs() {
Workmanager().cancelAll(); //cancelByTag('tokenRefresher');
// Cancel the token refresh timers
//final TokenRefresher tokenRefresher = GetIt.instance.get<TokenRefresher>();
//tokenRefresher.cancelTimers();
}
}