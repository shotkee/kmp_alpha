package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceProductCategory(
    @SerialName("category_id")
    val id: Int,
    @SerialName("title")
    val title: String,
    @SerialName("product_list")
    val productList: List<InsuranceProduct>,
    @SerialName("show_in_filters")
    val showInFilters: Boolean
)

@Serializable
data class InsuranceProductCategoryList(
    @SerialName("insurance_product_list")
    val products: List<InsuranceProductCategory>
)
