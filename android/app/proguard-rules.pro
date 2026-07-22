# Standard Attributes
-keepattributes Signature,Exceptions,InnerClasses,Annotation,SourceFile,LineNumberTable

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

# Support du Java 8+ desugaring
-keep class j$.** { *; }
-keep interface j$.** { *; }
-dontwarn j$.**

# JNI & Reflection Protection
-keepclasseswithmembernames class * {
    native <methods>;
}
