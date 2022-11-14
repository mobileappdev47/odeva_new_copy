# downloads_path_provider_28

Flutter plugin to get the downloads directory.  

> This plugin has lots of inconsistencies and should no **longer be used**. Feel free to fork and tweak it.

## Getting Started

For help getting started with Flutter, view our online
[documentation](https://flutter.io/).

For help on editing plugin code, view the [documentation](https://flutter.io/developing-packages/#edit-plugin-package).

## Usage

  * Add [downloads_path_provider_28](https://pub.dartlang.org/packages/downloads_path_provider_28#-installing-tab-) as a dependency in your pubspec.yaml file.
  * Add `<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />` to your `AndroidManifest.xml`

## Example
```dart
import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';  

Future<Directory> downloadsDirectory = DownloadsPathProvider.downloadsDirectory;
```
