package local.family.alice_companions

import android.app.Activity
import android.content.ActivityNotFoundException
import android.content.ClipData
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMethodCodec
import java.io.File
import java.io.IOException
import java.nio.file.Files
import java.nio.file.InvalidPathException
import java.nio.file.LinkOption.NOFOLLOW_LINKS

class UpdateFileProvider : FileProvider()

internal class AppUpdateInstaller(private val activity: Activity) {
    private val packages get() = activity.packageManager

    fun register(messenger: BinaryMessenger): MethodChannel = MethodChannel(
        messenger,
        "alice/update",
        StandardMethodCodec.INSTANCE,
        messenger.makeBackgroundTaskQueue(),
    ).apply {
        setMethodCallHandler(::handle)
    }

    private fun handle(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "installed" -> {
                    val installed = installedPackage()
                    val name = installed.versionName
                        ?: throw UpdateError("installed_version", "无法读取已安装的版本名称。")
                    result.success(mapOf("versionName" to name, "versionCode" to installed.buildCode()))
                }
                "install" -> {
                    val archive = checkedArchive(call.arguments)
                    launch(result, "无法打开系统安装界面。") { promptInstall(archive) }
                }
                "openDownloads" -> launch(result, "无法打开 GitHub 下载目录。") {
                    activity.startActivity(
                        Intent(Intent.ACTION_VIEW, Uri.parse(DOWNLOADS_URL))
                            .addCategory(Intent.CATEGORY_BROWSABLE),
                    )
                    null
                }
                else -> result.notImplemented()
            }
        } catch (error: UpdateError) {
            result.error(error.code, error.message, null)
        } catch (_: PackageManager.NameNotFoundException) {
            result.error("installed_package", "无法读取已安装的小小伙伴。", null)
        } catch (_: IOException) {
            result.error("update_file", "无法读取更新文件，请重新下载。", null)
        } catch (_: InvalidPathException) {
            result.error("update_path", "更新文件路径无效，请重新下载。", null)
        } catch (_: SecurityException) {
            result.error("update_access", "系统拒绝读取更新文件。", null)
        }
    }

    private fun checkedArchive(arguments: Any?): File {
        val fields = arguments as? Map<*, *>
        val rawPath = fields?.get("path") as? String
        val expectedCode = when (val value = fields?.get("versionCode")) {
            is Int -> value.toLong()
            is Long -> value
            else -> 0L
        }
        if (rawPath.isNullOrBlank() || expectedCode <= 0L) {
            throw UpdateError("update_arguments", "更新文件或版本无效，请重新下载。")
        }

        val directory = File(activity.cacheDir.canonicalFile, "alice-updates")
        val requested = File(rawPath)
        val archive = requested.canonicalFile
        if (!requested.isAbsolute ||
            requested.parentFile?.canonicalFile != directory || archive.parentFile != directory ||
            !requested.extension.equals("apk", ignoreCase = true) ||
            !Files.isRegularFile(requested.toPath(), NOFOLLOW_LINKS) || requested.length() <= 0L
        ) {
            throw UpdateError("update_path", "更新文件未下载完成，请重新下载。")
        }

        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            PackageManager.GET_SIGNING_CERTIFICATES
        } else {
            @Suppress("DEPRECATION")
            PackageManager.GET_SIGNATURES
        }
        val installed = installedPackage(flags)
        val candidate = archivedPackage(archive, flags)
            ?: throw UpdateError("invalid_apk", "安装包无法读取，请重新下载。")

        if (candidate.packageName != activity.packageName) {
            throw UpdateError("wrong_package", "这个安装包不属于已安装的小小伙伴。")
        }
        if (candidate.buildCode() != expectedCode) {
            throw UpdateError("unexpected_version", "安装包版本与更新记录不一致。")
        }
        if (expectedCode <= installed.buildCode()) {
            throw UpdateError("old_version", "安装包版本未高于当前版本。")
        }
        val installedSigners = installed.currentSigners()
        if (installedSigners.isEmpty() || installedSigners != candidate.currentSigners()) {
            throw UpdateError("wrong_signature", "安装包签名与已安装的小小伙伴不一致。")
        }
        return archive
    }

    @Suppress("DEPRECATION")
    private fun installedPackage(flags: Int = 0): PackageInfo =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packages.getPackageInfo(
                activity.packageName,
                PackageManager.PackageInfoFlags.of(flags.toLong()),
            )
        } else {
            packages.getPackageInfo(activity.packageName, flags)
        }

    @Suppress("DEPRECATION")
    private fun archivedPackage(file: File, flags: Int): PackageInfo? =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            packages.getPackageArchiveInfo(file.path, PackageManager.PackageInfoFlags.of(flags.toLong()))
        } else {
            packages.getPackageArchiveInfo(file.path, flags)
        }

    @Suppress("DEPRECATION")
    private fun PackageInfo.buildCode(): Long =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) longVersionCode else versionCode.toLong()

    @Suppress("DEPRECATION")
    private fun PackageInfo.currentSigners(): Set<Signature> =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            signingInfo?.apkContentsSigners?.toSet().orEmpty()
        } else {
            signatures?.toSet().orEmpty()
        }

    @Suppress("DEPRECATION")
    private fun promptInstall(archive: File): String {
        if (!packages.canRequestPackageInstalls()) {
            try {
                activity.startActivity(
                    Intent(
                        Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                        Uri.fromParts("package", activity.packageName, null),
                    ),
                )
            } catch (_: ActivityNotFoundException) {
                throw UpdateError("install_settings", "无法打开允许安装应用的系统设置。")
            }
            return "permission"
        }
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.updates", archive)
        val intent = Intent(Intent.ACTION_INSTALL_PACKAGE)
            .setDataAndType(uri, "application/vnd.android.package-archive")
            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        intent.clipData = ClipData.newRawUri("APK", uri)
        activity.startActivity(intent)
        return "launched"
    }

    private fun launch(result: MethodChannel.Result, message: String, action: () -> Any?) {
        activity.runOnUiThread {
            if (activity.isFinishing || activity.isDestroyed) {
                result.error("inactive_app", "请返回小小伙伴后重试。", null)
                return@runOnUiThread
            }
            try {
                result.success(action())
            } catch (error: UpdateError) {
                result.error(error.code, error.message, null)
            } catch (_: ActivityNotFoundException) {
                result.error("update_activity", message, null)
            } catch (_: SecurityException) {
                result.error("update_activity", message, null)
            } catch (_: IllegalArgumentException) {
                result.error("update_activity", message, null)
            }
        }
    }

    private class UpdateError(val code: String, message: String) : Exception(message)

    companion object {
        private const val DOWNLOADS_URL =
            "https://github.com/tonymd323/alice-little-companions/tree/android-downloads/downloads"
    }
}
