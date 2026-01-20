//
//  MovementStore.swift
//  FinanzasApp
//

import Foundation

protocol MovementStoreProtocol {
    func load() throws -> [Movement]
    func save(_ movements: [Movement]) throws
}

final class MovementStore: MovementStoreProtocol {
    private let defaults: UserDefaults
    private let key: String

    init(defaults: UserDefaults = .standard, key: String = "finanzasapp.movements.v1") {
        self.defaults = defaults
        self.key = key
    }

    func load() throws -> [Movement] {
        guard let data = defaults.data(forKey: key) else { return [] }
        return try JSONDecoder().decode([Movement].self, from: data)
    }

    func save(_ movements: [Movement]) throws {
        let data = try JSONEncoder().encode(movements)
        defaults.set(data, forKey: key)
    }
}


