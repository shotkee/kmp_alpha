package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceProduct (
    @SerialName("product_id")
    val id: Int,
    @SerialName("title")
    val title: String,
    @SerialName("text")
    val text: String,
    @SerialName("image")
    val image: String,
    @SerialName("detailed_image")
    val detailedImage: String,
    @SerialName("tag_list")
    val tagList: List<InsuranceProductTag>
)
