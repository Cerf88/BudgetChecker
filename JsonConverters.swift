//
//  JsonConverters.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 04.03.2021.
//

import Foundation

struct Transaction: Identifiable, Codable, Hashable {
    var id = UUID()
    var details: String
    var category: String
    var date: Date
    var amount: Int
    
}

class TransactionList: NSObject, ObservableObject {

    @Published var list: [Transaction] = []
    var categories: [String] = []
    var sections: [Day] = []
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
    
    func load<T: Decodable>(_ data: Data) -> T {

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse as \(T.self):\n\(error)")
        }
    }
    
    struct Day: Identifiable {
        let id = UUID()
        let title: String
        let transactions: [Transaction]
        let date: Date
    }
    func completeDictionareAfterAnyUpdate() {
        
        for item in list {
            if !categories.contains(item.category){
                categories.append(item.category)
            }
        }
        
        let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
        
        let grouped = Dictionary(grouping: self.list) { (transaction: Transaction) -> String in
                    dateFormatter.string(from: transaction.date)
                }
        
        self.sections = grouped.map { day -> Day in
            Day(title: day.key, transactions: day.value, date: day.value[0].date)
               }.sorted { $0.date > $1.date }
        
    }
    
    func addTransaction(newTransaction: Transaction){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        list.append(newTransaction)
        list.sort {
            
            (($0).date.compare($1.date)) == .orderedDescending
        }
        completeDictionareAfterAnyUpdate()
        var jsonArr: [Transaction] = []
        for item in list {
            jsonArr.append(item)
            if !categories.contains(item.category){
                categories.append(item.category)
            }
        }
        let data = try! encoder.encode(newTransaction)
        print(String(data: data, encoding: .utf8)!)
        
        self.writeJson(filename: "transaction_list", allSiteKeys: list)
    }
    
    func updateJsonAfterTransactionDeleted(){
        self.writeJson(filename: "transaction_list", allSiteKeys: list)
    }
    
    func editTransaction(withNewTransactionData newTransaction: Transaction, UUID: UUID){
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        
        if let transactionOffset = TransactionList.shared.list.firstIndex(where: {$0.id == UUID}) {
            TransactionList.shared.list[transactionOffset] = newTransaction
        }
        
        list.sort {
            
            (($0).date.compare($1.date)) == .orderedDescending
        }
        completeDictionareAfterAnyUpdate()
        let data = try! encoder.encode(newTransaction)
        print(String(data: data, encoding: .utf8)!)
        
        self.writeJson(filename: "transaction_list", allSiteKeys: list)
    }
    
    private func updateListforTransactions(withJSONData data: Data){

        list = load(data)
        
        list.sort {

            (($0).date.compare($1.date)) == .orderedDescending
        }

        completeDictionareAfterAnyUpdate()

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
