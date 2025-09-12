package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceProductTag(
    @SerialName("title")
    val title: String,
    @SerialName("title_color")
    val titleColor: String,
    @SerialName("background_color")
    val backgroundColor: String?
)