package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceGroupCategory(
    @SerialName("insurance_category")
    val insuranceCategory: InsuranceCategoryMain,
    @SerialName("insurance_list")
    val insuranceList: List<InsuranceShort>
)
