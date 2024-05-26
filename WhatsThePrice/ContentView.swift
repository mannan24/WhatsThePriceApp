//
//  ContentView.swift
//  WhatsThePrice
//
//  Created by Jannat Bedi on 24/5/24.
//
//let apiKey = "8b424e0fa7186ba1919610f6"

// File: ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ForexViewModel()
    @State private var priceInSGD: String = ""
    @State private var priceInDestination: String = ""
    @State private var destinationCurrency: String = "MYR" // Default to MYR

    var body: some View {
        VStack(spacing: 30) {
            Text("Price Comparator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 60)

            Spacer()

            VStack(spacing: 20) {
                HStack(spacing: 10) {
                    TextField("SGD Price", text: $priceInSGD)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)

                    Picker("Currency", selection: $destinationCurrency) {
                        ForEach(viewModel.currencies, id: \.self) { currency in
                            Text(currency)
                                .foregroundColor(.black)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)

                    TextField("Destination Price", text: $priceInDestination)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)
            }

            Button(action: {
                guard let sgdPrice = Double(priceInSGD), let destinationPrice = Double(priceInDestination) else {
                    print("Invalid input.")
                    return
                }
                viewModel.convertAndCompare(priceInSGD: sgdPrice, priceInDestination: destinationPrice, destinationCurrency: destinationCurrency)
            }) {
                Text("Compare Prices")
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
            }
            .padding(.horizontal)

            VStack(spacing: 20) {
                HStack {
                    Text("Converted Price:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Text(viewModel.convertedPrice)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
                .padding()

                HStack {
                    Text("Comparison Result:")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    Spacer()
                    Text(viewModel.comparisonResult)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(viewModel.comparisonResult.contains("▲") ? .red : .green)
                }
                .padding()
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.black]), startPoint: .top, endPoint: .bottom))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            // Fetch initial exchange rates and currencies
            viewModel.fetchExchangeRates {
                // Initial fetch completion handler
                // Do nothing here
            }
        }
    }
}
