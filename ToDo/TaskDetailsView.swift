//
//  TaskDetailsView.swift
//  ToDo
//
//  Created by Marcelina Ziółkiewicz on 14/08/2025.
//

import SwiftUI

struct TaskDetailView: View {
    @Binding var task: Task
    var onSave: () -> Void

    var body: some View {
        Text("Szczegóły: ")
        Text(task.title)
            
    }
}
