//
//  JsonConverters.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 04.03.2021.
//

import Foundation

struct Transaction: Identifiable, Encodable {
    var id = UUID()
    var details: String
    var category: String
    var date: Date
    var amount: Int
    
}

struct TransactionJSONData: Codable {
    let amount: Int
    let details, category: String
    let date: Date
    let id: UUID
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case amount = "amount"
        case details = "details"
        case category = "category"
        case date = "date"
        
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        amount = try container.decode(Int.self, forKey: .amount)
        details = try container.decode(String.self, forKey: .details)
        category = try container.decode(String.self, forKey: .category)
        date = try container.decode(Date.self, forKey: .date)
        id = try container.decode(UUID.self, forKey: .id)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(amount, forKey: .amount)
        try container.encode(details, forKey: .details)
        try container.encode(category, forKey: .category)
        try container.encode(date, forKey: .date)
        try container.encode(id, forKey: .id)
    }
}

class TransactionList: NSObject, ObservableObject {
    private var jSoLlist: Array<TransactionJSONData> = []
    @Published var list: Array<Transaction> = []
    private var destURL: URL!
    private var fileName: String = "transaction_list.json"
    static let shared = TransactionList()
    private override init() {
        super .init()
        
        
        self.destURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName)
        
        loadTransactions(FromFileNamed: fileName)
        
    }
    
    func loadTransactions(FromFileNamed fileName:String){
        if let jsonData = self.readLocalFile(forName: fileName){
            updateListforTransactions(withJSONData: jsonData)
        }
        else
        {
            copyFileFromBundleToDocumentsFolder(sourceFile: fileName)
            loadTransactions(FromFileNamed: fileName)
        }
    }
    
    func addTransaction(newTransaction: Transaction){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        list.append(newTransaction)
        list.sort {
            
            (($0).date.compare($1.date)) == .orderedDescending
        }
        var jsonArr: [Transaction] = []
        for item in list {
            jsonArr.append(item)
        }
        let data = try! encoder.encode(newTransaction)
        print(String(data: data, encoding: .utf8)!)
        
        self.writeJson(filename: "transaction_list", allSiteKeys: list)
    }
    
    private func updateListforTransactions(withJSONData data: Data){
        
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let transaction = try! decoder.decode([TransactionJSONData].self, from: data)
        jSoLlist = transaction
        
        
        for item in jSoLlist {
            
            let transactionItem = Transaction(id: item.id, details: item.details, category: item.category, date: item.date, amount: item.amount)
            
            list.append(transactionItem)
        }
        
        list.sort {
            
            (($0).date.compare($1.date)) == .orderedDescending
        }
        
    }
    
    private func copyFileFromBundleToDocumentsFolder(sourceFile: String, destinationFile: String = "") {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let documentsURL = documentsURL {
            let sourceURL = Bundle.main.bundleURL.appendingPathComponent(sourceFile)
            
            // Use the same filename if destination filename is not specified
            let destURL = documentsURL.appendingPathComponent(!destinationFile.isEmpty ? destinationFile : sourceFile)
            
            do {
                try FileManager.default.removeItem(at: destURL)
                print("Removed existing file at destination")
            } catch (let error) {
                print(error)
            }
            
            do {
                try FileManager.default.copyItem(at: sourceURL, to: destURL)
                self.destURL = destURL
                print("\(sourceFile) was copied successfully.")
            } catch (let error) {
                print(error)
            }
        }
    }
    private func readLocalFile(forName name: String) -> Data? {
        do {
            
            if destURL != nil{
                
                if let jsonData = try String(contentsOf: destURL).data(using: .utf8){
                    
                    return jsonData
                }
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    
    func writeJson(filename fileName: String, allSiteKeys : [Transaction]){
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        if self.destURL != nil {
            do {
                try encoder.encode(allSiteKeys).write(to: destURL)
                
            } catch {
                print(error)
            }
        }
    }
    
}
