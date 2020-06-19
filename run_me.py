
# add remaining dependencies
import os
os.system("pip install numpy pandas matplotlib==2.2.3 seaborn python-pptx")

# https://stackoverflow.com/questions/43697460/import-matplotlib-failing-on-heroku
# force matplotlib to NOT use TK, since that has dependency issues
import matplotlib
matplotlib.use('Agg')

import json
import utils as u
import dsl
import os
import input as i

# do this here? 
df = u.run_sql_query(u.full_path("Ann_report_sql", "Fleet_general_info.sql"), i.shared)
df.to_csv('plots/genInf.csv')

import PPTALSIBox
import PPTPortSupVisited
import PPTstar_burst_charts
import PPTsummAnalysisQuan
import PPTtwincat
import glbl_clnt_side_by_side
import PPTGenDet
try:
    import PPTPortSupplier
except:
    pass
import alsi_gt_40_plot
import port_ship_sankey
import ppt_spider
import close_plots
import AlsiKDE
import kpi
import PPT
# import text_slides
import final_slide
# import iso_revision

import pptx_den_off_table


print(i.shared)
ppt = u.full_path(f'PPTPeriodicalTemplate {i.shared["cl"]}.pptx')

if os.name == 'posix':
    login = os.environ['USER_LOGIN']
    email = os.environ['USER_EMAIL']
else:
    login = "u_test"
    email = "e_test"

print(
    json.dumps(
                   [dsl.email(ppt, email, {
                       'from': 'fobas@lr.org',
                       'subject': 'Periodic powerpoint',
                       'bcc': 'danny.osborne@lr.org',
                       'body': 'Attached is periodic report for client'
                   })
                    ]
                   ))
