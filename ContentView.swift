//
//  ContentView.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 15.02.2021.
//

import SwiftUI

struct ContentView: View {
    
    init() {
        UITabBar.appearance().barTintColor = UIColor(named: "mainBlue")
        UINavigationBar.appearance().barTintColor = UIColor(named: "mainBlue")
    }
    
    @State private var selection = 0
    var body: some View {
        
        TabView(selection: $selection) {
            
            PersonalTransactionsView()
                .tabItem {
                    Image(systemName: selection == 0 ? "person.fill": "person").renderingMode(.template)
                    Text("Personal")
                }
                .tag(0)
            
            FamilyTransactionsView()
                .tabItem {
                    Image(systemName: selection == 1 ? "person.3.fill": "person.3")
                    Text("Family")
                    
                }
                .tag(1)
        }
        .accentColor(Color("mainDarkBlue"))
        
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
