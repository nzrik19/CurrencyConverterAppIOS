//
//  APICodesResponce.swift
//  CurrencyConverterApp
//
//  Created by ІПЗС-21 on 14.11.2025.
//
import Foundation

// Модель для /v6/YOUR-KEY/codes
struct APICodesResponse: Codable {
let result: String
// "supported_codes" - це масив масивів: [ ["AED", "UAE Dirham"], ... ]
let supportedCodes: [[String]]

// Кастомні ключі для декодування
enum CodingKeys: String, CodingKey {
    case result
    case supportedCodes = "supported_codes"
}


}
