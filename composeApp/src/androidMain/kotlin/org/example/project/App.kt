package org.example.project

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import coil3.ImageLoader
import coil3.PlatformContext
import coil3.compose.setSingletonImageLoaderFactory
import coil3.disk.DiskCache
import coil3.memory.MemoryCache
import coil3.request.CachePolicy
import coil3.request.crossfade
import coil3.util.DebugLogger
import composables.BuyListScreenComposable
import composables.MainScreenComposable
import org.jetbrains.compose.ui.tooling.preview.Preview
import network.ApiService
import okio.FileSystem
import org.koin.compose.KoinContext
import style.TTNormsTypography
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.Text
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.ui.Alignment
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kmp_alpha.composeapp.generated.resources.Res
import kmp_alpha.composeapp.generated.resources.divkit_up
import kmp_alpha.composeapp.generated.resources.navigate_back
import org.jetbrains.compose.resources.painterResource
import style.Style

@OptIn(ExperimentalMaterial3Api::class)
@Composable
@Preview
fun App(rest: ApiService) {
    MaterialTheme(
        typography = TTNormsTypography()
    ) {
        setSingletonImageLoaderFactory { context ->
            getAsyncImageLoader(context)
        }

        KoinContext {
            val navigationController = rememberNavController()

            var topBarTitle by remember { mutableStateOf("Главный экран") }
            var showNavigationBar by remember { mutableStateOf(false) }

            Scaffold(
                topBar = {
                    if (showNavigationBar) {
                        CenterAlignedTopAppBar(
                            modifier = Modifier.height(44.dp),
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = Color.White
                            ),
                            title = {
                                Box(
                                    modifier = Modifier.fillMaxHeight(),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = topBarTitle,
                                        fontWeight = FontWeight.SemiBold,
                                        fontSize = 16.sp
                                    )
                                }
                            },
                            navigationIcon = {
                                IconButton(
                                    onClick = {
                                        navigationController.popBackStack()
                                    }
                                ) {
                                    Icon(
                                        painter = painterResource( Res.drawable.navigate_back),
                                        tint = Style.Color.accentIcon,
                                        //Icons.AutoMirrored.Filled.ArrowBack,
                                        contentDescription = "Назад"
                                    )
                                }
                            }
                        )
                    }
                }
            ) { padding ->
                NavHost(
                    modifier = Modifier.padding(padding),
                    navController = navigationController,
                    startDestination = "home"
                ) {
                    composable(route = "home") {
                        MainScreenComposable(
                            rest,
                            title = { topBarTitle = it },
                            showNavigationBar = { showNavigationBar = it },
                            paddingValues = padding,
                            buyButtonCallback = {
                                navigationController.navigate("buyList")
                            }
                        )
                    }

                    composable(route = "buyList") {
                        BuyListScreenComposable(
                            rest,
                            title = { topBarTitle = it },
                            showNavigationBar = { showNavigationBar = it }
                        )
                    }
                }
            }
        }
    }
}

fun getAsyncImageLoader(context: PlatformContext) =
    ImageLoader
        .Builder(context)
        .memoryCachePolicy(CachePolicy.ENABLED)
        .memoryCache {
            MemoryCache
                .Builder()
                .maxSizePercent(context, 0.3)
                .strongReferencesEnabled(true)
                .build()
        }
        .diskCachePolicy(CachePolicy.ENABLED)
        .networkCachePolicy(CachePolicy.ENABLED)
        .diskCache {
            newDiskCache()
        }
        .crossfade(true)
        .logger(DebugLogger())
        .build()

fun newDiskCache(): DiskCache {
    return DiskCache
        .Builder()
        .directory(FileSystem.SYSTEM_TEMPORARY_DIRECTORY / "image_cache")
        .maximumMaxSizeBytes(1024L * 1024 * 1024)
        .build()
}