//
//  OsagoProlongationFieldData
//  AlfaStrah
//
//  Created by Vasiliy Kotsiuba on 12.03.2021.
//  Copyright © 2021 Redmadrobot. All rights reserved.
//

import Legacy

enum OsagoProlongationFieldData: Equatable {
    case string(String)
    case date(Date)
    case geo(GeoPlace)
    case driverLicense(SeriesAndNumberDocument)

    static func == (lhs: OsagoProlongationFieldData, rhs: OsagoProlongationFieldData) -> Bool {
        switch (lhs, rhs) {
            case (.string(let lhs), .string(let rhs)):
                return lhs == rhs
            case (.date(let lhs), .date(let rhs)):
                return lhs == rhs
            case (.geo(let lhs), .geo(let rhs)):
                return lhs == rhs
            case (.driverLicense(let lhs), .driverLicense(let rhs)):
                return lhs == rhs
            default:
                return false
        }
    }
}

struct OsagoProlongationFieldDataTransformer: Transformer {
    public typealias Source = Any
    public typealias Destination = OsagoProlongationFieldData

    let dataName = "data"

    let dataStringTransformer = CastTransformer<Any, String>()
    let dataDateTransformer = DateTransformer<Any>(format: "yyyy-MM-dd", locale: AppLocale.currentLocale)
    let dataGeoTransformer = GeoPlaceTransformer()
    let dataDriverLicenseTransformer = SeriesAndNumberDocumentTransformer()

    public func transform(source value: Source) -> TransformerResult<Destination> {
        fatalError("Transform from source not implemented!")
    }

    public func transform(destination value: Destination) -> TransformerResult<Source> {
        let dataResult: TransformerResult<Any>
        switch value {
            case .string(let data):
                dataResult = dataStringTransformer.transform(destination: data)
            case .date(let date):
                dataResult = dataDateTransformer.transform(destination: date)
            case .geo(let geo):
                dataResult = dataGeoTransformer.transform(destination: geo)
            case .driverLicense(let driverLicense):
                dataResult = dataDriverLicenseTransformer.transform(destination: driverLicense)
        }

        var errors: [(String, TransformerError)] = []
        dataResult.error.map { errors.append((dataName, $0)) }

        guard let data = dataResult.value else { return .failure(.multiple(errors)) }

        return .success(data)
    }
}
