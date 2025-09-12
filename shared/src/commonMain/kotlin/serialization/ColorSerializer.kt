package serialization

import androidx.compose.ui.graphics.Color
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.*
import kotlinx.serialization.encoding.*

object ColorSerializer : KSerializer<Color> {
    override val descriptor: SerialDescriptor =
        PrimitiveSerialDescriptor("Color", PrimitiveKind.STRING)

    override fun serialize(encoder: Encoder, value: Color) {
        val hexString = "#" + (value.value and 0xFFFFFFu).toString(16).padStart(6, '0').uppercase()
        encoder.encodeString(hexString)
    }

    override fun deserialize(decoder: Decoder): Color {
        val rawHex = decoder.decodeString().removePrefix("#").lowercase().trim()

        require(rawHex.matches(Regex("^[0-9a-f]{6,8}$"))) {
            "Invalid hex color format: '$rawHex'"
        }

        val intValue = rawHex.toInt(16)

        return Color(intValue)
    }
}