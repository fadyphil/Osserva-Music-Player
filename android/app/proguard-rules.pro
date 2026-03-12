# ============================================================
# Flutter Play Core (Deferred Components) — not used in this app
# Flutter's engine references these but we don't use dynamic delivery.
# R8 sees dangling references and fails; we suppress the warnings.
# ============================================================
-dontwarn com.google.android.play.core.**

# ============================================================
# Flutter wrapper — keep all Flutter engine classes
# ============================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ============================================================
# audio_service — keep the service and all MediaSession classes
# ============================================================
-keep class com.ryanheise.audioservice.** { *; }

# ============================================================
# just_audio / ExoPlayer
# ============================================================
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# ============================================================
# Kotlin coroutines (used by just_audio and audio_service internals)
# ============================================================
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}