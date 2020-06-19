import os
import psycopg2
from urllib.parse import urlparse

def db_info():
  if 'FOLLOWER' not in os.environ:
    print("Missing config")
  else:
    bits = urlparse(os.environ['FOLLOWER'])
    return {'host': bits.hostname, 'port': bits.port, 'user': bits.username, 'pass': bits.password, 'db': bits.path.lstrip('/')}


def connect():
    i = db_info()
    con = psycopg2.connect(host=i['host'], user=i['user'], password=i['pass'], dbname=i['db'], port=i['port'], sslmode="require")
    cur = con.cursor()
    return cur, con 

def closeCon():
  # probably not needed? 
  _, db = connect()

  if (db):    
    db.close()
    
