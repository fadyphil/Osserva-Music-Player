package com.osserva.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.media.AudioManager
import android.net.Uri
import android.os.SystemClock
import android.view.KeyEvent
import android.widget.RemoteViews
import android.app.PendingIntent
import es.antonborri.home_widget.HomeWidgetProvider
import es.antonborri.home_widget.HomeWidgetLaunchIntent

class MusicPlayerWidget : HomeWidgetProvider() {

    companion object {
        private const val ACTION_PLAY_PAUSE = "com.osserva.app.WIDGET_PLAY_PAUSE"
        private const val ACTION_NEXT       = "com.osserva.app.WIDGET_NEXT"
        private const val ACTION_PREV       = "com.osserva.app.WIDGET_PREV"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (widgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, widgetId, widgetData)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_PLAY_PAUSE -> dispatchMediaKey(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
            ACTION_NEXT       -> dispatchMediaKey(context, KeyEvent.KEYCODE_MEDIA_NEXT)
            ACTION_PREV       -> dispatchMediaKey(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
        }
    }

    private fun updateWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        widgetId: Int,
        widgetData: SharedPreferences
    ) {
        val title     = widgetData.getString("song_title", "") ?: ""
        val artist    = widgetData.getString("artist", "") ?: ""
        val isPlaying = widgetData.getBoolean("is_playing", false)
        val isShuffle = widgetData.getBoolean("is_shuffle", false)
        val artPath   = widgetData.getString("art_path", "") ?: ""

        val views = RemoteViews(context.packageName, R.layout.music_widget)

        // Text
        views.setTextViewText(R.id.widget_song_title, if (title.isEmpty()) "Not Playing" else title)
        views.setTextViewText(R.id.widget_artist, artist)

        // Album art
        if (artPath.isNotEmpty()) {
            val bitmap = BitmapFactory.decodeFile(artPath)
            if (bitmap != null) {
                views.setImageViewBitmap(R.id.widget_album_art, bitmap)
            } else {
                views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_default_art)
            }
        } else {
            views.setImageViewResource(R.id.widget_album_art, R.drawable.ic_default_art)
        }

        // Play/Pause icon
        val playPauseIcon = if (isPlaying) R.drawable.ic_pause else R.drawable.ic_play
        views.setImageViewResource(R.id.widget_btn_play_pause, playPauseIcon)

        // Shuffle tint (active = accent color, inactive = white with opacity)
        val shuffleTint = if (isShuffle) 0xFF1DB954.toInt() else 0x99FFFFFF.toInt()
        views.setInt(R.id.widget_btn_shuffle, "setColorFilter", shuffleTint)

        // Button intents
        views.setOnClickPendingIntent(
            R.id.widget_btn_play_pause,
            broadcastIntent(context, ACTION_PLAY_PAUSE, widgetId),
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_next,
            broadcastIntent(context, ACTION_NEXT, widgetId),
        )
        views.setOnClickPendingIntent(
            R.id.widget_btn_prev,
            broadcastIntent(context, ACTION_PREV, widgetId),
        )
        // Shuffle -> launches Flutter via HomeWidget URI
        views.setOnClickPendingIntent(
            R.id.widget_btn_shuffle,
            shuffleLaunchIntent(context),
        )

        appWidgetManager.updateAppWidget(widgetId, views)
    }

    private fun broadcastIntent(context: Context, action: String, widgetId: Int): PendingIntent {
        val intent = Intent(context, MusicPlayerWidget::class.java).apply {
            this.action = action
        }
        return PendingIntent.getBroadcast(
            context,
            widgetId,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private fun shuffleLaunchIntent(context: Context): PendingIntent {
        val intent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("audiography://widget/shuffle")
        )
        return intent
    }

    private fun dispatchMediaKey(context: Context, keyCode: Int) {
        val am = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val eventTime = SystemClock.uptimeMillis()
        am.dispatchMediaKeyEvent(KeyEvent(eventTime, eventTime, KeyEvent.ACTION_DOWN, keyCode, 0))
        am.dispatchMediaKeyEvent(KeyEvent(eventTime, eventTime, KeyEvent.ACTION_UP, keyCode, 0))
    }
}