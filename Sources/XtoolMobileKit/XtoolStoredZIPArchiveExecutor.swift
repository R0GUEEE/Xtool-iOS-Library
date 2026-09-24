import Foundation

public struct XtoolStoredZIPArchiveExecutor: XtoolArchiveExecutor {
    public let identifier = "archive.swift.stored"

    public init() {}

    public func createZip(
        contentsOf directory: URL,
        outputURL: URL
    ) async throws {
        let fileManager = FileManager.default

        let files = try recursiveFiles(
            in: directory,
            fileManager: fileManager
        )

        var archive = Data()
        var centralDirectory = Data()

        for file in files {
            try Task.checkCancellation()

            let relativePath = String(
                file.path.dropFirst(directory.path.count)
            ).trimmingCharacters(
                in: CharacterSet(charactersIn: "/")
            )

            let nameData = Data(relativePath.utf8)
            let data = try Data(contentsOf: file)
            let crc = CRC32.checksum(data)
            let offset = UInt32(archive.count)

            let attributes = try fileManager.attributesOfItem(
                atPath: file.path
            )
            let permissions = (attributes[.posixPermissions] as? NSNumber)?
                .uint32Value ?? 0o644
            let unixMode = UInt32(0o100000) | permissions

            archive.appendUInt32LE(0x04034b50)
            archive.appendUInt16LE(20)
            archive.appendUInt16LE(0x0800)
            archive.appendUInt16LE(0)
            archive.appendUInt16LE(0)
            archive.appendUInt16LE(0)
            archive.appendUInt32LE(crc)
            archive.appendUInt32LE(UInt32(data.count))
            archive.appendUInt32LE(UInt32(data.count))
            archive.appendUInt16LE(UInt16(nameData.count))
            archive.appendUInt16LE(0)
            archive.append(nameData)
            archive.append(data)

            centralDirectory.appendUInt32LE(0x02014b50)
            centralDirectory.appendUInt16LE(0x0314)
            centralDirectory.appendUInt16LE(20)
            centralDirectory.appendUInt16LE(0x0800)
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt32LE(crc)
            centralDirectory.appendUInt32LE(UInt32(data.count))
            centralDirectory.appendUInt32LE(UInt32(data.count))
            centralDirectory.appendUInt16LE(UInt16(nameData.count))
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt16LE(0)
            centralDirectory.appendUInt32LE(unixMode << 16)
            centralDirectory.appendUInt32LE(offset)
            centralDirectory.append(nameData)
        }

        let centralOffset = UInt32(archive.count)
        archive.append(centralDirectory)

        archive.appendUInt32LE(0x06054b50)
        archive.appendUInt16LE(0)
        archive.appendUInt16LE(0)
        archive.appendUInt16LE(UInt16(files.count))
        archive.appendUInt16LE(UInt16(files.count))
        archive.appendUInt32LE(UInt32(centralDirectory.count))
        archive.appendUInt32LE(centralOffset)
        archive.appendUInt16LE(0)

        let parent = outputURL.deletingLastPathComponent()
        try fileManager.createDirectory(
            at: parent,
            withIntermediateDirectories: true
        )

        try archive.write(
            to: outputURL,
            options: .atomic
        )
    }

    private func recursiveFiles(
        in directory: URL,
        fileManager: FileManager
    ) throws -> [URL] {
        guard let enumerator = fileManager.enumerator(
            at: directory,
            includingPropertiesForKeys: [
                .isRegularFileKey
            ],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        var files: [URL] = []

        for case let url as URL in enumerator {
            let values = try url.resourceValues(
                forKeys: [.isRegularFileKey]
            )
            if values.isRegularFile == true {
                files.append(url)
            }
        }

        return files.sorted {
            $0.path < $1.path
        }
    }
}

private enum CRC32 {
    static let table: [UInt32] = (0..<256).map { index in
        var c = UInt32(index)
        for _ in 0..<8 {
            c = (c & 1) != 0
                ? 0xedb88320 ^ (c >> 1)
                : c >> 1
        }
        return c
    }

    static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff

        for byte in data {
            let index = Int((crc ^ UInt32(byte)) & 0xff)
            crc = table[index] ^ (crc >> 8)
        }

        return crc ^ 0xffffffff
    }
}

private extension Data {
    mutating func appendUInt16LE(_ value: UInt16) {
        var value = value.littleEndian
        Swift.withUnsafeBytes(of: &value) {
            append(contentsOf: $0)
        }
    }

    mutating func appendUInt32LE(_ value: UInt32) {
        var value = value.littleEndian
        Swift.withUnsafeBytes(of: &value) {
            append(contentsOf: $0)
        }
    }
}
