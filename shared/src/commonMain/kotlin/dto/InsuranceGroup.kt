package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceGroup(
    @SerialName("object_name")
    val objectName : String,
    @SerialName("object_type")
    val objectType : String,
    @SerialName("insurance_group_category_list")
    val insuranceGroupCategoryList : List<InsuranceGroupCategory>
)
