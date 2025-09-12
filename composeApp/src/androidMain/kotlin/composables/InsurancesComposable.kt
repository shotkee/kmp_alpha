package composables

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.requiredHeight
import androidx.compose.foundation.layout.requiredWidth
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.layout.wrapContentSize
import androidx.compose.foundation.layout.wrapContentWidth
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import dto.InsuranceGroup
import dto.InsuranceGroupCategory
import dto.InsuranceMain
import dto.InsuranceShort
import kmp_alpha.composeapp.generated.resources.Res
import kmp_alpha.composeapp.generated.resources.compose_multiplatform
import kmp_alpha.composeapp.generated.resources.divkit_down
import kmp_alpha.composeapp.generated.resources.divkit_up
import kotlinx.coroutines.launch
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.format
import kotlinx.datetime.format.DateTimeComponents
import kotlinx.datetime.format.DateTimeFormat
import kotlinx.datetime.format.byUnicodePattern
import kotlinx.datetime.toLocalDateTime
import network.ApiService
import org.jetbrains.compose.resources.painterResource
import utils.onError
import utils.onSuccess

@Composable
fun InsurancesComposable(
    rest: ApiService,
    buyButtonCallback: (() -> Unit)? = null
) {
    var insuranceMain by remember {
        mutableStateOf<InsuranceMain?>(null)
    }

    val scope = rememberCoroutineScope()

    scope.launch {
        rest.insurances()
            .onSuccess {
                insuranceMain = it
            }
            .onError {

            }
    }

    Box(
        modifier = Modifier
            .wrapContentHeight()
            .fillMaxWidth()
            .shadow(elevation = 16.dp, shape = RoundedCornerShape(12.dp))
            .background(Color.White)
    ) {
        Column(
            modifier = Modifier
                .padding(14.dp)
        ) {
            Row(
                verticalAlignment = Alignment.CenterVertically,
                modifier = Modifier
                    .fillMaxWidth()
                    .wrapContentHeight()
            ) {
                Text(
                    modifier = Modifier
                        .weight(1f),
                    text = "Полисы",
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold
                )

                Button(
                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFE51937)),
                    modifier = Modifier
                        .height(36.dp)
                        .wrapContentWidth(),
                    onClick = {
                        buyButtonCallback?.invoke()
                    }
                ) {
                    Text(
                        text = "Купить",
                        fontSize = 15.sp,
                        color = Color.White
                    )
                }
            }

            Spacer(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(20.dp)
            )

            Surface(
                modifier = Modifier
                    .shadow(elevation = 8.dp, shape = RoundedCornerShape(12.dp))
            ) {
                Column {
                    insuranceMain?.insuranceGroupList?.forEach { item: InsuranceGroup ->
                        Box(
                            modifier = Modifier
                                .wrapContentHeight()
                                .fillMaxWidth()
                                .background(Color.White)
                        ) {
                            Column(
                                modifier = Modifier
                                    .padding(15.dp)
                            ) {
                                var isHidden by remember {
                                    mutableStateOf<Boolean>(false)
                                }

                                Row(
                                    verticalAlignment = Alignment.CenterVertically,
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .wrapContentHeight()
                                ) {
                                    Column(
                                        modifier = Modifier
                                            .weight(1f)
                                            .wrapContentHeight()
                                            //.width(100.dp)
                                           // .padding(end = 30.dp)
                                    ) {
                                        Text(
                                            modifier = Modifier
                                                .wrapContentSize(),
                                            text = item.objectType,
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Normal,
                                            textAlign = TextAlign.Start
                                        )
                                        Text(
                                            modifier = Modifier
                                                .wrapContentSize(),
                                            text = item.objectName,
                                            fontSize = 16.sp,
                                            fontWeight = FontWeight.Bold,
                                            textAlign = TextAlign.Start
                                        )
                                    }
                                    //Spacer(modifier = Modifier.weight(1f))
                                    IconButton(
                                        onClick = { isHidden = !isHidden },
                                        modifier = Modifier
                                            .wrapContentSize()
                                    ){
                                        Icon(
                                            modifier = Modifier
                                                .requiredWidth(24.dp)
                                                .requiredHeight(24.dp),
                                            painter =
                                                if (isHidden)
                                                    painterResource(Res.drawable.divkit_up)
                                                else
                                                    painterResource(Res.drawable.divkit_down),
                                            contentDescription =
                                                if (isHidden)
                                                    "Selected icon button"
                                                else
                                                    "Unselected icon button."
                                        )
                                    }
                                }

                                if(!isHidden) {
                                    item.insuranceGroupCategoryList.forEach { category: InsuranceGroupCategory ->
                                        Column(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .wrapContentHeight()
                                                .background(Color.LightGray)
                                        ) {
                                            Text(
                                                text = category.insuranceCategory.title,
                                                fontSize = 18.sp,
                                                fontWeight = FontWeight.Normal
                                            )

                                            val formatter = LocalDateTime.Format {
                                                byUnicodePattern("HH:mm:ss dd.MM.yyyy")
                                            }

                                            category.insuranceList.forEach { insurance: InsuranceShort ->
                                                Column {
                                                    Text(
                                                        text = insurance.title,
                                                        fontSize = 18.sp,
                                                        fontWeight = FontWeight.Normal
                                                    )
                                                    Text(
                                                        text = "Действителен до ${ insurance.endDate?.toLocalDateTime(
                                                            TimeZone.currentSystemDefault())?.format(formatter) }",
                                                        fontSize = 11.sp,
                                                        fontWeight = FontWeight.Normal
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        Spacer(
                            modifier = Modifier
                                .height(2.dp)
                                .fillMaxWidth()
                        )
                    }
                }
            }
        }
    }
}


