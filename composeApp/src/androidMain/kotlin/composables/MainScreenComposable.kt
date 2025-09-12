package composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll

import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect

import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import network.ApiService

@Composable
fun MainScreenComposable(
    rest: ApiService,
    title: (String) -> Unit,
    showNavigationBar: (Boolean) -> Unit,
    paddingValues: PaddingValues,
    buyButtonCallback: (() -> Unit)? = null
) {
    LaunchedEffect(Unit) {
        title("")
        showNavigationBar(false)
    }
    Box(modifier = Modifier.fillMaxSize()) {
        Column(
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .background(Color.White)
                .fillMaxSize()
        ) {
            StoriesComposable(rest)
            Spacer(
                modifier = Modifier
                    .height(14.dp)
                    .fillMaxWidth()
            )
            InsurancesComposable(
                rest,
                buyButtonCallback
            )
        }
    }
}