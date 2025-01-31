package com.example.maso

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channel = "maso.file"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Handling of the intent to open .maso files
        if (intent?.action == Intent.ACTION_VIEW && intent.data != null) {
            handleFileOpen(intent.data)
        }
    }

    private fun handleFileOpen(fileUri: Uri?) {
        fileUri?.let {
            try {
                val inputStream = contentResolver.openInputStream(it)
                val tempFile = File(cacheDir, "temp.maso")
                tempFile.outputStream().use { output -> inputStream?.copyTo(output) }

                // Send temporary file path to Flutter
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, channel)
                    .invokeMethod("openFile", tempFile.absolutePath)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }
}
