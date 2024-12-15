![](https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Flag_of_Palestine.svg/1280px-Flag_of_Palestine.svg.png)
# Free Palestine

## Chatku

Simple Chat application using Flutter and Firebase.

### Install
* [Flutter](https://flutter.dev/docs/get-started/install)
* [Android Studio](https://developer.android.com/studio)
* [Android SDK](https://developer.android.com/studio/command-line/sdkmanager)
* [Xcode](https://developer.apple.com/xcode/)
* [Xcode Command Line Tools](https://developer.apple.com/xcode/resources/)
* [Android Emulator](https://developer.android.com/studio/run/managing-avds)
* [FlutterFirebase](https://firebase.google.com/docs/flutter/setup)

* Clone this project 
```bash
$ git clone https://github.com/Kynonim/Chatku.git
$ cd Chatku
```

### Run the app
```bash
$ flutter pub get
$ flutter run
```
### .env
* Create a file named `.env` in the root directory of the project.
```bash
GEMINI_APIKEY=your_gemini_api_key
```

#### Constants
```dart
import 'package:chatku/core/statis.dart';

// Firebase Auth
Static.auth...

// Firebase Storage
Static.storage...

// User DatabaseReference
Static.userReference...

// Chat DatabaseReference
Static.chatReference...

// Storage Reference
Static.storageReference...

// User local id
Static.uid...
```

# End