# Facebook SDK
-keep class com.facebook.** { *; }
-dontwarn com.facebook.**

# Flutter plugins
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.engine.** { *; }
-dontwarn io.flutter.**

# Keep all annotations
-keepattributes *Annotation*
