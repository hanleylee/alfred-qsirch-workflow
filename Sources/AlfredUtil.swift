//
//  AlfredUtil.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//

struct AlfredUtil {
    @MainActor static let shared: AlfredUtil = .init()
//    func mapToAlfred(results: [String: Any]) -> [[String: String]] {
//        guard let items = results["items"] as? [[String: Any]] else {
//            return []
//        }
//        return items.compactMap { self.itemToAlfred(item: $0) }
//    }

    private func metadataToDictionary(item: [String: Any]) -> [String: String] {
        var metadata: [String: String] = [:]
        guard let preview = item["preview"] as? [String: Any],
              let info = preview["info"] as? [[String: Any]]
        else {
            return metadata
        }
        for meta in info {
            if let key = meta["key"] as? String, let value = meta["value"] as? String {
                metadata[key] = value
            }
        }
        return metadata
    }

    func searchResultToAlfredFileList(result: SearchResult, domain: String) -> AlfredModel? {
//        guard let path = item["path"] as? String,
//              let name = item["name"] as? String,
//              let ext = item["extension"] as? String
//        else {
//            return nil
//        }
//
//
        var alfredItems: [AlfredItem] = []

        for item in result.items {
            //            let title = item.title
            let title = item.title
            guard let path = item.preview?.info.first(where: { $0.key == "path" })?.value.value as? String else { continue }
            let pathInMac = "/Volumes/\(path)"
            let iconUrl = domain + item.actions.icon
            alfredItems.append(AlfredItem(title: title, subtitle: pathInMac, arg: pathInMac, icon: .init(path: iconUrl)))
        }
//        if ext == "eml", let from = metadata["from"], let subject = metadata["subject"], let sentDate = metadata["sent_date"] {
//            title = "\(sentDate.split(separator: " ")[0]) \(subject): \(from)"
//        } else if let itemTitle = item["title"] as? String {
//            title = "\(itemTitle).\(ext)"
//        }

        return AlfredModel(items: alfredItems)
    }
}
