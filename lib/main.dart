import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:self_code/api/api_follow_user.dart';
import 'package:self_code/pages/after_join.dart';
import 'package:self_code/pages/audio_library.dart';

import 'package:self_code/pages/home_page.dart';
import 'package:self_code/pages/intro.dart';
import 'package:self_code/pages/join_page.dart';
import 'package:self_code/pages/jsonPrint.dart';
import 'package:self_code/pages/library.dart';
import 'package:self_code/pages/log_screen.dart';
import 'package:self_code/pages/media_editor_page.dart';
import 'package:self_code/pages/music_upload.dart';
import 'package:self_code/pages/new_home_screen.dart';
import 'package:self_code/pages/playlist.dart';
import 'package:self_code/pages/post/post_screen_composition.dart';
import 'package:self_code/pages/post/post_single_affirmation.dart';
import 'package:self_code/pages/post/post_video_screen.dart';
import 'package:self_code/pages/prepare_join_list.dart';

import 'package:self_code/pages/profile.dart';
import 'package:self_code/pages/record.dart';
import 'package:self_code/pages/reels.dart';
import 'package:self_code/pages/start_a_program.dart';
import 'package:self_code/pages/edit_view_your_library.dart';

import 'package:provider/provider.dart';
import 'package:self_code/Services/directories.dart';
import 'package:self_code/provider/audio_list_provider.dart';
import 'package:self_code/provider/auth_provider.dart';
import 'package:self_code/provider/characteristics_provider.dart';
import 'package:self_code/provider/local_file_provider.dart';
import 'package:self_code/provider/media_list_provider.dart';
import 'package:self_code/provider/media_track_provider.dart';
import 'package:self_code/provider/single_audio_provider.dart';
import 'package:self_code/provider/single_image_provider.dart';
import 'package:self_code/provider/single_video_provider.dart';
import 'package:self_code/provider/user_data_provider.dart';
import 'package:self_code/services/log_service.dart';
import 'package:self_code/widgets/loginScreenWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'api/api_auth_native_login.dart';
import 'api/api_auth_nativ_registration.dart';
import 'api/api_auth_set_username.dart';
import 'api/api_auth_social_login_and_registration.dart';
import 'api/api_like_post.dart';
import 'api/api_user_profile_upload.dart';
import 'api/token_handler.dart';


import 'api/token_refresher.dart';
import 'models/audio.dart';
import 'models/audio_adapter.dart';
import 'models/composition.dart';
import 'models/composition_adapter.dart';
import 'models/composition_audio_adapter.dart';
import 'models/composition_tag_adapter.dart';
import 'models/personal_growth_characteristic_adapter.dart';
import 'notifier/scroll_position_notifier.dart';
import 'provider/record_list_provider.dart';


//todo implement Dependency Injection Framework to serve instances of classes over the application
//todo implement State Management Solution
//todo write testing for everything
//todo check why main is called twice!!!!!!!!!!!!!!!!!!!!!!!!!
//todo check on just_audio_background (removed) how to cope with that

final getIt = GetIt.instance;
bool isInitialized = false;
Future<void> setupDependencies() async {
  /*TokenApiKeeperValidator instance as a singleton because it typically represents a long-lived and globally shared resource that needs to maintain its state throughout the app's lifecycle.
  This makes sense for a token keeper because we want to ensure that tokens are managed consistently and persistently, even if different parts of the app need to access them.
  On the other hand, RegistrationAPI and SocialAuth are registered as dependencies without using the singleton pattern.
  This means that a new instance of RegistrationAPI and SocialAuth will be created each time they are requested via getIt.get<T>()
  */
  try {
  final tokenApiKeeper = TokenHandler();
  print('Dependency init');
  getIt.registerSingleton<TokenHandler>(tokenApiKeeper);
  //Dependency Injection / registration
  getIt.registerSingleton<ApiAuthNativeRegistration>(ApiAuthNativeRegistration(tokenApiKeeper));
  getIt.registerSingleton<ApiAuthSocialLoginAndRegistration>(ApiAuthSocialLoginAndRegistration(tokenApiKeeper));
  //todo needed anymore?: ApiAuthNativeLogin, ApiAuthSetUsername
  getIt.registerSingleton<ApiAuthNativeLogin>(ApiAuthNativeLogin(tokenApiKeeper));
  getIt.registerSingleton<ApiAuthSetUsername>(ApiAuthSetUsername(tokenApiKeeper));
  getIt.registerSingleton<AuthProvider>(AuthProvider(tokenApiKeeper));
  //This instance is only instanced when needed:
  GetIt.I.registerLazySingleton<ApiLikePost>(() => ApiLikePost());
  GetIt.I.registerLazySingleton<ApiFollowUser>(() => ApiFollowUser());
  getIt.registerLazySingleton<ApiUserProfileUpload>(() => ApiUserProfileUpload());

  getIt.registerSingleton<UserDataProvider>(UserDataProvider(getIt.get<AuthProvider>()));
  getIt.registerSingleton<TokenRefresher>(TokenRefresher());
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  } catch (e) {
    print("Main: Error setting up dependencies: $e");
  }

}

