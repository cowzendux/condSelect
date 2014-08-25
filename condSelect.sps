* condSelect
* Written by Jamie DeCoster

* This function will randomly select a fixed number of participants from each level of
* a condition variable. This is useful when you want to graph trends by condition,
* but there are too many participants to make sense of the graphs containing all
* of the participants.

* usage: condSelect(condition variable, number per condition)
*     "condition variable" is a string containing the name of the condition variable.
* The condition variable itself can be either a string or numeric variable, and can
* have any number of levels.
*     "number per condition" is a number indicating how many subjects you want
* to select from each condition.

* example: condSelect("cond", 10)
* This would randomly select 10 subjects from each level of the cond variable.

***********
* Version History
***********
* 2012-08-23 Created

set printback = off.
begin program python.
import spss, spssaux, random

def getVariableIndex(variable):
   	for t in range(spss.GetVariableCount()):
      if (variable.upper() == spss.GetVariableName(t).upper()):
         return(t)

def getValues(variable):
# Use the OMS to pull the values from the frequencies command
   submitstring = """SET Tnumbers=values.

OMS SELECT TABLES
/IF COMMANDs=['Frequencies'] SUBTYPES=['Frequencies']
/DESTINATION FORMAT=OXML XMLWORKSPACE='freq_table'.
FREQUENCIES VARIABLES=%s.
OMSEND.

SET Tnumbers=Labels.""" %(variable)
   spss.Submit(submitstring)
 
   handle='freq_table'
   context="/outputTree"
#get rows that are totals by looking for varName attribute
#use the group element to skip split file category text attributes
   xpath="//group/category[@varName]/@text"
   values=spss.EvaluateXPath(handle,context,xpath)

# If the original variable was numeric, convert the list to numbers

   varnum=getVariableIndex(variable)
   values2 = []
   if (spss.GetVariableType(varnum) == 0):
      for t in range(len(values)):
         values2.append(int(float(values[t])))
   else:
      for t in range(len(values)):
         values2.append("'" + values[t] + "'")

   return(values2)

def descriptive(variable, stat):
# Valid values for stat are MEAN STDDEV MINIMUM MAXIMUM
# SEMEAN VARIANCE SKEWNESS SESKEW RANGE
# MODE KURTOSIS SEKURT MEDIAN SUM

	cmd = "FREQUENCIES VARIABLES="+variable+"\n\
  /FORMAT=NOTABLE\n\
  /STATISTICS="+stat+"\n\
  /ORDER=ANALYSIS."
	handle,failcode=spssaux.CreateXMLOutput(
		cmd,
		omsid="Frequencies",
		subtype="Statistics",
		visible=False)
	result=spssaux.GetValuesFromXMLWorkspace(
		handle,
		tableSubtype="Statistics",
		cellAttrib="text")
	return float(result[2])

def condSelect(condvar, selnum):
    submitstring = """use all.
SPLIT FILE OFF.
compute s766380 = $casenum.
execute."""
    spss.Submit(submitstring)

    cond = getValues(condvar)

# Create ranked list of subject numbers within condition

    submitstring = """AUTORECODE VARIABLES=%s
  /INTO C766380
  /PRINT.
RANK VARIABLES=s766380 (A) BY C766380
  /RANK
  /PRINT=YES
  /TIES=MEAN.""" %(condvar)
    spss.Submit(submitstring)

    keeplist = []
    for t in cond:
        submitstring = """USE ALL.
COMPUTE filter_$=(%s = %s).
FILTER BY filter_$.
EXECUTE.""" %(condvar, t)
        spss.Submit(submitstring)
        cases = descriptive("rs766380", "MAXIMUM")
        condkeeplist = []
        for i in range(selnum):
            newnum = -1
            while (newnum < 0 or newnum in condkeeplist):
                newnum = random.randrange(cases)+1
            condkeeplist.append(newnum)
        keeplist.append(condkeeplist)

    conditional = "(1=2)"
    for t in range(len(cond)):
        for i in keeplist[t]:
            conditional = conditional + " or ( %s = %s and rs766380 = %s)" %(condvar, cond[t], i)

    submitstring = """use all.
COMPUTE filter_$=(%s).
execute.
delete variables s766380 C766380 Rs766380.
FILTER BY filter_$.
EXECUTE.""" %(conditional)
    spss.Submit(submitstring)
      
end program python.
set printback = on.
