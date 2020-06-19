import os
import json


# global shared
shared = {}


def values():
    return shared


def get_from_env():
    input = json.loads(os.environ['JSON_INPUT'])
    print(input)
    global shared
    if len(input) == 3:
        shared = {"df": input["date_gteq"],
                  "dt": input["date_lteq"],
                  "cl": input["client_name_eq"],
                  "u":  "RUN"}
    else:
        shared = {"df": input["date_gteq"],
                  "dt": input["date_lteq"],
                  "cl": input["client_name_eq"],
                  "u":  input["user_login_eq"]}
    print(shared)


def get_from_keyboard():
    date_from = input("Date from: ")
    date_to = input("Date to: ")
    client_name = input("Enter client name: ")
    user = input("Your first name: ")
    # flag for non-local access
    global shared
    shared = {"df": date_from, "dt": date_to, "cl": client_name, "u": user}


if 'JSON_INPUT' not in os.environ:
    get_from_keyboard()
else:
    get_from_env()
