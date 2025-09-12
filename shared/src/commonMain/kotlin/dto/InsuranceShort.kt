package dto

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.datetime.Instant
import serialization.DateAndTimeSerializer

@Serializable
data class InsuranceShort(
    @SerialName("id")
    val id: String,
    @SerialName("title")
    val title: String,
    @SerialName("start_date")
    @Serializable(with = DateAndTimeSerializer::class)
    val startDate: Instant? = null,
    @SerialName("end_date")
    @Serializable(with = DateAndTimeSerializer::class)
    val endDate: Instant? = null,
    @SerialName("renew_available")
    val renewAvailable: Boolean,
    @SerialName("renew_type")
    val renewType: RenewType,
    @SerialName("description")
    val description: String? = null,
    @SerialName("event_report_type")
    val eventReportType: EventReportType?,
    @SerialName("label")
    val label: String? = null,
    @SerialName("type")
    val type: Kind,
    @SerialName("warning")
    val warning: String?
) {
    @Serializable
    enum class Kind {
        @SerialName("0")
        UNSUPPORTED,
        @SerialName("1")
        KASKO,
        @SerialName("2")
        OSAGO,
        @SerialName("3")
        DMS,
        @SerialName("4")
        VZR,
        @SerialName("5")
        PROPERTY,
        @SerialName("6")
        PASSENGERS,
        @SerialName("7")
        LIFE,
        @SerialName("8")
        ACCIDENT,
        @SerialName("9")
        KASKOONOFF,
        @SerialName("10")
        VZRONOFF,
        @SerialName("11")
        FLATONOFF;
    }

    @Serializable
    enum class RenewType {
        @SerialName("0")
        UNSUPPORTED,
        @SerialName("1")
        URL,
        @SerialName("2")
        OSAGO,
        @SerialName("3")
        KASKO,
        @SerialName("4")
        REMONT,
        @SerialName("5")
        NEIGHBORS;
    }

    @Serializable
    enum class EventReportType {
        @SerialName("0")
        UNSUPPORTED,
        @SerialName("1")
        KASKO,
        @SerialName("2")
        OSAGO,
        @SerialName("3")
        DOCTOR,
        @SerialName("4")
        PASSENGER,
        @SerialName("5")
        VZR;
    }
}
