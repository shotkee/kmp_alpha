package network

import dto.InsuranceMain
import dto.InsuranceProductCategoryList
import dto.Response
import dto.StoryList
import io.ktor.client.*
import io.ktor.client.call.body
import io.ktor.client.request.get
import io.ktor.client.request.header
import io.ktor.http.ContentType
import io.ktor.http.contentType
import io.ktor.util.network.UnresolvedAddressException
import kotlinx.serialization.SerializationException
import utils.NetworkError
import utils.Result

class ApiService(private val client: HttpClient = MyNetworkClient.httpClient) {
    suspend fun insurances(): Result<InsuranceMain, NetworkError> {
        return request(client,"https://alfa-stage.entelis.team/api/insurances")
    }

    suspend fun stories(): Result<StoryList, NetworkError> {
        return request(client,"https://alfa-stage.entelis.team/api/stories?screen_width=414")
    }

    suspend fun products(): Result<InsuranceProductCategoryList, NetworkError> {
        return request(client,"https://alfa-stage.entelis.team/api/insurances/products")
    }

    suspend inline fun <reified T>request(client: HttpClient, urlString: String): Result<T, NetworkError> {
        val response = try {
            client.get(
                urlString = urlString
            ) {
                //parameter("text", param)
                //header("Content-Type" , "application-json")
                contentType(ContentType.Application.Json)
                header("Access-Token", "96125653593476aaa3133d6ac366c51c74fcf99acbba")
            }
        } catch (e: UnresolvedAddressException) {
            return Result.Error(NetworkError.NO_INTERNET)
        } catch(e: SerializationException) {
            return Result.Error(NetworkError.SERIALIZATION)
        }

        return when(response.status.value) {
            in 200  ..  299 -> {
                val text = response.body<Response<T>>()
                Result.Success(text.data)
            }
            401 -> Result.Error(NetworkError.UNAUTHORIZED)
            409 -> Result.Error(NetworkError.CONFLICT)
            408 -> Result.Error(NetworkError.REQUEST_TIMEOUT)
            413 -> Result.Error(NetworkError.PAYLOAD_TOO_LARGE)
            in 500..599 -> Result.Error(NetworkError.SERVER_ERROR)
            else -> Result.Error(NetworkError.UNKNOWN)
        }
    }
}