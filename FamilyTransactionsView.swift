//
//  FamilyTransactionsView.swift
//  BudgetChecker
//
//  Created by Anna Bunchuzhna on 22.03.2021.
//

import SwiftUI


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
