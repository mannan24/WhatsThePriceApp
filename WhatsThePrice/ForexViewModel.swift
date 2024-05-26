//
//  ForexViewModel.swift
//  WhatsThePrice
//
//  Created by Jannat Bedi on 26/5/24.
//

import Foundation

class ForexViewModel: ObservableObject {
    @Published var convertedPrice: String = ""
    @Published var comparisonResult: String = ""
    @Published var currencies: [String] = []
    private var exchangeRates: [String: Double] = [:]

    private var lastUpdateDate: Date?

    init() {
        loadExchangeData()
    }

    private func loadExchangeData() {
        if let savedData = UserDefaults.standard.data(forKey: "exchangeData"),
           let savedExchangeData = try? JSONDecoder().decode(ExchangeData.self, from: savedData) {
            exchangeRates = savedExchangeData.exchangeRates
            currencies = savedExchangeData.currencies
            lastUpdateDate = savedExchangeData.lastUpdateDate
        }
    }

    private func saveExchangeData() {
        let exchangeData = ExchangeData(exchangeRates: exchangeRates, currencies: currencies, lastUpdateDate: Date())
        if let encoded = try? JSONEncoder().encode(exchangeData) {
            UserDefaults.standard.set(encoded, forKey: "exchangeData")
        }
    }

    func fetchExchangeRates(completion: @escaping () -> Void) {
        let urlString = "https://6b1a59fc-6181-4016-a4c6-01a30ea80762.mock.pstmn.io/latest/SGD"

        guard let url = URL(string: urlString) else {
            print("Invalid URL.")
            completion()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching exchange rates: \(error.localizedDescription)")
                completion()
                return
            }

            guard let data = data else {
                print("No data received.")
                completion()
                return
            }

            do {
                let response = try JSONDecoder().decode(ForexResponse.self, from: data)
                DispatchQueue.main.async {
                    self.exchangeRates = response.conversion_rates
                    self.currencies = Array(response.conversion_rates.keys).sorted()
                    self.saveExchangeData()
                    completion()
                }
            } catch {
                print("Error decoding response: \(error.localizedDescription)")
                completion()
            }
        }.resume()
    }

    func convertAndCompare(priceInSGD: Double, priceInDestination: Double, destinationCurrency: String) {
        guard let exchangeRate = exchangeRates[destinationCurrency] else {
            print("Exchange rate not available for the selected currency.")
            convertedPrice = "N/A"
            comparisonResult = "N/A"
            return
        }

        print("Using exchange rate for \(destinationCurrency): \(exchangeRate)")

        let convertedValue = priceInSGD * exchangeRate
        convertedPrice = String(format: "%.2f \(destinationCurrency)", convertedValue)

        let difference = priceInDestination - convertedValue
        let percentageDifference = (difference / convertedValue) * 100
        if percentageDifference >= 0 {
            comparisonResult = String(format: "%.2f%% ▲", abs(percentageDifference))
        } else {
            comparisonResult = String(format: "%.2f%% ▼", abs(percentageDifference))
        }
    }
}

struct ExchangeData: Codable {
    let exchangeRates: [String: Double]
    let currencies: [String]
    let lastUpdateDate: Date
}
