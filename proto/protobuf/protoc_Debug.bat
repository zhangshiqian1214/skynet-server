@echo off
%--protoc -I ./ --cpp_out ./ ./Mail.proto%
protoc %1 %2 %3 %4 %5 %6 %7 %8
pause