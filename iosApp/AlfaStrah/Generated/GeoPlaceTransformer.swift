// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct GeoPlaceTransformer: Transformer {
    typealias Source = Any
    typealias Destination = GeoPlace

    let titleName = "title"
    let descriptionName = "description"
    let fullTitleName = "full_title"
    let countryName = "country"
    let regionName = "region"
    let districtName = "district"
    let cityName = "city"
    let streetName = "street"
    let houseName = "house"
    let apartmentName = "apartment"
    let fiasIdName = "fias_id"
    let fiasLevelName = "fias_level"
    let coordinateName = "coordinate"

    let titleTransformer = CastTransformer<Any, String>()
    let descriptionTransformer = CastTransformer<Any, String>()
    let fullTitleTransformer = CastTransformer<Any, String>()
    let countryTransformer = CastTransformer<Any, String>()
    let regionTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let districtTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let cityTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let streetTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let houseTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let apartmentTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let fiasIdTransformer = OptionalTransformer(transformer: CastTransformer<Any, String>())
    let fiasLevelTransformer = OptionalTransformer(transformer: NumberTransformer<Any, Int>())
    let coordinateTransformer = OptionalTransformer(transformer: CoordinateTransformer())

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let titleResult = dictionary[titleName].map(titleTransformer.transform(source:)) ?? .failure(.requirement)
        let descriptionResult = dictionary[descriptionName].map(descriptionTransformer.transform(source:)) ?? .failure(.requirement)
        let fullTitleResult = dictionary[fullTitleName].map(fullTitleTransformer.transform(source:)) ?? .failure(.requirement)
        let countryResult = dictionary[countryName].map(countryTransformer.transform(source:)) ?? .failure(.requirement)
        let regionResult = regionTransformer.transform(source: dictionary[regionName])
        let districtResult = districtTransformer.transform(source: dictionary[districtName])
        let cityResult = cityTransformer.transform(source: dictionary[cityName])
        let streetResult = streetTransformer.transform(source: dictionary[streetName])
        let houseResult = houseTransformer.transform(source: dictionary[houseName])
        let apartmentResult = apartmentTransformer.transform(source: dictionary[apartmentName])
        let fiasIdResult = fiasIdTransformer.transform(source: dictionary[fiasIdName])
        let fiasLevelResult = fiasLevelTransformer.transform(source: dictionary[fiasLevelName])
        let coordinateResult = coordinateTransformer.transform(source: dictionary[coordinateName])

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        fullTitleResult.error.map { errors.append((fullTitleName, $0)) }
        countryResult.error.map { errors.append((countryName, $0)) }
        regionResult.error.map { errors.append((regionName, $0)) }
        districtResult.error.map { errors.append((districtName, $0)) }
        cityResult.error.map { errors.append((cityName, $0)) }
        streetResult.error.map { errors.append((streetName, $0)) }
        houseResult.error.map { errors.append((houseName, $0)) }
        apartmentResult.error.map { errors.append((apartmentName, $0)) }
        fiasIdResult.error.map { errors.append((fiasIdName, $0)) }
        fiasLevelResult.error.map { errors.append((fiasLevelName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }

        guard
            let title = titleResult.value,
            let description = descriptionResult.value,
            let fullTitle = fullTitleResult.value,
            let country = countryResult.value,
            let region = regionResult.value,
            let district = districtResult.value,
            let city = cityResult.value,
            let street = streetResult.value,
            let house = houseResult.value,
            let apartment = apartmentResult.value,
            let fiasId = fiasIdResult.value,
            let fiasLevel = fiasLevelResult.value,
            let coordinate = coordinateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                title: title,
                description: description,
                fullTitle: fullTitle,
                country: country,
                region: region,
                district: district,
                city: city,
                street: street,
                house: house,
                apartment: apartment,
                fiasId: fiasId,
                fiasLevel: fiasLevel,
                coordinate: coordinate
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let titleResult = titleTransformer.transform(destination: value.title)
        let descriptionResult = descriptionTransformer.transform(destination: value.description)
        let fullTitleResult = fullTitleTransformer.transform(destination: value.fullTitle)
        let countryResult = countryTransformer.transform(destination: value.country)
        let regionResult = regionTransformer.transform(destination: value.region)
        let districtResult = districtTransformer.transform(destination: value.district)
        let cityResult = cityTransformer.transform(destination: value.city)
        let streetResult = streetTransformer.transform(destination: value.street)
        let houseResult = houseTransformer.transform(destination: value.house)
        let apartmentResult = apartmentTransformer.transform(destination: value.apartment)
        let fiasIdResult = fiasIdTransformer.transform(destination: value.fiasId)
        let fiasLevelResult = fiasLevelTransformer.transform(destination: value.fiasLevel)
        let coordinateResult = coordinateTransformer.transform(destination: value.coordinate)

        var errors: [(String, TransformerError)] = []
        titleResult.error.map { errors.append((titleName, $0)) }
        descriptionResult.error.map { errors.append((descriptionName, $0)) }
        fullTitleResult.error.map { errors.append((fullTitleName, $0)) }
        countryResult.error.map { errors.append((countryName, $0)) }
        regionResult.error.map { errors.append((regionName, $0)) }
        districtResult.error.map { errors.append((districtName, $0)) }
        cityResult.error.map { errors.append((cityName, $0)) }
        streetResult.error.map { errors.append((streetName, $0)) }
        houseResult.error.map { errors.append((houseName, $0)) }
        apartmentResult.error.map { errors.append((apartmentName, $0)) }
        fiasIdResult.error.map { errors.append((fiasIdName, $0)) }
        fiasLevelResult.error.map { errors.append((fiasLevelName, $0)) }
        coordinateResult.error.map { errors.append((coordinateName, $0)) }

        guard
            let title = titleResult.value,
            let description = descriptionResult.value,
            let fullTitle = fullTitleResult.value,
            let country = countryResult.value,
            let region = regionResult.value,
            let district = districtResult.value,
            let city = cityResult.value,
            let street = streetResult.value,
            let house = houseResult.value,
            let apartment = apartmentResult.value,
            let fiasId = fiasIdResult.value,
            let fiasLevel = fiasLevelResult.value,
            let coordinate = coordinateResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[titleName] = title
        dictionary[descriptionName] = description
        dictionary[fullTitleName] = fullTitle
        dictionary[countryName] = country
        dictionary[regionName] = region
        dictionary[districtName] = district
        dictionary[cityName] = city
        dictionary[streetName] = street
        dictionary[houseName] = house
        dictionary[apartmentName] = apartment
        dictionary[fiasIdName] = fiasId
        dictionary[fiasLevelName] = fiasLevel
        dictionary[coordinateName] = coordinate
        return .success(dictionary)
    }
}
