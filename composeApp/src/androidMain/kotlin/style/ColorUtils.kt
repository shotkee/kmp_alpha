package style

import androidx.compose.ui.graphics.Color

fun color(from: String?): Color {
    val str = from ?: return Color.Black

    val cleanHex = str.removePrefix("#")

    val isValid = cleanHex.length == 6 || cleanHex.length == 8
            && cleanHex.all { it in "0123456789ABCDEFabcdef" }

    if (!isValid)
        return Color.Black

    val colorLong = cleanHex.toLongOrNull(16)
        ?: return Color.Black

    return when (cleanHex.length) {
        6 -> Color(colorLong or 0xFF000000)
        8 -> Color(colorLong)
        else -> Color.Black
    }
}