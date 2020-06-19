import os
import auto_dates as ad
import pandas as pd

########### location stuff

if os.name == 'posix':
    base_path = os.getcwd()
    import neptcon as nc
else:
    base_path = r'C:/Users/Danny/PycharmProjects/pptx_periodical'
    import Neptcon.neptcon as nc
    print(base_path)


def full_path(*names):
    return os.path.join(base_path, *names)


def name_list(*names):
    """use this to convert multiple pathnames to a single string"""
    return ':::'.join(names)


# get dates in std format
def date_hash():
    dates = ad.date_ranges()
    return {'df': dates[3], 'dt': dates[4]}


# execute queries and write output to csv
def run_query(sql_file, replacements):
    cur, con = nc.connect()
    with open(sql_file, encoding='utf-8') as input:
        script = input.read()
    cur.execute(script.format(**replacements))
    return cur.description, cur.fetchall()


# execute queries and write output to df
def run_sql_query(sql_file, replacements):
    cur, con = nc.connect()
    with open(sql_file) as input:
        script = input.read()
        # print(script.format(**replacements))
        df = pd.read_sql(script.format(**replacements), con)
        return df
