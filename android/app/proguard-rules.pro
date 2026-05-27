# Flutter/Dart-specific ProGuard rules

# Keep all classes in our app package (AccessibilityService, BlockingActivity, BootReceiver, MainActivity)
-keep class com.stayfocus.stayfocusintern.** { *; }

# Keep AccessibilityService subclasses (critical — R8 would remove them otherwise)
-keep class * extends android.accessibilityservice.AccessibilityService { *; }

# Keep BroadcastReceiver subclasses (BootReceiver)
-keep class * extends android.content.BroadcastReceiver { *; }

# Keep Activity subclasses (BlockingActivity)
-keep class * extends android.app.Activity { *; }

# Flutter engine — do not touch
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# SharedPreferences — used by both Flutter plugin and native code
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$* { *; }
