package composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import network.ApiService
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Surface
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import coil3.compose.LocalPlatformContext
import coil3.request.ImageRequest
import dto.InsuranceProductCategoryList
import dto.InsuranceProductTag
import dto.StoryList
import kotlinx.coroutines.launch
import style.Style
import style.color
import utils.onError
import utils.onSuccess

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun BuyListScreenComposable(
    rest: ApiService,
    title: (String) -> Unit,
    showNavigationBar: (Boolean) -> Unit
) {
    LaunchedEffect(Unit) {
        title("Купить полис")
        showNavigationBar(true)
    }

    var productCategoryList by remember {
        mutableStateOf<InsuranceProductCategoryList>(InsuranceProductCategoryList(products = emptyList()))
    }

    val scope = rememberCoroutineScope()

    scope.launch {
        rest.products()
            .onSuccess {
                productCategoryList = it
            }
            .onError {

            }
    }

    Column(
        modifier = Modifier
            .verticalScroll(rememberScrollState())
            .background(Color.White)
            .fillMaxSize()
    ) {
        Spacer(modifier = Modifier.height(16.dp))
        productCategoryList.products.getOrNull(0)?.productList?.forEach {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .wrapContentHeight()
                    .padding(
                        start = 18.dp,
                        top = 7.dp,
                        end = 18.dp,
                        bottom = 7.dp
                    )
                    .shadow(elevation = 8.dp, shape = RoundedCornerShape(12.dp))
            ) {
                Row(
                    modifier = Modifier
                        .background(Color.White),
                    verticalAlignment = Alignment.Bottom,
                ) {
                    Column(
                        modifier = Modifier
                            .weight(1f)
                            .wrapContentHeight()
                            .padding(start = 15.dp, top = 15.dp, bottom = 15.dp)
                    ) {
                        Text(
                            text = it.title,
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold
                        )

                        Text(
                            text = it.text,
                            color = Style.Color.secondaryText,
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Normal
                        )

                        Column {
                            it.tagList.forEach { tag: InsuranceProductTag ->
                                Spacer(modifier = Modifier.height(2.dp))
                                Box(
                                    modifier = Modifier
                                        .clip(shape = RoundedCornerShape(percent = 25))
                                        .background(color(from = tag.backgroundColor))
                                ) {
                                    Box(
                                        modifier = Modifier
                                            .padding(start = 10.dp, top = 2.dp, end = 10.dp, bottom = 2.dp)
                                    ) {
                                        Text(
                                            color = color(from = tag.titleColor),
                                            text = tag.title,
                                            fontSize = 15.sp,
                                            fontWeight = FontWeight.Normal
                                        )
                                    }
                                }
                            }
                        }
                    }
                    AsyncImage(
                        model = ImageRequest
                            .Builder(LocalPlatformContext.current)
                            .data(it.image)
                            .build(),
                        contentDescription = null,
                        modifier = Modifier
                            .size(126.dp, 126.dp)
                    )
                }
            }
            Spacer(modifier = Modifier.height(2.dp))
        }
    }
}