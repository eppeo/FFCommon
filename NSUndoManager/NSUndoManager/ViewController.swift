//
//  ViewController.swift
//  NSUndoManager
//
//  Created by 武飞跃 on 2019/10/24.
//  Copyright © 2019 Chat. All rights reserved.
//

import UIKit

class Person: UIView {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    @objc
    func addFigure(figure: FigureView) {
        registerUndoAddFigure(figure: figure)
        addSubview(figure)
    }
    
    @objc
    func removeFigure(figure: FigureView) {
        registerUnoRemoveFigure(figure: figure)
        figure.removeFromSuperview()
    }
    
    @objc
    func moveFigure(figure: FigureView, center: CGPoint) {
        registerUnoMoveFigure(figure: figure)
        figure.center = center
    }
    
    private func registerUndoAddFigure(figure: FigureView) {
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.removeFigure(figure: figure)
        })
        undoManager?.setActionName("Add Figure")
    }
    
    private func registerUnoRemoveFigure(figure: FigureView) {
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.addFigure(figure: figure)
        })
        undoManager?.setActionName("Remove Figure")
    }
    
    private func registerUnoMoveFigure(figure: FigureView) {
        let center = figure.center
        undoManager?.registerUndo(withTarget: self, handler: { (target) in
            target.moveFigure(figure: figure, center: center)
        })
        undoManager?.setActionName("Move Figure")
    }
    
    override func didMoveToWindow() {
        becomeFirstResponder()
    }
}

class FigureView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
    }
    
    required init?(coder: NSCoder) {
        return nil
    }
}

class ViewController: UIViewController {

    var btn1 = UIButton()
    var btn2 = UIButton()
    var btn3 = UIButton()
    var btn4 = UIButton()
    
    var person: Person!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btn1.frame = CGRect(x: 10, y: 100, width: 100, height: 44)
        btn1.backgroundColor = .black
        btn1.setTitle("撤回", for: .normal)
        btn2.frame = CGRect(x: 120, y: 100, width: 100, height: 44)
        btn2.backgroundColor = .black
        btn2.setTitle("重做", for: .normal)
        
        btn3.frame = CGRect(x: 10, y: 150, width: 100, height: 44)
        btn3.backgroundColor = .black
        btn3.setTitle("添加", for: .normal)
        btn4.frame = CGRect(x: 120, y: 150, width: 100, height: 44)
        btn4.backgroundColor = .black
        btn4.setTitle("删除", for: .normal)
        
        [btn1, btn2, btn3, btn4].forEach{ view.addSubview($0) }
        
        btn1.addTarget(self, action: #selector(undoAction), for: .touchUpInside)
        btn2.addTarget(self, action: #selector(redoAction), for: .touchUpInside)
        btn3.addTarget(self, action: #selector(addAction), for: .touchUpInside)
        btn4.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        
        person = Person(frame: CGRect(x: 0, y: 220, width: 300, height: 300))
        person.backgroundColor = UIColor.lightGray
        view.addSubview(person)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(forName: .NSUndoManagerDidUndoChange, object: person.undoManager, queue: nil) { (notification) in
            print("didUndo: \(notification)")
        }
        
        NotificationCenter.default.addObserver(forName: .NSUndoManagerDidRedoChange, object: person.undoManager, queue: nil) { (notification) in
            print("didRedo: \(notification)")
        }
    }
    
    @objc
    private func undoAction() {
        print("canUndo: \(person.undoManager?.canUndo)")
        if person.undoManager?.canUndo == true {
            person.undoManager?.undo()
        }
    }
    
    @objc
    private func redoAction() {
        print("canRedo: \(person.undoManager?.canRedo)")
        if person.undoManager?.canRedo == true {
            person.undoManager?.redo()
        }
    }
    
    @objc
    private func addAction() {
        let figure = FigureView(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        person.addFigure(figure: figure)
    }
    
    @objc
    private func deleteAction() {
        if let figure = person.subviews.last as? FigureView {
            person.removeFigure(figure: figure)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        for touch in touches {
            let point = touch.location(in: person)
            if let figure = person.subviews.last as? FigureView {
                person.moveFigure(figure: figure, center: point)
            }
        }
    }
}
