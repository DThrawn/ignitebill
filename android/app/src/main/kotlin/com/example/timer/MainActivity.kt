package com.example.timer

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        // Force l'activité à mettre à jour son intent pour que Flutter puisse le lire
        setIntent(intent)
    }
}
