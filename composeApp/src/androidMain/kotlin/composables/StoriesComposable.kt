package composables

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.runtime.Composable
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil3.compose.AsyncImage
import coil3.compose.LocalPlatformContext
import coil3.request.ImageRequest
import dto.Story
import dto.StoryList
import kotlinx.coroutines.launch
import network.ApiService
import utils.onError
import utils.onSuccess

@Composable
fun StoriesComposable(rest: ApiService) {
    var storiesList by remember {
        mutableStateOf<StoryList>(StoryList(stories = emptyList()))
    }

    val scope = rememberCoroutineScope()

    scope.launch {
        rest.stories()
            .onSuccess {
                storiesList = it
            }
            .onError {

            }
    }

    LazyRow(
        modifier = Modifier
            .height(110.dp)
    ) {
        items(storiesList.stories) { it: Story ->
            Row(
                modifier = Modifier
                    .wrapContentHeight()
                    .padding(),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    modifier = Modifier
                        .padding(4.dp)
                        .height(102.dp)
                        .width(102.dp)
                        .background(Color.Transparent),
                    shape = RoundedCornerShape(15.dp),
                    border = BorderStroke(2.dp,  Color(0x7FE51937))
                ) {
                    Box(
                        modifier = Modifier
                            .padding(4.dp)
                            .clip(shape = RoundedCornerShape(13.dp)),
                        contentAlignment = Alignment.BottomStart
                    ) {
                        //val path = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg"
                        AsyncImage(
                            model = ImageRequest
                                .Builder(LocalPlatformContext.current)
                                .data(it.previewUrlPath)
                                .build(),
                            contentDescription = null,
                            modifier = Modifier
                                .fillMaxSize()
                        )

                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .background(
                                    Brush.verticalGradient(
                                        0F to Color.Transparent,
                                        .5F to Color.Black.copy(alpha = 0.5F),
                                        1F to Color.Black.copy(alpha = 0.8F)
                                    )
                                )
                        )

                        Text(
                            modifier = Modifier
                                .padding(10.dp)
                                .wrapContentSize(),
                            text = it.title,
                            textAlign = TextAlign.Start,
                            color = Color.White,
                            fontSize = 13.sp,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
                Spacer(
                    modifier = Modifier
                        .width(9.dp)
                        .fillMaxHeight()
                )
            }
        }
    }
}