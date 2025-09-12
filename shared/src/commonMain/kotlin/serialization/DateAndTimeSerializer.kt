package serialization

import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.KSerializer
import kotlinx.serialization.descriptors.PrimitiveKind
import kotlinx.serialization.descriptors.PrimitiveSerialDescriptor
import kotlinx.serialization.descriptors.SerialDescriptor
import kotlinx.serialization.encoding.Decoder
import kotlinx.serialization.encoding.Encoder

object DateAndTimeSerializer : KSerializer<Instant> {
    override val descriptor: SerialDescriptor = PrimitiveSerialDescriptor("DateAndTime", PrimitiveKind.STRING)

    override fun deserialize(decoder: Decoder): Instant {
        val raw = decoder.decodeString()
        val formatted = raw.replace(" ", "T")   // "2025-05-18 00:00:00" → "2025-05-18T00:00:00"
        val ldt = LocalDateTime.parse(formatted)
        return ldt.toInstant(TimeZone.UTC)
    }

    override fun serialize(encoder: Encoder, value: Instant) {
        val ldt = value.toLocalDateTime(TimeZone.UTC)
        val formatted = ldt.toString().replace("T", " ")
        encoder.encodeString(formatted)
    }
}