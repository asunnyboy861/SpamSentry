import Contacts
import Foundation

actor ContactProtectionService {
    func fetchContactNumbers() -> Set<Int64> {
        let store = CNContactStore()
        var contactNumbers = Set<Int64>()

        let keys = [CNContactPhoneNumbersKey as CNKeyDescriptor]
        let request = CNContactFetchRequest(keysToFetch: keys)

        do {
            try store.enumerateContacts(with: request) { contact, _ in
                for phone in contact.phoneNumbers {
                    let digits = phone.value.stringValue
                        .components(separatedBy: CharacterSet.decimalDigits.inverted)
                        .joined()
                    if let number = Int64(digits) {
                        contactNumbers.insert(number)
                    }
                }
            }
        } catch {
            NSLog("SpamSentry: Failed to fetch contacts - \(error.localizedDescription)")
        }

        return contactNumbers
    }

    func removeContactNumbersFromBlocklist() {
        let contactNumbers = fetchContactNumbers()
        let db = BlocklistDatabase.shared

        for number in contactNumbers {
            db.removeBlockedNumber(number)
        }
    }
}
