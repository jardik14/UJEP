from PyQt5 import QtWidgets, uic, QtCore
from PyQt5.QtGui import QPixmap, QIcon



class MainWindow(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        uic.loadUi("todo_list.ui", self)  

        with open("style.css", "r") as file:
            self.setStyleSheet(file.read())  

        self.button_addtask.clicked.connect(self.add_task)
        self.list_widgets = [self.list_todo, self.list_doing, self.list_done]

        for widget in self.list_widgets:
            widget.itemSelectionChanged.connect(self.change_selection)

        self.button_deletetask.clicked.connect(self.delete_task)

        self.setWindowIcon(QIcon("Icons\\logo.png"))

        dropdown_images_path = ['Icons\\low.png','Icons\\medium.png','Icons\\high.png']   
        for i in range(self.dropdown_priority.count()):
            self.dropdown_priority.setItemIcon(i, QIcon(dropdown_images_path[i]))  
        
        self.dropdown_priority.setIconSize(QtCore.QSize(30,10))

        for widget in self.list_widgets:
            widget.setIconSize(QtCore.QSize(40,40))

    def add_task(self):
        text_taskinput = self.line_taskinput.text().strip()
        idx_item_dropdown = self.dropdown_priority.currentIndex()
        priority_icons_path = ['Icons\\low.png', 'Icons\\medium.png', 'Icons\\high.png']

        idx_drop_box_date = self.dropdown_doto.currentIndex()
  
        if text_taskinput == '':
            self.input_error("Error","Please write task")
        else: 
            item = QtWidgets.QListWidgetItem(text_taskinput)
            icon = QIcon(priority_icons_path[idx_item_dropdown])
            item.setIcon(icon)
            self.list_todo.addItem(item)

            if idx_drop_box_date == 1:
                self.select_date(item)
  
            self.line_taskinput.clear()

    def input_error(self, title, text):
        window_error = QtWidgets.QMessageBox(self)
        window_error.setWindowTitle(title)
        window_error.setText(text)

        window_error.setIcon(QtWidgets.QMessageBox.Warning)

        pixmap = QPixmap("Icons\\error_2.png")  
        skale_pixmap = pixmap.scaled(90,90)
        window_error.setIconPixmap(skale_pixmap)  
  
        window_error.setStandardButtons(QtWidgets.QMessageBox.Ok)
        window_error.exec_()

    def change_selection(self):
        fokus_widget = None
        for widget in self.list_widgets:
            if widget.hasFocus():
                fokus_widget = widget
                break
      
        for widget in self.list_widgets:
            if widget != fokus_widget:
                widget.clearSelection()  

    def delete_task(self):
        for widget in self.list_widgets:
            if widget.selectedItems():
                answer = self.confirm_delete("Confirm Delete", "Are you sure?")

                if answer == QtWidgets.QMessageBox.Yes:
                    row = widget.currentRow()
                    widget.takeItem(row)
                    break

    def confirm_delete(self, title, text):
        window_confirm = QtWidgets.QMessageBox(self)
        window_confirm.setWindowTitle(title)
        window_confirm.setText(text)
  
        pixmap = QPixmap("Icons\\thinking_cat.png")  
        scale_pixmap = pixmap.scaled(90,90)
        window_confirm.setIconPixmap(scale_pixmap)
        window_confirm.setStandardButtons( QtWidgets.QMessageBox.Yes | QtWidgets.QMessageBox.No)

        answer = window_confirm.exec_()
        return answer
    

    def select_date(self,item):
        dialog_window = QtWidgets.QDialog(self)
        layout = QtWidgets.QVBoxLayout()
  
        calendar = QtWidgets.QCalendarWidget()
        layout.addWidget(calendar)
  
        buttons = QtWidgets.QDialogButtonBox(QtWidgets.QDialogButtonBox.Ok | QtWidgets.QDialogButtonBox.Cancel)
        layout.addWidget(buttons)
  
        dialog_window.setLayout(layout)
          
        def add_date(calendar, dialog_window, item):
            selected_date = calendar.selectedDate().toString("dd.MM.yyyy")
            item.setText(f"{selected_date}  {item.text()}")
            dialog_window.accept()
  
        buttons.accepted.connect(lambda: add_date(calendar, dialog_window, item))
        buttons.rejected.connect(dialog_window.reject)
  
        dialog_window.exec_()

    

app = QtWidgets.QApplication([])
window = MainWindow()
window.show()
app.exec_()