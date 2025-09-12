package network

import io.ktor.client.HttpClient
import io.ktor.client.engine.darwin.Darwin
import io.ktor.client.plugins.logging.Logger
import io.ktor.client.plugins.logging.Logging
import platform.Foundation.NSLog
import io.ktor.client.plugins.logging.LogLevel

actual object MyNetworkClient {
    actual val httpClient: HttpClient = HttpClient(Darwin) {
        commonHttpClientConfig().invoke(this)

        install(Logging) {
            logger = object : Logger {
                override fun log(message: String) {
                    NSLog("KtorLog: %s", message)
                }
            }
            level = LogLevel.ALL
        }
    }
}