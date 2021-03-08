//
//  ContentView.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 15.02.2021.
//

import SwiftUI
import Combine

struct ContentView: View {
    
    init() {
        //        UITabBar.appearance().barTintColor = UIColor(named: "mainGray")
        
        UITabBar.appearance().barTintColor = UIColor(named: "mainBlue")
        UINavigationBar.appearance().barTintColor = UIColor(named: "mainBlue")
    }
    
    @State private var selection = 0
    var body: some View {
        
        TabView(selection: $selection) {
            
            FirstTab()
                .tabItem {
                    Image(systemName: selection == 0 ? "person.fill": "person").renderingMode(.template)
                    Text("Personal")
                }
                .tag(0)
            
            SecondTab()
                .tabItem {
                    Image(systemName: selection == 1 ? "person.3.fill": "person.3")
                    Text("Family")
                    
                }
                .tag(1)
        }
        .accentColor(Color("mainDarkBlue"))
        
    }
    
}

struct FirstTab: View {
    @State private var showingAlert = false
    @ObservedObject var transactionData = TransactionList.shared
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        
        TransactionList.shared.list.remove(atOffsets: offsets)
        TransactionList.shared.updateJsonAfterTransactionDeleted()
        
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                LinearGradient(gradient: Gradient(colors: [Color("mainPink"), Color("mainGray")]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                Form{
                    
                    Section(header: Text("Today")
                                .foregroundColor(Color("mainBlack"))
                                .font(.custom("Helvetica Neue", size: 20))
                                .fontWeight(.light)
                    ) {
                        List{
                            ForEach(TransactionList.shared.list, id: \.self){ transaction in
                                NavigationLink(destination: EditTransactionView(id: transaction.id)) {
                                    TransactionCell(transaction: transaction)
                                }
                            }
                            .onDelete(perform: deleteTransaction)
                        }
                        .padding(.leading, -10)
                        .listRowBackground(Color.clear)
                    }
                    
                }
            }
            
            .navigationBarTitle(Text("Personal transactions"))
            
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: EditTransactionView(),
                        label: {
                            Text("Add new")
                        })
                }
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Filters") {
                        print("Filters tapped!")
                        showingAlert.toggle()
                        
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Important message"), message: Text("Under development!"), dismissButton: .default(Text("Got it!")))
            }
        }
    }
}

struct SecondTab: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color("mainPink"), Color("mainGray")]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            
            VStack {
                Text("Under development")
                    .foregroundColor(Color("mainBlack"))
            }
        }
    }
}

struct EditTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var details: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var value: String = ""
    var id: UUID?
    
    func cleanCurrency(_ value: String?) -> String {
        guard value != nil else { return "0.00" }
        let doubleValue = Double(value!) ?? 0.0
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.minimumFractionDigits = (value!.contains(".")) ? 0 : 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: doubleValue)) ?? "\(doubleValue)"
    }
    
    var body: some View {
        NavigationView{
            ZStack (alignment: .top) {
                LinearGradient(gradient: Gradient(colors: [Color("mainPink"), Color("mainGray")]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack {
                    TextField("Enter amount", text: $value)
                        .onReceive(Just(value)) { newValue in
                            
                            let filtered = newValue.filter {$0.isNumber || ".".contains($0)}
                            if filtered != newValue {
                                
                                self.value = filtered
                            }
                        }
                        .keyboardType(.numbersAndPunctuation)
                        .padding(.all, 25)
                    TextField("Enter description", text: $details)
                        .padding(.all, 25)
                    
                    TextField("Enter category", text: $category)
                        .padding(.all, 25)
                    
                    DatePicker(selection: $date, label: { Text("Select Date") })
                        .padding(.all, 25)
                    
                    Button("Done"){
                        
                        let transaction = Transaction(id: (id != nil) ? id! : UUID(), details: details, category: category, date: date, amount: Int(Float(value)!*100))
                        
                        if (id != nil){
                            TransactionList.shared.editTransaction(withNewTransactionData: transaction, UUID: id!)
                            
                        } else {
                            
                            TransactionList.shared.addTransaction(newTransaction: transaction)
                        }
                        self.presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(self.details.isEmpty)
                    .disabled(self.category.isEmpty)
                    .disabled(self.value.isEmpty)
                    .padding(.bottom, 70)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitle(Text((id != nil) ? "Edit Transaction" : "New Transaction"))
        .onAppear {
            if let transaction = TransactionList.shared.list.first(where: {$0.id == self.id}){
                
                details = transaction.details
                category = transaction.category
                date = transaction.date
                value = String("\(Float(transaction.amount)/100)")
                
            }
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TransactionList.shared)
        
        
    }
}


struct TransactionCell: View {
    let transaction: Transaction
    
    
    func getDateString(date:Date) -> String{
        let formatter = DateFormatter()
        
        formatter.dateStyle = .medium
        
        let dateString = formatter.string(from: date)
        
        return dateString
    }
    var body: some View {
        
        HStack (alignment: .top){
            VStack(alignment: .leading) {
                Text(transaction.details)
                    .foregroundColor(Color("mainBlack"))
                    .padding(.leading, 10)
                    .font(.headline)
                Text(transaction.category)
                    .foregroundColor(Color("mainBlack"))
                    .padding(.leading, 15)
                    .font(.footnote)
            }
            
            Spacer()
            VStack(alignment: .trailing) {
                Text (String (format: "%.2f UAH",  Double(transaction.amount)/100))
                    .fontWeight(.heavy)
                    .foregroundColor(Color("mainBlack"))
                    .multilineTextAlignment(.trailing)
                    .padding(.trailing, 10)
                    .font(.body)
                Text (getDateString(date: transaction.date))
                    .foregroundColor(Color("mainBlack"))
                    .multilineTextAlignment(.trailing)
                    .padding(.trailing, 10)
                    .font(.subheadline)
                
            }
        }
    }
}
