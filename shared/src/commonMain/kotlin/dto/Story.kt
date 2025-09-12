package dto

import androidx.compose.ui.graphics.Color
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import serialization.ColorSerializer

@Serializable
data class Story(
    @SerialName("story_id")
    val id: Int,
    @SerialName("title")
    val title: String,
    @SerialName("title_color")
    @Serializable(with = ColorSerializer::class)
    val titleColor: Color,
    @SerialName("preview")
    val previewUrlPath: String
)

@Serializable
data class StoryList(
    @SerialName("story_list")
    val stories: List<Story>
)
