import Foundation

enum APIServiceError: Error, LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case backendError(String)
    case unexpectedStatusCode(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network request failed: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode server response: \(error.localizedDescription)"
        case .backendError(let message):
            return "Server error: \(message)"
        case .unexpectedStatusCode(let code):
            return "Received unexpected status code: \(code)"
        case .unknown:
            return "An unknown API error occurred."
        }
    }
}

class SubscriptionAPIService {

    // REMOVE: Hardcoded base URL string
    // private let baseAPIURLString = "https://apple-pay-in-app-demo-backend.vercel.app"

    // CHANGE: Use AppConfig for URLs
    private var plansURL: URL { AppConfig.baseAPIURL.appendingPathComponent("/api/plans") }
    private var subscriptionURL: URL { AppConfig.baseAPIURL.appendingPathComponent("/api/subscription") }

    func fetchPlans() async throws -> [SubscriptionPlan] {
        do {
            let (data, response) = try await URLSession.shared.data(from: plansURL)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIServiceError.unknown
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    throw APIServiceError.backendError(errorMessage)
                } else {
                    throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
            }

            let fetchedPlans = try JSONDecoder().decode([SubscriptionPlan].self, from: data)
            return fetchedPlans
        } catch let error as DecodingError {
            throw APIServiceError.decodingError(error)
        } catch let error as APIServiceError {
            throw error
        } catch {
            throw APIServiceError.networkError(error)
        }
    }

    func createSubscriptionIntent(priceId: String) async throws -> SubscriptionResponse {
        var request = URLRequest(url: subscriptionURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = SubscriptionRequest(priceId: priceId)

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIServiceError.unknown
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    throw APIServiceError.backendError(errorMessage)
                } else {
                    throw APIServiceError.unexpectedStatusCode(httpResponse.statusCode)
                }
            }

            let subscriptionResponse = try JSONDecoder().decode(SubscriptionResponse.self, from: data)
            print("APIService: Received clientSecret: \(subscriptionResponse.clientSecret), subscriptionId: \(subscriptionResponse.subscriptionId)")
            return subscriptionResponse

        } catch let error as EncodingError {
            throw APIServiceError.networkError(error)
        } catch let error as DecodingError {
            throw APIServiceError.decodingError(error)
        } catch let error as APIServiceError {
            throw error
        } catch {
            throw APIServiceError.networkError(error)
        }
    }
}
