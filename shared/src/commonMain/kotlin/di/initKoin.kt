package di

import network.ApiService
import org.koin.core.Koin
import org.koin.core.context.startKoin
import org.koin.dsl.KoinAppDeclaration

fun initKoin(config: KoinAppDeclaration? = null) {
    startKoin {
        config?.invoke(this)
        modules(sharedModule, platformModule)
    }
}

private var koinInstance: Koin? = null

fun initKoinOnce(): Koin {
    if (koinInstance == null) {
        koinInstance = startKoin {
            modules(sharedModule)
        }.koin
    }
    return koinInstance!!
}

fun getApiService(): ApiService {
    return koinInstance?.get() ?: error("Koin is not initialized")
}

