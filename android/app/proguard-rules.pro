# Flutter Play Store deferred components (not used)
-dontwarn com.google.android.play.core.**

# audio_service
-keep class com.ryanheise.audioservice.** { *; }
-keep class com.ryanheise.** { *; }
-keep public class * extends androidx.media.MediaBrowserServiceCompat

# just_audio + media3 (newer just_audio uses media3, not exoplayer2)
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# on_audio_query
-keep class com.lucasjosino.on_audio_query.** { *; }

# Flutter plugin infrastructure
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.embedding.** { *; }

-printusage build/app/outputs/mapping/release/usage.txt
