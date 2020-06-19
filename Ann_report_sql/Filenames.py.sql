import os
for filename in os.listdir("."):
	#if filename.endswith(r" (1).sql"):
		os.rename(filename, filename+'.sql')