from flask import Flask, render_template, request, redirect, url_for, jsonify
import redis
import psycopg2
import json

app = Flask(__name__)

# Connect to Redis server
redis_client = redis.Redis(host='redis', port=6379, decode_responses=True)

# PostgreSQL connection
def get_postgres_connection():
    return psycopg2.connect(
        dbname="your_db",
        user="your_user",
        password="your_pass",
        host="db",
        port="5432"
    )

def cache_page(key, ttl=60):
    """Decorator to cache page responses in Redis with a given TTL."""
    def decorator(f):
        def wrapper(*args, **kwargs):
            cached_content = redis_client.get(key)
            if cached_content:
                print("Loaded from cache")
                # Append a message indicating it's loaded from cache
                return cached_content + "<!-- Loaded from cache -->"
            else:
                content = f(*args, **kwargs)
                redis_client.setex(key, ttl, content)  # Set cache with TTL
                print("Saved to cache")
                # Append a message indicating it's saved to cache
                return content + "<!-- Saved to cache -->"
        wrapper.__name__ = f.__name__  # Ensure each wrapper has a unique name
        return wrapper
    return decorator
@app.route('/')
@cache_page("home_page", ttl=60)
def hello():
    redis_client.incr('page_counter')
    count = redis_client.get('page_counter')
    return render_template('index.html', count=count)

@app.route('/pozdrav')
@cache_page("pozdrav_page", ttl=60)
def pozdrav_navstevnika():
    redis_client.incr('pozdrav_counter')
    count = redis_client.get('pozdrav_counter')
    return f"""
    <h1> Nadpis </h1>
    <p> ahoj! </p>
    <p> Page visited {count} times. </p>
    """



@app.route('/formular')
@cache_page("formular_page", ttl=60)
def formular():
    return render_template('formular.html')


@app.route('/recipes')
@cache_page("recipe_list", ttl=60)
def recipe_list():
    conn = get_postgres_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT name, ingredients, instructions FROM recipes")
    recipes = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('recipe_list.html', recipes=recipes)


@app.route('/add_recipe', methods=['GET', 'POST'])
def add_recipe():
    if request.method == 'POST':
        # Get data from form
        name = request.form.get('name')
        ingredients = request.form.get('ingredients')
        instructions = request.form.get('instructions')

        # Save recipe to PostgreSQL
        conn = get_postgres_connection()
        cursor = conn.cursor()
        cursor.execute(
            """
            INSERT INTO recipes (name, ingredients, instructions) 
            VALUES (%s, %s, %s)
            """,
            (name, ingredients, instructions)
        )
        conn.commit()
        cursor.close()
        conn.close()

        # Clear the cache for the recipe list to ensure it's updated
        redis_client.delete("recipe_list")
        return redirect(url_for('recipe_list'))

    return render_template('add_recipe.html')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
