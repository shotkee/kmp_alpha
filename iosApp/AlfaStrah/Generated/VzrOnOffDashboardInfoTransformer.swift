// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
import Foundation
import CoreGraphics
import Legacy

// swiftlint:disable all
struct VzrOnOffDashboardInfoTransformer: Transformer {
    typealias Source = Any
    typealias Destination = VzrOnOffDashboardInfo

    let balanceName = "balance"
    let activeTripListName = "active_trip_list"

    let balanceTransformer = NumberTransformer<Any, Int>()
    let activeTripListTransformer = ArrayTransformer(from: Any.self, transformer: VzrOnOffTripTransformer(), skipFailures: true)

    func transform(source value: Source) -> TransformerResult<Destination> {
        guard let dictionary = value as? [String: Any] else { return .failure(.source) }

        let balanceResult = dictionary[balanceName].map(balanceTransformer.transform(source:)) ?? .failure(.requirement)
        let activeTripListResult = dictionary[activeTripListName].map(activeTripListTransformer.transform(source:)) ?? .failure(.requirement)

        var errors: [(String, TransformerError)] = []
        balanceResult.error.map { errors.append((balanceName, $0)) }
        activeTripListResult.error.map { errors.append((activeTripListName, $0)) }

        guard
            let balance = balanceResult.value,
            let activeTripList = activeTripListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        return .success(
            Destination(
                balance: balance,
                activeTripList: activeTripList
            )
        )
    }

    func transform(destination value: Destination) -> TransformerResult<Source> {
        let balanceResult = balanceTransformer.transform(destination: value.balance)
        let activeTripListResult = activeTripListTransformer.transform(destination: value.activeTripList)

        var errors: [(String, TransformerError)] = []
        balanceResult.error.map { errors.append((balanceName, $0)) }
        activeTripListResult.error.map { errors.append((activeTripListName, $0)) }

        guard
            let balance = balanceResult.value,
            let activeTripList = activeTripListResult.value,
            errors.isEmpty
        else {
            return .failure(.multiple(errors))
        }

        var dictionary: [String: Any] = [:]
        dictionary[balanceName] = balance
        dictionary[activeTripListName] = activeTripList
        return .success(dictionary)
    }
}
