//
//  ViewController.swift
//  Notes
//
//  Created by Me on 26.03.2022.
//

import UIKit

class NotesListViewController: UITableViewController {
    
    //MARK: - private properties
    private let cellID = "cell"
    private var notes: [Note] = []
    private var dataManager: DataStoreManagerProtocol!
    
    //MARK: - init
    init(dataManager: DataStoreManagerProtocol) {
        self.dataManager = dataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - override metods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        tableView.tableFooterView = UIView()
        setupNavigationBar()
        createInitialNote()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    //MARK: - Setup of navigation bar
    private func setupNavigationBar() {
        title = "Notes"
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearance.backgroundColor = UIColor(
            red: 20/255,
            green: 100/255,
            blue: 100/255,
            alpha: 200/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action:  #selector(addNewNote)
        )
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationController?.navigationBar.tintColor = .white
    }
    //MARK: - Objc metods
    @objc private func addNewNote() {
        let noteViewController = NoteViewController(dataStoreManager: dataManager)
        noteViewController.delegate = self
        noteViewController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(noteViewController, animated: true)

    }
    //MARK: -  Work with data
    private func fetchData() {
        notes =  dataManager.fetchData(notes: notes)
        tableView.reloadData()
            }
    private func createInitialNote() {
        if !UserDefaults.standard.bool(forKey: "isNotFirstTime") {
            dataManager.createInitialNote()
            UserDefaults.standard.set(true, forKey: "isNotFirstTime")
        }
        

    }

    
}
//MARK: - Extension table view metods
extension NotesListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let note = notes[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        if let noteTitle = note.title, !noteTitle.isEmpty {
            content.text = note.title
            content.secondaryText = note.text
        } else {
            content.text = note.text
        }
        
        
        cell.contentConfiguration = content
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newNoteViewController = NoteViewController(dataStoreManager: dataManager)
        newNoteViewController.modalPresentationStyle = .fullScreen
        newNoteViewController.editingNote = notes[indexPath.row]
        newNoteViewController.indexOfEditingNote = indexPath.row
        newNoteViewController.delegate = self
        navigationController?.pushViewController(newNoteViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let acionDelete = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _)  in
                let note = self.notes.remove(at: indexPath.row)
                self.dataManager.delete(note: note)
                tableView.reloadData()
            }
        let action = UISwipeActionsConfiguration(actions: [acionDelete])
        return action
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    

}

//MAKR: - Extension NoteViewControllerDelegate metods
extension NotesListViewController: NoteViewControllerDelegate {
    
    func addNoteInTable(note: Note) {
        notes.append(note)
        let cellIndex = IndexPath(row: notes.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
        
    }
    func updateNoteInTable(indexOfEditedRow: Int)  {
        let cellIndex = IndexPath(row: indexOfEditedRow, section: 0)
        tableView.reloadRows(at: [cellIndex], with: .automatic)
        
    }
}
    
    




