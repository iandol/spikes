function cleanMemory
mb = 1024^2;
fprintf('\n================================\n')
fprintf('Max Memory:   %g MB\n', java.lang.Runtime.getRuntime.maxMemory / mb)
fprintf('Total Memory: %g MB\n', java.lang.Runtime.getRuntime.totalMemory / mb)
init = java.lang.Runtime.getRuntime.freeMemory / mb;
fprintf('Free Memory:  %g MB\n', init)
fprintf('->Run Garbage Collection<-\n')
java.lang.Runtime.getRuntime().gc;
new = java.lang.Runtime.getRuntime.freeMemory / mb;
fprintf('Free Memory:  %g MB -- %g MB freed up\n', new, new-init)
fprintf('================================\n\n')