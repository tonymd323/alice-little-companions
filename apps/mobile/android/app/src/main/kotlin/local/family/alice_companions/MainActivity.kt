package local.family.alice_companions

import android.content.Context
import android.media.AudioAttributes
import android.media.SoundPool
import android.util.Log
import io.flutter.FlutterInjector
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileNotFoundException
import java.io.IOException

class MainActivity : FlutterActivity() {
    private var foley: VerandaFoley? = null
    private var soundChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val sounds = VerandaFoley(applicationContext)
        foley = sounds
        soundChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "alice/wind-sound")
            .also { channel ->
                channel.setMethodCallHandler { call, result ->
                    try {
                        when (call.method) {
                            "prepare" -> sounds.prepare()
                            "play" -> sounds.play(call.arguments as? String)
                            "stop" -> sounds.stop()
                            "setMuted" -> sounds.updateMute(call.arguments == true)
                            "isMuted" -> {
                                result.success(sounds.muted)
                                return@setMethodCallHandler
                            }
                            else -> {
                                result.notImplemented()
                                return@setMethodCallHandler
                            }
                        }
                        result.success(null)
                    } catch (error: IOException) {
                        result.error("foley_asset", error.message, null)
                    }
                }
            }
    }

    override fun onResume() {
        super.onResume()
        foley?.foreground = true
    }

    override fun onPause() {
        foley?.apply {
            foreground = false
            stop()
        }
        super.onPause()
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        soundChannel?.setMethodCallHandler(null)
        soundChannel = null
        foley?.close()
        foley = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}

private class VerandaFoley(private val context: Context) {
    var foreground = true
    private val settings = context.getSharedPreferences("veranda_audio", Context.MODE_PRIVATE)
    var muted = settings.getBoolean("muted", false)
        private set
    private var pool: SoundPool? = null
    private val cues = setOf("wind", "scarf", "basket", "takeLeaf", "seatLeaf", "windowLight", "footsteps")
    private val samples = mutableMapOf<String, Int>()
    private val ready = mutableSetOf<Int>()
    private val requested = mutableSetOf<Int>()
    private val playing = mutableMapOf<Int, Int>()

    private fun player(): SoundPool {
        pool?.let { return it }
        val attributes = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_GAME)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        return SoundPool.Builder().setMaxStreams(cues.size).setAudioAttributes(attributes).build().also { next ->
            pool = next
            next.setOnLoadCompleteListener { source, sample, status ->
                if (source !== pool) return@setOnLoadCompleteListener
                val shouldPlay = requested.remove(sample)
                if (status == 0) {
                    ready.add(sample)
                    if (shouldPlay && foreground) start(sample)
                } else {
                    samples.values.remove(sample)
                    Log.w("VerandaFoley", "Could not decode sample, status=$status")
                }
            }
        }
    }

    private fun load(name: String): Int = samples.getOrPut(name) {
        val audio = player()
        val asset = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset("assets/wind/audio/$name.wav")
        val id = try {
            context.assets.openFd(asset).use { audio.load(it, 1) }
        } catch (_: FileNotFoundException) {
            // AssetManager will only give out file descriptors for uncompressed APK entries.
            val file = File.createTempFile("veranda_", ".wav", context.cacheDir)
            try {
                context.assets.open(asset).use { input ->
                    file.outputStream().use { output -> input.copyTo(output) }
                }
                audio.load(file.absolutePath, 1)
            } finally {
                file.delete()
            }
        }
        if (id == 0) throw IOException("Could not load $name")
        id
    }

    fun updateMute(value: Boolean) {
        muted = value
        if (value) stop()
        settings.edit().putBoolean("muted", value).apply()
    }

    fun prepare() {
        if (muted) return
        for (name in cues) load(name)
    }

    fun play(name: String?) {
        if (muted || !foreground || name == null || name !in cues) return
        val sample = load(name)
        if (sample in ready) start(sample) else requested.add(sample)
    }

    private fun start(sample: Int) {
        val audio = pool ?: return
        playing[sample]?.let(audio::stop)
        val stream = audio.play(sample, 1f, 1f, 1, 0, 1f)
        if (stream != 0) playing[sample] = stream
    }

    fun stop() {
        requested.clear()
        playing.values.forEach { pool?.stop(it) }
        playing.clear()
    }

    fun close() {
        stop()
        pool?.release()
        pool = null
        samples.clear()
        ready.clear()
    }
}
