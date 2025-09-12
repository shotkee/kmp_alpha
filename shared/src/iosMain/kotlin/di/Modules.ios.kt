package di

import dependencies.DbClient
import dependencies.MyViewModel
import org.koin.dsl.module
import org.koin.core.module.dsl.singleOf
import org.koin.core.module.dsl.viewModelOf

actual val platformModule = module {
    singleOf(::DbClient)
    viewModelOf(::MyViewModel)
}