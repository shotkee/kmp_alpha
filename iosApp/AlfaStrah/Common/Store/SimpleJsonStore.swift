//
// SimpleJsonStore
// AlfaStrah
//
// Created by Eugene Egorov on 23 November 2018.
// Copyright (c) 2018 Redmadrobot. All rights reserved.
//

import Legacy

class SimpleJsonStore<EntityTransformer: Transformer> where EntityTransformer.Source == Any {
    typealias Entity = EntityTransformer.Destination

    private let directory: URL
    private let name: String
    private let url: URL
    private let transformer: EntityTransformer

    init(
        directory: URL = Storage.cachesDirectory.appendingPathComponent("Data", isDirectory: true),
        name: String = String(describing: Entity.self),
        transformer: EntityTransformer
    ) {
        self.directory = directory
        self.name = name
        url = directory.appendingPathComponent("\(name).json", isDirectory: false)
        self.transformer = transformer
    }

    func load() -> Entity? {
        guard
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
        else { return nil }

        return transformer.transform(source: json).value
    }

    func save(_ entity: Entity?) {
        try? FileManager.default.removeItem(at: url)

        guard
            let entity = entity,
            let json = transformer.transform(destination: entity).value,
            let data = try? JSONSerialization.data(withJSONObject: json, options: [])
        else { return }

        Storage.createDirectory(url: directory)
        try? data.write(to: url)
    }
}
