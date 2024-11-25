//
//  SearchResult.swift
//  alfred-qsirch-workflow
//
//  Created by Hanley Lee on 2024/11/23.
//
import AlfredWorkflowScriptFilter

public struct SearchResult: Codable, @unchecked Sendable {
    struct Item: Codable {
        struct Preview: Codable {
            struct Info: Codable {

                let key: String
                let display: String
                let value: CustomCodableAny
            }

            let container_type: CustomCodableAny?
            let info: [Info]
        }
        struct Actions: Codable {
            let download: String
            let open: String
            let share: String
            let icon: String
        }

        let owner: String
        /// without extension
        let name: String
        let id: String
        let title: String
        let preview: Preview?
        let hidden: Bool
        let type: String
        let size: Int
        let actions: Actions
        /// dir path of file
        let path: String
        var `extension`: String?
    }

    let total: Int
    let items: [Item]
}

extension SearchResult {

    public func convertToAlfredFileList(domain: String) -> String {
        if items.isEmpty {
            ScriptFilter.item(
                AlfredWorkflowScriptFilter.Item(title: "No matched")
                    .subtitle("There is no matched file in your QNAP: \(domain)")
            )
        } else {
            for item in items {
                let title = item.title
                let dirPath = item.path
                let fileName = item.name
                let fileExtension = item.extension ?? ""
                guard let filePath = item.preview?.info.first(where: { $0.key == "path" })?.value.value as? String else { continue }
                let pathInMac = "/Volumes/\(filePath)"
                let iconUrl = domain + item.actions.icon

                let fileStationUrl = CommonTools.assembleURL(
                    "/filestation/",
                    domain: domain,
                    params: ["path": dirPath, "file": fileExtension.isEmpty ? fileName : "\(fileName).\(fileExtension)"]
                )
                let downloadUrl = CommonTools.assembleURL(item.actions.download, domain: domain)

                ScriptFilter.add(
                    AlfredWorkflowScriptFilter.Item(title: title)
                        .subtitle(pathInMac)
                        .arg(pathInMac)
                        .icon(.init(path: pathInMac, type: .fileicon))
                        .quicklookurl(pathInMac)
                        .mods(
                            Cmd().subtitle("Reveal file in Finder").arg(pathInMac),
                            Alt().subtitle("Download file").arg(downloadUrl ?? ""),
                            Ctrl().subtitle("Open file in FileStation").arg(fileStationUrl ?? "")
                        )
                )
            }
        }
        return ScriptFilter.output()
    }
}