//todo do I also have to load refresh tokens?
//Function to load Tokens from tokenRefresher background job
Future<void> loadTokens() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? accessToken = prefs.getString('accessToken');
  String? refreshToken = prefs.getString('refreshToken');
  if (accessToken != null) {
    getIt.get<TokenHandler>().setAccessToken(accessToken);
    getIt.get<TokenHandler>().setRefreshToken(refreshToken!);
  }
  // Similarly for refresh token
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  // initialize hive
  await Hive.initFlutter();
  // Register custom adapters
  Hive.registerAdapter(CompositionAdapter());
  Hive.registerAdapter(CompositionAudioAdapter());
  Hive.registerAdapter(AudioFileAdapter());
  Hive.registerAdapter(CompositionTagAdapter());
  Hive.registerAdapter(PersonalGrowthCharacteristicAdapter());
  // Open boxes without specifying types
  var metadataBox = await Hive.openBox<Audio>('audioMetadata');
  var compositionBox = await Hive.openBox<Composition>('compositionMetadata');
  var characteristicsBox = await Hive.openBox('characteristicsRatingsBox');



  print('main() called');
  print(StackTrace.current);
  try {
    //Check if initialization was already done
    if (!isInitialized) {
      await setupDependencies();
      isInitialized = true;
    }

    // Load tokens from SharedPreferences
    loadTokens().then((_) {
      // Validate token and load user data if valid
      final tokenHandler = getIt.get<TokenHandler>();
      if (tokenHandler.isAccessTokenAvailableAndValid()) {
        print('Token available, user data loading...');
        final userDataProvider = getIt.get<UserDataProvider>();
        userDataProvider.loadUserData();
        print('logged in with userDataProvider.user?.username: ${userDataProvider.currentUser?.username}');
        // If additional validation is needed (like checking with backend), include it here
      }
      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => getIt.get<AuthProvider>()), // Register AuthProvider
            ChangeNotifierProvider(create: (_) => UserDataProvider(getIt.get<AuthProvider>())),
            ChangeNotifierProvider(create: (context) => AudioListProvider()),
            ChangeNotifierProvider(create: (context) => RecordListProvider(metadataBox)),
            ChangeNotifierProvider(create: (context) => MediaListProvider()),
            ChangeNotifierProvider(create: (context) => SingleImageProvider ()),
            ChangeNotifierProvider(create: (context) => MediaTrackProvider()),
            ChangeNotifierProvider(create: (context) => ScrollPositionNotifier()),
            ChangeNotifierProvider(create: (context) => SingleAudioProvider()),
            ChangeNotifierProvider(create: (context) => LocalFilesProvider()),
            ChangeNotifierProvider(create: (context) => CharacteristicsProvider()),
            ChangeNotifierProvider(create: (context) => SingleVideoProvider()),
            // Add other providers here if needed
          ],
          child: CustomMaterialApp(),  // You can include the lifecycle hooks here
        ),
      );
    });
  } catch (e) {
    print("Main An error occurred: $e");
  }
  //debugPaintSizeEnabled = true;
  //debugPrintLayouts = true;
}

/*  final AuthProvider authProvider = GetIt.instance.get<AuthProvider>();
  if (authProvider.isLoggedIn) {
    final TokenRefresher tokenRefresher = GetIt.instance.get<TokenRefresher>();
    tokenRefresher.initiateTokenRefreshTimers();
  }*/



// CustomMaterialApp now extends StatefulWidget
class CustomMaterialApp extends StatefulWidget {
  @override
  _CustomMaterialAppState createState() => _CustomMaterialAppState();
}

class _CustomMaterialAppState extends State<CustomMaterialApp> with WidgetsBindingObserver {
  //<-- Functionality to keep authentication working when app in background ect.
  final AuthProvider _authProvider = getIt.get<AuthProvider>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAuthState();
    }
  }

  Future<void> _checkAuthState() async {
    if (!await _authProvider.isLoggedIn) {
      await _authProvider.refreshToken;
    }
    final userDataProvider = getIt.get<UserDataProvider>();
    await userDataProvider.loadUserData();
  }
  //----<
  @override
  Widget build(BuildContext context) {
    DirectoryCheck();
    return MaterialApp(

      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/record': (context) => AudioRecorder(),
        '/join': (context) => JoinPage(),
        '/join_list': (context) => AudioFileListScreen(title: 'Mix it up'),
        '/start_a_program': (context) => StartAProgram(),
        '/edit_view_your_library': (context) => AudioLibrary(),
        '/view_json': (context) => ViewJson(),
        '/playlist': (context) => Playlist(),
        '/reels': (context) => SoundReelsPage(),
        '/intro': (context) => Intro(),
        '/library': (context) => MusicLibraryHomeScreen(),
        '/upload_files': (context) => MusicUploadScreen(),
        '/compositionPostPage': (context) => CompositionPostPage(),
        '/postVideoScreen': (context) => PostVideoScreen(),
        '/postSingleAffirmation': (context) => PostSingleAffirmation(),
    '/profile': (context, {arguments}) {
          final userId = arguments?['userId'] as String?;
          return ProfilePage(userId: userId);
        },
        '/authentication': (context) => CustomLoginScreen(),
        '/log': (context) => LogScreen(),
        '/create_media': (context) => MediaEditorPage(),
        '/after_join': (context) => AfterJoin(),
      },
    );
  }
}
