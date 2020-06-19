# -*- coding: utf-8 -*-

def review(person_or_people, file_or_files, thing):
  return {'action': 'review', 'reviewers': person_or_people, 'files': file_or_files, 'thing' : thing }

def email(file_or_files, recipients, opts):
  return {'action': 'email', 'files': file_or_files, 'recipients': recipients, 'opts': opts }

def upload(file_or_files, thing_type, thing_id, options):
  return {'action': 'upload', 'files': file_or_files, 'thing_type': thing_type, 'thing_id': thing_id, 'options': options}


