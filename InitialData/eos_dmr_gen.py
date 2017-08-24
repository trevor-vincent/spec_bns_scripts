import csv
import numpy as np
from math import *
old_fields = []
file = 'TOV_output.txt'
with open(file, 'rb') as f:
    reader = csv.reader(f, delimiter='|')
    for row in reader:
            old_fields.append(row[1])

d = float(old_fields[8])
RStar_1 = float(old_fields[13])
RStar_2 = float(old_fields[17])
    
RS_1 = 1.05*RStar_1
Rin_1 = 1.05*RStar_1
R1_1 = 1.3*RS_1
R2_1 = 1.3*RS_1

RS_2 = 1.05*RStar_2
Rin_2 = 1.05*RStar_2
R1_2 = 1.3*RS_2
R2_2 = 1.3*RS_2

R3_1 = 1.01*max( sqrt(3)*R1_2*RStar_1/RStar_2, sqrt(3)*R1_1, d/(1 + RStar_2/RStar_1) )
R3_2 = RStar_2*R3_1/RStar_1
madm1 = float(old_fields[6])
madm2 = float(old_fields[7])
MR = madm1/(madm1 + madm2)

fw = open("TOV_output_fortab.txt",'w')
fw.write("@bnsSystems = (\n")
fw.write("  {\n")
fw.write("    'Name'    =>%s,\n" % old_fields[0])
fw.write("    'eos'     =>%s,\n" % old_fields[1])
fw.write("    'rhocOne' =>%s,\n" % old_fields[2])
fw.write("    'rhocTwo' =>%s,\n" % old_fields[3])
fw.write("    'mass1'   =>%s,\n" % old_fields[4])
fw.write("    'mass2'   =>%s,\n" % old_fields[5])
fw.write("    'madm1'   =>%s,\n" % old_fields[6])
fw.write("    'madm2'   =>%s,\n" % old_fields[7])
fw.write("    'MR'      => %s,\n" % str(MR))
fw.write("    'd'       =>%s,\n" % old_fields[9])
fw.write("    'R1_1'    => %s,\n" % str(R1_1))
fw.write("    'R2_1'    => %s,\n" % str(R2_1))
fw.write("    'R3_1'    => %s,\n" % str(R3_1))
fw.write("    'Rin_1'   => %s,\n" % str(Rin_1))
fw.write("    'RS_1'    => %s,\n" % str(RS_1))
fw.write("    'R1_2'    => %s,\n" % str(R1_2))
fw.write("    'R2_2'    => %s,\n" % str(R2_2))
fw.write("    'R3_2'    => %s,\n" % str(R3_2))
fw.write("    'Rin_2'   => %s,\n" % str(Rin_2))
fw.write("    'RS_2'    => %s,\n" % str(RS_2))
fw.write("    'z'       => 1.,\n")
fw.write("    'TwoShell'=> 0,\n")
fw.write("    'TopLevParamSolve'=> 10\n")
fw.write("  },\n")
fw.write(");\n")
fw.close()
