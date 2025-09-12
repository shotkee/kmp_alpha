package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class InsuranceMain(
    @SerialName("insurance_group_list")
    val insuranceGroupList: List<InsuranceGroup>
)
