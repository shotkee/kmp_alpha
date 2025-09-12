package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceCategoryMain(
    @SerialName("id")
    val id: String,
    @SerialName("title")
    val title: String,
    @SerialName("description")
    val description: String,
    @SerialName("type")
    val type: CategoryType,
    @SerialName("icon")
    val icon: String?,
    @SerialName("icon_themed")
    val iconThemed: ThemedValue?
) {
    @Serializable
    enum class CategoryType {
        @SerialName ("0")
        UNSUPPORTED,
        @SerialName("1")
        AUTO,
        @SerialName("2")
        HEALTH,
        @SerialName("3")
        PROPERTY,
        @SerialName("4")
        TRAVEL,
        @SerialName("5")
        PASSENGERS,
        @SerialName("6")
        LIFE;
    }
}
