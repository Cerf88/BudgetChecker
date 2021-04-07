//
//  EditTransactionView.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 22.03.2021.
//

import SwiftUI
import Combine

struct EditTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var details: String = ""
    @State private var category: String = ""
    @State private var date: Date = Date()
    @State private var value: String = ""
    @State private var completedCategory: Bool = false
    var id: UUID?
    
    var body: some View {
        NavigationView{
            ZStack (alignment: .top) {
                LinearGradient(gradient: Gradient(colors: [Color("mainPink"), Color("mainGray")]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack {
                    TextField("Enter amount", text: $value)
                        
                        .onReceive(Just(value)) { newValue in
                            
                            var filtered = newValue.filter {$0.isNumber || (".,".contains($0))}
                            let filteredDot = (filtered.replacingOccurrences(of: ",", with: "."))
                            if Float(filteredDot) != nil{
                                filtered = "\(filteredDot)"
                            } else {
                                filtered = String(filtered.dropLast())
                            }
                            if filtered != newValue {
                                    self.value = "\(filtered)"
                            }
                        }
                        .keyboardType(.decimalPad)
                        .padding(.all, 25)
                    
                    TextField("Enter description", text: $details)
                        .padding(.all, 25)
                    
                    TextField("Enter category", text: $category, onEditingChanged: { (isBegin) in
                        if isBegin {
                            self.completedCategory = true
                        } else {
                            self.completedCategory = false
                        }
                    },
                    onCommit: {
                        self.completedCategory = false
                    })
                        .padding(.all, 25)
                    
                    if completedCategory {
                        ScrollView([.horizontal], showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(TransactionList.shared.categories.filter{$0.hasPrefix(category)}, id: \.self) {filteredCategory in
                                    Text("\(filteredCategory)")
                                        .onTapGesture{
                                            self.category = filteredCategory
                                            self.completedCategory = false
                                            hideKeyboard()
                                        }
                                }
                            .listRowBackground(Color.clear)
                            }
                            .padding(.leading, 15)
                        }
                    }
                    
                    
                    
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
        .navigationBarTitle(Text((id != nil) ? "Edit Transaction" : "New Transaction"), displayMode: .inline)
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

//struct EditTransactionView_Previews: PreviewProvider {
//    static var previews: some View {
//        Group {
//            EditTransactionView()
//              .environment(\.colorScheme, .light)
//
//            EditTransactionView()
//              .environment(\.colorScheme, .dark)
//        }
//    }
//}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
