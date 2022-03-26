//
//  NoteViewController.swift
//  Notes
//
//  Created by Me on 26.03.2022.
//

import UIKit

//MARK: - NoteViewControllerDelegate Protocol
protocol NoteViewControllerDelegate: AnyObject {
    func addNoteInTable(note: Note)
    func updateNoteInTable(indexOfEditedRow: Int)
}

class NoteViewController: UIViewController {
    //MARK: - Setup views
    private lazy var noteTitleField: UITextField = {
       let textField = UITextField()
        if let editingNoteTitle = editingNote?.title {
            textField.text = editingNoteTitle
        } else {
            textField.placeholder = "Title"
        }
        textField.layer.cornerRadius = 10
        textField.returnKeyType = UIReturnKeyType.done
        textField.font = .systemFont(ofSize: 30)
        textField.backgroundColor = UIColor(red: 10/255, green: 20/255, blue: 100/255, alpha: 20/255)
        return textField
    }()
    private lazy var noteTextView: UITextView = {
        let textView = UITextView()
        if let editingNoteText = editingNote?.text {
            textView.text = editingNoteText
        } else {
            textView.text = "Start typing"
            textView.textColor = UIColor.lightGray
        }
        textView.layer.cornerRadius = 10
        textView.font = .systemFont(ofSize: 16)
        textView.backgroundColor = UIColor(red: 10/255, green: 20/255, blue: 100/255, alpha: 20/255)
        return textView
    }()
    
    //MARK: - properties
    weak var delegate: NoteViewControllerDelegate?
    var editingNote: Note?
    var indexOfEditingNote: Int?
    
    //MARK: - lifecicle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubViews()
        setupConstraints()
        setupNavigationBar()
        noteTitleField.delegate = self
        noteTextView.delegate = self
        // Do any additional setup after loading the view.
    }

    
    //MARK: - private metods
    private func addSubViews() {
        view.addSubview(noteTitleField)
        view.addSubview(noteTextView)
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "save",
            style: .done,
            target: self,
            action: #selector(save))
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    private func setupConstraints() {
        noteTitleField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteTitleField.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            noteTitleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noteTitleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noteTextView.topAnchor.constraint(equalTo: noteTitleField.bottomAnchor, constant: 20),
            noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noteTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    
    private func addNewTask() {
        var text = noteTextView.text ?? ""
        if let title = noteTitleField.text, !title.isEmpty {
            if noteTextView.textColor == UIColor.lightGray {
                text = ""
            }
            guard let note = DataStoreManager.shared.addNew(titleValue: title, textValue: text) else {return}
            delegate?.addNoteInTable(note: note)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateTask(note: Note) {
        guard let index = indexOfEditingNote else { return }
        note.title = noteTitleField.text ?? ""
        note.text = noteTextView.text ?? ""
        DataStoreManager.shared.update()
        delegate?.updateNoteInTable(indexOfEditedRow: index)
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Objc metods
    @objc private func save () {
        if let note = editingNote {
           updateTask(note: note)
        } else {
            addNewTask()
        }
    }
}

//MARK: - Extension UITextFieldDelegate
extension NoteViewController: UITextFieldDelegate {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
    }
}

//MARK: - Extension UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Placeholder"
            textView.textColor = UIColor.lightGray
        }
    }
}


