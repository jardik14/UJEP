from flask import Flask, request, render_template
import psycopg2
import redis

app = Flask(__name__)
conn = psycopg2.connect(database="your_db", user="your_user", password="your_pass", host="localhost", port="5432")

@app.route('/query', methods=['POST'])
def query_db():
    user_query = request.form['query']
    with conn.cursor() as cursor:
        cursor.execute(user_query)
        result = cursor.fetchall()
    return render_template('results.html', results=result)




cache = redis.Redis(host='localhost', port=6379)

@app.route('/query', methods=['POST'])
def query_db():
    user_query = request.form['query']
    cached_result = cache.get(user_query)
    if cached_result:
        result = eval(cached_result)
    else:
        with conn.cursor() as cursor:
            cursor.execute(user_query)
            result = cursor.fetchall()
            cache.set(user_query, str(result), ex=60)  # Cache for 60 seconds
    return render_template('results.html', results=result)


if __name__ == '__main__':
    app.run(port=5000, debug=True)