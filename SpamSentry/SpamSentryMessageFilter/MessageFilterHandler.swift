import IdentityLookup
import Foundation

final class MessageFilterHandler: ILMessageFilterExtension, ILMessageFilterQueryHandling {
    func handle(_ queryRequest: ILMessageFilterQueryRequest, context: ILMessageFilterExtensionContext, completion: @escaping (ILMessageFilterQueryResponse) -> Void) {
        let response = ILMessageFilterQueryResponse()
        response.action = .none

        guard let sender = queryRequest.sender else {
            completion(response)
            return
        }

        let db = BlocklistDatabase.shared
        let blockedNumbers = db.fetchAllBlockedNumbers()

        let senderDigits = sender.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let senderNumber = Int64(senderDigits),
           blockedNumbers.contains(senderNumber) {
            response.action = .junk
        }

        completion(response)
    }
}
