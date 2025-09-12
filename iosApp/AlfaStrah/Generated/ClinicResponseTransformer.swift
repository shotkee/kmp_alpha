// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct ClinicResponseTransformer: Transformer {
    typealias Source = Any
    typealias Destination = ClinicResponse

    let clinicListName = "clinic_list"
    let cityListName = "city_list"
    let filterListName = "filter_list"

    let clinicListTransformer = ArrayTransformer(from: Any.self, transformer: ClinicTransformer(), skipFailures: true)
    let cityListTransformer = ArrayTransformer(from: Any.self, transformer: ClinicWithMetroTransformer(), skipFailures: true)
    let filterListTransformer = ArrayTransformer(from: Any.self, transformer: ClinicFilterTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let clinicListResult = dictionary[clinicListName].map(clinicListTransformer.transform(source:)) ?? .failure(.requirement)
        let cityListResult = dictionary[cityListName].map(cityListTransformer.transform(source:)) ?? .failure(.requirement)
        let filterListResult = dictionary[filterListName].map(filterListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        clinicListResult.error.map { errors.append((clinicListName, $0)) }
        cityListResult.error.map { errors.append((cityListName, $0)) }
        filterListResult.error.map { errors.append((filterListName, $0)) }

        guard
            let clinicList = clinicListResult.value,
            let cityList = cityListResult.value,
            let filterList = filterListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                clinicList: clinicList,
                cityList: cityList,
                filterList: filterList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let clinicListResult = clinicListTransformer.transform(destination: value.clinicList)
        let cityListResult = cityListTransformer.transform(destination: value.cityList)
        let filterListResult = filterListTransformer.transform(destination: value.filterList)

        var errors: [(String, TransformerError)] = []
        clinicListResult.error.map { errors.append((clinicListName, $0)) }
        cityListResult.error.map { errors.append((cityListName, $0)) }
        filterListResult.error.map { errors.append((filterListName, $0)) }

        guard
            let clinicList = clinicListResult.value,
            let cityList = cityListResult.value,
            let filterList = filterListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[clinicListName] = clinicList
        dictionary[cityListName] = cityList
        dictionary[filterListName] = filterList
        return .success(dictionary)
    }
}
