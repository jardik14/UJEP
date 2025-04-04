import tkinter as tk

# Function to handle button clicks
def button_click(item):
    global expression
    expression = expression + str(item)
    input_text.set(expression)

# Function to clear the input field
def button_clear():
    global expression
    expression = ""
    input_text.set("")

# Function to calculate the result
def button_equal():
    global expression
    try:
        result = str(eval(expression))  # eval evaluates the expression
        input_text.set(result)
        expression = result
    except:
        input_text.set("Error")
        expression = ""

# Create the main window
root = tk.Tk()
root.title("Calculator")
root.geometry("320x400")

expression = ""
input_text = tk.StringVar()

# Input field
input_frame = tk.Frame(root, width=312, height=50, bd=0, highlightbackground="black", highlightcolor="black", highlightthickness=1)
input_frame.pack(side=tk.TOP)

input_field = tk.Entry(input_frame, font=('arial', 18, 'bold'), textvariable=input_text, width=50, bg="yellow", bd=0, justify=tk.RIGHT)
input_field.grid(row=0, column=0)
input_field.pack(ipady=10)  # Internal padding for field height

# Calculator buttons
buttons_frame = tk.Frame(root, width=312, height=272.5, bg="grey")
buttons_frame.pack()

# List of buttons
buttons = [
    '7', '8', '9', '/',
    '4', '5', '6', '*',
    '1', '2', '3', '-',
    '0', '.', '=', '+'
]

# Place buttons on the grid
row, col = 1, 0
for button in buttons:
    tk.Button(buttons_frame, text=button, fg="black", width=10, height=3, bd=0, bg="#fff", cursor="hand2",
              command=lambda x=button: button_click(x) if x != '=' else button_equal()).grid(row=row, column=col, padx=1, pady=1)
    col += 1
    if col > 3:
        col = 0
        row += 1

# Clear button
tk.Button(buttons_frame, text="C", fg="black", width=10, height=3, bd=0, bg="#eee", cursor="hand2",
          command=button_clear).grid(row=row, column=col, padx=1, pady=1)

# Start the main loop
root.mainloop()