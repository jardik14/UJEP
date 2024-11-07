import requests
import time

def test_cache():
    # First request - should not be cached
    response = requests.get("http://localhost:5000/")
    print("First request response:", response.text)

    # Sleep for 2 seconds and make a second request - should be cached
    time.sleep(2)
    response = requests.get("http://localhost:5000/")
    print("Second request (should be cached):", response.text)

    # Sleep for 61 seconds to expire the cache and test again - should not be cached
    time.sleep(61)
    response = requests.get("http://localhost:5000/")
    print("Third request after cache expiry:", response.text)

test_cache()
