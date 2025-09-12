package style

import androidx.compose.material3.Typography
import androidx.compose.runtime.Composable
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import org.jetbrains.compose.resources.Font
import kmp_alpha.composeapp.generated.resources.Res
import kmp_alpha.composeapp.generated.resources.tt_norms_pro_demibold
import kmp_alpha.composeapp.generated.resources.tt_norms_pro_medium
import kmp_alpha.composeapp.generated.resources.tt_norms_pro_normal
import kmp_alpha.composeapp.generated.resources.tt_norms_pro_regular

@Composable
fun TTNormsFontFamily() = FontFamily(
    Font(Res.font.tt_norms_pro_regular, weight = FontWeight.Light),
    Font(Res.font.tt_norms_pro_normal, weight = FontWeight.Normal),
    Font(Res.font.tt_norms_pro_medium, weight = FontWeight.Medium),
    Font(Res.font.tt_norms_pro_demibold, weight = FontWeight.SemiBold),
    Font(Res.font.tt_norms_pro_demibold, weight = FontWeight.Bold)
)

@Composable
fun TTNormsTypography() = Typography().run {
    val fontFamily = TTNormsFontFamily()

    copy (
        displayLarge = displayLarge.copy(fontFamily = fontFamily),
        displayMedium = displayMedium.copy(fontFamily = fontFamily),
        displaySmall = displaySmall.copy(fontFamily = fontFamily),
        headlineLarge = headlineLarge.copy(fontFamily = fontFamily),
        headlineMedium = headlineMedium.copy(fontFamily = fontFamily),
        headlineSmall = headlineSmall.copy(fontFamily = fontFamily),
        titleLarge = titleLarge.copy(fontFamily = fontFamily),
        titleMedium = titleMedium.copy(fontFamily = fontFamily),
        titleSmall = titleSmall.copy(fontFamily = fontFamily),
        bodyLarge = bodyLarge.copy(fontFamily =  fontFamily),
        bodyMedium = bodyMedium.copy(fontFamily = fontFamily),
        bodySmall = bodySmall.copy(fontFamily = fontFamily),
        labelLarge = labelLarge.copy(fontFamily = fontFamily),
        labelMedium = labelMedium.copy(fontFamily = fontFamily),
        labelSmall = labelSmall.copy(fontFamily = fontFamily)
    )
}