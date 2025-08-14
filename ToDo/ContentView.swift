//
//  ContentView.swift
//  ToDo
//
//  Created by Marcelina Ziółkiewicz on 14/08/2025.
//

import SwiftUI
import FirebaseFirestore

struct Task: Identifiable, Codable {
    let id: UUID
    var title: String
    var dateAdded: Date
    var description: String

    init(id: UUID = UUID(), title: String, dateAdded: Date = Date(), description: String = "") {
        self.id = id
        self.title = title
        self.dateAdded = dateAdded
        self.description = description
    }
}

struct ContentView: View {
    @State private var tasks: [Task] = []
    @State private var newTask: String = ""

    private let db = Firestore.firestore()

    private let tasksKey = "savedTasks"

    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Wpisz nowe zadanie", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button(action: addTask) {
                    Text("Dodaj zadanie")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                List {
                    ForEach(tasks) { task in
                        NavigationLink(
                            destination: TaskDetailView(task: binding(for: task), onSave: saveTasks)
                        ) {
                            Text(task.title)
                        }
                    }
                    .onDelete(perform: delete)
                }
            }
            .navigationTitle("Moje zadania")
            .toolbar{ EditButton() }
            .onAppear(perform: loadTasksFromFirestore)
            
        }
    }
    
    
    private func addTask() {
        let trimmed = newTask.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        tasks.append(Task(title: trimmed))
        newTask = ""
        saveTasksToFirestore()
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let task = tasks[index]
            deleteTaskFromFirestore(task)
        }
        tasks.remove(atOffsets: offsets)
    }

    private func deleteTaskFromFirestore(_ task: Task) {
        let docRef = db.collection("tasks").document(task.id.uuidString)
        docRef.delete { error in
            if let error = error {
                print("Błąd usuwania zadania z Firestore: \(error)")
            } else {
                print("Zadanie usunięte z Firestore")
            }
        }
    }

    private func saveTasksToFirestore() {
        for task in tasks {
            do {
                try db.collection("tasks").document(task.id.uuidString).setData(from: task)
            } catch {
                print("Błąd zapisu do Firestore: \(error)")
            }
        }
    }

    private func saveTasks() {
//        TODO - zapisywanie szczegółów i zmiana tytułu taska
        if let encoded = try? JSONEncoder().encode(tasks) {
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }

    private func loadTasksFromFirestore() {
        db.collection("tasks").getDocuments { snapshot, error in
            if let error = error {
                print("Błąd wczytywania: \(error)")
                return
            }
            if let documents = snapshot?.documents {
                self.tasks = documents.compactMap { doc -> Task? in
                    try? doc.data(as: Task.self)
                }
            }
        }
    }

    private func binding(for task: Task) -> Binding<Task> {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            fatalError("Nie znaleziono zadania")
        }
        return $tasks[index]
    }
}

#Preview {
    ContentView()
}
