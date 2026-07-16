package com.example.timer

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class IgniteBillWidget : HomeWidgetProvider() {
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == "com.example.timer.WIDGET_CLICK") {
            // 1. LEVER LE DRAPEAU (A chaque clic !)
            val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
            widgetData.edit().putBoolean("DATA_WIDGET_CLICKED_FLAG", true).apply()

            // 2. OUVRIR L'APPLICATION
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)?.apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            if (launchIntent != null) {
                context.startActivity(launchIntent)
            }
        }
        super.onReceive(context, intent)
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.ignite_bill_widget).apply {
                val isRunning = widgetData.getBoolean("is_running", false)
                val text = widgetData.getString("widget_text", "Lancer")
                
                setTextViewText(R.id.widget_text, text)
                
                if (isRunning) {
                    setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_background_active)
                    setImageViewResource(R.id.widget_icon, android.R.drawable.ic_media_pause)
                } else {
                    setInt(R.id.widget_root, "setBackgroundResource", R.drawable.widget_background)
                    setImageViewResource(R.id.widget_icon, android.R.drawable.ic_media_play)
                }

                // Clic : On envoie l'action personnalisée à ce Receiver
                val clickIntent = Intent(context, IgniteBillWidget::class.java).apply {
                    action = "com.example.timer.WIDGET_CLICK"
                }
                
                val pendingIntent = PendingIntent.getBroadcast(
                    context, 
                    widgetId, 
                    clickIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                setOnClickPendingIntent(R.id.widget_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
