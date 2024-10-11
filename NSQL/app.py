from flask import Flask, render_template

app = Flask(__name__)

@app.route('/')
def hello():
    return render_template('index.html')

@app.route('/pozdrav')
def pozdrav_navstevnika():
    return """
    <h1> Nadpis </h1>
    <p> ahoj! </p>
    """

@app.route('/formular')
def formular():
    return render_template('formular.html')

if __name__ == '__main__':
    app.run(port=8500, debug=True)