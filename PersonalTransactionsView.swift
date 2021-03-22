//
//  PersonalTransactionsView.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 22.03.2021.
//


import SwiftUI
import Combine

struct PersonalTransactionsView: View {
    @State private var showingAlert = false
    @State private var isShowingEditView = false
    @ObservedObject var transactionData = TransactionList.shared
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().separatorStyle = .none
        UITableView.appearance().separatorColor = .clear
    }
    
    func deleteTransaction(at offsets: IndexSet) {
        
        TransactionList.shared.list.remove(atOffsets: offsets)
        TransactionList.shared.completeDictionareAfterAnyUpdate()
        TransactionList.shared.updateJsonAfterTransactionDeleted()
        
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                LinearGradient(gradient: Gradient(colors: [Color("mainPink"), Color("mainGray")]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                List{
                    ForEach(TransactionList.shared.sections) { section in
                        Section(header: Text(section.title)
                                    .foregroundColor(Color("mainBlack"))
                                    .font(.custom("Helvetica Neue", size: 20))
                                    .fontWeight(.light)
                        ) {
                            ForEach(section.transactions) { transaction in
                                NavigationLink(destination: EditTransactionView(id: transaction.id)) {
                                    TransactionCell(transaction: transaction)
                                }
                            }
                            .onDelete(perform: deleteTransaction)
                        }
                        
                    }
                    
                    .listRowBackground(Color.clear)
                }
            }
            
            .navigationBarTitle(Text("Personal transactions"), displayMode: .large)
            
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(
                        destination: EditTransactionView(),
                        isActive: $isShowingEditView,
                        label: {
                            Text("Add new")
                        })
                    
                        .onAppear {
                                        self.isShowingEditView = false
                                }
                    
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
