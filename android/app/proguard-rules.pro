# Standard Attributes
-keepattributes Signature,Exceptions,InnerClasses,Annotation,SourceFile,LineNumberTable

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.** { *; }

# flutter_background_service
-keep class id.flutter.flutter_background_service.** { *; }

# home_widget
-keep class es.antonborri.home_widget.** { *; }

# share_plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# printing & pdf
-keep class net.nfet.printing.** { *; }

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Core libraries
-keep class com.google.android.material.** { *; }
-keep class androidx.** { *; }
-dontwarn androidx.**
-dontwarn com.google.android.material.**
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.gms.**
-dontwarn com.google.firebase.**

# Support du Java 8+ desugaring
-keep class j$.** { *; }
-keep interface j$.** { *; }
-dontwarn j$.**

# JNI & Reflection Protection
-keepclasseswithmembernames class * {
    native <methods>;
}
