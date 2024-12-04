//
//  SaveRealmView.swift
//  De3ign
//
//  Created by Lemocuber on 2024/11/29.
//

import SwiftUI

struct SaveRealmView: View {
    
    @Environment(AppModel.self) var appModel
    @Environment(\.dismiss) var dismiss
    @State var enteredName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Enter a name")
                .font(.headline)
            
            HStack(spacing: 20) {
                TextField("Name", text: $enteredName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .frame(width: 500)
                
                Button {
                    if enteredName != "" {
                        saveRealm(appModel.editorEntities, name: enteredName, appModel: appModel)
                        dismiss()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
    }
}
