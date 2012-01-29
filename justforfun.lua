--`PROG SAFE "Sample TPTOS program" -M P- FN

function sys__init()
i=0
wnd=duplicateTable(component.consoleShellPrototype)
w=getTable(wnd).table
w.caption=uni("Sample")
tmr=duplicateTable(component.functionTimer)
t=getTable(tmr).table
t.time=1000
t.ontimer=ontimer
end
function ontimer()
i=i+1
w.writeln(i)
end
function sys__exit()
freeTable(wnd)
freetable(tmr)
end