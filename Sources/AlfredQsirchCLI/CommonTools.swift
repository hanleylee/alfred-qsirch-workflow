//
//  File.swift
//  
//
//  Created by Hanley Lee on 2024/11/26.
//

import Foundation

struct CommonTools {
    static let githubRepo = "hanleylee/alfred-qsirch-workflow"
    static let workflowAssetName = "Qsirch.alfredworkflow"
    
    /// 将字节大小格式化为易读的 KB, MB, GB, TB 格式
    /// - Parameters:
    ///   - bytes: 字节大小
    ///   - decimals: 保留的小数位数，默认为 2 位
    ///   - kilo: 进制, Apple 使用 1000 作为进制, linux 一般使用 1024 作为进制
    /// - Returns: 格式化的字符串（如 "10.24 MB", "50.5 KB"）
    static func formatBytes(_ bytes: Int, decimals: Int = 2, kilo: Double = 1000) -> String {
        // 如果字节为 0，直接返回
        guard bytes > 0 else { return "0 B" }
        
        // 单位列表（B, KB, MB, GB, TB, PB, EB, ZB, YB）
        let units = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        
        let bytesDouble = Double(bytes)
        
        // 计算需要的单位（以 1024 为单位每次除法）
        let unitIndex = Int(log(bytesDouble) / log(kilo))
        let formattedSize = bytesDouble / pow(kilo, Double(unitIndex))
        
        // 格式化为指定小数位的字符串
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        
        let formattedSizeString = formatter.string(from: NSNumber(value: formattedSize)) ?? "\(formattedSize)"
        let unit = units[unitIndex]
        
        return "\(formattedSizeString) \(unit)"
    }
}
