# GUI: Tkinter

### Before You Start
1. Make sure you have Python 3.x installed. We will use one of the built-in libraries, so no additional software installation is required.
2. Download the ZIP from this GitHub.
3. Try running the code. If you encounter errors copy the code, paste it into a new empty document, and save it as a Python file.
4. If the problem is not resolved, let someone from my team know.

I will be talking about the Tkinter library. At each stage, you will first see a simple example for clarity, followed by how it is used in my code.

# What is Tkinter?

**Tkinter** is the standard Python library for creating graphical user interfaces (GUI). It allows you to create windows, buttons, text fields, and other UI elements. Tkinter is based on the Tk library, which was originally developed for the Tcl language.

## Basic Principles of Tkinter

### 1. Main Window
Every Tkinter application starts by creating a main window. This window serves as a container for all other UI elements. It is created using the `Tk` class:

#### Basic Example:
```python
import tkinter as tk  # Import the Tkinter library

root = tk.Tk()        # Create the root window
root.title("My Application")  # Set the window title
root.mainloop()       # Start the main event loop
```

#### Example from my code:
```python
root = tk.Tk()                   # Create the main calculator window
root.title("Calculator")         # Set the title "Calculator"
root.geometry("300x400")         # Set a fixed window size
```




### 2. Widgets

**Widgets** — are UI elements such as buttons, labels, text fields, etc. In Tkinter, each widget is an instance of a specific class. For example:

- **`tk.Label`** — a label for displaying text.
- **`tk.Button`** — a button that performs an action when clicked.
- **`tk.Entry`** — a text input field.
- **`tk.Frame`** — a container for grouping other widgets.



#### Example of creating a button:
```python
button = tk.Button(
    root,                     # Parent window for the button
    text="Click me",          # Text displayed on the button
    command=some_function     # Function to be executed when clicked
)
button.pack()                # Place the button in the window
```


#### Examples from my code:

**`tk.Entry`** — text input field:
```python
input_field = tk.Entry(
    input_frame,                     # Parent container (Frame)
    font=('arial', 18, 'bold'),      # Font and its properties
    textvariable=input_text,         # Binding to a StringVar variable
    width=50,                        # Width in characters
    bg="#eee",                       # Background color (light gray)
    bd=0,                            # Border thickness (0 - no border)
    justify=tk.RIGHT                 # Right-align text
)
```

**`tk.Button`** — calculator buttons:
```python
tk.Button(
    buttons_frame,                   # Container for placing buttons
    text=button,                     # Button text (number/operator)
    fg="black",                      # Text color (foreground)
    width=10,                        # Button width
    height=3,                        # Button height
    bd=0,                            # Border thickness
    bg="#fff",                       # Background color
    cursor="hand2",                  # Cursor style when hovered
    command=lambda x=button:         # Click event handler:
        button_click(x) if x != '='  # For numbers and operators
        else button_equal()          # For the "=" button
)
```

**`tk.Frame`** — container for grouping widgets:
```python
input_frame = tk.Frame(
    root,                           # Parent window
    width=312,                      # Width in pixels
    height=50,                      # Height in pixels
    bd=0,                           # Border thickness
    highlightbackground="black",    # Frame border color
    highlightcolor="black",         # Active border color
    highlightthickness=1            # Border thickness
)

buttons_frame = tk.Frame(
    root,                           # Parent window
    width=312,                      # Width in pixels
    height=272.5,                   # Height in pixels
    bg="grey"                       # Background color
)
```




### 3. Geometry Management

To display widgets in the window, you need to place them using one of three geometry managers:

- **`pack()`** — automatically arranges widgets in the window.
- **`grid()`** — arranges widgets in a table format (rows and columns).
- **`place()`** — allows specifying exact coordinates for widget placement.

#### Example using **`grid()`**:

```python
label = tk.Label(
    root,                    # Parent window
    text="Hello, Tkinter!"   # Label text
)
label.grid(
    row=0,       # Row number in the grid
    column=0     # Column number in the grid
)
```


#### Example from my code

**`pack()`** — placing widgets:
```python
input_frame.pack(
    side=tk.TOP  # Place at the top of the window
)
buttons_frame.pack()  # Place below the previous element
```

**`grid()`** — arranging buttons in a table format:
```python
tk.Button(buttons_frame, ...).grid(
    row=row,     # Row number for the button
    column=col,  # Column number for the button
    padx=1,      # Horizontal padding
    pady=1       # Vertical padding
)
```



### 4. Event Handling

Tkinter allows reacting to user actions, such as **button clicks** or **text input**. This is done using the `command` parameter in widgets (e.g., buttons) or event binding with the `bind` method.

#### Example of handling a button click:
```python
def button_click(item):
    global expression       # Using a global variable
    expression += str(item) # Append a character to the expression
    input_text.set(expression)  # Update the text in the input field
```

#### Example from my code

**`button_click`**  — handling button clicks:
```python
def button_clear():
    global expression       # Using a global variable
    expression = ""         # Reset the expression
    input_text.set("")      # Clear the input field

```

**`button_clear`** — clearing the input field:
```python
def button_equal():
    global expression       # Using a global variable
    try:
        result = str(eval(expression))  # Evaluate the expression
        input_text.set(result)          # Display the result
        expression = result             # Store the result
    except:
        input_text.set("Error")        # Display an error
        expression = ""                # Reset the expression
```

**`button_equal`** — calculating the result:
```python
def button_equal():
    global expression
    try:
        result = str(eval(expression))
        input_text.set(result)
        expression = result
    except:
        input_text.set("Error")
        expression = ""
```


### 5. Tkinter Variables

Tkinter provides special variables ( **`StringVar`**,  **`IntVar`**,  **`DoubleVar`** etc.) that allow linking data to widgets. For example, **`StringVar`** is used to store text that can be linked to a label or input field.

```python
text_var = tk.StringVar()
label = tk.Label(root, textvariable=text_var)
text_var.set("Hello, Tkinter!")
```

#### Example from my code
**`tk.StringVar`** — linking text to an input field:
```python
input_text = tk.StringVar()  # Create a StringVar variable
input_field = tk.Entry(
    ...,                      # Other input field parameters
    textvariable=input_text   # Bind the variable to the input field
)
```
