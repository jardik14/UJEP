from flask import Flask

app = Flask(__name__)

@app.route('/pozdrav')
def pozdrav_navstevnika():
    return """
    <h1> Nadpis </h1>
    <p> ahoj! </p>
    """


if __name__ == '__main__':
    app.run(port=8500, debug=True)