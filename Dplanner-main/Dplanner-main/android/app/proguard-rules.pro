# Flutter Local Notifications Plugin
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep notification related classes
-keep class * extends android.app.Notification
-keep class * extends android.app.NotificationManager
-keep class * extends android.content.BroadcastReceiver

# Keep timezone related classes
-keep class org.threeten.bp.** { *; }

# Keep Gson classes if used
-keep class com.google.gson.** { *; }
-keepattributes Signature
-keepattributes *Annotation*

# Keep Flutter plugin classes
-keep class io.flutter.plugins.** { *; }

# Keep all classes with @Keep annotation
-keep @androidx.annotation.Keep class * { *; }

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep all classes in the flutter_local_notifications package
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }

# Keep all notification channel classes
-keep class * extends android.app.NotificationChannel { *; }

# Keep all pending intent classes
-keep class * extends android.app.PendingIntent { *; }

# Keep all intent classes
-keep class * extends android.content.Intent { *; }

# Keep all bundle classes
-keep class * extends android.os.Bundle { *; }

# Keep all parcelable classes
-keep class * implements android.os.Parcelable { *; }

# Keep all serializable classes
-keep class * implements java.io.Serializable { *; }
