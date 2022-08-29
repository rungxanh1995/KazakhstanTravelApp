//
//  CurrencyViewModel.swift
//  Travel KZH
//
//  Created by Joe Pham on 2022-08-29.
//

import Foundation
import MastercardOAuth1Signer

extension CurrencyView {
	
	final class ViewModel: ObservableObject {
		@Published
		var rateInfo: CustomMastercardProperties?
		var rate = UserDefaults().getRate() ?? 0.0
		var rateDate = UserDefaults().getRateDate()
		
		@Published
		var customKZTAmount: Double?
		var convertedCHFAmount: Double { (customKZTAmount ?? 0) * rate }
		@Published
		var errorMessage: String?
		
		@Published
		var displayAlert = false

		
		// MARK - Update rate provided by Mastercard API
		func getCurrentRate() {
			// TODO: - Import your certificate in this Xcode project
			// TODO: - Change the name with the one from your certificate
			let certificateName = "YOUR_CERTIFICATE_NAME_HERE"
			let certificateExtension = "p12"
			
			if let certificatePath = Bundle.main.path(forResource: certificateName, ofType: certificateExtension) {
				// Certificate path retrieved ✅
				// TODO: - Change the password with the one from your certificate readme.txt
				let keystorePassword = "YOUR_KEYSTORE_PASSWORD" // from certificate readme.txt
				
				if let signingKey = KeyProvider.loadPrivateKey(fromPath: certificatePath, keyPassword: keystorePassword) {
					// Private Key loaded ✅
					// TODO: - Edit the Consumer Key with the one from the Mastercard Developer Portal
					let consumerKey = "YOUR_CONSUMER_KEY_HERE" // from developer portal
					let url = getURL()
					
					do {
						let header = try OAuth.authorizationHeader(
							forUri: url,
							method: "GET",
							payload: nil,
							consumerKey: consumerKey,
							signingPrivateKey: signingKey
						)
						
						// OAuth Authorization Header created ✅
						var urlRequest = URLRequest(url: url)
						urlRequest.httpMethod = "GET"
						urlRequest.allHTTPHeaderFields = [
							"Authorization": header, // Add token in request header
							"Accept": "application/json",
							"Referer": "api.mastercard.com"
						]
						
						let task = URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
							if let data = data {
								if let response = try? JSONDecoder().decode(CustomMastercardProperties.self, from: data) {
									DispatchQueue.main.async { [weak self] in
										// Save locally/Update local rate
										self?.updateLocalData(
											rate: response.data.effectiveConversionRate,
											rateDate: response.requestDate
										)
									}
									return
								} else {
									self?.errorMessage = "Failed to decode JSON object."
									self?.displayAlert.toggle()
								}
							} else if let error = error {
								self?.errorMessage = "HTTP request failed: \(error)."
								self?.displayAlert.toggle()
							}
						}
						
						task.resume()
					} catch {
						errorMessage = "Failed to create the OAuth Authorization Header."
						displayAlert.toggle()
					}
				} else {
					errorMessage = "Failed to load the Private Key."
					displayAlert.toggle()
				}
			} else {
				errorMessage = "Failed to locate the project's certificate."
				displayAlert.toggle()
			}
		}
		
		// MARK - Get and create Mastercard API URL
		func getURL() -> URL {
			let cardCurrency = "CHF"
			let transactionCurrency = "KZT"
			let date = Date.now.getFormattedDate()
			
			var urlString = "https://sandbox.api.mastercard.com/enhanced/settlement/currencyrate/subscribed/summary-rates"
			urlString += "?rate_date=\(date)"
			urlString += "&trans_curr=\(transactionCurrency)"
			urlString += "&trans_amt=1"
			urlString += "&crdhld_bill_curr=\(cardCurrency)"
			
			return URL(string: urlString)!
		}
		
		// MARK - Get Footer Date
		func getFooterString() -> String {
			if let date = UserDefaults().getRateDate()?.toDate() {//rateDate?.toDate() {
				let formattedDate = date.getReadableDate()
				return "Last updated: \(formattedDate)"
			}
			
			return "Pull to refresh the exchange rate."
		}
		
		// MARK - Get Header Date
		func getHeaderString() -> String? {
			return rate != 0 ? "Exchange rate \(rate)" : nil
		}
		
		func updateLocalData(rate: Double, rateDate: String) {
			UserDefaults().saveRate(rate)
			UserDefaults().saveRateDate(rateDate)
			self.rate = rate
			self.rateDate = rateDate
		}
	}
}
