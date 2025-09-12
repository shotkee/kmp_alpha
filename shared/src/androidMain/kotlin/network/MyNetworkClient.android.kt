package network

import io.ktor.client.HttpClient
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import io.ktor.client.plugins.logging.LogLevel
import android.util.Log
import io.ktor.client.engine.cio.CIO

actual object MyNetworkClient {
    actual val httpClient: HttpClient = HttpClient(CIO) {
        commonHttpClientConfig().invoke(this)

        install(Logging) {
            logger = object : Logger {
                override fun log(message: String) {
                    Log.d("KtorLog", message)
                }
            }
            level = LogLevel.ALL
        }
    }
}