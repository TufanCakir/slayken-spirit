import Foundation

extension Bundle {
    public func decode<T: Decodable>(
        _ file: String,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy =
            .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle \(self).")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) from bundle \(self).")
        }
        return decode(
            T.self,
            from: data,
            dateDecodingStrategy: dateDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy
        )
    }

    public func decode<T: Decodable>(
        _ type: T.Type,
        from data: Data,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy =
            .deferredToDate,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys
    ) -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Failed to decode \(T.self) from data: \(error)")
        }
    }
}
