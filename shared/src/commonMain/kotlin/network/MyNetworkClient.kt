package network

import io.ktor.client.HttpClient
import io.ktor.client.HttpClientConfig
import io.ktor.client.plugins.contentnegotiation.ContentNegotiation
import io.ktor.client.plugins.logging.LogLevel
import io.ktor.client.plugins.logging.Logging
import io.ktor.serialization.kotlinx.json.json
import io.ktor.client.plugins.logging.Logger
import kotlinx.serialization.json.Json

expect object MyNetworkClient {
    val httpClient: HttpClient
}

fun commonHttpClientConfig(): HttpClientConfig<*>.() -> Unit = {
    install(ContentNegotiation) {
        json(
            json = Json {
                ignoreUnknownKeys = true
                prettyPrint = true
                isLenient = true
            }
        )
    }

    install(Logging) {
        logger = object: Logger {
            override fun log(message: String) {
                println("KtorLog: $message")
            }
        }
        level = LogLevel.ALL
    }
}