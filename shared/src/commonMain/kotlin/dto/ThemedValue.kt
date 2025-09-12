package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class ThemedValue(
    @SerialName("light")
    val light: String,
    @SerialName("dark")
    val dark: String
)
